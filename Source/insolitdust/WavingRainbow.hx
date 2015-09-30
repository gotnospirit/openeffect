// @see http://insolitdust.sourceforge.net/code.html

package insolitdust;

class WavingRainbow implements IEffect
{
    var palette : Array<Int>;

    var dx : Float;
    var yvalues : Array<Float>;
    var yvalueslen : Int;
    var Theta : Float;
    var wave_x : Float;

    static inline var XSPACING : Int = 10;
    static inline var AMPLITUDE : Float = 150.0;
    static inline var PERIOD : Float = 500.0;

    static inline var XRES = 320;
    static inline var YRES = 240;

    public function new()
    {
        dx = ((Math.PI * 2) / PERIOD) * XSPACING;
        Theta = 0.0;
        wave_x = 0.0;

        yvalues = new Array<Float>();

        palette = [
            0,
            EffectUtils.ColorRGB(255, 0, 0),
            EffectUtils.ColorRGB(255, 106, 0),
            EffectUtils.ColorRGB(255, 213, 0),
            EffectUtils.ColorRGB(191, 255, 0),
            EffectUtils.ColorRGB(85, 255, 0),
            EffectUtils.ColorRGB(0, 255, 21),
            EffectUtils.ColorRGB(0, 255, 128),
            EffectUtils.ColorRGB(0, 255, 234),
            EffectUtils.ColorRGB(0, 170, 255),
            EffectUtils.ColorRGB(0, 64, 255),
        ];
    }

    public function init(width : Int, height : Int) : Array<Array<Int>>
    {
        yvalueslen = Std.int((width + 16) / XSPACING);
        for (i in 0...yvalueslen)
        {
            yvalues[i] = 0.0;
        }
        return EffectUtils.CreateBuffer(XRES, YRES, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        // cls
        EffectUtils.ClearBuffer(buffer, 0);

        calcWave();
        renderRainbow(buffer, XRES, YRES);
        return null;
    }

    public function update(_) : Void
    {
    }

    public function keyboard(_) : Void
    {
    }

    // Generate a new moving table
    private function calcWave() : Void
    {
        Theta += 0.05;
        wave_x = Theta;

        for (i in 0...yvalueslen)
        {
            yvalues[i] = Math.sin(wave_x) * AMPLITUDE;
            wave_x += dx;
        }
    }

    private function renderRainbow(buffer : Array<Array<Int>>, width : Int, height : Int) : Void
    {
        for (i in 0...palette.length)
        {
            for (x in 0...yvalueslen)
            {
                drawStrokedLine(
                    (x - 5 + i) * XSPACING, Std.int(height / 2 + yvalues[x] / 2),
                    (x + 5) * XSPACING, Std.int(height / 2 + yvalues[x] / 2),
                    palette[i + 1],
                    4,
                    buffer, width
                );
            }
        }
    }

    // Draw an horizontal stroked line
    private function drawStrokedLine(x1 : Int, y1 : Int, x2 : Int, y2 : Int, color : Int, stroke : Int, buffer : Array<Array<Int>>, width : Int) : Void
    {
        x1 = EffectUtils.IntClamp(x1, 0, width - 1);
        x2 = EffectUtils.IntClamp(x2, 0, width - 1);

        for (i in 0...stroke)
        {
            drawLine(x1, y1, x2, y2, color, buffer, width);

            --y1;
            --y2;
        }
    }

    private function drawLine(x1 : Int, y1 : Int, x2 : Int, y2 : Int, color : Int, buffer : Array<Array<Int>>, width : Int) : Void
    {
        var dx : Int = abs(x1 - x2);
        var dy : Int = abs(y1 - y2);
        var cxy : Int = 0;
        var dxy : Int = 0;

        if (dy > dx)
        {
            if (y1 > y2)
            {
                swap(y1, y2);
                swap(x1, x2);
            }

            if (x1 > x2)
            {
                dxy = -1;
            }
            else
            {
                dxy = 1;
            }

            for (i in y1...y2)
            {
                cxy += dx;

                if (cxy >= dy)
                {
                    x1 += dxy;
                    cxy -= dy;
                }

                buffer[x1][i] = color;
            }
        }
        else
        {
            if (x1 > x2)
            {
                swap(x1, x2);
                swap(y1, y2);
            }

            if (y1 > y2)
            {
                dxy = -1;
            }
            else
            {
                dxy = 1;
            }

            for (i in x1...x2)
            {
                cxy += dy;

                if (cxy >= dx)
                {
                    y1 += dxy;
                    cxy -= dx;
                }

                buffer[i][y1] = color;
            }
        }
    }

    private inline function swap(a : Int, b : Int) : Void
    {
        a ^= b;
        b ^= a;
        a ^= b;
    }

    private inline function abs(value : Int) : Int
    {
        return value > 0 ? value : value * -1;
    }
}