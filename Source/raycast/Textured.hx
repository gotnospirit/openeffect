// @see http://lodev.org/cgtutor/raycasting.html

package raycast;

class Textured extends BaseTextured
{
    override private function generateTextures(texture_width : Int, texture_height : Int) : Array<Array<Int>>
    {
        var result = new Array<Array<Int>>();
        for (i in 0...8)
        {
            result[i] = new Array<Int>();
        }

        for (x in 0...texture_width)
        {
            for (y in 0...texture_height)
            {
                var xorcolor : Int = EffectUtils.ToInt(x * 256 / texture_width) ^ EffectUtils.ToInt(y * 256 / texture_height);
                // var xcolor : Int = EffectUtils.ToInt(x * 256 / texture_width);
                var ycolor : Int = EffectUtils.ToInt(y * 256 / texture_height);
                var xycolor : Int = EffectUtils.ToInt(y * 128 / texture_height + x * 128 / texture_width);

                var index : Int = texture_width * y + x;

                result[0][index] = 65536 * 254 * ((x != y && x != texture_width - y) ? 1 : 0); //flat red texture with black cross
                result[1][index] = xycolor + 256 * xycolor + 65536 * xycolor; //sloped greyscale
                result[2][index] = 256 * xycolor + 65536 * xycolor; //sloped yellow gradient
                result[3][index] = xorcolor + 256 * xorcolor + 65536 * xorcolor; //xor greyscale
                result[4][index] = 256 * xorcolor; //xor green
                result[5][index] = 65536 * 192 * (((0 != (x % 16)) && (0 != (y % 16))) ? 1 : 0); //red bricks
                result[6][index] = 65536 * ycolor; //red gradient
                result[7][index] = 128 + 256 * 128 + 65536 * 128; //flat grey texture
            }
        }
        return result;
    }
}