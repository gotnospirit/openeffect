// @see http://lodev.org/cgtutor/tunnel.html

package tunnel;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.Assets;

class BetterTexture implements IEffect
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
        texture = Assets.getBitmapData("assets/tunnelstonetex.png");

        var texture_width = texture.width;
        var texture_height = texture.height;

        // generate non-linear transformation table
        var ratio : Float = 32.0;

        for (x in 0...w)
        {
            distance[x] = new Array<Int>();
            angle[x] = new Array<Int>();

            for (y in 0...h)
            {
                distance[x][y] = Math.ceil(ratio * texture_height / Math.sqrt((x - w / 2.0) * (x - w / 2.0) + (y - h / 2.0) * (y - h / 2.0))) % texture_height;
                angle[x][y] = Math.ceil(0.5 * texture_width * Math.atan2(y - h / 2.0, x - w / 2.0) / Math.PI);
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
        var shift_x : Int = Math.ceil(texture_width * 1.0 * animation);
        var shift_y : Int = Math.ceil(texture_height * 0.25 * animation);

        bm.lock();
        for (y in 0...h)
        {
            for (x in 0...w)
            {
                // get the texel from the texture by using the tables, shifted with the animation values
                bm.setPixel(x, y, texture.getPixel32(
                    Math.ceil(distance[x][y] + shift_x) % texture_width,
                    Math.ceil(angle[x][y] + shift_y) % texture_height
                ));
            }
        }
        bm.unlock();
    }

    public function keyboard(_) : Void
    {
    }
}