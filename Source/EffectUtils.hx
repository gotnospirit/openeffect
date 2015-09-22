// @see http://lodev.org/cgtutor/files/quickcg/quickcg.cpp

package;

import flash.Lib;

class EffectUtils
{
	static public inline function getTime() : Float
    {
		return Lib.getTimer();
	}

    static public inline function rand() : Int
    {
        return 32768 + Std.random(32767);
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
        return ColorRGB(Math.ceil(r * 255.0), Math.ceil(g * 255.0), Math.ceil(b * 255.0));
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
        return ColorRGB(Math.ceil(r * 255.0), Math.ceil(g * 255.0), Math.ceil(b * 255.0));
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
}