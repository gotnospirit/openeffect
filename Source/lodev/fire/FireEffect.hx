// @see http://lodev.org/cgtutor/fire.html

package lodev.fire;

class FireEffect implements IEffect
{
    var palette : Array<Int>;
    var width : Int;
    var height : Int;

	public function new()
    {
        palette = new Array<Int>();
        width = 0;
        height = 0;
	}

    public function init(width : Int, height : Int) : Array<Array<Int>>
    {
        this.width = width;
        this.height = height;

        // Init palette
        for (i in 0...256)
        {
            //HSLtoRGB is used to generate colors:
            //Hue goes from 0 to 85: red to yellow
            //Saturation is always the maximum: 255
            //Lightness is 0..255 for x=0..128, and 255 for x=128..255

            //set the palette to the calculated RGB value
            palette[i] = EffectUtils.ColorHSL(i / 3, 255, EffectUtils.Min(255, i * 2));
        }
        return EffectUtils.CreateBuffer(width, height, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        var palette_depth : Int = palette.length;

        // randomize the bottom row of the fire buffer
        for (x in 0...width)
        {
            buffer[x][height - 1] = (32768 + EffectUtils.Rand()) % palette_depth;
        }

        // do the fire calculations for every pixel, from top to bottom
        for (y in 0...height - 1)
        {
            for (x in 0...width)
            {
                buffer[x][y] = EffectUtils.ToInt(
                    (
                        buffer[(x - 1 + width) % width][(y + 1) % height]
                            + buffer[(x) % width][(y + 1) % height]
                            + buffer[(x + 1) % width][(y + 1) % height]
                            + buffer[(x) % width][(y + 2) % height]
                    )
                    / (129 / 32)
                );
            }
        }
        return palette;
    }

    public function update(_) : Void
    {
    }

    public function keyboard(_) : Void
    {
    }
}