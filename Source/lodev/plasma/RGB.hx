// @see http://lodev.org/cgtutor/plasma.html

package lodev.plasma;

class RGB implements IEffect
{
    var width : Int;
    var height : Int;

	public function new(width : Int, height : Int)
    {
        this.width = width;
        this.height = height;
	}

    public function init() : Array<Array<Int>>
    {
        return EffectUtils.CreateBuffer(width, height, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        var time : Float = EffectUtils.GetTime() / 50.0;

        for (x in 0...width)
        {
            for (y in 0...height)
            {
                var value : Float = Math.sin(dist(x + time, y, 128.0, 128.0) / 8.0)
                    + Math.sin(dist(x, y, 64.0, 64.0) / 8.0)
                    + Math.sin(dist(x, y + time / 7, 192.0, 64) / 7.0)
                    + Math.sin(dist(x, y, 192.0, 100.0) / 8.0);

                var color : Int = EffectUtils.ToInt(4 + value) * 32;

                buffer[x][y] = EffectUtils.ColorRGB(color, color * 2, 255 - color);
            }
        }
        return null;
    }

    public function update(_) : Void
    {
    }

    public function keyboard(_) : Void
    {
    }

    private inline function dist(a : Float, b : Float, c : Float, d : Float) : Float
    {
        return Math.sqrt((a - c) * (a - c) + (b - d) * (b - d));
    }
}