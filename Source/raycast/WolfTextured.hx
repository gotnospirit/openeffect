// @see http://lodev.org/cgtutor/raycasting.html

package raycast;

class WolfTextured extends BaseTextured
{
    var assets : Array<String>;

    public function new(width : Int, height : Int)
    {
        super(width, height);

        assets = ["eagle.png", "redbrick.png", "purplestone.png", "greystone.png", "bluestone.png", "mossy.png", "wood.png", "colorstone.png"];
    }

    private function getTexturePixels(filepath : String) : Array<Int>
    {
        var result = new Array<Int>();
        var texture : Array<Array<Int>> = EffectUtils.GetAssetPixels(filepath);
        var texture_width : Int = texture.length;
        for (x in 0...texture_width)
        {
            var len : Int = texture[x].length;

            for (y in 0...len)
            {
                result[texture_width * y + x] = texture[x][y];
            }
        }
        return result;
    }

    override private function generateTextures(texture_width : Int, texture_height : Int) : Array<Array<Int>>
    {
        var result = new Array<Array<Int>>();
        for (i in 0...assets.length)
        {
            result.push(getTexturePixels("assets/wolftex/" + assets[i]));
        }
        return result;
    }
}