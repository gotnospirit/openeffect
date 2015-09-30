// @see http://lodev.org/cgtutor/randomnoise.html

package lodev.noise;

class Marble extends Turbulence
{
    override private function getPixel(x : Int, y : Int, width : Int, height : Int) : Int
    {
        // x_period and y_period together define the angle of the lines
        // x_period and y_period both 0 ==> it becomes a normal clouds or turbulence pattern
        var x_period : Float = 5.0; // defines repetition of marble lines in x direction
        var y_period : Float = 10.0; // defines repetition of marble lines in y direction
        // turb_power = 0 ==> it becomes a normal sine pattern
        var turb_power : Float = 5.0; // makes twists
        var turb_size : Float = 32.0; // initial size of the turbulence

        var xy_value : Float = x * x_period / height + y * y_period / width + turb_power * turbulence(x, y, turb_size, width, height) / 256.0;
        var sine_value : Float = 256 * Math.abs(Math.sin(xy_value * Math.PI));
        var component : Int = EffectUtils.ToInt(sine_value);

        return EffectUtils.ColorRGB(component, component, component);
    }
}