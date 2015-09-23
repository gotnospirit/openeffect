// @see http://lodev.org/cgtutor/raycasting.html

package raycast;

import openfl.display.BitmapData;

class Textured extends BaseEffect
{
    var texture : Array<Array<Int>>;

    static inline var TEXTURE_WIDTH : Int = 64;
    static inline var TEXTURE_HEIGHT : Int = 64;

	public function new()
    {
        super();

        texture = new Array<Array<Int>>();
	}

    override private function initWorld() : Array<Array<Int>>
    {
        // generate some textures
        for (i in 0...8)
        {
            texture[i] = new Array<Int>();
        }

        for (x in 0...TEXTURE_WIDTH)
        {
            for (y in 0...TEXTURE_HEIGHT)
            {
                var xorcolor : Int = Math.round(x * 256 / TEXTURE_WIDTH) ^ Math.round(y * 256 / TEXTURE_HEIGHT);
                // var xcolor : Int = Math.round(x * 256 / TEXTURE_WIDTH);
                var ycolor : Int = Math.round(y * 256 / TEXTURE_HEIGHT);
                var xycolor : Int = Math.round(y * 128 / TEXTURE_HEIGHT + x * 128 / TEXTURE_WIDTH);

                texture[0][TEXTURE_WIDTH * y + x] = 65536 * 254 * ((x != y && x != TEXTURE_WIDTH - y) ? 1 : 0); //flat red texture with black cross
                texture[1][TEXTURE_WIDTH * y + x] = xycolor + 256 * xycolor + 65536 * xycolor; //sloped greyscale
                texture[2][TEXTURE_WIDTH * y + x] = 256 * xycolor + 65536 * xycolor; //sloped yellow gradient
                texture[3][TEXTURE_WIDTH * y + x] = xorcolor + 256 * xorcolor + 65536 * xorcolor; //xor greyscale
                texture[4][TEXTURE_WIDTH * y + x] = 256 * xorcolor; //xor green
                texture[5][TEXTURE_WIDTH * y + x] = 65536 * 192 * (((0 != (x % 16)) && (0 != (y % 16))) ? 1 : 0); //red bricks
                texture[6][TEXTURE_WIDTH * y + x] = 65536 * ycolor; //red gradient
                texture[7][TEXTURE_WIDTH * y + x] = 128 + 256 * 128 + 65536 * 128; //flat grey texture
            }
        }

        return [
            [4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,7,7,7,7,7,7,7,7],
            [4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,7],
            [4,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7],
            [4,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7],
            [4,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,7],
            [4,0,4,0,0,0,0,5,5,5,5,5,5,5,5,5,7,7,0,7,7,7,7,7],
            [4,0,5,0,0,0,0,5,0,5,0,5,0,5,0,5,7,0,0,0,7,7,7,1],
            [4,0,6,0,0,0,0,5,0,0,0,0,0,0,0,5,7,0,0,0,0,0,0,8],
            [4,0,7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,7,7,1],
            [4,0,8,0,0,0,0,5,0,0,0,0,0,0,0,5,7,0,0,0,0,0,0,8],
            [4,0,0,0,0,0,0,5,0,0,0,0,0,0,0,5,7,0,0,0,7,7,7,1],
            [4,0,0,0,0,0,0,5,5,5,5,0,5,5,5,5,7,7,7,7,7,7,7,1],
            [6,6,6,6,6,6,6,6,6,6,6,0,6,6,6,6,6,6,6,6,6,6,6,6],
            [8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4],
            [6,6,6,6,6,6,0,6,6,6,6,0,6,6,6,6,6,6,6,6,6,6,6,6],
            [4,4,4,4,4,4,0,4,4,4,6,0,6,2,2,2,2,2,2,2,3,3,3,3],
            [4,0,0,0,0,0,0,0,0,4,6,0,6,2,0,0,0,0,0,2,0,0,0,2],
            [4,0,0,0,0,0,0,0,0,0,0,0,6,2,0,0,5,0,0,2,0,0,0,2],
            [4,0,0,0,0,0,0,0,0,4,6,0,6,2,0,0,0,0,0,2,2,0,2,2],
            [4,0,6,0,6,0,0,0,0,4,6,0,0,0,0,0,5,0,0,0,0,0,0,2],
            [4,0,0,5,0,0,0,0,0,4,6,0,6,2,0,0,0,0,0,2,2,0,2,2],
            [4,0,6,0,6,0,0,0,0,4,6,0,6,2,0,0,5,0,0,2,0,0,0,2],
            [4,0,0,0,0,0,0,0,0,4,6,0,6,2,0,0,0,0,0,2,0,0,0,2],
            [4,4,4,4,4,4,4,4,4,4,1,1,1,2,2,2,2,2,2,3,3,3,3,3]
        ];
    }

    override private function raycast(bm : BitmapData, w : Int, h : Int, world : Array<Array<Int>>) : Void
    {
        for (x in 0...w)
        {
            // calculate ray position and direction
            var camera_x : Float = 2 * x / w - 1;   // x-coordinate in camera space
            var ray_pos_x : Float = posX;
            var ray_pos_y : Float = posY;
            var ray_dir_x : Float = dirX + planeX * camera_x;
            var ray_dir_y : Float = dirY + planeY * camera_x;

            // which box of the map we're in
            var map_x : Int = Math.round(ray_pos_x);
            var map_y : Int = Math.round(ray_pos_y);

            // length of ray from current position to next x or y-side
            var side_dist_x : Float = 0.0;
            var side_dist_y : Float = 0.0;

            // length of ray from one x or y-side to next x or y-side
            var delta_dist_x : Float = Math.sqrt(1 + (ray_dir_y * ray_dir_y) / (ray_dir_x * ray_dir_x));
            var delta_dist_y : Float = Math.sqrt(1 + (ray_dir_x * ray_dir_x) / (ray_dir_y * ray_dir_y));
            var perp_wall_dist : Float = 0.0;

            // what direction to step in x or y-direction (either +1 or -1)
            var step_x : Int = 0;
            var step_y : Int = 0;

            // was there a wall hit?
            var hit : Int = 0;
            // was a NS or a EW wall hit?
            var side : Int = 0;

            // calculate step and initial side_dist
            if (ray_dir_x < 0)
            {
                step_x = -1;
                side_dist_x = (ray_pos_x - map_x) * delta_dist_x;
            }
            else
            {
                step_x = 1;
                side_dist_x = (map_x + 1.0 - ray_pos_x) * delta_dist_x;
            }

            if (ray_dir_y < 0)
            {
                step_y = -1;
                side_dist_y = (ray_pos_y - map_y) * delta_dist_y;
            }
            else
            {
                step_y = 1;
                side_dist_y = (map_y + 1.0 - ray_pos_y) * delta_dist_y;
            }

            // perform DDA
            while (0 == hit)
            {
                // jump to next map square, OR in x-direction, OR in y-direction
                if (side_dist_x < side_dist_y)
                {
                    side_dist_x += delta_dist_x;
                    map_x += step_x;
                    side = 0;
                }
                else
                {
                    side_dist_y += delta_dist_y;
                    map_y += step_y;
                    side = 1;
                }

                // check if ray has hit a wall
                if (world[map_x][map_y] > 0)
                {
                    hit = 1;
                }
            }

            // Calculate distance projected on camera direction (oblique distance will give fisheye effect!)
            if (0 == side)
            {
                perp_wall_dist = Math.abs((map_x - ray_pos_x + (1 - step_x) / 2) / ray_dir_x);
            }
            else
            {
                perp_wall_dist = Math.abs((map_y - ray_pos_y + (1 - step_y) / 2) / ray_dir_y);
            }

            // Calculate height of line to draw on screen
            var line_height : Int = abs(h / perp_wall_dist);

            // calculate lowest and highest pixel to fill in current stripe
            var draw_start : Int = Math.round(-line_height / 2 + h / 2);
            if (draw_start < 0)
            {
                draw_start = 0;
            }

            var draw_end : Int = Math.round(line_height / 2 + h / 2);
            if (draw_end >= h)
            {
                draw_end = h - 1;
            }

            // texturing calculations
            var tex_num : Int = world[map_x][map_y] - 1; // 1 substracted from it so that texture 0 can be used!

            // calculate value of wall_x
            var wall_x : Float = 0.0; // where exactly the wall was hit

            if (1 == side)
            {
                wall_x = ray_pos_x + ((map_y - ray_pos_y + (1 - step_y) / 2) / ray_dir_y) * ray_dir_x;
            }
            else
            {
                wall_x = ray_pos_y + ((map_x - ray_pos_x + (1 - step_x) / 2) / ray_dir_x) * ray_dir_y;
            }

            wall_x -= Math.floor(wall_x);

            // x coordinate on the texture
            var tex_x : Int = Math.round(wall_x * TEXTURE_WIDTH);
            if (0 == side && ray_dir_x > 0)
            {
                tex_x = TEXTURE_WIDTH - tex_x - 1;
            }
            if (1 == side && ray_dir_y < 0)
            {
                tex_x = TEXTURE_WIDTH - tex_x - 1;
            }

            for (y in draw_start...draw_end)
            {
                var d : Int = Math.ceil(y * 256 - h * 128 + line_height * 128); // 256 and 128 factors to avoid floats
                var tex_y : Int = Math.ceil(((d * TEXTURE_HEIGHT) / line_height) / 256);
                var color : Int = texture[tex_num][TEXTURE_HEIGHT * tex_y + tex_x];
                // make color darker for y-sides: R, G and B byte each divided through two with a "shift" and an "and"
                if (1 == side)
                {
                    color = (color >> 1) & 8355711;
                }

                bm.setPixel(x, y, color);
            }
        }
    }
}