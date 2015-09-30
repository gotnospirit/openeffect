// @see http://lodev.org/cgtutor/tunnel.html

package lodev.tunnel;

class BlueXOR implements IEffect
{
    var texture : Array<Array<Int>>;
    var texture_width : Int;
    var texture_height : Int;

    var distance : Array<Array<Int>>;
    var angle : Array<Array<Int>>;

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

        // generate the texture
        texture = generateTexture();

        texture_width = texture.length;
        texture_height = texture[0].length;

        distance = generateDistanceTable(32.0);
        angle = generateAngleTable();
        return EffectUtils.CreateBuffer(width, height, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        var animation : Float = EffectUtils.GetTime() / 1000.0;
        // calculate the shift values out of the animation value
        var shift_x : Int = EffectUtils.ToInt(texture_width * 1.0 * animation);
        var shift_y : Int = EffectUtils.ToInt(texture_height * 0.25 * animation);

        for (x in 0...width)
        {
            for (y in 0...height)
            {
                // get the texel from the texture by using the tables, shifted with the animation values
                buffer[x][y] = texture[EffectUtils.ToInt(distance[x][y] + shift_x) % texture_width][EffectUtils.ToInt(angle[x][y] + shift_y) % texture_height];
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

    private function generateDistanceTable(ratio : Float) : Array<Array<Int>>
    {
        // generate non-linear transformation table
        var result = new Array<Array<Int>>();

        for (x in 0...width)
        {
            result[x] = new Array<Int>();

            for (y in 0...height)
            {
                result[x][y] = EffectUtils.ToInt(ratio * texture_height / Math.sqrt((x - width / 2.0) * (x - width / 2.0) + (y - height / 2.0) * (y - height / 2.0))) % texture_height;
            }
        }
        return result;
    }

    private function generateAngleTable() : Array<Array<Int>>
    {
        var result = new Array<Array<Int>>();

        for (x in 0...width)
        {
            result[x] = new Array<Int>();

            for (y in 0...height)
            {
                result[x][y] = EffectUtils.ToInt(0.5 * texture_width * Math.atan2(y - height / 2.0, x - width / 2.0) / Math.PI);
            }
        }
        return result;
    }

    private function generateTexture() : Array<Array<Int>>
    {
        var result = new Array<Array<Int>>();

        for (x in 0...256)
        {
            result[x] = new Array<Int>();

            for (y in 0...256)
            {
                result[x][y] = EffectUtils.ToInt(x * 256 / 256) ^ EffectUtils.ToInt(y * 256 / 256);
            }
        }
        return result;
    }
}