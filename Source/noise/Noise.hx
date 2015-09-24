// @see http://lodev.org/cgtutor/randomnoise.html

package noise;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

class Noise implements IEffect
{
    var noise : Array<Array<Float>>;

    static inline var NOISE_WIDTH : Int = 128;
    static inline var NOISE_HEIGHT : Int = 128;

	public function new()
    {
        noise = new Array<Array<Float>>();
	}

    public function init(w : Int, h : Int, _) : Void
    {
        // generate noise
        for (x in 0...NOISE_WIDTH)
        {
            noise[x] = new Array<Float>();

            for (y in 0...NOISE_HEIGHT)
            {
                noise[x][y] = (EffectUtils.rand() % 32768) / 32768.0;
            }
        }
    }

    public function render(frame : Bitmap) : Void
    {
        var bm : BitmapData = frame.bitmapData;

        var w : Int = bm.width;
        var h : Int = bm.height;

        bm.lock();
        for (y in 0...h)
        {
            for (x in 0...w)
            {
                bm.setPixel(x, y, getPixel(x, y, NOISE_WIDTH, NOISE_HEIGHT));
            }
        }
        bm.unlock();
    }

    public function keyboard(_) : Void
    {
    }

    private function getPixel(x : Int, y : Int, width : Int, height : Int) : Int
    {
        var component : Int = EffectUtils.ToInt(noise[x % width][y % height] * 256);
        return EffectUtils.ColorRGB(component, component, component);
    }
}