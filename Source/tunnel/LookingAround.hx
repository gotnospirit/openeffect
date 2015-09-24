// @see http://lodev.org/cgtutor/tunnel.html

package tunnel;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.Assets;

class LookingAround implements IEffect
{
    var texture : BitmapData;
    var distance : Array<Array<Int>>;
    var angle : Array<Array<Int>>;

	public function new()
    {
        distance = new Array<Array<Int>>();
        angle = new Array<Array<Int>>();
	}

    public function init(w : Int, h : Int, _) : Void
    {
        // generate the texture
        texture = Assets.getBitmapData("assets/tunnelarboreatex.png");

        var texture_width = texture.width;
        var texture_height = texture.height;

        // generate non-linear transformation table, now for the bigger buffers (twice as big)
        var ratio : Float = 32.0;

        for (x in 0...w * 2)
        {
            distance[x] = new Array<Int>();
            angle[x] = new Array<Int>();

            for (y in 0...h * 2)
            {
                distance[x][y] = EffectUtils.ToInt(ratio * texture_height / Math.sqrt((x - w) * (x - w) + (y - h) * (y - h))) % texture_height;
                angle[x][y] = EffectUtils.ToInt(0.5 * texture_width * Math.atan2(y - h, x - w) / Math.PI);
            }
        }
    }

    public function render(frame : Bitmap) : Void
    {
        var bm : BitmapData = frame.bitmapData;

        var w : Int = bm.width;
        var h : Int = bm.height;

        var texture_width = texture.width;
        var texture_height = texture.height;

        var animation : Float = EffectUtils.getTime() / 1000.0;
        // calculate the shift values out of the animation value
        var shift_x : Int = EffectUtils.ToInt(texture_width * 1.0 * animation);
        var shift_y : Int = EffectUtils.ToInt(texture_height * 0.25 * animation);
        // calculate the look values out of the animation value
        // by using sine functions, it'll alternate between looking left/right and up/down
        // make sure that x + shift_look_x never goes outside the dimensions of the table, same for y
        var shift_look_x : Int = EffectUtils.ToInt(w / 2 + (w / 2 * Math.sin(animation)));
        var shift_look_y : Int = EffectUtils.ToInt(h / 2 + (h / 2 * Math.sin(animation * 2.0)));

        bm.lock();
        for (y in 0...h)
        {
            for (x in 0...w)
            {
                // get the texel from the texture by using the tables, shifted with the animation variable
                // now, x and y are shifted as well with the "look" animation values
                bm.setPixel(x, y, texture.getPixel32(
                    EffectUtils.ToInt(distance[x + shift_look_x][y + shift_look_y] + shift_x) % texture_width,
                    EffectUtils.ToInt(angle[x + shift_look_x][y + shift_look_y] + shift_y) % texture_height
                ));
            }
        }
        bm.unlock();
    }

    public function keyboard(_) : Void
    {
    }
}