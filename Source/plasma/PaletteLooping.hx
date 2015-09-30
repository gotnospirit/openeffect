// @see http://lodev.org/cgtutor/plasma.html

package plasma;

class PaletteLooping implements IEffect
{
    var palette : Array<Int>;
    var plasma : Array<Array<Int>>;
    var width : Int;
    var height : Int;

	public function new(width : Int, height : Int)
    {
        palette = new Array<Int>();
        plasma = new Array<Array<Int>>();
        this.width = width;
        this.height = height;
	}

    public function init() : Array<Array<Int>>
    {
        // generate the palette
        for (i in 0...256)
        {
            var v : Float = Math.PI * i;

            // palette[i] = EffectUtils.ColorHSV(i, 255, 255);

            palette[i] = EffectUtils.ColorRGB(
                EffectUtils.ToInt(127.0 + 127 * Math.sin(v / 32.0)),
                EffectUtils.ToInt(127.0 + 127 * Math.sin(v / 64.0)),
                EffectUtils.ToInt(127.0 + 127 * Math.sin(v / 128.0))
            );

            // palette[i] = EffectUtils.ColorRGB(
                // EffectUtils.ToInt(127.0 + 127 * Math.sin(v / 16.0)),
                // EffectUtils.ToInt(127.0 + 127 * Math.sin(v / 128.0)),
                // 0
            // );
        }

        // generate the plasma once
        for (x in 0...width)
        {
            plasma[x] = new Array<Int>();

            for (y in 0...height)
            {
                plasma[x][y] = Math.ceil(
                    // (
                        // (127.0 + 127.0 * Math.sin(x / 16.0))
                        // + (127.0 + 127.0 * Math.sin(y / 16.0))
                    // ) / 2

                    // (
                        // (127.0 + 127.0 * Math.sin(x / 16.0))
                        // + (127.0 + 127.0 * Math.sin(y / 8.0))
                        // + (127.0 + 127.0 * Math.sin((x + y) / 16.0))
                        // + (127.0 + 127.0 * Math.sin(Math.sqrt(x * x + y * y) / 8.0))
                    // ) / 4

                    (
                        (127.0 + 127.0 * Math.sin(x / 16.0))
                        + (127.0 + 127.0 * Math.sin(y / 32.0))
                        + (127.0 + 127.0 * Math.sin(Math.sqrt((x - width / 2.0)* (x - width / 2.0) + (y - height / 2.0) * (y - height / 2.0)) / 8.0))
                        + (127.0 + 127.0 * Math.sin(Math.sqrt(x * x + y * y) / 8.0))
                    ) / 4
                );
            }
        }
        return EffectUtils.CreateBuffer(width, height, 0);
        // return plasma;
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        // the parameter to shift the palette varies with time
        var palette_shift : Int = Math.ceil(EffectUtils.GetTime() / 10);

        // @TODO update palette, not buffer (buffer = plasma)
        for (x in 0...width)
        {
            for (y in 0...height)
            {
                // draw every pixel again, with the shifted palette color
                buffer[x][y] = (plasma[x][y] + palette_shift) % palette.length;
                // buffer[x][y] = palette[(plasma[x][y] + palette_shift) % palette.length];
            }
        }
        return palette;
        // return null;
    }

    public function keyboard(_) : Void
    {
    }
}