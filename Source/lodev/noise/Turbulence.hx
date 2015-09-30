// @see http://lodev.org/cgtutor/randomnoise.html

package lodev.noise;

class Turbulence extends SmoothNoise
{
    override private function getPixel(x : Int, y : Int, width : Int, height : Int) : Int
    {
        var component = EffectUtils.ToInt(turbulence(x, y, 64, width, height));
        return EffectUtils.ColorRGB(component, component, component);
    }

    private function turbulence(x : Float, y : Float, size : Float, width : Int, height : Int) : Float
    {
        var value : Float = 0.0;
        var initial_size : Float = size;

        while (size >= 1)
        {
            value += smoothNoise(x / size, y / size, width, height) * size;
            size /= 2.0;
        }
        return 128.0 * value / initial_size;
    }
}