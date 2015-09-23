package sin;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

class BaseEffect implements IEffect
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

        bm.lock();
        for (y in 0...h)
        {
            for (x in 0...w)
            {
                var color : Int = getColor(x, y, w, h);

                bm.setPixel(x, y, EffectUtils.ColorRGB(color, color, color));
            }
        }
        bm.unlock();
    }

    public function keyboard(_) : Void
    {
    }

    private function getColor(x : Int, y : Int, w : Int, h : Int) : Int
    {
        return 0;
    }
}