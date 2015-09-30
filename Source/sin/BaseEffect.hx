package sin;

class BaseEffect implements IEffect
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

    public function keyboard(_) : Void
    {
    }

    private function getColor(x : Int, y : Int, w : Int, h : Int) : Int
    {
        return 0;
    }
}