package ob.components.skins
{
    import mx.skins.ProgrammaticSkin;

    public class DividerSkin extends ProgrammaticSkin
    {
        override protected function updateDisplayList(w:Number, h:Number):void
        {
            super.updateDisplayList(w, h);

            graphics.clear();
            graphics.beginFill(0x171A1F);
            graphics.drawRect(0, 0, w, h);
            graphics.endFill();

            graphics.beginFill(0x626873, 0.45);
            if (w > h) {
                graphics.drawRect(0, 0, w, 1);
            } else {
                graphics.drawRect(0, 0, 1, h);
            }
            graphics.endFill();

            graphics.beginFill(0x2B2F35, 0.65);
            if (w > h) {
                graphics.drawRect(0, Math.max(0, h - 1), w, 1);
            } else {
                graphics.drawRect(Math.max(0, w - 1), 0, 1, h);
            }
            graphics.endFill();
        }
    }
}
