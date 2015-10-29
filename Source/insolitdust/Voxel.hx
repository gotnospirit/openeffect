// @see http://insolitdust.sourceforge.net/code.html

package insolitdust;

class Voxel implements IEffect
{
    var palette : Array<Int>;
    // Height map and color map
    var hmap : Array<Int>;
    var cmap : Array<Int>;
    // Focal length
    var fov : Float;
    // Temp tables
    var lasty : Array<Int>;
    var lastc : Array<Int>;
    // Time to change direction
    var delay : Int;

    var X0 : Int;
    var Y0 : Int;
    var Cnt : Int;
    var Mul : Int;
    var Rotation : Float;
    var A : Float;

    static inline var XRES = 320;
    static inline var YRES = 240;

    static inline var SPEED : Int = 14000;

    public function new()
    {
        palette = initPalette();
        hmap = new Array<Int>();
        cmap = new Array<Int>();
        fov = Math.PI / 3.5;
        lasty = new Array<Int>();
        lastc = new Array<Int>();
        delay = 90;

        X0 = 0;
        Y0 = 0;
        Cnt = 0;
        Mul = -1;
        Rotation = 0.004;
        A = 0;
    }

    public function init(_, _) : Array<Array<Int>>
    {
        makeMap();
        return EffectUtils.CreateBuffer(XRES, YRES, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        EffectUtils.ClearBuffer(buffer, 0);

        doVoxel(X0, Y0, A, buffer, XRES, YRES);
        return palette;
    }

    public function update(_) : Void
    {
        X0 = EffectUtils.ToInt(X0 + SPEED * Math.cos(A));
        Y0 = EffectUtils.ToInt(Y0 + SPEED * Math.sin(A));
        A += Rotation;
        ++Cnt;

        if (Cnt >= delay)
        {
            // Change direction
            Rotation *= Mul;
            Mul *= -1;
            Cnt = 0;
            delay = 90 + (EffectUtils.Rand() % 60);
        }
    }

    public function keyboard(_) : Void
    {
    }

    private inline function initPalette() : Array<Int>
    {
        var result = new Array<Int>();
        for (i in 0...256)
        {
            result[i] = EffectUtils.ColorRGB(i * 4, i * 4, i * 4);
        }
        return result;
    }

    // Calculate the maps...
    private inline function makeMap() : Void
    {
        hmap[0] = 128;

        var p : Int = 256;
        var p2 : Int = 0;

        while (p > 1)
        {
            p2 = p >> 1;

            var k : Int = p * 8 + 20;
            var k2 : Int = k >> 1;

            var i : Int = 0;
            while (i < 256)
            {
                var j : Int = 0;
                while (j < 256)
                {
                    var a : Int = hmap[(i << 8) + j];
                    var b : Int = hmap[(((i + p) & 255) << 8) + j];
                    var c : Int = hmap[(i << 8) + ((j + p) & 255)];
                    var d : Int = hmap[(((i + p) & 255) << 8) + ((j + p) & 255)];

                    hmap[(i << 8) + ((j + p2) & 255)] = EffectUtils.IntClamp(((a + c) >> 1) + (EffectUtils.Rand() % k - k2), 0, 255);
                    hmap[(((i + p2) & 255) << 8) + ((j + p2) & 255)] = EffectUtils.IntClamp(((a + b + c + d) >> 2) + (EffectUtils.Rand() % k - k2), 0, 255);
                    hmap[(((i + p2) & 255) << 8) + j] = EffectUtils.IntClamp(((a + b) >> 1) + (EffectUtils.Rand() % k - k2), 0, 255);

                    j += p;
                }

                i += p;
            }

            p = p2;
        }

        for (k in 0...3)
        {
            var i : Int = 0;
            while (i < 256 * 256)
            {
                for (j in 0...256)
                {
                    hmap[i + j] = (
                        hmap[((i + 256) & 0xff00) + j]
                        + hmap[i + ((j + 1) & 0xff)]
                        + hmap[((i - 256) & 0xff00) + j]
                        + hmap[i + ((j - 1) & 0xff)]
                    ) >> 2;
                }

                i += 256;
            }
        }

        var i : Int = 0;
        while (i < 256 * 256)
        {
            for (j in 0...256)
            {
                cmap[i + j] = EffectUtils.IntClamp(128 + (hmap[((i + 256) & 0xff00) + ((j + 1) & 255)] - hmap[i + j]) * 6, 0, 255);
            }

            i += 256;
        }
    }

    // Draw a voxel line
    private inline function line(x0 : Int, y0 : Int, x1 : Int, y1 : Int, hy : Int, s : Int, buffer : Array<Array<Int>>, width : Int, height : Int) : Void
    {
        var sx : Int = EffectUtils.ToInt((x1 - x0) / width);
        var sy : Int = EffectUtils.ToInt((y1 - y0) / width);

        for (i in 0...width)
        {
            var u0 : Int = (x0 >> 16) & 0xff;
            var a : Int = (x0 >> 8) & 255;
            var v0 : Int = ((y0 >> 8) & 0xff00);
            var b : Int = (y0 >> 8) & 255;
            var u1 : Int = (u0 + 1) & 0xff;
            var v1 : Int = (v0 + 256) & 0xff00;

            var h0 : Int = hmap[u0 + v0];
            var h2 : Int = hmap[u0 + v1];
            var h1 : Int = hmap[u1 + v0];
            var h3 : Int = hmap[u1 + v1];

            h0 = (h0 << 8) + a * (h1 - h0);
            h2 = (h2 << 8) + a * (h3 - h2);
            var h : Int = ((h0 << 8) + b * (h2 - h0)) >> 16;

            h0 = cmap[u0 + v0];
            h2 = cmap[u0 + v1];
            h1 = cmap[u1 + v0];
            h3 = cmap[u1 + v1];

            h0 = (h0 << 8) + a * (h1 - h0);
            h2 = (h2 << 8) + a * (h3 - h2);
            var c : Int = (h0 << 8) + b * (h2 - h0);

            var y : Int = (((h - hy) * s) >> 11) + EffectUtils.ToInt(height / 2);

            a = lasty[i];

            if (y < a)
            {
                var App : Int = (a << 8) + (a << 6) + i;

                if (-1 == lastc[i])
                {
                    lastc[i] = c;
                }

                var sc : Int = EffectUtils.ToInt((c - lastc[i]) / (a - y));
                var cc : Int = lastc[i];

                if (a > height - 1)
                {
                    App -= (a - (height - 1)) * width;
                    cc += (a - (height - 1)) * sc;
                    a = height - 1;
                }

                if (y < 0)
                {
                    y = 0;
                }

                while (y < a)
                {
                    var bx : Int = App % width;
                    var by : Int = EffectUtils.ToInt(App / width);

                    buffer[bx][by] = cc >> 18;
                    cc += sc;

                    App -= width;
                    a--;
                }

                lasty[i] = y;
            }

            lastc[i] = c;

            x0 += sx;
            y0 += sy;
        }
    }

    // Show single frame
    private inline function doVoxel(x0 : Int, y0 : Int, aa : Float, buffer : Array<Array<Int>>, width : Int, height : Int) : Void
    {
        for (i in 0...width)
        {
            lasty[i] = height;
            lastc[i] = -1;
        }

        var u0 : Int = (x0 >> 16) & 0xff;
        var a : Int = (x0 >> 8) & 255;
        var v0 : Int = ((y0 >> 8) & 0xff00);
        var b : Int = (y0 >> 8) & 255;
        var u1 : Int = (u0 + 1) & 0xff;
        var v1 : Int = (v0 + 256) & 0xff00;

        var d : Int = 0;
        var max : Int = EffectUtils.ToInt(height / 2);
        while (d < max)
        {
            line(
                EffectUtils.ToInt(x0 + d * 65536 * Math.cos(aa - fov)),
                EffectUtils.ToInt(y0 + d * 65536 * Math.sin(aa - fov)),
                EffectUtils.ToInt(x0 + d * 65536 * Math.cos(aa + fov)),
                EffectUtils.ToInt(y0 + d * 65536 * Math.sin(aa + fov)),
                -30,
                EffectUtils.ToInt(max * 256 / (d + 1)),
                buffer,
                width,
                height
            );

            d += 1 + (d >> 16);
        }
    }
}