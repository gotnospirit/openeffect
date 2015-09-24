// @see http://lodev.org/cgtutor/plasma.html

package plasma;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

class RGB implements IEffect
{
	public function new()
    {
	}

    public function init(w : Int, h : Int, _) : Void
    {
    }

    public function render(frame : Bitmap) : Void
    {
        var bm : BitmapData = frame.bitmapData;

        var w : Int = bm.width;
        var h : Int = bm.height;

        var time : Float = EffectUtils.getTime() / 50.0;

        bm.lock();
        for (y in 0...h)
        {
            for (x in 0...w)
            {
                var value : Float = Math.sin(dist(x + time, y, 128.0, 128.0) / 8.0)
                    + Math.sin(dist(x, y, 64.0, 64.0) / 8.0)
                    + Math.sin(dist(x, y + time / 7, 192.0, 64) / 7.0)
                    + Math.sin(dist(x, y, 192.0, 100.0) / 8.0);

                var color : Int = EffectUtils.ToInt(4 + value) * 32;

                bm.setPixel(x, y, EffectUtils.ColorRGB(color, color * 2, 255 - color));
            }
        }
        bm.unlock();
    }

    public function keyboard(_) : Void
    {
    }

    private inline function dist(a : Float, b : Float, c : Float, d : Float) : Float
    {
        return Math.sqrt((a - c) * (a - c) + (b - d) * (b - d));
    }
}