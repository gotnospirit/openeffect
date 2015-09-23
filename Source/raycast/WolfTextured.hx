// @see http://lodev.org/cgtutor/raycasting.html

package raycast;

import openfl.display.BitmapData;
import openfl.Assets;

class WolfTextured extends BaseTextured
{
    private function getTexturePixels(index : Int) : Array<Int>
    {
        var result = new Array<Int>();
        var pix = ["eagle.png", "redbrick.png", "purplestone.png", "greystone.png", "bluestone.png", "mossy.png", "wood.png", "colorstone.png"];
        var texture : BitmapData = Assets.getBitmapData("assets/wolftex/" + pix[index]);
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
        return [
            getTexturePixels(0),
            getTexturePixels(1),
            getTexturePixels(2),
            getTexturePixels(3),
            getTexturePixels(4),
            getTexturePixels(5),
            getTexturePixels(6),
            getTexturePixels(7)
        ];
    }
}