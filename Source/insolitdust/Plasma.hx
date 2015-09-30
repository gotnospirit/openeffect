// @see http://insolitdust.sourceforge.net/code.html

package insolitdust;

class Plasma implements IEffect
{
    var palette : Array<Int>;
    var SinC : Array<Int>;
    var a : Int;

    static inline var XRES = 320;
    static inline var YRES = 240;

    public function new()
    {
        palette = initPalette();
        SinC = new Array<Int>();
        for (i in 0...1800)
        {
            SinC[i] = Std.int(Math.cos((Math.PI * i) / 180) * 1024);
        }
        a = 1;
    }

    public function init(_, _) : Array<Array<Int>>
    {
        return EffectUtils.CreateBuffer(XRES, YRES, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        doPlasma(buffer, XRES, YRES);
        return palette;
    }

    public function update(_) : Void
    {
    }

    public function keyboard(_) : Void
    {
    }

    private function doPlasma(buffer : Array<Array<Int>>, width : Int, height : Int) : Void
    {
        a += 2;

        if (a > 720)
        {
            a = 0;
        }

        for (c in 0...width)
        {
            var e : Int = 75 + ((SinC[(c << 1) + (a >> 1)] + SinC[c + (a << 1)] + (SinC[(c >> 1) + a] << 1)) >> 6);

            for (d in 0...height)
            {
                var f : Int = 75 + (((SinC[d + (a << 1)] << 1) + SinC[(d << 1) + (a >> 1)] + (SinC[d + a] << 1)) >> 5);

                var n : Int = (d << 8) + (d << 6) + c;

                var x : Int = n % width;
                var y : Int = Std.int(n / width);

                buffer[x][y] = ((e * f) >> 5);
            }
        }
    }

    private inline function initPalette() : Array<Int>
    {
        var r : Int = 0;
        var g : Int = 0;
        var b : Int = 0;

        var result = new Array<Int>();
        for (i in 0...42)
        {
            result[i] = EffectUtils.ColorRGB(r++ * 4, 0, 0);
        }
        for (i in 42...84)
        {
            result[i] = EffectUtils.ColorRGB(r * 4, g++ * 4, 0);
        }
        for (i in 84...126)
        {
            result[i] = EffectUtils.ColorRGB(r * 4, g * 4, b++ * 4);
        }
        for (i in 126...168)
        {
            result[i] = EffectUtils.ColorRGB(r-- * 4, g * 4, b * 4);
        }
        for (i in 168...210)
        {
            result[i] = EffectUtils.ColorRGB(r * 4, g-- * 4, b * 4);
        }
        for (i in 210...252)
        {
            result[i] = EffectUtils.ColorRGB(r * 4, g * 4, b-- * 4);
        }
        for (i in 252...256)
        {
            result[i] = 0;
        }
        return result;
    }
}