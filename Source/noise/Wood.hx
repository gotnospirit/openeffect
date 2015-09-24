// @see http://lodev.org/cgtutor/randomnoise.html

package noise;

class Wood extends Turbulence
{
    override private function getPixel(x : Int, y : Int, width : Int, height : Int) : Int
    {
        var xy_period : Float = 12.0; // number of rings
        var turb_power : Float = 0.1; // makes twists
        var turb_size : Float = 32.0; // initial size of the turbulence

        var x_value : Float = (x - height / 2) / height;
        var y_value : Float = (y - width / 2) / width;
        var dist_value : Float = Math.sqrt(x_value * x_value + y_value * y_value) + turb_power * turbulence(x, y, turb_size, width, height) / 256.0;
        var sine_value : Float = 128.0 * Math.abs(Math.sin(2 * xy_period * dist_value * Math.PI));

        return EffectUtils.ColorRGB(EffectUtils.ToInt(80 + sine_value), EffectUtils.ToInt(30 + sine_value), 30);
    }
}