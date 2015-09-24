// @see http://lodev.org/cgtutor/plasma.html

package sin;

class SlopeEffect extends BaseEffect
{
    override private function getColor(x : Int, y : Int, w : Int, h : Int) : Int
    {
        return EffectUtils.ToInt(
            127.0 + 127.0 *
            Math.sin((x + y) / 8.0)
        );
    }
}