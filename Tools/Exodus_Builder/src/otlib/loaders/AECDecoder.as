package otlib.loaders
{
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    import otlib.animation.AnimationMode;
    import otlib.animation.FrameDuration;
    import otlib.animation.FrameGroup;
    import otlib.events.ProgressEvent;
    import otlib.obd.OBDVersions;
    import otlib.sprites.SpriteData;
    import otlib.things.FrameGroupType;
    import otlib.things.ThingCategory;
    import otlib.things.ThingData;
    import otlib.things.ThingType;
    import otlib.utils.SpriteExtent;
    import otlib.utils.SpriteUtils;

    [Event(name="complete", type="flash.events.Event")]
    [Event(name="error", type="flash.events.ErrorEvent")]
    [Event(name="progress", type="otlib.events.ProgressEvent")]

    public class AECDecoder extends EventDispatcher
    {
        private static const TILE_SIZE:uint = SpriteExtent.DEFAULT_SIZE;
        private static const POINT:Point = new Point();
        private static const MAX_DAT_BYTE:uint = 255;
        private static const MAX_PARALLEL_SPRITE_DECODERS:uint = 8;

        private var _thingDataList:Vector.<ThingData>;
        private var _appearances:Array;
        private var _appearanceIndex:int;
        private var _nextSpriteIndex:int;
        private var _decodedSprites:uint;
        private var _activeSpriteDecoders:uint;
        private var _decodeFailed:Boolean;
        private var _currentAppearance:Object;
        private var _currentBitmaps:Array;

        public function get thingDataList():Vector.<ThingData> { return _thingDataList; }

        public function decode(bytes:ByteArray):void
        {
            bytes.position = 0;
            _thingDataList = new Vector.<ThingData>();
            _appearances = parseAppearances(bytes);
            _appearanceIndex = -1;
            processNextAppearance();
        }

        private function processNextAppearance():void
        {
            _appearanceIndex++;

            if (_appearanceIndex >= _appearances.length) {
                dispatchEvent(new Event(Event.COMPLETE));
                return;
            }

            _currentAppearance = _appearances[_appearanceIndex];
            _currentBitmaps = [];
            _nextSpriteIndex = 0;
            _decodedSprites = 0;
            _activeSpriteDecoders = 0;
            _decodeFailed = false;

            if (!_currentAppearance || !_currentAppearance.frameGroups || _currentAppearance.frameGroups.length == 0) {
                processNextAppearance();
                return;
            }

            dispatchProgress();
            scheduleSpriteDecoders();
        }

        private function scheduleSpriteDecoders():void
        {
            if (_decodeFailed) return;

            while (!_decodeFailed &&
                   _activeSpriteDecoders < MAX_PARALLEL_SPRITE_DECODERS &&
                   _nextSpriteIndex < _currentAppearance.spriteData.length) {
                decodeSprite(_nextSpriteIndex++);
            }

            if (_nextSpriteIndex >= _currentAppearance.spriteData.length && _activeSpriteDecoders == 0) {
                try {
                    var thingData:ThingData = buildThingData(_currentAppearance, _currentBitmaps);
                    if (thingData) {
                        _thingDataList.push(thingData);
                    }
                } catch (error:Error) {
                    dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, error.message, error.errorID));
                    return;
                }

                processNextAppearance();
                return;
            }
        }

        private function decodeSprite(spriteIndex:uint):void
        {
            var bytes:ByteArray = _currentAppearance.spriteData[spriteIndex] as ByteArray;
            if (!bytes || bytes.length == 0) {
                _currentBitmaps[spriteIndex] = new BitmapData(TILE_SIZE, TILE_SIZE, true, 0x00000000);
                _decodedSprites++;
                dispatchProgress();
                return;
            }

            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            _activeSpriteDecoders++;

            try {
                bytes.position = 0;
                loader.loadBytes(bytes);
            } catch (error:Error) {
                loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
                loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
                _activeSpriteDecoders--;
                failDecode(error.message, error.errorID);
            }

            function completeHandler(event:Event):void
            {
                loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
                loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
                _activeSpriteDecoders--;

                var bitmap:Bitmap = loader.content as Bitmap;
                if (!bitmap) {
                    failDecode("Failed to decode AEC sprite image.");
                    return;
                }

                _currentBitmaps[spriteIndex] = SpriteUtils.removeMagenta(bitmap.bitmapData.clone());
                _decodedSprites++;
                dispatchProgress();
                scheduleSpriteDecoders();
            }

            function errorHandler(event:IOErrorEvent):void
            {
                loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
                loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
                _activeSpriteDecoders--;
                failDecode(event.text, event.errorID);
            }
        }

        private function failDecode(message:String, errorID:int = 0):void
        {
            if (_decodeFailed) return;

            _decodeFailed = true;
            dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message, errorID));
        }

        private function dispatchProgress():void
        {
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,
                                            "default",
                                            _decodedSprites,
                                            _currentAppearance.spriteData.length));
        }

        private function buildThingData(appearance:Object, bitmaps:Array):ThingData
        {
            var thing:ThingType = new ThingType();
            thing.id = uint(appearance.id);
            thing.category = appearance.category;
            applyFlags(thing, appearance.flags);

            var sprites:Dictionary = new Dictionary();
            var globalTextureIndex:int = 0;

            for each (var frameGroupData:Object in appearance.frameGroups)
            {
                var groupType:uint = getFrameGroupType(appearance.category, frameGroupData.fixedFrameGroup);
                var texturesCount:int = int(frameGroupData.spriteCount);
                var referenceBitmap:BitmapData = globalTextureIndex < bitmaps.length ? bitmaps[globalTextureIndex] as BitmapData : null;
                var tilesWide:uint = referenceBitmap ? Math.max(1, Math.ceil(referenceBitmap.width / TILE_SIZE)) : 1;
                var tilesHigh:uint = referenceBitmap ? Math.max(1, Math.ceil(referenceBitmap.height / TILE_SIZE)) : 1;

                var frameGroup:FrameGroup = new FrameGroup();
                frameGroup.width = clampDatByte(tilesWide, 1);
                frameGroup.height = clampDatByte(tilesHigh, 1);
                frameGroup.exactSize = clampDatByte(uint(Math.max(uint(frameGroupData.patternSize), referenceBitmap ? Math.max(referenceBitmap.width, referenceBitmap.height) : TILE_SIZE)), 1);
                frameGroup.layers = clampDatByte(uint(frameGroupData.layers), 1);
                frameGroup.patternX = clampDatByte(uint(frameGroupData.patternWidth), 1);
                frameGroup.patternY = clampDatByte(uint(frameGroupData.patternHeight), 1);
                frameGroup.patternZ = clampDatByte(uint(frameGroupData.patternDepth), 1);
                frameGroup.frames = clampDatByte(uint(frameGroupData.patternFrames), 1);
                frameGroup.isAnimation = Boolean(frameGroupData.isAnimation) || frameGroup.frames > 1;
                frameGroup.animationMode = clampDatByte(uint(frameGroupData.animationMode));
                frameGroup.loopCount = int(frameGroupData.loopCount);
                frameGroup.startFrame = int(clampDatByte(uint(Math.max(0, int(frameGroupData.startFrame)))));

                var totalSprites:uint = frameGroup.getTotalSprites();
                if (totalSprites > SpriteExtent.DEFAULT_DATA_SIZE) {
                    throw new Error("AEC appearance " + appearance.id + " has too many sprites for this DAT format (" + totalSprites + " > " + SpriteExtent.DEFAULT_DATA_SIZE + ").");
                }

                frameGroup.spriteIndex = new Vector.<uint>(totalSprites, true);

                if (frameGroup.frames > 1) {
                    frameGroup.frameDurations = new Vector.<FrameDuration>(frameGroup.frames, true);
                    for (var f:uint = 0; f < frameGroup.frames; f++) {
                        var duration:Object = f < frameGroupData.frameDurations.length ? frameGroupData.frameDurations[f] : null;
                        var min:uint = duration ? uint(duration.minimum) : 100;
                        var max:uint = duration ? uint(duration.maximum) : min;
                        frameGroup.frameDurations[f] = new FrameDuration(min, max);
                    }
                }

                var spriteList:Vector.<SpriteData> = new Vector.<SpriteData>(totalSprites, true);
                var textureCursor:int = globalTextureIndex;

                for (f = 0; f < frameGroup.frames; f++)
                {
                    for (var z:uint = 0; z < frameGroup.patternZ; z++)
                    {
                        for (var y:uint = 0; y < frameGroup.patternY; y++)
                        {
                            for (var x:uint = 0; x < frameGroup.patternX; x++)
                            {
                                for (var l:uint = 0; l < frameGroup.layers; l++)
                                {
                                    var textureBitmap:BitmapData = textureCursor < bitmaps.length ? bitmaps[textureCursor] as BitmapData : null;
                                    if (!textureBitmap) {
                                        textureBitmap = new BitmapData(frameGroup.width * TILE_SIZE, frameGroup.height * TILE_SIZE, true, 0x00000000);
                                    }

                                    writeTextureTiles(frameGroup, spriteList, textureBitmap, l, x, y, z, f);
                                    textureCursor++;
                                }
                            }
                        }
                    }
                }

                globalTextureIndex += texturesCount;
                sprites[groupType] = spriteList;
                thing.setFrameGroup(groupType, frameGroup);
            }

            if (thing.category == ThingCategory.OUTFIT && !thing.getFrameGroup(FrameGroupType.DEFAULT) && thing.getFrameGroup(FrameGroupType.WALKING)) {
                var walking:FrameGroup = thing.getFrameGroup(FrameGroupType.WALKING).clone();
                var walkingSprites:Vector.<SpriteData> = sprites[FrameGroupType.WALKING] as Vector.<SpriteData>;
                walking.type = FrameGroupType.DEFAULT;
                thing.setFrameGroup(FrameGroupType.DEFAULT, walking);
                sprites[FrameGroupType.DEFAULT] = walkingSprites ? cloneSprites(walkingSprites) : new Vector.<SpriteData>();
            }

            return ThingData.create(OBDVersions.OBD_VERSION_3, 1098, thing, sprites);
        }

        private function writeTextureTiles(frameGroup:FrameGroup,
                                           spriteList:Vector.<SpriteData>,
                                           bitmap:BitmapData,
                                           layer:uint,
                                           patternX:uint,
                                           patternY:uint,
                                           patternZ:uint,
                                           frame:uint):void
        {
            var padded:BitmapData = new BitmapData(frameGroup.width * TILE_SIZE, frameGroup.height * TILE_SIZE, true, 0x00000000);
            padded.copyPixels(bitmap, bitmap.rect, POINT, null, null, true);

            for (var w:uint = 0; w < frameGroup.width; w++)
            {
                for (var h:uint = 0; h < frameGroup.height; h++)
                {
                    var rect:Rectangle = new Rectangle((frameGroup.width - w - 1) * TILE_SIZE,
                                                       (frameGroup.height - h - 1) * TILE_SIZE,
                                                       TILE_SIZE,
                                                       TILE_SIZE);
                    var tile:BitmapData = new BitmapData(TILE_SIZE, TILE_SIZE, true, 0x00000000);
                    tile.copyPixels(padded, rect, POINT, null, null, true);

                    var spriteIndex:uint = frameGroup.getSpriteIndex(w, h, layer, patternX, patternY, patternZ, frame);
                    var spriteData:SpriteData = new SpriteData();
                    spriteData.id = uint.MAX_VALUE;
                    spriteData.pixels = tile.getPixels(tile.rect);
                    spriteList[spriteIndex] = spriteData;
                    frameGroup.spriteIndex[spriteIndex] = spriteData.id;
                }
            }

            padded.dispose();
        }

        private function cloneSprites(source:Vector.<SpriteData>):Vector.<SpriteData>
        {
            var result:Vector.<SpriteData> = new Vector.<SpriteData>(source.length, true);
            for (var i:uint = 0; i < source.length; i++) {
                result[i] = source[i] ? source[i].clone() : SpriteData.createSpriteData(uint.MAX_VALUE);
            }
            return result;
        }

        private function clampDatByte(value:uint, minimum:uint = 0):uint
        {
            if (value < minimum) return minimum;
            if (value > MAX_DAT_BYTE) return MAX_DAT_BYTE;
            return value;
        }

        private function getFrameGroupType(category:String, fixedFrameGroup:uint):uint
        {
            if (category == ThingCategory.OUTFIT && fixedFrameGroup == 1) {
                return FrameGroupType.WALKING;
            }

            return FrameGroupType.DEFAULT;
        }

        private function parseAppearances(bytes:ByteArray):Array
        {
            var result:Array = [];

            while (bytes.bytesAvailable > 0)
            {
                var tag:uint = uint(readVarint(bytes));
                var field:uint = tag >> 3;
                var wire:uint = tag & 7;

                if (wire == 2 && field >= 1 && field <= 4) {
                    var appearanceBytes:ByteArray = readLengthDelimited(bytes);
                    var appearance:Object = parseAppearance(appearanceBytes, field);
                    if (appearance && appearance.category) {
                        result.push(appearance);
                    }
                } else {
                    skipField(bytes, wire);
                }
            }

            return result;
        }

        private function parseAppearance(bytes:ByteArray, field:uint):Object
        {
            var appearance:Object = {
                id: 0,
                category: ThingCategory.getCategoryByValue(field),
                frameGroups: [],
                flags: {},
                spriteData: []
            };

            while (bytes.bytesAvailable > 0)
            {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;

                switch (fieldId)
                {
                    case 1:
                        appearance.id = uint(readVarint(bytes));
                        break;

                    case 2:
                        appearance.frameGroups.push(parseFrameGroup(readLengthDelimited(bytes)));
                        break;

                    case 3:
                        appearance.flags = parseFlags(readLengthDelimited(bytes));
                        break;

                    case 6:
                        if (wire == 0) {
                            appearance.category = ThingCategory.getCategoryByValue(uint(readVarint(bytes))) || appearance.category;
                        } else {
                            skipField(bytes, wire);
                        }
                        break;

                    case 7:
                        appearance.spriteData.push(readLengthDelimited(bytes));
                        break;

                    default:
                        skipField(bytes, wire);
                        break;
                }
            }

            return appearance;
        }

        private function parseFrameGroup(bytes:ByteArray):Object
        {
            var result:Object = {
                fixedFrameGroup: 0,
                patternWidth: 1,
                patternHeight: 1,
                patternDepth: 1,
                layers: 1,
                patternSize: TILE_SIZE,
                patternFrames: 1,
                isAnimation: false,
                animationMode: AnimationMode.ASYNCHRONOUS,
                loopCount: 0,
                startFrame: 0,
                frameDurations: [],
                spriteCount: 0
            };

            while (bytes.bytesAvailable > 0)
            {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;

                switch (fieldId)
                {
                    case 1:
                        result.fixedFrameGroup = uint(readVarint(bytes));
                        break;

                    case 3:
                        mergeSpriteInfo(result, parseSpriteInfo(readLengthDelimited(bytes)));
                        break;

                    default:
                        skipField(bytes, wire);
                        break;
                }
            }

            return result;
        }

        private function parseSpriteInfo(bytes:ByteArray):Object
        {
            var result:Object = {
                patternWidth: 1,
                patternHeight: 1,
                patternDepth: 1,
                layers: 1,
                patternSize: TILE_SIZE,
                patternFrames: 1,
                isAnimation: false,
                animationMode: AnimationMode.ASYNCHRONOUS,
                loopCount: 0,
                startFrame: 0,
                frameDurations: [],
                spriteCount: 0
            };

            while (bytes.bytesAvailable > 0)
            {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;

                switch (fieldId)
                {
                    case 1:
                        result.patternWidth = Math.max(1, uint(readVarint(bytes)));
                        break;

                    case 2:
                        result.patternHeight = Math.max(1, uint(readVarint(bytes)));
                        break;

                    case 3:
                        result.patternDepth = Math.max(1, uint(readVarint(bytes)));
                        break;

                    case 4:
                        result.layers = Math.max(1, uint(readVarint(bytes)));
                        break;

                    case 5:
                        if (wire == 0) {
                            readVarint(bytes);
                            result.spriteCount++;
                        } else if (wire == 2) {
                            var packed:ByteArray = readLengthDelimited(bytes);
                            while (packed.bytesAvailable > 0) {
                                readVarint(packed);
                                result.spriteCount++;
                            }
                        } else {
                            skipField(bytes, wire);
                        }
                        break;

                    case 6:
                        mergeAnimation(result, parseAnimation(readLengthDelimited(bytes)));
                        break;

                    case 10:
                        result.patternSize = uint(readVarint(bytes));
                        break;

                    case 15:
                        result.patternFrames = Math.max(1, uint(readVarint(bytes)));
                        break;

                    case 16:
                        result.isAnimation = readBool(bytes);
                        break;

                    default:
                        skipField(bytes, wire);
                        break;
                }
            }

            return result;
        }

        private function parseAnimation(bytes:ByteArray):Object
        {
            var result:Object = {
                startFrame: 0,
                animationMode: AnimationMode.ASYNCHRONOUS,
                loopCount: 0,
                frameDurations: []
            };
            var synchronized:Boolean = false;

            while (bytes.bytesAvailable > 0)
            {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;

                switch (fieldId)
                {
                    case 1:
                        result.startFrame = int(readVarint(bytes));
                        break;

                    case 2:
                        synchronized = readBool(bytes);
                        result.animationMode = synchronized ? AnimationMode.SYNCHRONOUS : AnimationMode.ASYNCHRONOUS;
                        break;

                    case 5:
                        result.loopCount = int(readVarint(bytes));
                        break;

                    case 6:
                        result.frameDurations.push(parseSpritePhase(readLengthDelimited(bytes)));
                        break;

                    case 7:
                        result.animationMode = uint(readVarint(bytes)) == 1 ? AnimationMode.SYNCHRONOUS : AnimationMode.ASYNCHRONOUS;
                        break;

                    default:
                        skipField(bytes, wire);
                        break;
                }
            }

            return result;
        }

        private function parseSpritePhase(bytes:ByteArray):Object
        {
            var result:Object = { minimum: 100, maximum: 100 };

            while (bytes.bytesAvailable > 0)
            {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;

                switch (fieldId)
                {
                    case 1:
                        result.minimum = uint(readVarint(bytes));
                        break;

                    case 2:
                        result.maximum = uint(readVarint(bytes));
                        break;

                    default:
                        skipField(bytes, wire);
                        break;
                }
            }

            if (result.maximum < result.minimum) {
                result.maximum = result.minimum;
            }

            return result;
        }

        private function parseFlags(bytes:ByteArray):Object
        {
            var result:Object = {};

            while (bytes.bytesAvailable > 0)
            {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;

                switch (fieldId)
                {
                    case 1:
                        mergeObject(result, parseGround(readLengthDelimited(bytes)));
                        break;
                    case 2:
                        result.isGroundBorder = readBool(bytes);
                        break;
                    case 3:
                        result.isOnBottom = readBool(bytes);
                        break;
                    case 4:
                        result.isOnTop = readBool(bytes);
                        break;
                    case 5:
                        result.isContainer = readBool(bytes);
                        break;
                    case 6:
                        result.stackable = readBool(bytes);
                        break;
                    case 7:
                        result.usable = readBool(bytes);
                        break;
                    case 8:
                        result.forceUse = readBool(bytes);
                        break;
                    case 9:
                        result.multiUse = readBool(bytes);
                        break;
                    case 10:
                        mergeObject(result, parseWritable(readLengthDelimited(bytes), false));
                        break;
                    case 11:
                        mergeObject(result, parseWritable(readLengthDelimited(bytes), true));
                        break;
                    case 12:
                        result.isFluid = readBool(bytes);
                        break;
                    case 13:
                        result.isUnpassable = readBool(bytes);
                        break;
                    case 14:
                        result.isUnmoveable = readBool(bytes);
                        break;
                    case 15:
                        result.blockMissile = readBool(bytes);
                        break;
                    case 16:
                        result.blockPathfind = readBool(bytes);
                        break;
                    case 17:
                        result.noMoveAnimation = readBool(bytes);
                        break;
                    case 18:
                        result.pickupable = readBool(bytes);
                        break;
                    case 19:
                        result.isFluidContainer = readBool(bytes);
                        break;
                    case 20:
                        result.hangable = readBool(bytes);
                        break;
                    case 21:
                        mergeObject(result, parseHook(readLengthDelimited(bytes)));
                        break;
                    case 22:
                        result.rotatable = readBool(bytes);
                        break;
                    case 23:
                        mergeObject(result, parseLight(readLengthDelimited(bytes)));
                        break;
                    case 24:
                        result.dontHide = readBool(bytes);
                        break;
                    case 25:
                        result.isTranslucent = readBool(bytes);
                        break;
                    case 26:
                        mergeObject(result, parseShift(readLengthDelimited(bytes)));
                        break;
                    case 27:
                        mergeObject(result, parseHeight(readLengthDelimited(bytes)));
                        break;
                    case 28:
                        result.isLyingObject = readBool(bytes);
                        break;
                    case 29:
                        result.animateAlways = readBool(bytes);
                        break;
                    case 30:
                        mergeObject(result, parseAutomap(readLengthDelimited(bytes)));
                        break;
                    case 31:
                        mergeObject(result, parseLenshelp(readLengthDelimited(bytes)));
                        break;
                    case 32:
                        result.isFullGround = readBool(bytes);
                        break;
                    case 33:
                        result.ignoreLook = readBool(bytes);
                        break;
                    case 34:
                        mergeObject(result, parseClothes(readLengthDelimited(bytes)));
                        break;
                    case 35:
                        mergeObject(result, parseDefaultAction(readLengthDelimited(bytes)));
                        break;
                    case 36:
                        mergeObject(result, parseMarket(readLengthDelimited(bytes)));
                        break;
                    case 37:
                        result.wrappable = readBool(bytes);
                        break;
                    case 38:
                        result.unwrappable = readBool(bytes);
                        break;
                    case 39:
                        result.topEffect = readBool(bytes);
                        break;
                    default:
                        skipField(bytes, wire);
                        break;
                }
            }

            return result;
        }

        private function parseGround(bytes:ByteArray):Object
        {
            var result:Object = {};
            while (bytes.bytesAvailable > 0) {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;
                if (fieldId == 1 && wire == 0) {
                    result.isGround = true;
                    result.groundSpeed = uint(readVarint(bytes));
                } else {
                    skipField(bytes, wire);
                }
            }
            return result;
        }

        private function parseWritable(bytes:ByteArray, once:Boolean):Object
        {
            var result:Object = {};
            while (bytes.bytesAvailable > 0) {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;
                if (fieldId == 1 && wire == 0) {
                    result.maxTextLength = uint(readVarint(bytes));
                    if (once) {
                        result.writableOnce = true;
                    } else {
                        result.writable = true;
                    }
                } else {
                    skipField(bytes, wire);
                }
            }
            return result;
        }

        private function parseHook(bytes:ByteArray):Object
        {
            var result:Object = {};
            while (bytes.bytesAvailable > 0) {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;
                if (fieldId == 1 && wire == 0) {
                    var direction:uint = uint(readVarint(bytes));
                    if (direction == 1) {
                        result.isHorizontal = true;
                    } else if (direction == 2) {
                        result.isVertical = true;
                    }
                } else {
                    skipField(bytes, wire);
                }
            }
            return result;
        }

        private function parseLight(bytes:ByteArray):Object
        {
            var result:Object = { hasLight: true };
            while (bytes.bytesAvailable > 0) {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;
                if (fieldId == 1 && wire == 0) {
                    result.lightLevel = uint(readVarint(bytes));
                } else if (fieldId == 2 && wire == 0) {
                    result.lightColor = uint(readVarint(bytes));
                } else {
                    skipField(bytes, wire);
                }
            }
            return result;
        }

        private function parseShift(bytes:ByteArray):Object
        {
            var result:Object = { hasOffset: true, offsetX: 0, offsetY: 0 };
            while (bytes.bytesAvailable > 0) {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;
                if (fieldId == 1 && wire == 0) {
                    result.offsetX = toSigned32(readVarint(bytes));
                } else if (fieldId == 2 && wire == 0) {
                    result.offsetY = toSigned32(readVarint(bytes));
                } else {
                    skipField(bytes, wire);
                }
            }
            return result;
        }

        private function parseHeight(bytes:ByteArray):Object
        {
            var result:Object = {};
            while (bytes.bytesAvailable > 0) {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;
                if (fieldId == 1 && wire == 0) {
                    result.hasElevation = true;
                    result.elevation = uint(readVarint(bytes));
                } else {
                    skipField(bytes, wire);
                }
            }
            return result;
        }

        private function parseAutomap(bytes:ByteArray):Object
        {
            var result:Object = { miniMap: true };
            while (bytes.bytesAvailable > 0) {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;
                if (fieldId == 1 && wire == 0) {
                    result.miniMapColor = uint(readVarint(bytes));
                } else {
                    skipField(bytes, wire);
                }
            }
            return result;
        }

        private function parseLenshelp(bytes:ByteArray):Object
        {
            var result:Object = {};
            while (bytes.bytesAvailable > 0) {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;
                if (fieldId == 1 && wire == 0) {
                    result.isLensHelp = true;
                    result.lensHelp = uint(readVarint(bytes));
                } else {
                    skipField(bytes, wire);
                }
            }
            return result;
        }

        private function parseClothes(bytes:ByteArray):Object
        {
            var result:Object = { cloth: true };
            while (bytes.bytesAvailable > 0) {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;
                if (fieldId == 1 && wire == 0) {
                    result.clothSlot = uint(readVarint(bytes));
                } else {
                    skipField(bytes, wire);
                }
            }
            return result;
        }

        private function parseDefaultAction(bytes:ByteArray):Object
        {
            var result:Object = { hasDefaultAction: true };
            while (bytes.bytesAvailable > 0) {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;
                if (fieldId == 1 && wire == 0) {
                    result.defaultAction = uint(readVarint(bytes));
                } else {
                    skipField(bytes, wire);
                }
            }
            return result;
        }

        private function parseMarket(bytes:ByteArray):Object
        {
            var result:Object = { isMarketItem: true };
            while (bytes.bytesAvailable > 0) {
                var tag:uint = uint(readVarint(bytes));
                var fieldId:uint = tag >> 3;
                var wire:uint = tag & 7;
                switch (fieldId)
                {
                    case 1:
                        result.marketCategory = uint(readVarint(bytes));
                        break;
                    case 2:
                        result.marketTradeAs = uint(readVarint(bytes));
                        break;
                    case 3:
                        result.marketShowAs = uint(readVarint(bytes));
                        break;
                    case 6:
                        result.marketRestrictLevel = uint(readVarint(bytes));
                        break;
                    case 7:
                        result.marketName = readString(bytes);
                        break;
                    case 8:
                        result.marketRestrictProfession = uint(readVarint(bytes));
                        break;
                    default:
                        skipField(bytes, wire);
                        break;
                }
            }
            return result;
        }

        private function applyFlags(thing:ThingType, flags:Object):void
        {
            if (!flags) {
                return;
            }

            for (var name:String in flags) {
                if (thing.hasOwnProperty(name)) {
                    thing[name] = flags[name];
                }
            }
        }

        private function mergeSpriteInfo(target:Object, source:Object):void
        {
            target.patternWidth = source.patternWidth;
            target.patternHeight = source.patternHeight;
            target.patternDepth = source.patternDepth;
            target.layers = source.layers;
            target.patternSize = source.patternSize;
            target.patternFrames = source.patternFrames;
            target.isAnimation = source.isAnimation;
            target.animationMode = source.animationMode;
            target.loopCount = source.loopCount;
            target.startFrame = source.startFrame;
            target.frameDurations = source.frameDurations;
            target.spriteCount = source.spriteCount;
        }

        private function mergeAnimation(target:Object, source:Object):void
        {
            target.animationMode = source.animationMode;
            target.loopCount = source.loopCount;
            target.startFrame = source.startFrame;
            target.frameDurations = source.frameDurations;
            if (source.frameDurations.length > 0) {
                target.isAnimation = true;
                target.patternFrames = Math.max(1, source.frameDurations.length);
            }
        }

        private function mergeObject(target:Object, source:Object):void
        {
            for (var name:String in source) {
                target[name] = source[name];
            }
        }

        private function readBool(bytes:ByteArray):Boolean
        {
            return readVarint(bytes) != 0;
        }

        private function readString(bytes:ByteArray):String
        {
            var raw:ByteArray = readLengthDelimited(bytes);
            raw.position = 0;
            return raw.readUTFBytes(raw.length);
        }

        private function readLengthDelimited(bytes:ByteArray):ByteArray
        {
            var length:uint = uint(readVarint(bytes));
            var result:ByteArray = new ByteArray();
            if (length > 0) {
                bytes.readBytes(result, 0, length);
            }
            result.position = 0;
            return result;
        }

        private function readVarint(bytes:ByteArray):Number
        {
            var result:Number = 0;
            var shift:uint = 0;

            while (bytes.bytesAvailable > 0)
            {
                var current:uint = bytes.readUnsignedByte();
                result += Number(current & 0x7F) * Math.pow(2, shift);
                if ((current & 0x80) == 0) {
                    return result;
                }
                shift += 7;
            }

            return result;
        }

        private function skipField(bytes:ByteArray, wire:uint):void
        {
            switch (wire)
            {
                case 0:
                    readVarint(bytes);
                    break;

                case 1:
                    bytes.position += 8;
                    break;

                case 2:
                    var length:uint = uint(readVarint(bytes));
                    bytes.position += length;
                    break;

                case 5:
                    bytes.position += 4;
                    break;

                default:
                    throw new Error("Unsupported protobuf wire type " + wire + ".");
            }
        }

        private function toSigned32(value:Number):int
        {
            if (value > 0x7FFFFFFF) {
                return int(value - 0x100000000);
            }
            return int(value);
        }
    }
}
