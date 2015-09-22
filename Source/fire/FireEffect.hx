// @see http://lodev.org/cgtutor/fire.html

package fire;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

class FireEffect implements IEffect
{
    var fire : Array<Array<Int>>;
    var palette : Array<Int>;

	public function new()
    {
        fire = new Array<Array<Int>>();
        palette = new Array<Int>();
	}

    public function init(w : Int, h : Int) : Void
    {
        for (x in 0...w)
        {
            fire[x] = new Array<Int>();

            for (y in 0...h)
            {
                fire[x][y] = 0;
            }
        }

        // Init palette
        for (i in 0...256)
        {
            //HSLtoRGB is used to generate colors:
            //Hue goes from 0 to 85: red to yellow
            //Saturation is always the maximum: 255
            //Lightness is 0..255 for x=0..128, and 255 for x=128..255

            //set the palette to the calculated RGB value
            palette[i] = EffectUtils.ColorHSL(i / 3, 255, min(255, i * 2));
        }
    }

    private inline function min(a : Int, b : Int) : Int
    {
        return a < b ? a : b;
    }

    public function render(frame : Bitmap) : Void
    {
        var bm : BitmapData = frame.bitmapData;

        var w : Int = bm.width;
        var h : Int = bm.height;
        var palette_depth : Int = palette.length;

        // randomize the bottom row of the fire buffer
        for (x in 0...w)
        {
            fire[x][h - 1] = EffectUtils.rand() % palette_depth;
        }

        // do the fire calculations for every pixel, from top to bottom
        for (y in 0...h - 1)
        {
            for (x in 0...w)
            {
                fire[x][y] = Math.ceil(
                    (
                        fire[(x - 1 + w) % w][(y + 1) % h]
                            + fire[(x) % w][(y + 1) % h]
                            + fire[(x + 1) % w][(y + 1) % h]
                            + fire[(x) % w][(y + 2) % h]
                    )
                    / (129 / 32)
                );
            }
        }

        bm.lock();
        for (y in 0...h)
        {
            for (x in 0...w)
            {
                bm.setPixel(x, y, palette[fire[x][y]]);
            }
        }
        bm.unlock();
    }
}