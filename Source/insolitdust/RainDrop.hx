// @see http://insolitdust.sourceforge.net/code.html

package insolitdust;

class RainDrop implements IEffect
{
    var background : Array<Int>;
    var cnt : Int;

    var water : Array<Float>;
    var pxoffset : Array<Int>;

    static inline var DAMP : Float = 0.975; // Must be < 1!!!!
    static inline var REF : Float = 18.0; // Reflections
    static inline var DEPTH : Float = 300.0; // Water depth

    static inline var XRES = 320;
    static inline var YRES = 240;

    public function new()
    {
        pxoffset = new Array<Int>();
        water = new Array<Float>();
        cnt = 0;
    }

    public function init(width : Int, height : Int) : Array<Array<Int>>
    {
        for (i in 0...YRES)
        {
            pxoffset[i] = i * XRES;
        }

        background = buildBackImage(XRES, YRES);

        for (i in 0...XRES * YRES * 2)
        {
            water[i] = 0.0;
        }
        return EffectUtils.CreateBuffer(XRES, YRES, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        doWater(buffer, XRES, YRES);

        if (++cnt >= 15)
        {
            cnt = 0;
            makeDrop(XRES, YRES);
        }
        return null;
    }

    public function update(_) : Void
    {
    }

    public function keyboard(_) : Void
    {
    }

    // Create the background image
    private function buildBackImage(width : Int, height : Int) : Array<Int>
    {
        var result : Array<Int> = new Array<Int>();

        for (y in 0...height)
        {
            var b : Int = pxoffset[y];

            for (x in 0...width)
            {
                var c : Int = Std.int((((x ^ y) & 255) / 255.0 * ((height - y) / width) * 0.8 + 0.2) * 200.0);

                result[b + x] = EffectUtils.ColorRGB(c, c, c);
            }
        }
        return result;
    }

    // Release a water drop...
    private function makeDrop(width : Int, height : Int) : Void
    {
        var ix : Int = EffectUtils.Rand() % width;
        var iy : Int = EffectUtils.Rand() % height;

        if (ix > 0 && ix < width - 1 && iy > 1 && iy < height - 1)
        {
            water[iy * width + ix] -= DEPTH;
        }
    }

    // Moving water
    private function doWater(buffer : Array<Array<Int>>, width : Int, height : Int) : Void
    {
        var scrdim : Int = width * height;

        // Water physics & 1st buffer copy pass
        for (y in 1...height - 1)
        {
            var yi : Int = pxoffset[y];

            for (x in 1...width - 1)
            {
                var bi = yi + x;

                water[bi + scrdim] = ((water[bi - 1] + water[bi + 1] +
                    water[bi - width] +
                    water[bi + width]) * 0.5 -
                    water[bi + scrdim]) * DAMP;
            }
        }

        // Refraction & render pass
        for (y in 1...height - 1)
        {
            var yi : Int = pxoffset[y];

            for (x in 1...width - 1)
            {
                var bi : Int = yi + x;

                var nx : Float = water[bi + 1 + scrdim] - water[bi - 1 + scrdim];
                var ny : Float = water[bi + width + scrdim] - water[bi - width + scrdim];
                var rx : Int = EffectUtils.IntClamp(x - Std.int(nx * REF), 1, width - 2);
                var ry : Int = EffectUtils.IntClamp(y - Std.int(ny * REF), 1, height - 2);

                var s : Int = EffectUtils.IntClamp(Std.int(ny * 64.0), 0, 64);

                var rgb : Int = background[(ry << 8) + (ry << 6) + rx];

                var r : Int = EffectUtils.IntClamp(((rgb >> 16) & 255) + s, 0, 255);
                var g : Int = EffectUtils.IntClamp(((rgb >> 8) & 255) + s, 0, 255);
                var b : Int = EffectUtils.IntClamp((rgb & 255) + s, 0, 255);

                buffer[x][y] = EffectUtils.ColorRGB(r, g, b);
            }
        }

        // 2nd buffer copy pass
        for (y in 1...height - 1)
        {
            var yi : Int = pxoffset[y];

            for (x in 1...width - 1)
            {
                var bi : Int = yi + x;

                var w : Float = water[bi + scrdim];
                water[bi + scrdim] = water[bi];
                water[bi] = w;
            }
        }

        // Blur pass...
        for (y in 1...height - 1)
        {
            var yi : Int = pxoffset[y];

            for (x in 1...width - 1)
            {
                var bi : Int = yi + x;

                water[bi] = (water[bi] + water[bi - 1] +
                    water[bi + 1] + water[bi - width] +
                    water[bi + width]) * 0.2;
            }
        }
    }
}