// @see http://lodev.org/cgtutor/raycasting.html

package raycast;

import openfl.display.BitmapData;
import openfl.Assets;

class WolfTextured extends BaseTextured
{
    var assets : Array<String>;

    public function new()
    {
        super();

        assets = ["eagle.png", "redbrick.png", "purplestone.png", "greystone.png", "bluestone.png", "mossy.png", "wood.png", "colorstone.png"];
    }

    private function getTexturePixels(filepath : String) : Array<Int>
    {
        var result = new Array<Int>();
        var texture : BitmapData = Assets.getBitmapData(filepath);
        var texture_width = texture.width;
        var texture_height = texture.height;

        for (x in 0...texture_width)
        {
            for (y in 0...texture_height)
            {
                result[texture_width * y + x] = texture.getPixel32(x, y);
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