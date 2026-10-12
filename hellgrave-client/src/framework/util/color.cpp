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

#include "color.h"

// NOTE: AABBGGRR order
const Color Color::alpha      = 0x00000000U;
const Color Color::white      = 0xffffffff;
const Color Color::black      = 0xff000000;
const Color Color::red        = 0xff0000ff;
const Color Color::darkRed    = 0xff000080;
const Color Color::green      = 0xff00ff00;
const Color Color::darkGreen  = 0xff008000;
const Color Color::blue       = 0xffff0000;
const Color Color::darkBlue   = 0xff800000;
const Color Color::pink       = 0xffff00ff;
const Color Color::darkPink   = 0xff800080;
const Color Color::yellow     = 0xff00ffff;
const Color Color::darkYellow = 0xff008080;
const Color Color::teal       = 0xffffff00;
const Color Color::darkTeal   = 0xff808000;
const Color Color::gray       = 0xffa0a0a0;
const Color Color::darkGray   = 0xff808080;
const Color Color::lightGray  = 0xffc0c0c0;
const Color Color::orange     = 0xff008cff;

bool Color::parseCssName(const std::string& name, Color& color)
{
    struct CssColor {
        const char* name;
        uint32 rgb;
    };

    // CSS Color Module named colors. Values are stored as RRGGBB.
    static const CssColor colors[] = {
        {"aliceblue", 0xF0F8FF}, {"antiquewhite", 0xFAEBD7}, {"aqua", 0x00FFFF},
        {"aquamarine", 0x7FFFD4}, {"azure", 0xF0FFFF}, {"beige", 0xF5F5DC},
        {"bisque", 0xFFE4C4}, {"blanchedalmond", 0xFFEBCD}, {"blueviolet", 0x8A2BE2},
        {"brown", 0xA52A2A}, {"burlywood", 0xDEB887}, {"cadetblue", 0x5F9EA0},
        {"chartreuse", 0x7FFF00}, {"chocolate", 0xD2691E}, {"coral", 0xFF7F50},
        {"cornflowerblue", 0x6495ED}, {"cornsilk", 0xFFF8DC}, {"crimson", 0xDC143C},
        {"cyan", 0x00FFFF}, {"darkblue", 0x00008B}, {"darkcyan", 0x008B8B}, {"darkgoldenrod", 0xB8860B},
        {"darkgray", 0xA9A9A9}, {"darkgreen", 0x006400}, {"darkgrey", 0xA9A9A9}, {"darkkhaki", 0xBDB76B},
        {"darkmagenta", 0x8B008B}, {"darkolivegreen", 0x556B2F}, {"darkorange", 0xFF8C00},
        {"darkorchid", 0x9932CC}, {"darkred", 0x8B0000}, {"darksalmon", 0xE9967A}, {"darkseagreen", 0x8FBC8F},
        {"darkslateblue", 0x483D8B}, {"darkslategray", 0x2F4F4F}, {"darkslategrey", 0x2F4F4F},
        {"darkturquoise", 0x00CED1}, {"darkviolet", 0x9400D3}, {"deeppink", 0xFF1493},
        {"deepskyblue", 0x00BFFF}, {"dimgray", 0x696969}, {"dimgrey", 0x696969},
        {"dodgerblue", 0x1E90FF}, {"firebrick", 0xB22222}, {"floralwhite", 0xFFFAF0},
        {"forestgreen", 0x228B22}, {"fuchsia", 0xFF00FF}, {"gainsboro", 0xDCDCDC},
        {"ghostwhite", 0xF8F8FF}, {"gold", 0xFFD700}, {"goldenrod", 0xDAA520},
        {"greenyellow", 0xADFF2F}, {"grey", 0x808080}, {"honeydew", 0xF0FFF0},
        {"hotpink", 0xFF69B4}, {"indianred", 0xCD5C5C}, {"indigo", 0x4B0082},
        {"ivory", 0xFFFFF0}, {"khaki", 0xF0E68C}, {"lavender", 0xE6E6FA},
        {"lavenderblush", 0xFFF0F5}, {"lawngreen", 0x7CFC00}, {"lemonchiffon", 0xFFFACD},
        {"lightblue", 0xADD8E6}, {"lightcoral", 0xF08080}, {"lightcyan", 0xE0FFFF},
        {"lightgoldenrodyellow", 0xFAFAD2}, {"lightgray", 0xD3D3D3}, {"lightgreen", 0x90EE90}, {"lightgrey", 0xD3D3D3},
        {"lightpink", 0xFFB6C1}, {"lightsalmon", 0xFFA07A}, {"lightseagreen", 0x20B2AA},
        {"lightskyblue", 0x87CEFA}, {"lightslategray", 0x778899}, {"lightslategrey", 0x778899},
        {"lightsteelblue", 0xB0C4DE}, {"lightyellow", 0xFFFFE0}, {"lime", 0x00FF00},
        {"limegreen", 0x32CD32}, {"linen", 0xFAF0E6}, {"magenta", 0xFF00FF},
        {"maroon", 0x800000}, {"mediumaquamarine", 0x66CDAA}, {"mediumblue", 0x0000CD},
        {"mediumorchid", 0xBA55D3}, {"mediumpurple", 0x9370DB}, {"mediumseagreen", 0x3CB371},
        {"mediumslateblue", 0x7B68EE}, {"mediumspringgreen", 0x00FA9A}, {"mediumturquoise", 0x48D1CC},
        {"mediumvioletred", 0xC71585}, {"midnightblue", 0x191970}, {"mintcream", 0xF5FFFA},
        {"mistyrose", 0xFFE4E1}, {"moccasin", 0xFFE4B5}, {"navajowhite", 0xFFDEAD},
        {"navy", 0x000080}, {"oldlace", 0xFDF5E6}, {"olive", 0x808000},
        {"olivedrab", 0x6B8E23}, {"orangered", 0xFF4500}, {"orchid", 0xDA70D6},
        {"palegoldenrod", 0xEEE8AA}, {"palegreen", 0x98FB98}, {"paleturquoise", 0xAFEEEE},
        {"palevioletred", 0xDB7093}, {"papayawhip", 0xFFEFD5}, {"peachpuff", 0xFFDAB9},
        {"peru", 0xCD853F}, {"plum", 0xDDA0DD}, {"powderblue", 0xB0E0E6},
        {"purple", 0x800080}, {"rebeccapurple", 0x663399}, {"rosybrown", 0xBC8F8F},
        {"royalblue", 0x4169E1}, {"saddlebrown", 0x8B4513}, {"salmon", 0xFA8072},
        {"sandybrown", 0xF4A460}, {"seagreen", 0x2E8B57}, {"seashell", 0xFFF5EE},
        {"sienna", 0xA0522D}, {"silver", 0xC0C0C0}, {"skyblue", 0x87CEEB},
        {"slateblue", 0x6A5ACD}, {"slategray", 0x708090}, {"slategrey", 0x708090},
        {"snow", 0xFFFAFA}, {"springgreen", 0x00FF7F}, {"steelblue", 0x4682B4},
        {"tan", 0xD2B48C}, {"thistle", 0xD8BFD8}, {"tomato", 0xFF6347},
        {"turquoise", 0x40E0D0}, {"violet", 0xEE82EE}, {"wheat", 0xF5DEB3},
        {"whitesmoke", 0xF5F5F5}, {"yellowgreen", 0x9ACD32}
    };

    for(const auto& entry : colors) {
        if(name == entry.name) {
            color.setRGBA(static_cast<uint8>((entry.rgb >> 16) & 0xff),
                          static_cast<uint8>((entry.rgb >> 8) & 0xff),
                          static_cast<uint8>(entry.rgb & 0xff), 0xff);
            return true;
        }
    }
    return false;
}

Color::Color(const std::string& coltext)
{
    std::stringstream ss(coltext);
    ss >> *this;
}

Color Color::getOutfitColor(int color)
{
    static const int HSI_SI_VALUES = 7;
    static const int HSI_H_STEPS = 19;

    if (color >= HSI_H_STEPS * HSI_SI_VALUES)
        color = 0;

    float loc1 = 0, loc2 = 0, loc3 = 0;
    if (color % HSI_H_STEPS != 0) {
        loc1 = color % HSI_H_STEPS * 1.0 / 18.0;
        loc2 = 1;
        loc3 = 1;

        switch (int(color / HSI_H_STEPS)) {
        case 0:
            loc2 = 0.25;
            loc3 = 1.00;
            break;
        case 1:
            loc2 = 0.25;
            loc3 = 0.75;
            break;
        case 2:
            loc2 = 0.50;
            loc3 = 0.75;
            break;
        case 3:
            loc2 = 0.667;
            loc3 = 0.75;
            break;
        case 4:
            loc2 = 1.00;
            loc3 = 1.00;
            break;
        case 5:
            loc2 = 1.00;
            loc3 = 0.75;
            break;
        case 6:
            loc2 = 1.00;
            loc3 = 0.50;
            break;
        }
    } else {
        loc1 = 0;
        loc2 = 0;
        loc3 = 1 - (float)color / HSI_H_STEPS / (float)HSI_SI_VALUES;
    }

    if (loc3 == 0)
        return Color(0, 0, 0);

    if (loc2 == 0) {
        int loc7 = int(loc3 * 255);
        return Color(loc7, loc7, loc7);
    }

    float red = 0, green = 0, blue = 0;

    if (loc1 < 1.0 / 6.0) {
        red = loc3;
        blue = loc3 * (1 - loc2);
        green = blue + (loc3 - blue) * 6 * loc1;
    } else if (loc1 < 2.0 / 6.0) {
        green = loc3;
        blue = loc3 * (1 - loc2);
        red = green - (loc3 - blue) * (6 * loc1 - 1);
    } else if (loc1 < 3.0 / 6.0) {
        green = loc3;
        red = loc3 * (1 - loc2);
        blue = red + (loc3 - red) * (6 * loc1 - 2);
    } else if (loc1 < 4.0 / 6.0) {
        blue = loc3;
        red = loc3 * (1 - loc2);
        green = blue - (loc3 - red) * (6 * loc1 - 3);
    } else if (loc1 < 5.0 / 6.0) {
        blue = loc3;
        green = loc3 * (1 - loc2);
        red = green + (loc3 - green) * (6 * loc1 - 4);
    } else {
        red = loc3;
        green = loc3 * (1 - loc2);
        blue = red - (loc3 - green) * (6 * loc1 - 5);
    }
    return Color(int(red * 255), int(green * 255), int(blue * 255));
}

std::string Color::toHex()
{
    std::stringstream ss;
    ss << *this;
    return ss.str();
}
