// @see http://lodev.org/cgtutor/plasma.html

package sin;

class DistanceToCenterEffect extends BaseEffect
{
    override private function getColor(x : Int, y : Int, w : Int, h : Int) : Int
    {
        return Math.ceil(
            127.0 + 127.0 *
            Math.sin((Math.sqrt((x - w / 2.0) * (x - w / 2.0) + (y - h / 2.0) * (y - h / 2.0))) / 8.0)
        );
    }
}