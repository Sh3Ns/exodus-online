#ifndef UIFLEXBOX_H
#define UIFLEXBOX_H

#include "uilayout.h"

enum class UIFlexDirection {
    ROW,
    COLUMN
};

enum class UIFlexAlignItems {
    START,
    STRETCH,
    CENTER
};

// @bindclass
class UIFlexBox : public UILayout
{
public:
    UIFlexBox(UIWidgetPtr parentWidget);

    void applyStyle(const OTMLNodePtr& styleNode);
    void removeWidget(const UIWidgetPtr& widget);
    void addWidget(const UIWidgetPtr& widget);

    void setFlexDirection(UIFlexDirection direction) { m_flexDirection = direction; update(); }
    void setAlignItems(UIFlexAlignItems align) { m_alignItems = align; update(); }
    void setSpacing(int spacing) { m_spacing = spacing; update(); }
    void setAutoSpacing(bool spacing) { m_autoSpacing = spacing; update(); }

    UIFlexDirection getFlexDirection() { return m_flexDirection; }
    UIFlexAlignItems getAlignItems() { return m_alignItems; }
    int getSpacing() { return m_spacing; }
    bool getAutoSpacing() { return m_autoSpacing; }

    virtual bool isUIFlexBox() { return true; }

protected:
    bool internalUpdate();

private:
    UIFlexDirection m_flexDirection;
    UIFlexAlignItems m_alignItems;
    int m_spacing;
    stdext::boolean<false> m_autoSpacing;
};

#endif
