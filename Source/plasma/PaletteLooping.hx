// @see http://lodev.org/cgtutor/plasma.html

package plasma;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

class PaletteLooping implements IEffect
{
    var palette : Array<Int>;
    var plasma : Array<Array<Int>>;

	public function new()
    {
        palette = new Array<Int>();
        plasma = new Array<Array<Int>>();
	}

    public function init(w : Int, h : Int) : Void
    {
        // generate the palette
        for (i in 0...256)
        {
            palette[i] = EffectUtils.ColorHSV(i, 255, 255);
        }

        // generate the plasma once
        for (x in 0...w)
        {
            plasma[x] = new Array<Int>();

            for (y in 0...h)
            {
                // cf sin.SumEffect
                plasma[x][y] = Math.ceil(
                    (
                        (127.0 + 127.0 * Math.sin(x / 16.0))
                        + (127.0 + 127.0 * Math.sin(y / 16.0))
                    ) / 2
                );
            }
        }
    }

    public function render(frame : Bitmap) : Void
    {
        var bm : BitmapData = frame.bitmapData;

        var w : Int = bm.width;
        var h : Int = bm.height;

        // the parameter to shift the palette varies with time
        var palette_shift : Int = Math.ceil(EffectUtils.getTime() / 10);

        bm.lock();
        for (y in 0...h)
        {
            for (x in 0...w)
            {
                // draw every pixel again, with the shifted palette color
                var color : Int = palette[(plasma[x][y] + palette_shift) % palette.length];

                bm.setPixel(x, y, color);
            }
        }
        bm.unlock();
    }
}