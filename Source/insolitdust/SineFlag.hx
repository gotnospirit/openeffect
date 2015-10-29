// @see http://insolitdust.sourceforge.net/code.html

package insolitdust;

class SineFlag implements IEffect
{
    var palette : Array<Int>;
    var stab : Array<Int>;
    var fbitmap : Array<Int>;
    var SidX : Int;

    static inline var SPEED = 2;
    static inline var SIZE = 3;
    static inline var CURVE = 125;
    static inline var XMAX = 230 / SIZE;
    static inline var YMAX = 140 / SIZE;
    static inline var SOFS = 50;
    static inline var SAMP = 10;
    static inline var SLEN = 255;

    static inline var XRES = 320;
    static inline var YRES = 240;

    public function new()
    {
        palette = [
            0,
            EffectUtils.ColorRGB(255, 0, 0),
            EffectUtils.ColorRGB(0, 255, 0),
            EffectUtils.ColorRGB(255, 255, 255)
        ];

        stab = new Array<Int>();
        fbitmap = new Array<Int>();
        SidX = 0;
    }

    public function init(_, _) : Array<Array<Int>>
    {
        makeSinTab();
        defineFlag();
        return EffectUtils.CreateBuffer(XRES, YRES, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        EffectUtils.ClearBuffer(buffer, 0);

        doFlag(buffer);
        return palette;
    }

    public function update(_) : Void
    {
    }

    public function keyboard(_) : Void
    {
    }

    private inline function makeSinTab() : Void
    {
        for (i in 0...SLEN)
        {
            stab[i] = Math.ceil(Math.sin(i * 4 * Math.PI / SLEN) * SAMP) + SOFS;
        }
    }

    private inline function defineFlag() : Void
    {
        var xmax : Int = EffectUtils.ToInt(XMAX);
        var third : Int = EffectUtils.ToInt(XMAX / 3);

        for (y in 0...EffectUtils.ToInt(YMAX))
        {
            // 1/3 green
            for (x in 0...third)
            {
                fbitmap[y * xmax + x] = 2;
            }

            // 1/3 white
            for (x in third...2 * third)
            {
                fbitmap[y * xmax + x] = 3;
            }

            // 1/3 red
            for (x in 2 * third...xmax)
            {
                fbitmap[y * xmax + x] = 1;
            }
        }
    }

    private inline function doFlag(buffer : Array<Array<Int>>) : Void
    {
        var xmax : Int = EffectUtils.ToInt(XMAX);

        for (y in 0...EffectUtils.ToInt(YMAX))
        {
            for (x in 0...xmax)
            {
                var xp : Int = SIZE * x + stab[(SidX + CURVE * x + CURVE * y) % SLEN];
                var yp : Int = SIZE * y + stab[(SidX + 4 * x + CURVE * y + y) % SLEN];

                buffer[xp][yp] = fbitmap[y * xmax + x];
            }
        }

        SidX = (SidX + SPEED) % SLEN;
    }
}