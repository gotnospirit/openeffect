// @see http://lodev.org/cgtutor/files/quickcg/quickcg.cpp

package;

class EffectUtils
{
    static public inline function GetAssetPixels(filepath : String) : Array<Array<Int>>
    {
        var texture = openfl.Assets.getBitmapData(filepath);

        var texture_width = texture.width;
        var texture_height = texture.height;

        var result = new Array<Array<Int>>();
        for (x in 0...texture_width)
        {
            result[x] = new Array<Int>();

            for (y in 0...texture_height)
            {
                result[x][y] = texture.getPixel32(x, y);
            }
        }
        return result;
    }

    static public inline function CreateBuffer(width : Int, height : Int, default_color : Int = 0) : Array<Array<Int>>
    {
        var result = new Array<Array<Int>>();
        for (x in 0...width)
        {
            result[x] = new Array<Int>();

            for (y in 0...height)
            {
                result[x][y] = default_color;
            }
        }
        return result;
    }

    static public inline function ClearBuffer(buffer : Array<Array<Int>>, default_color : Int = 0) : Void
    {
        for (x in 0...buffer.length)
        {
            var len : Int = buffer[x].length;

            for (y in 0...len)
            {
                buffer[x][y] = default_color;
            }
        }
    }

    static public inline function BlurBuffer(buffer : Array<Array<Int>>, width : Int, height : Int) : Void
    {
        for (y in 1...height - 1)
        {
            buffer[0][y - 1] = 0;
            buffer[0][y] = 0;
            buffer[0][y + 1] = 0;

            for (x in 1...width - 1)
            {
                var Color : Int = (buffer[x][y - 1] + buffer[x][y + 1] + buffer[x - 1][y] + buffer[x + 1][y]) >> 2;
                Color -= 2;

                if (Color < 0)
                {
                    Color = 0;
                }

                buffer[x][y] = Color;
            }

            buffer[width - 1][y - 1] = 0;
            buffer[width - 1][y] = 0;
            buffer[width - 1][y + 1] = 0;
        }
    }

    static public inline function ToInt(value : Float) : Int
    {
        return Std.int(value);
    }

	static public inline function GetTime() : Float
    {
		return flash.Lib.getTimer();
	}

    static public inline function Min(a : Int, b : Int) : Int
    {
        return a < b ? a : b;
    }

    static public inline function Rand() : Int
    {
        return Std.random(32767);
    }

    static public inline function ColorDarker(color : Int) : Int
    {
        return (color >> 1) & 8355711;
    }

    static public inline function ColorRGB(r : Int, g : Int, b : Int, a : Int = 255) : Int
    {
        return (a << 24) | (r << 16) | (g << 8) | b;
    }

    static public function ColorHSV(h : Float, s : Float, v : Float) : Int
    {
        var r : Float = 0.0;
        var g : Float = 0.0;
        var b : Float = 0.0; // this function works with floats between 0 and 1

        h /= 256.0;
        s /= 256.0;
        v /= 256.0;

        // if saturation is 0, the color is a shade of grey
        if (s == 0.0)
        {
            r = g = b = v;
        }
        // if saturation > 0, more complex calculations are needed
        else
        {
            var f : Float = 0.0;
            var p : Float = 0.0;
            var q : Float = 0.0;
            var t : Float = 0.0;
            var i : Int = 0;

            h *= 6.0; // to bring hue to a number between 0 and 6, better for the calculations
            i = Math.floor(h); // e.g. 2.7 becomes 2 and 3.01 becomes 3 or 4.9999 becomes 4
            f = h - i; // the fractional part of h

            p = v * (1.0 - s);
            q = v * (1.0 - (s * f));
            t = v * (1.0 - (s * (1.0 - f)));

            switch (i)
            {
                case 0:
                    r = v;
                    g = t;
                    b = p;

                case 1:
                    r = q;
                    g = v;
                    b = p;

                case 2:
                    r = p;
                    g = v;
                    b = t;

                case 3:
                    r = p;
                    g = q;
                    b = v;

                case 4:
                    r = t;
                    g = p;
                    b = v;

                case 5:
                    r = v;
                    g = p;
                    b = q;

                default:
                    r = g = b = 0;
            }
        }
        return ColorRGB(ToInt(r * 255.0), ToInt(g * 255.0), ToInt(b * 255.0));
    }

    static public function ColorHSL(h : Float, s : Float, l : Float) : Int
    {
        var r : Float = 0.0;
        var g : Float = 0.0;
        var b : Float = 0.0; // this function works with floats between 0 and 1

        var temp1 : Float = 0.0;
        var temp2 : Float = 0.0;

        var tempr : Float = 0.0;
        var tempg : Float = 0.0;
        var tempb : Float = 0.0;

        h /= 256.0;
        s /= 256.0;
        l /= 256.0;

        // If saturation is 0, the color is a shade of grey
        if (s == 0)
        {
            r = g = b = l;
        }
        // If saturation > 0, more complex calculations are needed
        else
        {
            // set the temporary values
            temp2 = (l < 0.5)
                ? l * (1 + s)
                : (l + s) - (l * s);

            temp1 = 2 * l - temp2;
            tempr = h + 1.0 / 3.0;
            if (tempr > 1.0)
            {
                --tempr;
            }

            tempg = h;
            tempb = h-1.0 / 3.0;
            if (tempb < 0.0)
            {
                ++tempb;
            }

            r = ColorPart(tempr, temp1, temp2);
            g = ColorPart(tempg, temp1, temp2);
            b = ColorPart(tempb, temp1, temp2);
        }
        return ColorRGB(ToInt(r * 255.0), ToInt(g * 255.0), ToInt(b * 255.0));
    }

    static private inline function ColorPart(input : Float, t1 : Float, t2 : Float) : Float
    {
        var result : Float = 0.0;

        if (input < 1.0 / 6.0)
        {
            result = t1 + (t2 - t1) * 6.0 * input;
        }
        else if (input < 0.5)
        {
            result = t2;
        }
        else if (input < 2.0 / 3.0)
        {
            result = t1 + (t2 - t1) * ((2.0 / 3.0) - input) * 6.0;
        }
        else
        {
            result = t1;
        }
        return result;
    }

    static public inline function IntClamp(value : Int, min : Int, max : Int) : Int
    {
        if (value > max)
        {
            value = max;
        }
        else if (value < min)
        {
            value = min;
        }
        return value;
    }

    static public inline function FloatClamp(value : Float, min : Float, max : Float) : Float
    {
        if (value > max)
        {
            value = max;
        }
        else if (value < min)
        {
            value = min;
        }
        return value;
    }

    static public inline function AddColor(color1 : Int, color2 : Int) : Int
    {
        var b1 : Int = color1 & 255;
        var g1 : Int = (color1 >> 8) & 255;
        var r1 : Int = (color1 >> 16) & 255;

        var b2 : Int = color2 & 255;
        var g2 : Int = (color2 >> 8) & 255;
        var r2 : Int = (color2 >> 16) & 255;

        return ColorRGB(r1 + r2, g1 + g2, b1 + b2);
    }

    static public inline function MulColor(color : Int, factor : Float) : Int
    {
        var b : Int = color & 255;
        var g : Int = (color >> 8) & 255;
        var r : Int = (color >> 16) & 255;

        return ColorRGB(ToInt(r * factor), ToInt(g * factor), ToInt(b * factor));
    }
}