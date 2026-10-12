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

#ifndef COLOR_H
#define COLOR_H

#include "../stdext/types.h"
#include "../stdext/cast.h"
#include "../stdext/string.h"
#include "../const.h"
#include <iomanip>
#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstdlib>
#include <sstream>
#include <vector>

class Color
{
public:
    Color() : m_r(1.0f), m_g(1.0f), m_b(1.0f), m_a(1.0f) { }
    Color(uint32 rgba) { setRGBA(rgba); }
    Color(uint8 r, uint8 g, uint8 b, uint8 a = 0xFF) : m_r(r/255.0f), m_g(g/255.0f), m_b(b/255.0f), m_a(a/255.0f) { }
    Color(int r, int g, int b, int a = 0xFF) : m_r(r/255.0f), m_g(g/255.0f), m_b(b/255.0f), m_a(a/255.0f) { }
    Color(float r, float g, float b, float a = 1.0f) : m_r(r), m_g(g), m_b(b), m_a(a) { }
    Color(const std::string& coltext);

    uint8 a() const { return 255.0f * m_a; }
    uint8 b() const { return 255.0f * m_b; }
    uint8 g() const { return 255.0f * m_g; }
    uint8 r() const { return 255.0f * m_r; }

    float aF() const { return m_a; }
    float bF() const { return m_b; }
    float gF() const { return m_g; }
    float rF() const { return m_r; }

    void setRed(int r) { m_r = 0.003921f * r; }
    void setGreen(int g) { m_g = 0.003921f * g; }
    void setBlue(int b) { m_b = 0.003921f * b; }
    void setAlpha(int a) { m_a = 0.003921f * a; }

    void setRed(float r) { m_r = r; }
    void setGreen(float g) { m_g = g; }
    void setBlue(float b) { m_b = b; }
    void setAlpha(float a) { m_a = a; }

    void setRGBA(uint8 r, uint8 g, uint8 b, uint8 a = 0xFF) { m_r = r/255.0f; m_g = g/255.0f; m_b = b/255.0f; m_a = a/255.0f; }
    void setRGBA(uint32 rgba) { setRGBA((rgba >> 0) & 0xff, (rgba >> 8) & 0xff, (rgba >> 16) & 0xff, (rgba >> 24) & 0xff); }

    Color opacity(float opacity) const {
        return Color(m_r, m_g, m_b, m_a * opacity);
    }

    Color operator+(const Color& other) const { return Color(m_r + other.m_r, m_g + other.m_g, m_b + other.m_b, m_a + other.m_a); }
    Color operator-(const Color& other) const { return Color(m_r - other.m_r, m_g - other.m_g, m_b - other.m_b, m_a - other.m_a); }

    Color operator*(float v) const { return Color(m_r*v, m_g*v, m_b*v, m_a*v); }
    Color operator/(float v) const { return Color(m_r/v, m_g/v, m_b/v, m_a/v); }

    Color& operator=(uint32_t rgba) { setRGBA(rgba); return *this; }
    
    Color operator+=(const Color& other) const { 
        return Color(std::min<float>(1.0f, m_r + other.m_r), std::min<float>(1.0f, m_g + other.m_g),
            std::min<float>(1.0f, m_b + other.m_b), std::min<float>(1.0f, m_a + other.m_a));
    }

    Color& operator=(const Color& other) { m_r = other.m_r; m_g = other.m_g; m_b = other.m_b; m_a = other.m_a; return *this; }
    bool operator==(const Color& other) const {
        if (std::abs(other.m_r - m_r) > 0.001) return false;
        if (std::abs(other.m_g - m_g) > 0.001) return false;
        if (std::abs(other.m_b - m_b) > 0.001) return false;
        if (std::abs(other.m_a - m_a) > 0.001) return false;
        return true;
    }
    bool operator!=(const Color& other) const { return !(other == *this); }

    std::string toHex();

    static uint8 to8bit(const Color& color) {
        uint8 c = 0;
        c += (color.r() / 51) * 36;
        c += (color.g() / 51) * 6;
        c += (color.b() / 51);
        return c;
    }

    static Color from8bit(int color) {
        if(color >= 216 || color <= 0)
            return Color(0, 0, 0);

        int r = int(color / 36) % 6 * 51;
        int g = int(color / 6) % 6 * 51;
        int b = color % 6 * 51;
        return Color(r, g, b);
    }

    static Color getOutfitColor(int color);
    static bool parseCssName(const std::string& name, Color& color);

    static const Color alpha;
    static const Color white;
    static const Color black;
    static const Color red;
    static const Color darkRed;
    static const Color green;
    static const Color darkGreen;
    static const Color blue;
    static const Color darkBlue;
    static const Color pink;
    static const Color darkPink;
    static const Color yellow;
    static const Color darkYellow;
    static const Color teal;
    static const Color darkTeal;
    static const Color gray;
    static const Color darkGray;
    static const Color lightGray;
    static const Color orange;

private:
    float m_r;
    float m_g;
    float m_b;
    float m_a;
};

inline std::ostream& operator<<(std::ostream& out, const Color& color)
{
    using namespace std;
    out << "#" << hex << setfill('0')
        << setw(2) << (int)color.r()
        << setw(2) << (int)color.g()
        << setw(2) << (int)color.b()
        << setw(2) << (int)color.a();
    out << dec << setfill(' ');
    return out;
}

inline std::istream& operator>>(std::istream& in, Color& color)
{
    using namespace std;
    std::string tmp;

    if(in.get() == '#') {
        in >> tmp;

        if(tmp.length() == 3 || tmp.length() == 4) {
            std::string expanded;
            expanded.reserve(tmp.length() * 2);
            for(char value : tmp) {
                expanded.push_back(value);
                expanded.push_back(value);
            }
            tmp.swap(expanded);
        }

        if(tmp.length() == 6 || tmp.length() == 8) {
            color.setRed((uint8)stdext::hex_to_dec(tmp.substr(0, 2)));
            color.setGreen((uint8)stdext::hex_to_dec(tmp.substr(2, 2)));
            color.setBlue((uint8)stdext::hex_to_dec(tmp.substr(4, 2)));
            if(tmp.length() == 8)
                color.setAlpha((uint8)stdext::hex_to_dec(tmp.substr(6, 2)));
            else
                color.setAlpha(255);
        } else
            in.seekg(-(std::streampos)tmp.length()-1, ios_base::cur);
    } else {
        in.unget();
        in >> tmp;

        std::string cssValue = tmp;
        std::transform(cssValue.begin(), cssValue.end(), cssValue.begin(), [](unsigned char value) {
            return static_cast<char>(std::tolower(value));
        });

        const bool isFunction = cssValue.compare(0, 4, "rgb(") == 0 || cssValue.compare(0, 5, "rgba(") == 0 ||
                                cssValue.compare(0, 4, "hsl(") == 0 || cssValue.compare(0, 5, "hsla(") == 0;
        if(isFunction && cssValue.find(')') == std::string::npos) {
            std::string tail;
            std::getline(in, tail, ')');
            cssValue += tail;
            cssValue.push_back(')');
        }

        if(isFunction) {
            cssValue.erase(std::remove_if(cssValue.begin(), cssValue.end(), [](unsigned char value) {
                return std::isspace(value) != 0;
            }), cssValue.end());

            const size_t open = cssValue.find('(');
            const size_t close = cssValue.rfind(')');
            std::vector<std::string> parts;
            if(open != std::string::npos && close != std::string::npos && close > open) {
                const std::string values = cssValue.substr(open + 1, close - open - 1);
                size_t start = 0;
                do {
                    const size_t comma = values.find(',', start);
                    parts.push_back(values.substr(start, comma == std::string::npos ? comma : comma - start));
                    if(comma == std::string::npos)
                        break;
                    start = comma + 1;
                } while(start <= values.size());
            }

            auto clampByte = [](int value) { return std::max(0, std::min(255, value)); };
            auto parseByte = [&](const std::string& value) {
                if(!value.empty() && value.back() == '%')
                    return clampByte(static_cast<int>(std::lround(std::strtod(value.c_str(), nullptr) * 2.55)));
                return clampByte(std::atoi(value.c_str()));
            };
            auto parseAlpha = [&](const std::string& value) {
                if(!value.empty() && value.back() == '%')
                    return clampByte(static_cast<int>(std::lround(std::strtod(value.c_str(), nullptr) * 2.55)));
                const double alpha = std::strtod(value.c_str(), nullptr);
                return clampByte(static_cast<int>(std::lround(alpha <= 1.0 ? alpha * 255.0 : alpha)));
            };

            const bool isRgb = cssValue.compare(0, 3, "rgb") == 0;
            const bool hasAlpha = cssValue.compare(0, 4, "rgba") == 0 || cssValue.compare(0, 4, "hsla") == 0;
            if(isRgb && parts.size() == (hasAlpha ? 4u : 3u)) {
                color.setRGBA(parseByte(parts[0]), parseByte(parts[1]), parseByte(parts[2]), hasAlpha ? parseAlpha(parts[3]) : 255);
                return in;
            }

            if(!isRgb && parts.size() == (hasAlpha ? 4u : 3u)) {
                double hue = std::fmod(std::strtod(parts[0].c_str(), nullptr), 360.0);
                if(hue < 0.0)
                    hue += 360.0;
                auto parseRatio = [](const std::string& value) {
                    double ratio = std::strtod(value.c_str(), nullptr);
                    if(!value.empty() && value.back() == '%')
                        ratio /= 100.0;
                    return std::max(0.0, std::min(1.0, ratio));
                };
                const double saturation = parseRatio(parts[1]);
                const double lightness = parseRatio(parts[2]);
                auto hueToRgb = [](double p, double q, double t) {
                    if(t < 0.0) t += 1.0;
                    if(t > 1.0) t -= 1.0;
                    if(t < 1.0 / 6.0) return p + (q - p) * 6.0 * t;
                    if(t < 0.5) return q;
                    if(t < 2.0 / 3.0) return p + (q - p) * (2.0 / 3.0 - t) * 6.0;
                    return p;
                };
                double red = lightness, green = lightness, blue = lightness;
                if(saturation != 0.0) {
                    const double q = lightness < 0.5 ? lightness * (1.0 + saturation) : lightness + saturation - lightness * saturation;
                    const double p = 2.0 * lightness - q;
                    const double normalizedHue = hue / 360.0;
                    red = hueToRgb(p, q, normalizedHue + 1.0 / 3.0);
                    green = hueToRgb(p, q, normalizedHue);
                    blue = hueToRgb(p, q, normalizedHue - 1.0 / 3.0);
                }
                color.setRGBA(clampByte(static_cast<int>(std::lround(red * 255.0))),
                              clampByte(static_cast<int>(std::lround(green * 255.0))),
                              clampByte(static_cast<int>(std::lround(blue * 255.0))),
                              hasAlpha ? parseAlpha(parts[3]) : 255);
                return in;
            }
        }

        if(tmp == "alpha") {
            color = Color::alpha;
        } else if(cssValue == "transparent") {
            color = Color::alpha;
        } else if(tmp == "black") {
            color = Color::black;
        } else if(tmp == "white") {
            color = Color::white;
        } else if(tmp == "red") {
            color = Color::red;
        } else if(tmp == "darkRed") {
            color = Color::darkRed;
        } else if(tmp == "green") {
            color = Color::green;
        } else if(tmp == "darkGreen") {
            color = Color::darkGreen;
        } else if(tmp == "blue") {
            color = Color::blue;
        } else if(tmp == "darkBlue") {
            color = Color::darkBlue;
        } else if(tmp == "pink") {
            color = Color::pink;
        } else if(tmp == "darkPink") {
            color = Color::darkPink;
        } else if(tmp == "yellow") {
            color = Color::yellow;
        } else if(tmp == "darkYellow") {
            color = Color::darkYellow;
        } else if(tmp == "teal") {
            color = Color::teal;
        } else if(tmp == "darkTeal") {
            color = Color::darkTeal;
        } else if(tmp == "gray") {
            color = Color::gray;
        } else if(tmp == "darkGray") {
            color = Color::darkGray;
        } else if(tmp == "lightGray") {
            color = Color::lightGray;
        } else if(tmp == "orange") {
            color = Color::orange;
        } else if(Color::parseCssName(cssValue, color)) {
            return in;
        } else {
            in.seekg(-tmp.length(), ios_base::cur);
        }
    }
    return in;
}

#endif
