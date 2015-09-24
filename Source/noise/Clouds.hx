// @see http://lodev.org/cgtutor/randomnoise.html

package noise;

class Clouds extends Turbulence
{
    override private function getPixel(x : Int, y : Int, width : Int, height : Int) : Int
    {
        var L : Float = 192 + EffectUtils.ToInt(turbulence(x, y, 64, width, height)) / 4;
        return EffectUtils.ColorHSL(169, 255, L);
    }
}