// @see http://lodev.org/cgtutor/randomnoise.html

package lodev.noise;

class SmoothNoise extends Noise
{
    override private function getPixel(x : Int, y : Int, width : Int, height : Int) : Int
    {
        var component = EffectUtils.ToInt(smoothNoise(x / 8, y / 8, width, height) * 256);
        return EffectUtils.ColorRGB(component, component, component);
    }

    private function smoothNoise(x : Float, y : Float, width : Int, height : Int) : Float
    {
        // get fractional part of x and y
        var fract_x : Float = x - EffectUtils.ToInt(x);
        var fract_y : Float = y - EffectUtils.ToInt(y);

        // wrap around
        var x1 : Int = (EffectUtils.ToInt(x) + width) % width;
        var y1 : Int = (EffectUtils.ToInt(y) + height) % height;

        // neighbor values
        var x2 : Int = (x1 + width - 1) % width;
        var y2 : Int = (y1 + height - 1) % height;

        // smooth the noise with bilinear interpolation
        var value : Float = 0.0;
        value += fract_x * fract_y * noise[x1][y1];
        value += fract_x * (1 - fract_y) * noise[x1][y2];
        value += (1 - fract_x) * fract_y * noise[x2][y1];
        value += (1 - fract_x) * (1 - fract_y) * noise[x2][y2];
        return value;
    }
}