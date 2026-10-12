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

#include "uianchorlayout.h"
#include "uiwidget.h"

UIWidgetPtr UIAnchor::getHookedWidget(const UIWidgetPtr& widget, const UIWidgetPtr& parentWidget)
{
    // determine hooked widget
    UIWidgetPtr hookedWidget;
    if(parentWidget) {
        if(m_hookedWidgetId == "parent")
            hookedWidget = parentWidget;
        else if(m_hookedWidgetId == "next")
            hookedWidget = parentWidget->getChildAfter(widget);
        else if(m_hookedWidgetId == "prev")
            hookedWidget = parentWidget->getChildBefore(widget);
        else
            hookedWidget = parentWidget->getChildById(m_hookedWidgetId);
    }
    return hookedWidget;
}

int UIAnchor::getHookedPoint(const UIWidgetPtr& hookedWidget, const UIWidgetPtr& parentWidget)
{
    // determine hooked widget edge point
    Rect hookedWidgetRect = hookedWidget->getRect();
    if(hookedWidget == parentWidget)
        hookedWidgetRect = parentWidget->getPaddingRect();

    int point = 0;
    switch(m_hookedEdge) {
        case Fw::AnchorLeft:
            point = hookedWidgetRect.left();
            break;
        case Fw::AnchorRight:
            point = hookedWidgetRect.right();
            break;
        case Fw::AnchorTop:
            point = hookedWidgetRect.top();
            break;
        case Fw::AnchorBottom:
            point = hookedWidgetRect.bottom();
            break;
        case Fw::AnchorHorizontalCenter:
            point = hookedWidgetRect.horizontalCenter();
            break;
        case Fw::AnchorVerticalCenter:
            point = hookedWidgetRect.verticalCenter();
            break;
        default:
            // must never happens
            VALIDATE(false);
            break;
    }

    if(hookedWidget == parentWidget) {
        switch(m_hookedEdge) {
            case Fw::AnchorLeft:
            case Fw::AnchorRight:
            case Fw::AnchorHorizontalCenter:
                point -= parentWidget->getVirtualOffset().x;
                break;
            case Fw::AnchorBottom:
            case Fw::AnchorTop:
            case Fw::AnchorVerticalCenter:
                point -= parentWidget->getVirtualOffset().y;
                break;
            default:
                break;
        }
    }

    return point;
}

void UIAnchorGroup::addAnchor(const UIAnchorPtr& anchor)
{
    // duplicated anchors must be replaced
    for(UIAnchorPtr& other : m_anchors) {
        if(other->getAnchoredEdge() == anchor->getAnchoredEdge()) {
            other = anchor;
            return;
        }
    }
    m_anchors.push_back(anchor);
}

void UIAnchorLayout::addAnchor(const UIWidgetPtr& anchoredWidget, Fw::AnchorEdge anchoredEdge,
                               const std::string& hookedWidgetId, Fw::AnchorEdge hookedEdge)
{
    if(!anchoredWidget)
        return;

    VALIDATE(anchoredWidget != getParentWidget());

    auto anchor = std::make_shared<UIAnchor>(anchoredEdge, hookedWidgetId, hookedEdge);
    UIAnchorGroupPtr& anchorGroup = m_anchorsGroups[anchoredWidget];
    if(!anchorGroup)
        anchorGroup = std::make_shared<UIAnchorGroup>();

    anchorGroup->addAnchor(anchor);

    // layout must be updated because a new anchor got in
    update();
}

void UIAnchorLayout::removeAnchors(const UIWidgetPtr& anchoredWidget)
{
    m_anchorsGroups.erase(anchoredWidget);
    update();
}

bool UIAnchorLayout::hasAnchors(const UIWidgetPtr& anchoredWidget)
{
    return m_anchorsGroups.find(anchoredWidget) != m_anchorsGroups.end();
}

void UIAnchorLayout::centerIn(const UIWidgetPtr& anchoredWidget, const std::string& hookedWidgetId)
{
    addAnchor(anchoredWidget, Fw::AnchorHorizontalCenter, hookedWidgetId, Fw::AnchorHorizontalCenter);
    addAnchor(anchoredWidget, Fw::AnchorVerticalCenter, hookedWidgetId, Fw::AnchorVerticalCenter);
}

void UIAnchorLayout::fill(const UIWidgetPtr& anchoredWidget, const std::string& hookedWidgetId)
{
    addAnchor(anchoredWidget, Fw::AnchorLeft, hookedWidgetId, Fw::AnchorLeft);
    addAnchor(anchoredWidget, Fw::AnchorRight, hookedWidgetId, Fw::AnchorRight);
    addAnchor(anchoredWidget, Fw::AnchorTop, hookedWidgetId, Fw::AnchorTop);
    addAnchor(anchoredWidget, Fw::AnchorBottom, hookedWidgetId, Fw::AnchorBottom);
}

void UIAnchorLayout::addWidget(const UIWidgetPtr& widget)
{
    update();
}

void UIAnchorLayout::removeWidget(const UIWidgetPtr& widget)
{
    removeAnchors(widget);
}

static bool isHtmlInlineWidget(UIWidget* widget)
{
    const auto display = widget->getDisplay();
    return display == DisplayType::Inline || display == DisplayType::InlineBlock;
}

bool UIAnchorLayout::updateWidget(const UIWidgetPtr& widget, const UIAnchorGroupPtr& anchorGroup, UIWidgetPtr first)
{
    UIWidgetPtr parentWidget = getParentWidget();
    if(!parentWidget)
        return false;

    if(first == widget) {
        g_logger.error(stdext::format("child '%s' of parent widget '%s' is recursively anchored to itself, please fix this", widget->getId(), parentWidget->getId()));
        return false;
    }

    if(!first)
        first = widget;

    if (widget->isSizePercantage()) {
        Rect paddingRect = parentWidget->getPaddingRect();
        widget->updatePercentSize(paddingRect.size());
    }

    Rect newRect = widget->getRect();
    bool verticalMoved = false;
    bool horizontalMoved = false;

    int realMarginTop = 0;
    int centerOffset = 0;
    if(widget->isOnHtml()) {
        const bool isInline = isHtmlInlineWidget(widget.get());
        bool calculateMargin = false;
        bool calculateCenter = false;
        const auto& previous = widget->getPrevWidget();

        if((!previous || previous->getDisplay() == DisplayType::Block) && isInline) {
            realMarginTop = widget->getDisplay() == DisplayType::InlineBlock ? widget->getMarginTop() : 0;
            calculateMargin = true;
        }

        if(isInline && (parentWidget->getTextAlign() == Fw::AlignCenter ||
                        parentWidget->getJustifyItems() == JustifyItemsType::Center)) {
            if(!previous || !isHtmlInlineWidget(previous.get())) {
                calculateCenter = true;
                centerOffset += (widget->getPaddingLeft() + widget->getPaddingRight()) / 2;
            }
        }

        if(calculateMargin || calculateCenter) {
            for(auto next = widget->getNextWidget();
                next && next->isAnchorable() && next->getPositionType() != PositionType::Absolute && isHtmlInlineWidget(next.get());
                next = next->getNextWidget()) {
                if(calculateCenter)
                    centerOffset += next->getWidth() + next->getMarginLeft() + next->getPaddingLeft() + next->getPaddingRight();
                if(calculateMargin && next->getDisplay() == DisplayType::InlineBlock)
                    realMarginTop = std::max(realMarginTop, next->getMarginTop());
            }
        }
    }

    const auto& virtualParentWidget = widget->getPositionType() == PositionType::Absolute ? widget->getVirtualParent() : nullptr;

    // calculates new rect based on anchors
    for(const UIAnchorPtr& anchor : anchorGroup->getAnchors()) {
        // skip invalid anchors
        if(anchor->getHookedEdge() == Fw::AnchorNone)
            continue;

        if(widget->getPositionType() == PositionType::Absolute) {
            const auto edge = anchor->getAnchoredEdge();
            const auto& positions = widget->getPositions();
            const bool usesOffset =
                (edge == Fw::AnchorTop && positions.top.unit != Unit::Auto) ||
                (edge == Fw::AnchorLeft && positions.left.unit != Unit::Auto) ||
                (edge == Fw::AnchorRight && positions.right.unit != Unit::Auto) ||
                (edge == Fw::AnchorBottom && positions.bottom.unit != Unit::Auto);
            parentWidget = usesOffset ? virtualParentWidget : getParentWidget();
        }

        // determine hooked widget
        UIWidgetPtr hookedWidget = anchor->getHookedWidget(widget, parentWidget);

        // skip invalid anchors
        if(!hookedWidget)
            continue;

        if(hookedWidget != getParentWidget()) {
            // update this hooked widget anchors
            auto it = m_anchorsGroups.find(hookedWidget);
            if(it != m_anchorsGroups.end()) {
                const UIAnchorGroupPtr& hookedAnchorGroup = it->second;
                if(!hookedAnchorGroup->isUpdated())
                    updateWidget(hookedWidget, hookedAnchorGroup, first);
            }
        }

        int point = anchor->getHookedPoint(hookedWidget, parentWidget);

        switch(anchor->getAnchoredEdge()) {
            case Fw::AnchorHorizontalCenter:
            {
                int margin = widget->getMarginLeft() - widget->getMarginRight();
                if(widget->isOnHtml() && centerOffset > 0)
                    margin = -(centerOffset / 2);
                newRect.moveHorizontalCenter(point + margin);
                horizontalMoved = true;
                break;
            }
            case Fw::AnchorLeft:
            {
                int margin = widget->getMarginLeft();
                if(widget->isOnHtml()) {
                    if(parentWidget != hookedWidget && isHtmlInlineWidget(hookedWidget.get()))
                        margin += hookedWidget->getMarginRight();

                    if(widget->getPositionType() == PositionType::Relative || widget->getPositionType() == PositionType::Absolute) {
                        if(widget->getPositions().left.unit != Unit::Auto)
                            margin -= hookedWidget->getPaddingLeft();
                        margin += widget->getPositions().left.value;
                    }

                    if(anchor->getAnchoredEdge() != anchor->getHookedEdge())
                        ++margin;
                }
                if(!horizontalMoved) {
                    newRect.moveLeft(point + margin);
                    horizontalMoved = true;
                } else
                    newRect.setLeft(point + margin);
                break;
            }
            case Fw::AnchorRight:
            {
                int margin = widget->getMarginRight();
                if(widget->isOnHtml()) {
                    if(widget->getPositionType() == PositionType::Absolute && widget->getPositions().right.unit != Unit::Auto)
                        margin -= hookedWidget->getPaddingRight();

                    if(widget->getPositions().left.unit == Unit::Auto &&
                       (widget->getPositionType() == PositionType::Relative || widget->getPositionType() == PositionType::Absolute))
                        margin += widget->getPositions().right.value;
                }
                if(!horizontalMoved) {
                    newRect.moveRight(point - margin);
                    horizontalMoved = true;
                } else
                    newRect.setRight(point - margin);
                break;
            }
            case Fw::AnchorVerticalCenter:
                newRect.moveVerticalCenter(point + widget->getMarginTop() - widget->getMarginBottom());
                verticalMoved = true;
                break;
            case Fw::AnchorTop:
            {
                int margin = widget->getMarginTop();
                if(widget->isOnHtml()) {
                    if(parentWidget != hookedWidget) {
                        if(isHtmlInlineWidget(widget.get())) {
                            margin = realMarginTop;
                        } else if(widget->getFloat() != FloatType::None) {
                            margin -= hookedWidget->getMarginTop();
                        } else if(hookedWidget->getDisplay() == DisplayType::Block) {
                            if(widget->getMarginBottom() > 0 && hookedWidget->getMarginBottom() > 0)
                                margin = std::max(margin, hookedWidget->getMarginBottom());
                            else
                                margin += hookedWidget->getMarginBottom();
                        }

                        if(hookedWidget->getPositionType() == PositionType::Relative)
                            margin -= hookedWidget->getPositions().top.value;
                    } else if(isHtmlInlineWidget(widget.get())) {
                        margin = realMarginTop;
                    }

                    if(isHtmlInlineWidget(widget.get()))
                        margin += widget->getLineHeight().valueCalculed - hookedWidget->getLineHeight().valueCalculed;

                    if(widget->getPositionType() == PositionType::Relative || widget->getPositionType() == PositionType::Absolute) {
                        if(widget->getPositions().top.unit != Unit::Auto)
                            margin -= hookedWidget->getPaddingTop();
                        margin += widget->getPositions().top.value;
                    }

                    if(anchor->getAnchoredEdge() != anchor->getHookedEdge())
                        ++margin;
                }
                if(!verticalMoved) {
                    newRect.moveTop(point + margin);
                    verticalMoved = true;
                } else
                    newRect.setTop(point + margin);
                break;
            }
            case Fw::AnchorBottom:
            {
                int margin = widget->getMarginBottom();
                if(widget->isOnHtml()) {
                    if(parentWidget != hookedWidget) {
                        if(widget->getFloat() != FloatType::None) {
                            margin -= hookedWidget->getMarginBottom();
                        } else if(widget->getDisplay() == DisplayType::Inline) {
                            margin = 0;
                        } else if(hookedWidget->getDisplay() == DisplayType::Block) {
                            if(widget->getMarginBottom() > 0 && hookedWidget->getMarginTop() > 0)
                                margin = std::max(margin, hookedWidget->getMarginTop());
                            else
                                margin += hookedWidget->getMarginTop();
                        }

                        if(hookedWidget->getPositionType() == PositionType::Relative)
                            margin += hookedWidget->getPositions().bottom.value;
                    }

                    if(widget->getPositionType() == PositionType::Absolute && widget->getPositions().bottom.unit != Unit::Auto)
                        margin -= hookedWidget->getPaddingBottom();

                    if(widget->getPositions().top.unit == Unit::Auto &&
                       (widget->getPositionType() == PositionType::Relative || widget->getPositionType() == PositionType::Absolute))
                        margin += widget->getPositions().bottom.value;
                }
                if(!verticalMoved) {
                    newRect.moveBottom(point - margin);
                    verticalMoved = true;
                } else
                    newRect.setBottom(point - margin);
                break;
            }
            default:
                break;
        }
    }

    bool changed = false;
    if(widget->setRect(newRect))
        changed = true;
    anchorGroup->setUpdated(true);
    return changed;
}

bool UIAnchorLayout::internalUpdate()
{
    bool changed = false;

    // reset all anchors groups update state
    for(auto& it : m_anchorsGroups) {
        const UIAnchorGroupPtr& anchorGroup = it.second;
        anchorGroup->setUpdated(false);
    }

    // update all anchors
    for(auto& it : m_anchorsGroups) {
        const UIWidgetPtr& widget = it.first;
        const UIAnchorGroupPtr& anchorGroup = it.second;
        if(!anchorGroup->isUpdated()) {
            if(updateWidget(widget, anchorGroup))
                changed = true;
        }
    }

    return changed;
}
