/*
 * Copyright (c) 2010-2017 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef UIWIDGET_H
#define UIWIDGET_H

#include "declarations.h"
#include "uilayout.h"

#include <framework/luaengine/luaobject.h>
#include <framework/graphics/declarations.h>
#include <framework/otml/otmlnode.h>
#include <framework/graphics/bitmapfont.h>
#include <framework/graphics/coordsbuffer.h>
#include <framework/core/timer.h>
#include <framework/html/declarations.h>

enum WidgetEvents : int {
    EVENT_TEXT_CLICK = 1,
    EVENT_TEXT_HOVER = 2
};

const std::unordered_map<std::string, WidgetEvents> eventMap = {
    {"text-click", EVENT_TEXT_CLICK},
    {"text-hover", EVENT_TEXT_HOVER}
};

struct TextEvent {
    std::string word;
    size_t startPos;
    size_t endPos;
    bool noUnderline = false;
};

template<typename T = int>
struct EdgeGroup {
    EdgeGroup() { top = right = bottom = left = T(0); }
    void set(T value) { top = right = bottom = left = value; }
    T top;
    T right;
    T bottom;
    T left;
};

enum FlagProp : uint64_t {
    PropTextVerticalAutoResize = 1ULL << 1,
    PropTextHorizontalAutoResize = 1ULL << 2,
    PropApplyAnchorAlignment = 1ULL << 26,
    PropUpdateSize = 1ULL << 27
};

enum class DisplayType : uint8_t {
    None, Block, Inline, InlineBlock, Flex, InlineFlex, Grid, InlineGrid,
    Table, TableRowGroup, TableHeaderGroup, TableFooterGroup, TableRow,
    TableCell, TableColumnGroup, TableColumn, TableCaption, ListItem,
    RunIn, Contents, Initial, Inherit
};

enum class FloatType : uint8_t { None, Left, Right, InlineStart, InlineEnd };
enum class ClearType : uint8_t { None, Left, Right, Both, InlineStart, InlineEnd };
enum class JustifyItemsType : uint8_t { Normal, Center, Left, Right };
enum class FlexDirection : uint8_t { Row, RowReverse, Column, ColumnReverse };
enum class FlexWrap : uint8_t { NoWrap, Wrap, WrapReverse };
enum class JustifyContent : uint8_t { FlexStart, FlexEnd, Center, SpaceBetween, SpaceAround, SpaceEvenly };
enum class AlignItems : uint8_t { Stretch, FlexStart, FlexEnd, Center, Baseline };
enum class AlignContent : uint8_t { Stretch, FlexStart, FlexEnd, Center, SpaceBetween, SpaceAround, SpaceEvenly };
enum class AlignSelf : uint8_t { Auto, Stretch, FlexStart, FlexEnd, Center, Baseline };
enum class Unit : uint8_t { Auto, FitContent, Px, Em, Percent, Invalid };
enum class OverflowType : uint8_t { Visible, Hidden, Scroll, Auto, Clip };
enum class PositionType : uint8_t { Static, Absolute, Relative };

struct SizeUnit {
    bool needsUpdate(Unit expected) const { return pendingUpdate && unit == expected; }
    bool needsUpdate(Unit expected, uint32_t expectedVersion) const {
        return pendingUpdate && unit == expected && version != expectedVersion;
    }
    void applyUpdate(int32_t calculated, uint32_t newVersion) {
        valueCalculed = calculated;
        version = newVersion;
        pendingUpdate = false;
    }

    SizeUnit() = default;
    SizeUnit(Unit valueUnit) : unit(valueUnit) {}
    SizeUnit(int32_t rawValue) : unit(Unit::Px), value(rawValue) {}
    SizeUnit(Unit valueUnit, int32_t rawValue, int32_t calculated, uint32_t needsUpdate)
        : unit(valueUnit), value(rawValue), valueCalculed(calculated), pendingUpdate(needsUpdate) {}

    Unit unit = Unit::Px;
    int32_t value = 0;
    int32_t valueCalculed = -1;
    uint32_t version = 0;
    bool pendingUpdate = false;
};

struct FlexBasis {
    enum class Type : uint8_t { Auto, Px, Percent, Content };
    Type type{ Type::Auto };
    float value{ 0.f };
};

struct FlexContainerStyle {
    FlexDirection direction{ FlexDirection::Row };
    FlexWrap wrap{ FlexWrap::NoWrap };
    JustifyContent justify{ JustifyContent::FlexStart };
    AlignItems alignItems{ AlignItems::Stretch };
    AlignContent alignContent{ AlignContent::Stretch };
    int rowGap{ 0 };
    int columnGap{ 0 };
};

struct FlexItemStyle {
    int order{ 0 };
    float flexGrow{ 0.f };
    float flexShrink{ 1.f };
    FlexBasis basis{};
    AlignSelf alignSelf{ AlignSelf::Auto };
};

struct UIWidgetStyle {
    DisplayType display{ DisplayType::Inline };
    PositionType position{ PositionType::Static };
    FlexDirection flexDirection{ FlexDirection::Row };
    FlexWrap flexWrap{ FlexWrap::NoWrap };
    JustifyContent justifyContent{ JustifyContent::FlexStart };
    AlignItems alignItems{ AlignItems::Stretch };
    AlignContent alignContent{ AlignContent::Stretch };
    int rowGap{ 0 };
    int columnGap{ 0 };
    int order{ 0 };
    float flexGrow{ 0.f };
    float flexShrink{ 1.f };
    FlexBasis flexBasis{};
    AlignSelf alignSelf{ AlignSelf::Auto };
    SizeUnit width{};
    SizeUnit height{};
    int minWidth{ 0 }, minHeight{ 0 }, maxWidth{ 0 }, maxHeight{ 0 };
    bool marginTopAuto{ false }, marginBottomAuto{ false }, marginLeftAuto{ false }, marginRightAuto{ false };
};

// @bindclass
class UIWidget : public LuaObject
{
// widget core
public:
    UIWidget();
    virtual ~UIWidget();

    virtual void draw(const Rect& visibleRect, Fw::DrawPane drawPane);

protected:
    virtual void drawSelf(Fw::DrawPane drawPane);
    virtual void drawChildren(const Rect& visibleRect, Fw::DrawPane drawPane);

    friend class UIManager;

    std::string m_id;
    std::string m_htmlId;
    uint32_t m_htmlRootId{0};
    std::string m_source;
    Rect m_rect;
    Size m_minSize;
    Size m_maxSize;
    Size m_percentSize;
    Size m_sizeOffset;
    Point m_virtualOffset;
    stdext::boolean<true> m_autoDraw;
    stdext::boolean<true> m_enabled;
    stdext::boolean<true> m_visible;
    stdext::boolean<true> m_focusable;
    stdext::boolean<false> m_fixedSize;
    stdext::boolean<false> m_phantom;
    stdext::boolean<false> m_draggable;
    stdext::boolean<false> m_destroyed;
    stdext::boolean<false> m_clipping;
    stdext::boolean<false> m_pixelTest;
    UILayoutPtr m_layout;
    UIWidgetPtr m_parent;
    std::string m_parentId;
    UIWidgetList m_children;
    UIWidgetList m_lockedChildren;
    std::map<UIWidgetPtr, std::string> m_childrenShortcuts;
    UIWidgetPtr m_focusedChild;
    HtmlNodePtr m_htmlNode;
    OTMLNodePtr m_style;
    Timer m_clickTimer;
    Fw::FocusReason m_lastFocusReason;
    Fw::AutoFocusPolicy m_autoFocusPolicy;
    int m_events = 0;
    int m_insertChildIndex{-1};

    DisplayType m_displayType{DisplayType::Inline};
    DisplayType m_originalDisplayType{DisplayType::Inline};
    FloatType m_floatType{FloatType::None};
    ClearType m_clearType{ClearType::None};
    JustifyItemsType m_justifyItems{JustifyItemsType::Normal};
    OverflowType m_overflowType{OverflowType::Hidden};
    PositionType m_positionType{PositionType::Static};
    Fw::AlignmentFlag m_placement{Fw::AlignNone};
    SizeUnit m_width;
    SizeUnit m_height;
    SizeUnit m_lineHeight;
    EdgeGroup<SizeUnit> m_positions;
    FlexContainerStyle m_flexContainer;
    FlexItemStyle m_flexItem;
    mutable UIWidgetStyle m_styleCache;
    uint32_t m_flexLayoutVersion{0};
    uint64_t m_htmlFlags{0};
    bool m_inFlexLayout{false};
    bool m_anchorable{true};

public:
    UIWidgetPtr insert(int32_t index, const std::string& html);
    UIWidgetPtr append(const std::string& html);
    UIWidgetPtr prepend(const std::string& html);
    UIWidgetPtr html(const std::string& html);
    size_t remove(const std::string& selector);

    void addChild(const UIWidgetPtr& child);
    void onChildIdChange(const UIWidgetPtr& child);
    void insertChild(int index, const UIWidgetPtr& child);
    void removeChild(UIWidgetPtr child);
    void removeChildByIndex(uint32 index);
    void focusChild(const UIWidgetPtr& child, Fw::FocusReason reason);
    void focusNextChild(Fw::FocusReason reason, bool rotate = false);
    void focusPreviousChild(Fw::FocusReason reason, bool rotate = false);
    void lowerChild(UIWidgetPtr child);
    void raiseChild(UIWidgetPtr child);
    void moveChildToIndex(const UIWidgetPtr& child, int index);
    void reorderChildren(const std::vector<UIWidgetPtr>& childrens);
    void lockChild(const UIWidgetPtr& child);
    void unlockChild(const UIWidgetPtr& child);
    void mergeStyle(const OTMLNodePtr& styleNode);
    void applyStyle(const OTMLNodePtr& styleNode);
    void addAnchor(Fw::AnchorEdge anchoredEdge, const std::string& hookedWidgetId, Fw::AnchorEdge hookedEdge);
    void removeAnchor(Fw::AnchorEdge anchoredEdge);
    void fill(const std::string& hookedWidgetId);
    void centerIn(const std::string& hookedWidgetId);
    void breakAnchors();
    void resetAnchors() { breakAnchors(); }
    void updateParentLayout();
    void updateLayout();
    void lock();
    void unlock();
    void focus();
    void recursiveFocus(Fw::FocusReason reason);
    void lower();
    void raise();
    void grabMouse();
    void ungrabMouse();
    void grabKeyboard();
    void ungrabKeyboard();
    void bindRectToParent();
    void destroy();
    void destroyChildren();

    void setId(const std::string& id);
    void setParent(const UIWidgetPtr& parent);
    void setLayout(const UILayoutPtr& layout);
    bool setRect(const Rect& rect);
    void setStyle(const std::string& styleName);
    void setStyleFromNode(const OTMLNodePtr& styleNode);
    void setEnabled(bool enabled);
    void setDisabled(bool disabled) { setEnabled(!disabled); }
    void setVisible(bool visible);
    void setAutoDraw(bool value);
    void setOn(bool on);
    void setChecked(bool checked);
    void setFocusable(bool focusable);
    void setPhantom(bool phantom);
    void setDraggable(bool draggable);
    void setFixedSize(bool fixed);
    void setClipping(bool clipping) { m_clipping = clipping; }
    void setLastFocusReason(Fw::FocusReason reason);
    void setAutoFocusPolicy(Fw::AutoFocusPolicy policy);
    void setAutoRepeatDelay(int delay) { m_autoRepeatDelay = delay; }
    void setVirtualOffset(const Point& offset);
    void setPixelTesting(bool pixelTest);
    void setEventListener(WidgetEvents event);
    void removeEventListener(WidgetEvents event);
    void setDisplay(DisplayType type);
    void setFloat(FloatType type) { m_floatType = type; scheduleHtmlTask(PropApplyAnchorAlignment); }
    void setClear(ClearType type) { m_clearType = type; scheduleHtmlTask(PropApplyAnchorAlignment); }
    void setJustifyItems(JustifyItemsType type) { m_justifyItems = type; scheduleHtmlTask(PropApplyAnchorAlignment); }
    void setFlexDirection(FlexDirection direction);
    void setFlexWrap(FlexWrap wrap);
    void setJustifyContent(JustifyContent justify);
    void setAlignItems(AlignItems align);
    void setAlignContent(AlignContent align);
    void setRowGap(int gap);
    void setColumnGap(int gap);
    void setGap(int rowGap, int columnGap);
    void setFlexOrder(int order);
    void setFlexGrow(float grow);
    void setFlexShrink(float shrink);
    void setFlexBasis(const FlexBasis& basis);
    void setAlignSelf(AlignSelf align);
    void setPlacement(const std::string& placement);
    void setOverflow(OverflowType type);
    void setPositions(std::string_view type, std::string_view value);
    void setHtmlNode(const HtmlNodePtr& node) { m_htmlNode = node; }
    void setHtmlRootId(uint32_t id) { m_htmlRootId = id; }
    void setAnchorable(bool value) { m_anchorable = value; }
    void setResultConditionIf(bool value) {
        if (value && m_displayType != DisplayType::None)
            return;
        if (!value)
            m_originalDisplayType = m_displayType;
        setDisplay(value ? m_originalDisplayType : DisplayType::None);
    }
    void setPositionType(PositionType type) {
        m_positionType = type;
        if (type == PositionType::Absolute) {
            applyDimension(true, m_width.unit, m_width.value);
            applyDimension(false, m_height.unit, m_height.value);
        }
        refreshHtml();
    }
    void ensureUniqueId();
    void updateSize();

    bool isAnchored();
    bool isChildLocked(const UIWidgetPtr& child);
    bool hasChild(const UIWidgetPtr& child);
    int getChildIndex(const UIWidgetPtr& child);
    int getChildIndex() { return m_parent ? m_parent->getChildIndex(static_self_cast<UIWidget>()) : -1; }
    Rect getPaddingRect();
    Rect getMarginRect();
    Rect getChildrenRect();
    UIAnchorLayoutPtr getAnchoredLayout();
    bool hasAnchoredLayout() { return getAnchoredLayout() != nullptr; }
    UIWidgetPtr getRootParent();
    UIWidgetPtr getNextWidget() {
        const auto& parent = getParent();
        return parent && parent->getChildCount() > getChildIndex() ? parent->getChildByIndex(getChildIndex() + 1) : nullptr;
    }
    UIWidgetPtr getPrevWidget() {
        const auto& parent = getParent();
        return parent && getChildIndex() > 1 ? parent->getChildByIndex(getChildIndex() - 1) : nullptr;
    }
    UIWidgetPtr getChildAfter(const UIWidgetPtr& relativeChild);
    UIWidgetPtr getChildBefore(const UIWidgetPtr& relativeChild);
    UIWidgetPtr getChildById(const std::string& childId);
    UIWidgetPtr getChildByPos(const Point& childPos);
    UIWidgetPtr getChildByIndex(int index);
    UIWidgetPtr recursiveGetChildById(const std::string& id);
    UIWidgetPtr recursiveGetChildByPos(const Point& childPos, bool wantsPhantom);
    UIWidgetList recursiveGetChildren();
    UIWidgetList recursiveGetChildrenByPos(const Point& childPos);
    UIWidgetList recursiveGetChildrenByMarginPos(const Point& childPos);
    UIWidgetPtr backwardsGetWidgetById(const std::string& id);
    bool hasEventListener(WidgetEvents event) { return (m_events & event) != 0; }
    std::vector<UIWidgetPtr> querySelectorAll(const std::string& selector);
    UIWidgetPtr querySelector(const std::string& selector);
    UIWidgetPtr getVirtualParent() const;

    bool isOnHtml() const { return m_htmlNode != nullptr; }
    bool isInFlexLayout() const { return m_inFlexLayout; }
    bool isAnchorable() const { return m_anchorable; }
    DisplayType getDisplay() const { return m_displayType; }
    FloatType getFloat() const { return m_floatType; }
    JustifyItemsType getJustifyItems() const { return m_justifyItems; }
    OverflowType getOverflow() const { return m_overflowType; }
    PositionType getPositionType() const { return m_positionType; }
    Fw::AlignmentFlag getPlacement() const { return m_placement; }
    const HtmlNodePtr& getHtmlNode() const { return m_htmlNode; }
    uint32_t getHtmlRootId() const { return m_htmlRootId; }
    const std::string& getHtmlId() const { return m_htmlId; }
    SizeUnit& getWidthHtml() { return m_width; }
    SizeUnit& getHeightHtml() { return m_height; }
    EdgeGroup<SizeUnit>& getPositions() { return m_positions; }
    const UIWidgetStyle& style() const;
    FlexDirection getFlexDirection() const { return m_flexContainer.direction; }
    FlexWrap getFlexWrap() const { return m_flexContainer.wrap; }
    JustifyContent getJustifyContent() const { return m_flexContainer.justify; }
    AlignItems getAlignItems() const { return m_flexContainer.alignItems; }
    AlignContent getAlignContent() const { return m_flexContainer.alignContent; }
    int getRowGap() const { return m_flexContainer.rowGap; }
    int getColumnGap() const { return m_flexContainer.columnGap; }
    int getFlexOrder() const { return m_flexItem.order; }
    float getFlexGrow() const { return m_flexItem.flexGrow; }
    float getFlexShrink() const { return m_flexItem.flexShrink; }
    const FlexBasis& getFlexBasis() const { return m_flexItem.basis; }
    AlignSelf getAlignSelf() const { return m_flexItem.alignSelf; }

private:
    stdext::boolean<false> m_updateEventScheduled;
    stdext::boolean<false> m_loadingStyle;


// state managment
protected:
    bool setState(Fw::WidgetState state, bool on);
    bool hasState(Fw::WidgetState state);

private:
    void internalDestroy();
    void updateState(Fw::WidgetState state, bool htmlState = false);
    void updateStates();
    void updateChildrenIndexStates();
    void updateStyle();
    void updateTableLayout();
    void applyAnchorAlignment();
    void scheduleHtmlTask(FlagProp prop);
    static void flushPendingHtmlWidgets();
    bool hasProp(FlagProp prop) const {
        if (prop == PropTextVerticalAutoResize)
            return m_textVerticalAutoResize;
        if (prop == PropTextHorizontalAutoResize)
            return m_textHorizontalAutoResize;
        return (m_htmlFlags & static_cast<uint64_t>(prop)) != 0;
    }
    void setProp(FlagProp prop, bool enabled) {
        if (prop == PropTextVerticalAutoResize) {
            m_textVerticalAutoResize = enabled;
            return;
        }
        if (prop == PropTextHorizontalAutoResize) {
            m_textHorizontalAutoResize = enabled;
            return;
        }
        if (enabled)
            m_htmlFlags |= static_cast<uint64_t>(prop);
        else
            m_htmlFlags &= ~static_cast<uint64_t>(prop);
    }

    stdext::boolean<false> m_updateStyleScheduled;
    stdext::boolean<true> m_firstOnStyle;
    OTMLNodePtr m_stateStyle;
    int m_states;


// event processing
protected:
    virtual void onStyleApply(const std::string& styleName, const OTMLNodePtr& styleNode);
    virtual void onGeometryChange(const Rect& oldRect, const Rect& newRect);
    virtual void onLayoutUpdate();
    virtual void onFocusChange(bool focused, Fw::FocusReason reason);
    virtual void onChildFocusChange(const UIWidgetPtr& focusedChild, const UIWidgetPtr& unfocusedChild, Fw::FocusReason reason);
    virtual void onHoverChange(bool hovered);
    virtual void onVisibilityChange(bool visible);
    virtual bool onDragEnter(const Point& mousePos);
    virtual bool onDragLeave(UIWidgetPtr droppedWidget, const Point& mousePos);
    virtual bool onDragMove(const Point& mousePos, const Point& mouseMoved);
    virtual bool onDrop(UIWidgetPtr draggedWidget, const Point& mousePos);
    virtual bool onKeyText(const std::string& keyText);
    virtual bool onKeyDown(uchar keyCode, int keyboardModifiers);
    virtual bool onKeyPress(uchar keyCode, int keyboardModifiers, int autoRepeatTicks);
    virtual bool onKeyUp(uchar keyCode, int keyboardModifiers);
    virtual bool onMousePress(const Point& mousePos, Fw::MouseButton button);
    virtual bool onMouseRelease(const Point& mousePos, Fw::MouseButton button);
    virtual bool onMouseMove(const Point& mousePos, const Point& mouseMoved);
    virtual bool onMouseWheel(const Point& mousePos, Fw::MouseWheelDirection direction);
    virtual bool onClick(const Point& mousePos);
    virtual bool onDoubleClick(const Point& mousePos);
    virtual void onTextHoverChange(const std::string& text, bool hovered);

    friend class UILayout;

    bool propagateOnKeyText(const std::string& keyText);
    bool propagateOnKeyDown(uchar keyCode, int keyboardModifiers);
    bool propagateOnKeyPress(uchar keyCode, int keyboardModifiers, int autoRepeatTicks);
    bool propagateOnKeyUp(uchar keyCode, int keyboardModifiers);
    bool propagateOnMouseEvent(const Point& mousePos, UIWidgetList& widgetList, bool checkContainsPoint = false);
    bool propagateOnMouseMove(const Point& mousePos, const Point& mouseMoved, UIWidgetList& widgetList);


// function shortcuts
public:
    void resize(int width, int height) { setRect(Rect(getPosition(), Size(width, height))); }
    void move(int x, int y) { setRect(Rect(x, y, getSize())); }
    void rotate(float degrees) { setRotation(degrees); }
    void hide() { setVisible(false); }
    void show() { setVisible(true); }
    void disable() { setEnabled(false); }
    void enable() { setEnabled(true); }

    bool isActive() { return hasState(Fw::ActiveState); }
    bool isEnabled() { return !hasState(Fw::DisabledState); }
    bool isDisabled() { return hasState(Fw::DisabledState); }
    bool isFocused() { return hasState(Fw::FocusState); }
    bool isHovered() { return hasState(Fw::HoverState); }
    bool isPressed() { return hasState(Fw::PressedState); }
    bool isFirst() { return hasState(Fw::FirstState); }
    bool isMiddle() { return hasState(Fw::MiddleState); }
    bool isLast() { return hasState(Fw::LastState); }
    bool isAlternate() { return hasState(Fw::AlternateState); }
    bool isChecked() { return hasState(Fw::CheckedState); }
    bool isOn() { return hasState(Fw::OnState); }
    bool isDragging() { return hasState(Fw::DraggingState); }
    bool isVisible() { return !hasState(Fw::HiddenState); }
    bool isHidden() { return hasState(Fw::HiddenState); }
    bool isExplicitlyEnabled() { return m_enabled; }
    bool isExplicitlyVisible() { return m_visible; }
    bool isAutoDraw() { return m_autoDraw; }
    bool isFocusable() { return m_focusable; }
    bool isPhantom() { return m_phantom; }
    bool isDraggable() { return m_draggable; }
    bool isFixedSize() { return m_fixedSize; }
    bool isClipping() { return m_clipping || (isOnHtml() && (m_overflowType == OverflowType::Clip || m_overflowType == OverflowType::Scroll)); }
    bool isDestroyed() { return m_destroyed; }
    bool isPixelTesting() { return m_pixelTest; }
    bool isEffectivelyVisible() { return isVisible() || m_displayType != DisplayType::None; }
    bool isPixelTransparent(const Point& mousePos);

    bool hasChildren() { return m_children.size() > 0; }
    bool containsMarginPoint(const Point& point) { return getMarginRect().contains(point); }
    bool containsPaddingPoint(const Point& point) { return getPaddingRect().contains(point); }
    bool containsPoint(const Point& point) { return m_rect.contains(point); }

    std::string getId() { return m_id; }
    std::string getSource() { return m_source; }
    UIWidgetPtr getParent() { return m_parent; }
    std::string getParentId() { return m_parentId; }
    UIWidgetPtr getFocusedChild() { return m_focusedChild; }
    UIWidgetList getChildren() { return m_children; }
    UIWidgetList& getChildrenRef() { return m_children; }
    const UIWidgetList& getChildrenRef() const { return m_children; }
    UIWidgetPtr getFirstChild() { return getChildByIndex(1); }
    UIWidgetPtr getLastChild() { return getChildByIndex(-1); }
    UILayoutPtr getLayout() { return m_layout; }
    OTMLNodePtr getStyle() { return m_style; }
    int getChildCount() { return m_children.size(); }
    Fw::FocusReason getLastFocusReason() { return m_lastFocusReason; }
    Fw::AutoFocusPolicy getAutoFocusPolicy() { return m_autoFocusPolicy; }
    int getAutoRepeatDelay() { return m_autoRepeatDelay; }
    Point getVirtualOffset() { return m_virtualOffset; }
    std::string getStyleName() { return m_style->tag(); }
    Point getLastClickPosition() { return m_lastClickPosition; }

    // for stats only
    bool isRootChild()
    {
        return m_isRootChild;
    }

    void setRootChild(bool v)
    {
        m_isRootChild = v;
    }


// base style
private:
    void initBaseStyle();
    void parseBaseStyle(const OTMLNodePtr& styleNode);

protected:
    void drawBackground(const Rect& screenCoords);
    void drawBorder(const Rect& screenCoords);
    void drawIcon(const Rect& screenCoords);

    Color m_color;
    Color m_backgroundColor;
    Rect m_backgroundRect;
    TexturePtr m_icon;
    Color m_iconColor;
    Rect m_iconRect;
    Rect m_iconClipRect;
    std::string m_iconPath;
    Fw::AlignmentFlag m_iconAlign;
    stdext::boolean<true> m_iconSmooth;
    EdgeGroup<Color> m_borderColor;
    EdgeGroup<int> m_borderWidth;
    EdgeGroup<int> m_margin;
    EdgeGroup<int> m_padding;
    bool m_marginTopAuto{false};
    bool m_marginBottomAuto{false};
    bool m_marginLeftAuto{false};
    bool m_marginRightAuto{false};
    float m_opacity;
    float m_rotation;
    int m_autoRepeatDelay;
    Point m_lastClickPosition;
    bool m_isRootChild = false; // for stats

public:
    void setX(int x) { move(x, getY()); }
    void setY(int y) { move(getX(), y); }
    void setWidth(int width, bool percentage = false);
    void setHeight(int height, bool percentage = false);
    void setWidth(std::string width) { applyDimension(true, std::move(width)); }
    void setHeight(std::string height) { applyDimension(false, std::move(height)); }
    void setWidth_px(int width) { resize(width, getHeight()); }
    void setHeight_px(int height) { resize(getWidth(), height); }
    void setTop(int value) { m_positions.top = SizeUnit(value); scheduleHtmlTask(PropUpdateSize); scheduleHtmlTask(PropApplyAnchorAlignment); updateLayout(); }
    void setBottom(int value) { m_positions.bottom = SizeUnit(value); scheduleHtmlTask(PropUpdateSize); scheduleHtmlTask(PropApplyAnchorAlignment); updateLayout(); }
    void setLeft(int value) { m_positions.left = SizeUnit(value); scheduleHtmlTask(PropUpdateSize); scheduleHtmlTask(PropApplyAnchorAlignment); updateLayout(); }
    void setRight(int value) { m_positions.right = SizeUnit(value); scheduleHtmlTask(PropUpdateSize); scheduleHtmlTask(PropApplyAnchorAlignment); updateLayout(); }
    void setSize(const Size& size) { resize(size.width(), size.height()); }
    void setMinWidth(int width) { m_minSize.setWidth(width); }
    void setMinHeight(int height) { m_minSize.setHeight(height); }
    void setMaxWidth(int width) { m_maxSize.setWidth(width); }
    void setMaxHeight(int height) { m_maxSize.setHeight(height); }
    void setWidthOffset(int offset) { m_sizeOffset.setWidth(offset); updateLayout(); }
    void setHeightOffset(int offset) { m_sizeOffset.setHeight(offset); updateLayout(); }
    void setSizeOffset(const Size& size) { m_sizeOffset = size; updateLayout(); }
    void setPosition(const Point& pos) { move(pos.x, pos.y); }
    void setColor(const Color& color) { m_color = color; }
    void setBackgroundColor(const Color& color) { m_backgroundColor = color; }
    void setBackgroundOffsetX(int x) { m_backgroundRect.setX(x); }
    void setBackgroundOffsetY(int y) { m_backgroundRect.setX(y); }
    void setBackgroundOffset(const Point& pos) { m_backgroundRect.move(pos); }
    void setBackgroundWidth(int width) { m_backgroundRect.setWidth(width); }
    void setBackgroundHeight(int height) { m_backgroundRect.setHeight(height); }
    void setBackgroundSize(const Size& size) { m_backgroundRect.resize(size); }
    void setBackgroundRect(const Rect& rect) { m_backgroundRect = rect; }
    void setIcon(const std::string& iconFile);
    void setIconColor(const Color& color) { m_iconColor = color; }
    void setIconOffsetX(int x) { m_iconOffset.x = x; }
    void setIconOffsetY(int y) { m_iconOffset.y = y; }
    void setIconOffset(const Point& pos) { m_iconOffset = pos; }
    void setIconWidth(int width) { m_iconRect.setWidth(width); }
    void setIconHeight(int height) { m_iconRect.setHeight(height); }
    void setIconSize(const Size& size) { m_iconRect.resize(size); }
    void setIconRect(const Rect& rect) { m_iconRect = rect; }
    void setIconClip(const Rect& rect) { m_iconClipRect = rect; }
    void setIconAlign(Fw::AlignmentFlag align) { m_iconAlign = align; }
    void setIconSmooth(bool smooth) { m_iconSmooth = smooth; }
    void setBorderWidth(int width) { m_borderWidth.set(width); updateLayout(); }
    void setBorderWidthTop(int width) { m_borderWidth.top = width; }
    void setBorderWidthRight(int width) { m_borderWidth.right = width; }
    void setBorderWidthBottom(int width) { m_borderWidth.bottom = width; }
    void setBorderWidthLeft(int width) { m_borderWidth.left = width; }
    void setBorderColor(const Color& color) { m_borderColor.set(color); updateLayout(); }
    void setBorderColorTop(const Color& color) { m_borderColor.top = color; }
    void setBorderColorRight(const Color& color) { m_borderColor.right = color; }
    void setBorderColorBottom(const Color& color) { m_borderColor.bottom = color; }
    void setBorderColorLeft(const Color& color) { m_borderColor.left = color; }
    void setMargin(int margin) { m_margin.set(margin); updateParentLayout(); }
    void setMarginHorizontal(int margin) { m_margin.right = m_margin.left = margin; updateParentLayout(); }
    void setMarginVertical(int margin) { m_margin.bottom = m_margin.top = margin; updateParentLayout(); }
    void setMarginTop(int margin) { m_margin.top = margin; updateParentLayout(); }
    void setMarginRight(int margin) { m_margin.right = margin; updateParentLayout(); }
    void setMarginBottom(int margin) { m_margin.bottom = margin; updateParentLayout(); }
    void setMarginLeft(int margin) { m_margin.left = margin; updateParentLayout(); }
    void setMarginTopAuto(bool value = true) { m_marginTopAuto = value; updateParentLayout(); }
    void setMarginRightAuto(bool value = true) { m_marginRightAuto = value; updateParentLayout(); }
    void setMarginBottomAuto(bool value = true) { m_marginBottomAuto = value; updateParentLayout(); }
    void setMarginLeftAuto(bool value = true) { m_marginLeftAuto = value; updateParentLayout(); }
    void setPadding(int padding) { m_padding.top = m_padding.right = m_padding.bottom = m_padding.left = padding; updateLayout(); }
    void setPaddingHorizontal(int padding) { m_padding.right = m_padding.left = padding; updateLayout(); }
    void setPaddingVertical(int padding) { m_padding.bottom = m_padding.top = padding; updateLayout(); }
    void setPaddingTop(int padding) { m_padding.top = padding; updateLayout(); }
    void setPaddingRight(int padding) { m_padding.right = padding; updateLayout(); }
    void setPaddingBottom(int padding) { m_padding.bottom = padding; updateLayout(); }
    void setPaddingLeft(int padding) { m_padding.left = padding; updateLayout(); }
    void setOpacity(float opacity) { m_opacity = stdext::clamp<float>(opacity, 0.0f, 1.0f); }
    void setRotation(float degrees) { m_rotation = degrees; }
    void setChangeCursorImage(bool enable) { m_changeCursorImage = enable; }
    void setCursor(const std::string& cursor);
    void updatePercentSize(const Size& size);

    int getX() { return m_rect.x(); }
    int getY() { return m_rect.y(); }
    Point getPosition() { return m_rect.topLeft(); }
    int getWidth() { return m_rect.width(); }
    int getHeight() { return m_rect.height(); }
    int getMinWidth() const { return m_minSize.width(); }
    int getMinHeight() const { return m_minSize.height(); }
    int getMaxWidth() const { return m_maxSize.width(); }
    int getMaxHeight() const { return m_maxSize.height(); }
    Size getSize() { return m_rect.size(); }
    int getWidthOffset() { return m_sizeOffset.width(); }
    int getHeightOffset() { return m_sizeOffset.height(); }
    Size getSizeOffset() { return m_sizeOffset; }
    Size getPercentSize() { return m_percentSize; }
    Rect getRect() { return m_rect; }
    bool isSizePercantage() { return !m_percentSize.isNull(); }
    Color getColor() { return m_color; }
    Color getBackgroundColor() { return m_backgroundColor; }
    int getBackgroundOffsetX() { return m_backgroundRect.x(); }
    int getBackgroundOffsetY() { return m_backgroundRect.y(); }
    Point getBackgroundOffset() { return m_backgroundRect.topLeft(); }
    int getBackgroundWidth() { return m_backgroundRect.width(); }
    int getBackgroundHeight() { return m_backgroundRect.height(); }
    Size getBackgroundSize() { return m_backgroundRect.size(); }
    Rect getBackgroundRect() { return m_backgroundRect; }
    Color getIconColor() { return m_iconColor; }
    int getIconOffsetX() { return m_iconOffset.x; }
    int getIconOffsetY() { return m_iconOffset.y; }
    Point getIconOffset() { return m_iconOffset; }
    int getIconWidth() { return m_iconRect.width(); }
    int getIconHeight() { return m_iconRect.height(); }
    Size getIconSize() { return m_iconRect.size(); }
    Rect getIconRect() { return m_iconRect; }
    Rect getIconClip() { return m_iconClipRect; }
    std::string getIconPath() { return m_iconPath; }
    Fw::AlignmentFlag getIconAlign() { return m_iconAlign; }
    Color getBorderTopColor() { return m_borderColor.top; }
    Color getBorderRightColor() { return m_borderColor.right; }
    Color getBorderBottomColor() { return m_borderColor.bottom; }
    Color getBorderLeftColor() { return m_borderColor.left; }
    int getBorderTopWidth() { return m_borderWidth.top; }
    int getBorderRightWidth() { return m_borderWidth.right; }
    int getBorderBottomWidth() { return m_borderWidth.bottom; }
    int getBorderLeftWidth() { return m_borderWidth.left; }
    int getMarginTop() { return m_margin.top; }
    int getMarginRight() { return m_margin.right; }
    int getMarginBottom() { return m_margin.bottom; }
    int getMarginLeft() { return m_margin.left; }
    bool isMarginTopAuto() const { return m_marginTopAuto; }
    bool isMarginRightAuto() const { return m_marginRightAuto; }
    bool isMarginBottomAuto() const { return m_marginBottomAuto; }
    bool isMarginLeftAuto() const { return m_marginLeftAuto; }
    int getPaddingTop() { return m_padding.top; }
    int getPaddingRight() { return m_padding.right; }
    int getPaddingBottom() { return m_padding.bottom; }
    int getPaddingLeft() { return m_padding.left; }
    float getOpacity() { return m_opacity; }
    float getRotation() { return m_rotation; }
    bool isChangingCursorImage() { return m_changeCursorImage; }

// image
private:
    void initImage();
    void parseImageStyle(const OTMLNodePtr& styleNode);
    void applyDimension(bool isWidth, std::string value);
    void applyDimension(bool isWidth, Unit unit, int32_t value);
    void refreshHtml(bool siblingsToo = false);

    void updateImageCache() { m_imageMustRecache = true; }
    void configureBorderImage() { m_imageBordered = true; updateImageCache(); }

    CoordsBuffer m_imageCoordsBuffer;
    Rect m_imageCachedScreenCoords;
    stdext::boolean<true> m_imageMustRecache;
    stdext::boolean<false> m_imageBordered;

    std::string m_cursor;
    stdext::boolean<false> m_changeCursorImage;

protected:
    void drawImage(const Rect& screenCoords);

    friend class HtmlManager;
    friend void layoutFlex(UIWidget& container);

    TexturePtr m_imageTexture;
    std::string m_imageSource;
    Rect m_imageClipRect;
    Rect m_imageRect;
    Color m_imageColor;
    Point m_iconOffset;
    stdext::boolean<false> m_imageFixedRatio;
    stdext::boolean<false> m_imageRepeated;
    stdext::boolean<true> m_imageSmooth;
    stdext::boolean<false> m_imageAutoResize;
    EdgeGroup<int> m_imageBorder;
    std::string m_shader;

public:
    void setQRCode(const std::string& code, int border);
    void setImageSource(const std::string& source);
    void setImageSourceBase64(const std::string & data);
    void setImageClip(const Rect& clipRect) { m_imageClipRect = clipRect; updateImageCache(); }
    void setImageOffsetX(int x) { m_imageRect.setX(x); updateImageCache(); }
    void setImageOffsetY(int y) { m_imageRect.setY(y); updateImageCache(); }
    void setImageOffset(const Point& pos) { m_imageRect.move(pos); updateImageCache(); }
    void setImageWidth(int width) { m_imageRect.setWidth(width); updateImageCache(); }
    void setImageHeight(int height) { m_imageRect.setHeight(height); updateImageCache(); }
    void setImageSize(const Size& size) { m_imageRect.resize(size); updateImageCache(); }
    void setImageRect(const Rect& rect) { m_imageRect = rect; updateImageCache(); }
    void setImageColor(const Color& color) { m_imageColor = color; updateImageCache(); }
    void setImageFixedRatio(bool fixedRatio) { m_imageFixedRatio = fixedRatio; updateImageCache(); }
    void setImageRepeated(bool repeated) { m_imageRepeated = repeated; updateImageCache(); }
    void setImageSmooth(bool smooth) { m_imageSmooth = smooth; }
    void setImageAutoResize(bool autoResize) { m_imageAutoResize = autoResize; }
    void setImageBorderTop(int border) { m_imageBorder.top = border; configureBorderImage(); }
    void setImageBorderRight(int border) { m_imageBorder.right = border; configureBorderImage(); }
    void setImageBorderBottom(int border) { m_imageBorder.bottom = border; configureBorderImage(); }
    void setImageBorderLeft(int border) { m_imageBorder.left = border; configureBorderImage(); }
    void setImageBorder(int border) { m_imageBorder.set(border); configureBorderImage(); }
    void setImageShader(const std::string& str) { m_shader = str; }

    std::string getImageSource() { return m_imageSource; }
    Rect getImageClip() { return m_imageClipRect; }
    int getImageOffsetX() { return m_imageRect.x(); }
    int getImageOffsetY() { return m_imageRect.y(); }
    Point getImageOffset() { return m_imageRect.topLeft(); }
    int getImageWidth() { return m_imageRect.width(); }
    int getImageHeight() { return m_imageRect.height(); }
    Size getImageSize() { return m_imageRect.size(); }
    Rect getImageRect() { return m_imageRect; }
    Color getImageColor() { return m_imageColor; }
    bool isImageFixedRatio() { return m_imageFixedRatio; }
    bool isImageSmooth() { return m_imageSmooth; }
    bool isImageAutoResize() { return m_imageAutoResize; }
    int getImageBorderTop() { return m_imageBorder.top; }
    int getImageBorderRight() { return m_imageBorder.right; }
    int getImageBorderBottom() { return m_imageBorder.bottom; }
    int getImageBorderLeft() { return m_imageBorder.left; }
    int getImageTextureWidth() { return m_imageTexture ? m_imageTexture->getWidth() : 0; }
    int getImageTextureHeight() { return m_imageTexture ? m_imageTexture->getHeight() : 0; }
    std::string getImageShader() { return m_shader; }

// text related
private:
    void initText();
    void parseTextStyle(const OTMLNodePtr& styleNode);

    stdext::boolean<true> m_textMustRecache;
    Rect m_textCachedScreenCoords;
    Size m_realTextSize;

protected:
    virtual void updateText();
    void processCodeTags();
    void cacheRectToWord();
    void updateRectToWord(const std::vector<Rect>& glyphCoords);
    void drawText(const Rect& screenCoords);
    void buildTextUnderline(Rect& wordRect, CoordsBuffer& textUnderlineCoords);

    virtual void onTextChange(const std::string& text, const std::string& oldText);
    virtual void onFontChange(const std::string& font);

    std::string m_text;
    std::string m_drawText;
    Fw::AlignmentFlag m_textAlign;
    Point m_textOffset;
    stdext::boolean<false> m_textWrap;
    stdext::boolean<false> m_textVerticalAutoResize;
    stdext::boolean<false> m_textHorizontalAutoResize;
    stdext::boolean<false> m_textOnlyUpperCase;
    BitmapFontPtr m_font;
    std::vector<std::pair<int, Color>> m_textColors;
    std::vector<std::pair<int, Color>> m_drawTextColors;
    stdext::boolean<false> m_shadow;
    uint16 m_textOverflowLength;
    std::string m_textOverflowCharacter;

    std::vector<TextEvent> m_textEvents;
    std::vector<std::pair<Rect, std::string>> m_rectToWord;
    CoordsBuffer m_textUnderline;

public:
    void resizeToText() { setSize(getTextSize()); }
    void clearText() { setText(""); }

    void setText(std::string text, bool dontFireLuaCall = false);
    void setColoredText(const std::vector<std::string>& texts, bool dontFireLuaCall = false);
    void setTextAlign(Fw::AlignmentFlag align) { m_textAlign = align; updateText(); }
    void setTextOffset(const Point& offset) { m_textOffset = offset; updateText(); }
    void setTextWrap(bool textWrap) { m_textWrap = textWrap; updateText(); }
    void setTextAutoResize(bool textAutoResize) { m_textHorizontalAutoResize = textAutoResize; m_textVerticalAutoResize = textAutoResize; updateText(); }
    void setTextHorizontalAutoResize(bool textAutoResize) { m_textHorizontalAutoResize = textAutoResize; updateText(); }
    void setTextVerticalAutoResize(bool textAutoResize) { m_textVerticalAutoResize = textAutoResize; updateText(); }
    void setTextOnlyUpperCase(bool textOnlyUpperCase) { m_textOnlyUpperCase = textOnlyUpperCase; setText(m_text); }
    void setFont(const std::string& fontName);
    void setShadow(bool shadow) { m_shadow = shadow; }
    void setTextOverflowLength(uint16 length) { m_textOverflowLength = length; updateText(); }
    void setTextOverflowCharacter(std::string character) { m_textOverflowCharacter = character; updateText(); }
    void setLineHeight(std::string height);
    const SizeUnit& getLineHeight() const { return m_lineHeight; }

    std::string getText() { return m_text; }
    std::string getDrawText() { return m_drawText; }
    Fw::AlignmentFlag getTextAlign() { return m_textAlign; }
    Point getTextOffset() { return m_textOffset; }
    bool getTextWrap() { return m_textWrap; }
    std::string getFont() { return m_font->getName(); }
    Size getTextSize() { return m_font->calculateTextRectSize(m_drawText); }
    Size getRealTextSize() const { return m_realTextSize; }
    std::string getTextByPos(const Point& mousePos);
};

#endif
