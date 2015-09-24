// @see http://lodev.org/cgtutor/tunnel.html

package tunnel;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

class BlueXOR implements IEffect
{
    var texture : Array<Array<Int>>;
    var distance : Array<Array<Int>>;
    var angle : Array<Array<Int>>;

    static inline var TEXTURE_WIDTH : Int = 256;
    static inline var TEXTURE_HEIGHT : Int = 256;

	public function new()
    {
        texture = new Array<Array<Int>>();
        distance = new Array<Array<Int>>();
        angle = new Array<Array<Int>>();
	}

    public function init(w : Int, h : Int, _) : Void
    {
        // generate the texture
        for (x in 0...TEXTURE_WIDTH)
        {
            texture[x] = new Array<Int>();

            for (y in 0...TEXTURE_HEIGHT)
            {
                texture[x][y] = EffectUtils.ToInt(x * 256 / TEXTURE_WIDTH) ^ EffectUtils.ToInt(y * 256 / TEXTURE_HEIGHT);
            }
        }

        // generate non-linear transformation table
        var ratio : Float = 32.0;

        for (x in 0...w)
        {
            distance[x] = new Array<Int>();
            angle[x] = new Array<Int>();

            for (y in 0...h)
            {
                distance[x][y] = EffectUtils.ToInt(ratio * TEXTURE_HEIGHT / Math.sqrt((x - w / 2.0) * (x - w / 2.0) + (y - h / 2.0) * (y - h / 2.0))) % TEXTURE_HEIGHT;
                angle[x][y] = EffectUtils.ToInt(0.5 * TEXTURE_WIDTH * Math.atan2(y - h / 2.0, x - w / 2.0) / Math.PI);
            }
        }
    }

    public function render(frame : Bitmap) : Void
    {
        var bm : BitmapData = frame.bitmapData;

        var w : Int = bm.width;
        var h : Int = bm.height;

        var animation : Float = EffectUtils.getTime() / 1000.0;
        // calculate the shift values out of the animation value
        var shift_x : Int = EffectUtils.ToInt(TEXTURE_WIDTH * 1.0 * animation);
        var shift_y : Int = EffectUtils.ToInt(TEXTURE_HEIGHT * 0.25 * animation);

        bm.lock();
        for (y in 0...h)
        {
            for (x in 0...w)
            {
                // get the texel from the texture by using the tables, shifted with the animation values
                bm.setPixel(x, y, texture[EffectUtils.ToInt(distance[x][y] + shift_x) % TEXTURE_WIDTH][EffectUtils.ToInt(angle[x][y] + shift_y) % TEXTURE_HEIGHT]);
                // bm.setPixel(x, y, texture[x % TEXTURE_WIDTH][y % TEXTURE_HEIGHT]);
            }
        }
        bm.unlock();
    }

    public function keyboard(_) : Void
    {
    }
}