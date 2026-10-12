using System.Drawing;

namespace DarkUI.Config
{
    public sealed class Colors
    {
        public static readonly Color GreyBackground = Color.FromArgb(0x3E, 0x42, 0x48);
        public static readonly Color HeaderBackground = Color.FromArgb(0x34, 0x38, 0x3E);
        public static readonly Color BlueBackground = Color.FromArgb(0x4D, 0x5B, 0x6D);
        public static readonly Color DarkBlueBackground = Color.FromArgb(0x2B, 0x2F, 0x35);
        public static readonly Color DarkBackground = Color.FromArgb(0x3E, 0x42, 0x48);
        public static readonly Color MediumBackground = Color.FromArgb(0x34, 0x38, 0x3E);
        public static readonly Color LightBackground = Color.FromArgb(0x62, 0x68, 0x73);
        public static readonly Color LighterBackground = Color.FromArgb(0x73, 0x7A, 0x85);
        public static readonly Color LightestBackground = Color.FromArgb(178, 178, 178);
        public static readonly Color LightBorder = Color.FromArgb(0x62, 0x68, 0x73);
        public static readonly Color DarkBorder = Color.FromArgb(0x17, 0x1A, 0x1F);
        public static readonly Color LightText = Color.FromArgb(0xDF, 0xDF, 0xDF);
        public static readonly Color DisabledText = Color.FromArgb(153, 153, 153);
        public static readonly Color BlueHighlight = Color.FromArgb(0x86, 0xA9, 0xBA);
        public static readonly Color BlueSelection = Color.FromArgb(0x4D, 0x5B, 0x6D);
        public static readonly Color GreyHighlight = Color.FromArgb(0x73, 0x7A, 0x85);
        public static readonly Color GreySelection = Color.FromArgb(0x4B, 0x50, 0x58);
        public static readonly Color DarkGreySelection = Color.FromArgb(0x34, 0x38, 0x3E);
        public static readonly Color DarkBlueBorder = Color.FromArgb(0x44, 0x67, 0x7A);
        public static readonly Color LightBlueBorder = Color.FromArgb(0x86, 0xA9, 0xBA);
        public static readonly Color ActiveControl = Color.FromArgb(0xB9, 0xC7, 0xD8);
        public static readonly Color BorderColor = Color.FromArgb(0x17, 0x1A, 0x1F);
        public static readonly Color ListBackgroudColor = Color.FromArgb(0x4B, 0x50, 0x58);
        public static readonly Color ListSelectionColor = Color.FromArgb(0x4D, 0x5B, 0x6D);


        public static readonly Pen BorderColorPen = new Pen(BorderColor);
        public static readonly Brush TextColorBrush = new SolidBrush(LightText);
        public static readonly Brush ListBackgroudBrush = new SolidBrush(ListBackgroudColor);
        public static readonly Brush ListSelectionBrush = new SolidBrush(ListSelectionColor);
        public static readonly Brush ListViewBackgroudBrush = new SolidBrush(LightBackground);
    }
}
