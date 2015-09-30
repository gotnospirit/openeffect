// @see http://lodev.org/cgtutor/tunnel.html

package tunnel;

class LookingAround extends BlueXOR
{
    override public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        var animation : Float = EffectUtils.GetTime() / 1000.0;
        // calculate the shift values out of the animation value
        var shift_x : Int = EffectUtils.ToInt(texture_width * 1.0 * animation);
        var shift_y : Int = EffectUtils.ToInt(texture_height * 0.25 * animation);
        // calculate the look values out of the animation value
        // by using sine functions, it'll alternate between looking left/right and up/down
        // make sure that x + shift_look_x never goes outside the dimensions of the table, same for y
        var shift_look_x : Int = EffectUtils.ToInt(width / 2 + (width / 2 * Math.sin(animation)));
        var shift_look_y : Int = EffectUtils.ToInt(height / 2 + (height / 2 * Math.sin(animation * 2.0)));

        for (x in 0...width)
        {
            for (y in 0...height)
            {
                // get the texel from the texture by using the tables, shifted with the animation variable
                // now, x and y are shifted as well with the "look" animation values
                buffer[x][y] = texture[EffectUtils.ToInt(distance[x + shift_look_x][y + shift_look_y] + shift_x) % texture_width][EffectUtils.ToInt(angle[x + shift_look_x][y + shift_look_y] + shift_y) % texture_height];
            }
        }
        return null;
    }

    override private function generateTexture() : Array<Array<Int>>
    {
        return EffectUtils.GetAssetPixels("assets/tunnelarboreatex.png");
    }

    override private function generateDistanceTable(ratio : Float) : Array<Array<Int>>
    {
        // generate non-linear transformation table
        var result = new Array<Array<Int>>();

        for (x in 0...width * 2)
        {
            result[x] = new Array<Int>();

            for (y in 0...height * 2)
            {
                result[x][y] = EffectUtils.ToInt(ratio * texture_height / Math.sqrt((x - width) * (x - width) + (y - height) * (y - height))) % texture_height;
            }
        }
        return result;
    }

    override private function generateAngleTable() : Array<Array<Int>>
    {
        var result = new Array<Array<Int>>();

        for (x in 0...width * 2)
        {
            result[x] = new Array<Int>();

            for (y in 0...height * 2)
            {
                result[x][y] = EffectUtils.ToInt(0.5 * texture_width * Math.atan2(y - height, x - width) / Math.PI);
            }
        }
        return result;
    }
}