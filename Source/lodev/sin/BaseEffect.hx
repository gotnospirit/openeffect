package lodev.sin;

class BaseEffect implements IEffect
{
    var width : Int;
    var height : Int;

	public function new()
    {
        width = 0;
        height = 0;
	}

    public function init(width : Int, height : Int) : Array<Array<Int>>
    {
        this.width = width;
        this.height = height;

        return EffectUtils.CreateBuffer(width, height, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        for (x in 0...width)
        {
            for (y in 0...height)
            {
                var color : Int = getColor(x, y, width, height);

                buffer[x][y] = EffectUtils.ColorRGB(color, color, color);
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

    private function getColor(x : Int, y : Int, w : Int, h : Int) : Int
    {
        return 0;
    }
}