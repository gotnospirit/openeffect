// @see http://lodev.org/cgtutor/randomnoise.html

package lodev.noise;

class Noise implements IEffect
{
    var noise : Array<Array<Float>>;
    var width : Int;
    var height : Int;

    static inline var NOISE_WIDTH : Int = 128;
    static inline var NOISE_HEIGHT : Int = 128;

	public function new(width : Int, height : Int)
    {
        noise = new Array<Array<Float>>();
        this.width = width;
        this.height = height;
	}

    public function init() : Array<Array<Int>>
    {
        // generate noise
        for (x in 0...NOISE_WIDTH)
        {
            noise[x] = new Array<Float>();

            for (y in 0...NOISE_HEIGHT)
            {
                noise[x][y] = (EffectUtils.Rand() % 32768) / 32768.0;
            }
        }
        return EffectUtils.CreateBuffer(width, height, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        for (x in 0...width)
        {
            for (y in 0...height)
            {
                buffer[x][y] = getPixel(x, y, NOISE_WIDTH, NOISE_HEIGHT);
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

    private function getPixel(x : Int, y : Int, width : Int, height : Int) : Int
    {
        var component : Int = EffectUtils.ToInt(noise[x % width][y % height] * 256);
        return EffectUtils.ColorRGB(component, component, component);
    }
}