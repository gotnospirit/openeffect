// @see http://lodev.org/cgtutor/plasma.html

package sin;

class SumEffect extends BaseEffect
{
    override private function getColor(x : Int, y : Int, w : Int, h : Int) : Int
    {
        return Math.ceil(
            (
                (127.0 + 127.0 * Math.sin(x / 8.0))
                + (127.0 + 127.0 * Math.sin(y / 8.0))
            ) / 2
        );
    }
}