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

#include "uiwidget.h"
#include "uihorizontallayout.h"
#include "uiverticallayout.h"
#include "uigridlayout.h"
#include "uianchorlayout.h"
#include "uiflexbox.h"
#include "uitranslator.h"

#include <framework/graphics/painter.h>
#include <framework/graphics/texture.h>
#include <framework/graphics/texturemanager.h>
#include <framework/html/htmlmanager.h>
#include <framework/html/htmlnode.h>
#include <framework/ui/uimanager.h>
#include <cstdlib>

namespace {
std::string htmlLower(std::string value)
{
    stdext::tolower(value);
    return value;
}

bool htmlIsAuto(std::string value)
{
    stdext::trim(value);
    stdext::tolower(value);
    return value == "auto";
}

bool htmlParseFloat(const std::string& token, float& value)
{
    char* end = nullptr;
    value = std::strtof(token.c_str(), &end);
    return end != token.c_str() && *end == '\0';
}

int htmlLength(const std::string& value)
{
    return static_cast<int>(stdext::to_number(value));
}

FlexDirection htmlFlexDirection(std::string value)
{
    value = htmlLower(value);
    if(value == "row-reverse") return FlexDirection::RowReverse;
    if(value == "column") return FlexDirection::Column;
    if(value == "column-reverse") return FlexDirection::ColumnReverse;
    return FlexDirection::Row;
}

FlexWrap htmlFlexWrap(std::string value)
{
    value = htmlLower(value);
    if(value == "wrap") return FlexWrap::Wrap;
    if(value == "wrap-reverse") return FlexWrap::WrapReverse;
    return FlexWrap::NoWrap;
}

JustifyContent htmlJustifyContent(std::string value)
{
    value = htmlLower(value);
    if(value == "flex-end" || value == "end" || value == "right") return JustifyContent::FlexEnd;
    if(value == "center") return JustifyContent::Center;
    if(value == "space-between") return JustifyContent::SpaceBetween;
    if(value == "space-around") return JustifyContent::SpaceAround;
    if(value == "space-evenly") return JustifyContent::SpaceEvenly;
    return JustifyContent::FlexStart;
}

AlignItems htmlAlignItems(std::string value)
{
    value = htmlLower(value);
    if(value == "flex-start" || value == "start" || value == "top") return AlignItems::FlexStart;
    if(value == "flex-end" || value == "end" || value == "bottom") return AlignItems::FlexEnd;
    if(value == "center") return AlignItems::Center;
    if(value == "baseline") return AlignItems::Baseline;
    return AlignItems::Stretch;
}

AlignContent htmlAlignContent(std::string value)
{
    value = htmlLower(value);
    if(value == "flex-start" || value == "start" || value == "top") return AlignContent::FlexStart;
    if(value == "flex-end" || value == "end" || value == "bottom") return AlignContent::FlexEnd;
    if(value == "center") return AlignContent::Center;
    if(value == "space-between") return AlignContent::SpaceBetween;
    if(value == "space-around") return AlignContent::SpaceAround;
    if(value == "space-evenly") return AlignContent::SpaceEvenly;
    return AlignContent::Stretch;
}

AlignSelf htmlAlignSelf(std::string value)
{
    value = htmlLower(value);
    if(value == "auto") return AlignSelf::Auto;
    if(value == "flex-start" || value == "start" || value == "top") return AlignSelf::FlexStart;
    if(value == "flex-end" || value == "end" || value == "bottom") return AlignSelf::FlexEnd;
    if(value == "center") return AlignSelf::Center;
    if(value == "baseline") return AlignSelf::Baseline;
    return AlignSelf::Stretch;
}

FlexBasis htmlFlexBasis(std::string value)
{
    stdext::trim(value);
    value = htmlLower(value);
    FlexBasis basis;
    if(value == "auto")
        basis.type = FlexBasis::Type::Auto;
    else if(value == "content")
        basis.type = FlexBasis::Type::Content;
    else if(stdext::ends_with(value, "%")) {
        basis.type = FlexBasis::Type::Percent;
        htmlParseFloat(value.substr(0, value.size() - 1), basis.value);
    } else {
        basis.type = FlexBasis::Type::Px;
        if(stdext::ends_with(value, "px"))
            value.resize(value.size() - 2);
        htmlParseFloat(value, basis.value);
    }
    return basis;
}

void htmlApplyFlex(UIWidget* widget, const std::string& value)
{
    std::vector<std::string> tokens;
    for(std::string token : stdext::split(value, " ")) {
        stdext::trim(token);
        if(!token.empty())
            tokens.push_back(token);
    }
    if(tokens.empty())
        return;
    if(tokens.size() == 1 && htmlLower(tokens[0]) == "auto") {
        widget->setFlexGrow(1.f);
        widget->setFlexShrink(1.f);
        widget->setFlexBasis(FlexBasis{FlexBasis::Type::Auto, 0.f});
        return;
    }
    if(tokens.size() == 1 && htmlLower(tokens[0]) == "none") {
        widget->setFlexGrow(0.f);
        widget->setFlexShrink(0.f);
        widget->setFlexBasis(FlexBasis{FlexBasis::Type::Auto, 0.f});
        return;
    }
    float grow = 0.f, shrink = 1.f;
    size_t index = 0;
    if(index < tokens.size() && htmlParseFloat(tokens[index], grow)) ++index;
    if(index < tokens.size() && htmlParseFloat(tokens[index], shrink)) ++index;
    const FlexBasis basis = index < tokens.size() ? htmlFlexBasis(tokens[index]) : FlexBasis{FlexBasis::Type::Px, 0.f};
    widget->setFlexGrow(grow);
    widget->setFlexShrink(shrink);
    widget->setFlexBasis(basis);
}
}

void UIWidget::initBaseStyle()
{
    m_backgroundColor = Color::alpha;
    m_borderColor.set(Color::black);
    m_iconColor = Color::white;
    m_color = Color::white;
    m_opacity = 1.0f;
    m_rotation = 0.0f;
    m_iconAlign = Fw::AlignNone;
    m_sizeOffset = Size(0, 0);

    // generate an unique id, this is need because anchored layouts find widgets by id
    static unsigned long id = 1;
    m_id = std::string("widget") + std::to_string(id++);
}

void UIWidget::parseBaseStyle(const OTMLNodePtr& styleNode)
{
    // parse lua variables and callbacks first
    for(const OTMLNodePtr& node : styleNode->children()) {
        // lua functions
        if(stdext::starts_with(node->tag(), "@")) {
            // load once
            if(m_firstOnStyle) {
                std::string funcName = node->tag().substr(1);
                std::string funcOrigin = std::string("@") + node->source() + ": [" + node->tag() + "]";
                g_lua.loadFunction(node->value(), funcOrigin);
                luaSetField(funcName);
            }
        // lua fields value
        } else if(stdext::starts_with(node->tag(), "&")) {
            std::string fieldName = node->tag().substr(1);
            std::string fieldOrigin = std::string("@") + node->source() + ": [" + node->tag() + "]";

            g_lua.evaluateExpression(node->value(), fieldOrigin);
            luaSetField(fieldName);
        }
    }
    // load styles used by all widgets
    const auto styleLength = [this](const std::string& value) {
        return isOnHtml() ? htmlLength(value) : stdext::safe_cast<int>(g_ui.getOTUIVarSafe(value));
    };
    for(const OTMLNodePtr& node : styleNode->children()) {
        if(node->tag() == "inherit-text") {
            if(m_htmlNode && node->value<bool>()) {
                bool isExpression = false;
                if(!m_htmlNode->getChildren().empty()) {
                    isExpression = m_htmlNode->getChildren().front()->isExpression();
                    if(isExpression) {
                        if(const auto root = g_html.getRoot(m_htmlRootId)) {
                            callLuaField("__applyOrBindHtmlAttribute", std::string("*text"),
                                         m_htmlNode->textContent(), false, root->moduleName,
                                         m_htmlNode->toString());
                        }
                    }
                }

                if(!isExpression)
                    setText(m_htmlNode->textContent());
                destroyChildren();
            }
        }
        else if(node->tag() == "color")
            setColor(node->value<Color>());
        else if(node->tag() == "x")
            setX(node->value<int>());
        else if(node->tag() == "y")
            setY(node->value<int>());
        else if(node->tag() == "pos")
            setPosition(node->value<Point>());
        else if (node->tag() == "width") {
            if(isOnHtml())
                applyDimension(true, node->value<std::string>());
            else
                setWidth(node->value<int>(), node->value().find('%') != std::string::npos);
        }
        else if (node->tag() == "height") {
            if(isOnHtml())
                applyDimension(false, node->value<std::string>());
            else
                setHeight(node->value<int>(), node->value().find('%') != std::string::npos);
        }
        else if(node->tag() == "min-width")
            setMinWidth(styleLength(node->value<std::string>()));
        else if(node->tag() == "max-width")
            setMaxWidth(styleLength(node->value<std::string>()));
        else if(node->tag() == "min-height")
            setMinHeight(styleLength(node->value<std::string>()));
        else if(node->tag() == "max-height")
            setMaxHeight(styleLength(node->value<std::string>()));
        else if(node->tag() == "rect")
            setRect(node->value<Rect>());
        else if(node->tag() == "background")
            setBackgroundColor(node->value<Color>());
        else if(node->tag() == "background-color")
            setBackgroundColor(node->value<Color>());
        else if(node->tag() == "background-offset-x")
            setBackgroundOffsetX(node->value<int>());
        else if(node->tag() == "background-offset-y")
            setBackgroundOffsetY(node->value<int>());
        else if(node->tag() == "background-offset")
            setBackgroundOffset(node->value<Point>());
        else if(node->tag() == "background-width")
            setBackgroundWidth(node->value<int>());
        else if(node->tag() == "background-height")
            setBackgroundHeight(node->value<int>());
        else if(node->tag() == "background-size")
            setBackgroundSize(node->value<Size>());
        else if(node->tag() == "background-rect")
            setBackgroundRect(node->value<Rect>());
        else if(node->tag() == "icon")
            setIcon(stdext::resolve_path(node->value(), node->source()));
        else if(node->tag() == "icon-source")
            setIcon(stdext::resolve_path(node->value(), node->source()));
        else if(node->tag() == "icon-color")
            setIconColor(node->value<Color>());
        else if(node->tag() == "icon-offset-x")
            setIconOffsetX(node->value<int>());
        else if(node->tag() == "icon-offset-y")
            setIconOffsetY(node->value<int>());
        else if(node->tag() == "icon-offset")
            setIconOffset(node->value<Point>());
        else if(node->tag() == "icon-width")
            setIconWidth(node->value<int>());
        else if(node->tag() == "icon-height")
            setIconHeight(node->value<int>());
        else if(node->tag() == "icon-size")
            setIconSize(node->value<Size>());
        else if(node->tag() == "icon-rect")
            setIconRect(node->value<Rect>());
        else if(node->tag() == "icon-clip")
            setIconClip(node->value<Rect>());
        else if(node->tag() == "icon-align")
            setIconAlign(Fw::translateAlignment(node->value()));
        else if (node->tag() == "icon-smooth")
            setIconSmooth(node->value<bool>());
        else if(node->tag() == "opacity")
            setOpacity(node->value<float>());
        else if (node->tag() == "rotation")
            setRotation(node->value<float>());
        else if(node->tag() == "enabled")
            setEnabled(node->value<bool>());
        else if(node->tag() == "visible")
            setVisible(node->value<bool>());
        else if(node->tag() == "visibility")
            setVisible(node->value<std::string>() != "hidden");
        else if(node->tag() == "checked")
            setChecked(node->value<bool>());
        else if(node->tag() == "draggable")
            setDraggable(node->value<bool>());
        else if(node->tag() == "on")
            setOn(node->value<bool>());
        else if(node->tag() == "focusable")
            setFocusable(node->value<bool>());
        else if (node->tag() == "auto-draw")
            setAutoDraw(node->value<bool>());
        else if(node->tag() == "auto-focus")
            setAutoFocusPolicy(Fw::translateAutoFocusPolicy(node->value()));
        else if(node->tag() == "phantom")
            setPhantom(node->value<bool>());
        else if(node->tag() == "pointer-events")
            setPhantom(node->value<std::string>() == "none");
        else if (node->tag() == "size") {
            // I know, setSize(node->value<Size>()) is better but this is a negligible and necessary change
            auto split = stdext::split(node->value(true), " ");
            if (split.size() == 2) {
                int width, height;
                if (stdext::cast(split[0], width)) {
                    setWidth(width, split[0].find('%') != std::string::npos);
                }

                if (stdext::cast(split[1], height)) {
                    setHeight(height, split[1].find('%') != std::string::npos);
                }
            }
        }
        else if(node->tag() == "width-offset")
            setWidthOffset(node->value<int>());
        else if(node->tag() == "height-offset")
            setHeightOffset(node->value<int>());
        else if(node->tag() == "size-offset")
            setSizeOffset(node->value<Size>());
        else if(node->tag() == "fixed-size")
            setFixedSize(node->value<bool>());
        else if(node->tag() == "clipping")
            setClipping(node->value<bool>());
        else if(node->tag() == "border") {
            auto split = stdext::split(node->value(true), " ");
            if(split.size() == 2) {
                setBorderWidth(styleLength(split[0]));
                setBorderColor(stdext::safe_cast<Color>(g_ui.getOTUIVarSafe(split[1])));
            } else
                throw OTMLException(node, "border param must have its width followed by its color");
        }
        else if(node->tag() == "border-width")
            setBorderWidth(styleLength(node->value<std::string>()));
        else if(node->tag() == "border-width-top" || node->tag() == "border-top-width")
            setBorderWidthTop(styleLength(node->value<std::string>()));
        else if(node->tag() == "border-width-right" || node->tag() == "border-right-width")
            setBorderWidthRight(styleLength(node->value<std::string>()));
        else if(node->tag() == "border-width-bottom" || node->tag() == "border-bottom-width")
            setBorderWidthBottom(styleLength(node->value<std::string>()));
        else if(node->tag() == "border-width-left" || node->tag() == "border-left-width")
            setBorderWidthLeft(styleLength(node->value<std::string>()));
        else if(node->tag() == "border-color")
            setBorderColor(node->value<Color>());
        else if(node->tag() == "border-color-top" || node->tag() == "border-top-color")
            setBorderColorTop(node->value<Color>());
        else if(node->tag() == "border-color-right" || node->tag() == "border-right-color")
            setBorderColorRight(node->value<Color>());
        else if(node->tag() == "border-color-bottom" || node->tag() == "border-bottom-color")
            setBorderColorBottom(node->value<Color>());
        else if(node->tag() == "border-color-left" || node->tag() == "border-left-color")
            setBorderColorLeft(node->value<Color>());
        else if(node->tag() == "top" || node->tag() == "bottom" || node->tag() == "left" || node->tag() == "right")
            setPositions(node->tag(), node->value<std::string>());
        else if(node->tag() == "display") {
            const std::string value = htmlLower(node->value<std::string>());
            DisplayType display = DisplayType::Initial;
            if(value == "none") display = DisplayType::None;
            else if(value == "block") display = DisplayType::Block;
            else if(value == "inline") display = DisplayType::Inline;
            else if(value == "inline-block") display = DisplayType::InlineBlock;
            else if(value == "flex") display = DisplayType::Flex;
            else if(value == "inline-flex") display = DisplayType::InlineFlex;
            else if(value == "grid") display = DisplayType::Grid;
            else if(value == "inline-grid") display = DisplayType::InlineGrid;
            else if(value == "table") display = DisplayType::Table;
            else if(value == "table-row-group") display = DisplayType::TableRowGroup;
            else if(value == "table-header-group") display = DisplayType::TableHeaderGroup;
            else if(value == "table-footer-group") display = DisplayType::TableFooterGroup;
            else if(value == "table-row") display = DisplayType::TableRow;
            else if(value == "table-cell") display = DisplayType::TableCell;
            else if(value == "table-column-group") display = DisplayType::TableColumnGroup;
            else if(value == "table-column") display = DisplayType::TableColumn;
            else if(value == "table-caption") display = DisplayType::TableCaption;
            else if(value == "list-item") display = DisplayType::ListItem;
            else if(value == "run-in") display = DisplayType::RunIn;
            else if(value == "contents") display = DisplayType::Contents;
            else if(value == "inherit") display = DisplayType::Inherit;
            setDisplay(display);
        }
        else if(node->tag() == "flex-direction")
            setFlexDirection(htmlFlexDirection(node->value<std::string>()));
        else if(node->tag() == "flex-wrap")
            setFlexWrap(htmlFlexWrap(node->value<std::string>()));
        else if(node->tag() == "flex-flow") {
            for(std::string part : stdext::split(node->value<std::string>(), " ")) {
                stdext::trim(part);
                const std::string value = htmlLower(part);
                if(value == "row" || value == "row-reverse" || value == "column" || value == "column-reverse")
                    setFlexDirection(htmlFlexDirection(value));
                else if(value == "wrap" || value == "nowrap" || value == "wrap-reverse")
                    setFlexWrap(htmlFlexWrap(value));
            }
        }
        else if(node->tag() == "justify-content")
            setJustifyContent(htmlJustifyContent(node->value<std::string>()));
        else if(node->tag() == "align-items")
            setAlignItems(htmlAlignItems(node->value<std::string>()));
        else if(node->tag() == "align-content")
            setAlignContent(htmlAlignContent(node->value<std::string>()));
        else if(node->tag() == "gap") {
            const int gap = htmlLength(node->value<std::string>());
            setGap(gap, gap);
        }
        else if(node->tag() == "row-gap")
            setRowGap(htmlLength(node->value<std::string>()));
        else if(node->tag() == "column-gap")
            setColumnGap(htmlLength(node->value<std::string>()));
        else if(node->tag() == "flex")
            htmlApplyFlex(this, node->value<std::string>());
        else if(node->tag() == "flex-grow") {
            float value = 0.f;
            htmlParseFloat(node->value<std::string>(), value);
            setFlexGrow(value);
        }
        else if(node->tag() == "flex-shrink") {
            float value = 1.f;
            htmlParseFloat(node->value<std::string>(), value);
            setFlexShrink(value);
        }
        else if(node->tag() == "flex-basis")
            setFlexBasis(htmlFlexBasis(node->value<std::string>()));
        else if(node->tag() == "order")
            setFlexOrder(htmlLength(node->value<std::string>()));
        else if(node->tag() == "align-self")
            setAlignSelf(htmlAlignSelf(node->value<std::string>()));
        else if(node->tag() == "overflow") {
            const std::string value = htmlLower(node->value<std::string>());
            OverflowType overflow = OverflowType::Visible;
            if(value == "hidden") overflow = OverflowType::Hidden;
            else if(value == "scroll") overflow = OverflowType::Scroll;
            else if(value == "auto") overflow = OverflowType::Auto;
            else if(value == "clip") overflow = OverflowType::Clip;
            setOverflow(overflow);
            setClipping(overflow == OverflowType::Hidden || overflow == OverflowType::Scroll ||
                        overflow == OverflowType::Auto || overflow == OverflowType::Clip);
        }
        else if(node->tag() == "position") {
            const std::string value = htmlLower(node->value<std::string>());
            setPositionType(value == "absolute" ? PositionType::Absolute : value == "relative" ? PositionType::Relative : PositionType::Static);
        }
        else if(node->tag() == "float") {
            const std::string value = htmlLower(node->value<std::string>());
            setFloat(value == "left" ? FloatType::Left : value == "right" ? FloatType::Right :
                value == "inline-start" ? FloatType::InlineStart : value == "inline-end" ? FloatType::InlineEnd : FloatType::None);
        }
        else if(node->tag() == "clear") {
            const std::string value = htmlLower(node->value<std::string>());
            setClear(value == "left" ? ClearType::Left : value == "right" ? ClearType::Right :
                value == "both" ? ClearType::Both : value == "inline-start" ? ClearType::InlineStart :
                value == "inline-end" ? ClearType::InlineEnd : ClearType::None);
        }
        else if(node->tag() == "justify-items") {
            const std::string value = htmlLower(node->value<std::string>());
            setJustifyItems(value == "center" ? JustifyItemsType::Center :
                (value == "right" || value == "flex-end" || value == "end") ? JustifyItemsType::Right :
                (value == "left" || value == "flex-start" || value == "start") ? JustifyItemsType::Left :
                JustifyItemsType::Normal);
        }
        else if(node->tag() == "line-height")
            setLineHeight(node->value<std::string>());
        else if(node->tag() == "margin-top") {
            const bool automatic = isOnHtml() && htmlIsAuto(node->value<std::string>());
            setMarginTopAuto(automatic);
            setMarginTop(automatic ? 0 : styleLength(node->value<std::string>()));
        }
        else if(node->tag() == "margin-right") {
            const bool automatic = isOnHtml() && htmlIsAuto(node->value<std::string>());
            setMarginRightAuto(automatic);
            setMarginRight(automatic ? 0 : styleLength(node->value<std::string>()));
        }
        else if(node->tag() == "margin-bottom") {
            const bool automatic = isOnHtml() && htmlIsAuto(node->value<std::string>());
            setMarginBottomAuto(automatic);
            setMarginBottom(automatic ? 0 : styleLength(node->value<std::string>()));
        }
        else if(node->tag() == "margin-left") {
            const bool automatic = isOnHtml() && htmlIsAuto(node->value<std::string>());
            setMarginLeftAuto(automatic);
            setMarginLeft(automatic ? 0 : styleLength(node->value<std::string>()));
        }
        else if(node->tag() == "margin") {
            std::vector<std::string> values;
            for(std::string value : stdext::split(node->value(true), " ")) {
                stdext::trim(value);
                if(!value.empty())
                    values.push_back(value);
            }
            if(values.empty())
                continue;
            const std::string top = values[0];
            const std::string right = values.size() == 1 ? top : values[1];
            const std::string bottom = values.size() < 3 ? top : values[2];
            const std::string left = values.size() < 2 ? top : values.size() == 2 ? right : values.size() == 3 ? right : values[3];
            const bool topAuto = isOnHtml() && htmlIsAuto(top);
            const bool rightAuto = isOnHtml() && htmlIsAuto(right);
            const bool bottomAuto = isOnHtml() && htmlIsAuto(bottom);
            const bool leftAuto = isOnHtml() && htmlIsAuto(left);
            setMarginTopAuto(topAuto); setMarginTop(topAuto ? 0 : styleLength(top));
            setMarginRightAuto(rightAuto); setMarginRight(rightAuto ? 0 : styleLength(right));
            setMarginBottomAuto(bottomAuto); setMarginBottom(bottomAuto ? 0 : styleLength(bottom));
            setMarginLeftAuto(leftAuto); setMarginLeft(leftAuto ? 0 : styleLength(left));
        }
        else if(node->tag() == "padding-top")
            setPaddingTop(styleLength(node->value<std::string>()));
        else if(node->tag() == "padding-right")
            setPaddingRight(styleLength(node->value<std::string>()));
        else if(node->tag() == "padding-bottom")
            setPaddingBottom(styleLength(node->value<std::string>()));
        else if(node->tag() == "padding-left")
            setPaddingLeft(styleLength(node->value<std::string>()));
        else if(node->tag() == "padding") {
            std::vector<std::string> values;
            for(std::string value : stdext::split(node->value(true), " ")) {
                stdext::trim(value);
                if(!value.empty())
                    values.push_back(value);
            }
            if(values.empty())
                continue;
            const int top = styleLength(values[0]);
            const int right = styleLength(values.size() == 1 ? values[0] : values[1]);
            const int bottom = styleLength(values.size() < 3 ? values[0] : values[2]);
            const int left = styleLength(values.size() < 2 ? values[0] : values.size() == 2 ? values[1] : values.size() == 3 ? values[1] : values[3]);
            setPaddingTop(top);
            setPaddingRight(right);
            setPaddingBottom(bottom);
            setPaddingLeft(left);
        }
        // layouts
        else if(node->tag() == "layout") {
            std::string layoutType;
            if(node->hasValue())
                layoutType = node->value();
            else
                layoutType = node->valueAt<std::string>("type", "");

            if(!layoutType.empty()) {
                UILayoutPtr layout;
                if(layoutType == "horizontalBox")
                    layout = std::make_shared<UIHorizontalLayout>(static_self_cast<UIWidget>());
                else if(layoutType == "verticalBox")
                    layout = std::make_shared<UIVerticalLayout>(static_self_cast<UIWidget>());
                else if(layoutType == "grid")
                    layout = std::make_shared<UIGridLayout>(static_self_cast<UIWidget>());
                else if(layoutType == "anchor")
                    layout = std::make_shared<UIAnchorLayout>(static_self_cast<UIWidget>());
                else if(layoutType == "flex")
                    layout = std::make_shared<UIFlexBox>(static_self_cast<UIWidget>());
                else
                    throw OTMLException(node, "cannot determine layout type");
                setLayout(layout);
            }

            if(node->hasChildren())
                m_layout->applyStyle(node);
        }
        // anchors
        else if(stdext::starts_with(node->tag(), "anchors.")) {
            UIWidgetPtr parent = getParent();
            if(!parent) {
                if(m_firstOnStyle)
                    throw OTMLException(node, "cannot create anchor, there is no parent widget!");
                else
                    continue;
            }

            UILayoutPtr layout = parent->getLayout();
            UIAnchorLayoutPtr anchorLayout;
            if(layout->isUIAnchorLayout())
                anchorLayout = layout->static_self_cast<UIAnchorLayout>();

            if(!anchorLayout)
                throw OTMLException(node, "cannot create anchor, the parent widget doesn't use anchor layout!");

            std::string what = node->tag().substr(8);
            if(what == "fill") {
                fill(node->value());
            } else if(what == "centerIn") {
                centerIn(node->value());
            } else {
                Fw::AnchorEdge anchoredEdge = Fw::translateAnchorEdge(what);

                if(node->value() == "none") {
                    removeAnchor(anchoredEdge);
                } else {
                    std::vector<std::string> split = stdext::split(node->value(true), ".");
                    if(split.size() != 2)
                        throw OTMLException(node, "invalid anchor description");

                    std::string hookedWidgetId = g_ui.getOTUIVarSafe(split[0]);
                    Fw::AnchorEdge hookedEdge = Fw::translateAnchorEdge(g_ui.getOTUIVarSafe(split[1]));

                    if(anchoredEdge == Fw::AnchorNone)
                        throw OTMLException(node, "invalid anchor edge");

                    if(hookedEdge == Fw::AnchorNone)
                        throw OTMLException(node, "invalid anchor target edge");

                    addAnchor(anchoredEdge, hookedWidgetId, hookedEdge);
                }
            }
        }
        else if (node->tag() == "cursor")
            setCursor(node->value());
        else if (node->tag() == "change-cursor-image")
            setChangeCursorImage(node->value<bool>());
        else if (node->tag() == "events") {
            auto split = stdext::split(node->value(true), " ");
            for (const auto& event : split) {
                auto it = eventMap.find(event);
                if (it != eventMap.end()) {
                    setEventListener(it->second);
                }
            }
        }
    }
}

void UIWidget::drawBackground(const Rect& screenCoords)
{
    if(m_backgroundColor.aF() > 0.0f) {
        Rect drawRect = screenCoords;
        drawRect.translate(m_backgroundRect.topLeft());
        if(m_backgroundRect.isValid())
            drawRect.resize(m_backgroundRect.size());
        g_drawQueue->addFilledRect(drawRect, m_backgroundColor);
    }
}

void UIWidget::drawBorder(const Rect& screenCoords)
{
    // top
    if(m_borderWidth.top > 0) {
        Rect borderRect(screenCoords.topLeft(), screenCoords.width(), m_borderWidth.top);
        g_drawQueue->addFilledRect(borderRect, m_borderColor.top);
    }
    
    // right
    if(m_borderWidth.right > 0) {
        Rect borderRect(screenCoords.topRight() - Point(m_borderWidth.right - 1, 0), m_borderWidth.right, screenCoords.height());
        g_drawQueue->addFilledRect(borderRect, m_borderColor.right);
    }

    // bottom
    if(m_borderWidth.bottom > 0) {
        Rect borderRect(screenCoords.bottomLeft() - Point(0, m_borderWidth.bottom - 1), screenCoords.width(), m_borderWidth.bottom);
        g_drawQueue->addFilledRect(borderRect, m_borderColor.bottom);
    }

    // left
    if(m_borderWidth.left > 0) {
        Rect borderRect(screenCoords.topLeft(), m_borderWidth.left, screenCoords.height());
        g_drawQueue->addFilledRect(borderRect, m_borderColor.left);
    }
}

void UIWidget::drawIcon(const Rect& screenCoords)
{
    if(m_icon) {
        m_icon->setSmooth(m_iconSmooth);
        Rect drawRect;
        if(m_iconRect.isValid()) {
            drawRect = screenCoords;
            drawRect.translate(m_iconRect.topLeft());
            drawRect.resize(m_iconRect.size());
        } else {
            drawRect.resize(m_iconClipRect.size());

            if(m_iconAlign == Fw::AlignNone)
                drawRect.moveCenter(screenCoords.center());
            else
                drawRect.alignIn(screenCoords, m_iconAlign);
        }
        drawRect.translate(m_iconOffset);
        g_drawQueue->addTexturedRect(drawRect, m_icon, m_iconClipRect, m_iconColor);
    }
}

void UIWidget::setIcon(const std::string& iconFile)
{
    if (iconFile.empty()) {
        m_icon = nullptr;
        m_iconPath = "";
    }
    else {
        m_icon = g_textures.getTexture(iconFile);
        m_iconPath = iconFile;
    }
    if(m_icon && !m_iconClipRect.isValid())
        m_iconClipRect = Rect(0, 0, m_icon->getSize());
}
