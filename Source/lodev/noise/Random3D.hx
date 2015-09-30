// @see http://lodev.org/cgtutor/randomnoise.html

package lodev.noise;

class Random3D implements IEffect
{
    var noise : Array<Array<Array<Float>>>;
    var width : Int;
    var height : Int;

    static inline var NOISE_WIDTH : Int = 192;
    static inline var NOISE_HEIGHT : Int = 192;
    static inline var NOISE_DEPTH : Int = 64;

	public function new()
    {
        noise = new Array<Array<Array<Float>>>();
        width = 0;
        height = 0;
	}

    public function init(width : Int, height : Int) : Array<Array<Int>>
    {
        this.width = width;
        this.height = height;

        // generate noise
        for (x in 0...NOISE_WIDTH)
        {
            noise[x] = new Array<Array<Float>>();

            for (y in 0...NOISE_HEIGHT)
            {
                noise[x][y] = new Array<Float>();

                for (z in 0...NOISE_DEPTH)
                {
                    noise[x][y][z] = (EffectUtils.Rand() % 32768) / 32768.0;
                }
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
                buffer[x][y] = getPixel(x, y, EffectUtils.GetTime() / 40.0);
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

    private inline function getPixel(x : Int, y : Int, t : Float) : Int
    {
        var L : Float = 192 + EffectUtils.ToInt(turbulence(x, y, t, 32, NOISE_WIDTH, NOISE_HEIGHT, NOISE_DEPTH)) / 4;
        return EffectUtils.ColorHSL(169, 255, L);
    }

    private function smoothNoise(x : Float, y : Float, z : Float, width : Int, height : Int, depth : Int) : Float
    {
        // get fractional part of x and y
        var fract_x : Float = x - EffectUtils.ToInt(x);
        var fract_y : Float = y - EffectUtils.ToInt(y);
        var fract_z : Float = z - EffectUtils.ToInt(z);

        // wrap around
        var x1 : Int = (EffectUtils.ToInt(x) + width) % width;
        var y1 : Int = (EffectUtils.ToInt(y) + height) % height;
        var z1 : Int = (EffectUtils.ToInt(z) + depth) % depth;

        // neighbor values
        var x2 : Int = (x1 + width - 1) % width;
        var y2 : Int = (y1 + height - 1) % height;
        var z2 : Int = (z1 + depth - 1) % depth;

        // smooth the noise with bilinear interpolation
        var value : Float = 0.0;
        value += fract_x * fract_y * fract_z * noise[x1][y1][z1];
        value += fract_x * (1 - fract_y) * fract_z * noise[x1][y2][z1];
        value += (1 - fract_x) * fract_y * fract_z * noise[x2][y1][z1];
        value += (1 - fract_x) * (1 - fract_y) * fract_z * noise[x2][y2][z1];

        value += fract_x * fract_y * (1 - fract_z) * noise[x1][y1][z2];
        value += fract_x * (1 - fract_y) * (1 - fract_z) * noise[x1][y2][z2];
        value += (1 - fract_x) * fract_y * (1 - fract_z) * noise[x2][y1][z2];
        value += (1 - fract_x) * (1 - fract_y) * (1 - fract_z) * noise[x2][y2][z2];
        return value;
    }

    private inline function turbulence(x : Float, y : Float, z : Float, size : Float, width : Int, height : Int, depth : Int) : Float
    {
        var value : Float = 0.0;
        var initial_size : Float = size;

        while (size >= 1)
        {
            value += smoothNoise(x / size, y / size, z / size, width, height, depth) * size;
            size /= 2.0;
        }
        return 128.0 * value / initial_size;
    }
}