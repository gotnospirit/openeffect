// @see http://lodev.org/cgtutor/raycasting.html

package raycast;

import openfl.display.BitmapData;

class FloorCeiling extends WolfTextured
{
    static inline var TEXTURE_WIDTH : Int = 64;
    static inline var TEXTURE_HEIGHT : Int = 64;

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
            var map_x : Int = EffectUtils.ToInt(ray_pos_x);
            var map_y : Int = EffectUtils.ToInt(ray_pos_y);

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
            var draw_start : Int = EffectUtils.ToInt(-line_height / 2 + h / 2);
            if (draw_start < 0)
            {
                draw_start = 0;
            }

            var draw_end : Int = EffectUtils.ToInt(line_height / 2 + h / 2);
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
            var tex_x : Int = EffectUtils.ToInt(wall_x * TEXTURE_WIDTH);
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
                var d : Int = EffectUtils.ToInt(y * 256 - h * 128 + line_height * 128); // 256 and 128 factors to avoid floats
                var tex_y : Int = EffectUtils.ToInt(((d * TEXTURE_HEIGHT) / line_height) / 256);
                var color : Int = textures[tex_num][TEXTURE_HEIGHT * tex_y + tex_x];
                // make color darker for y-sides: R, G and B byte each divided through two with a "shift" and an "and"
                if (1 == side)
                {
                    color = EffectUtils.ColorDarker(color);
                }

                bm.setPixel(x, y, color);
            }

            // Floor casting
            // x, y position of the floor texel at the bottom of the wall
            var floor_x_wall : Float = 0.0;
            var floor_y_wall : Float = 0.0;

            // 4 different wall directions possible
            if (0 == side && ray_dir_x > 0)
            {
                floor_x_wall = map_x;
                floor_y_wall = map_y + wall_x;
            }
            else if (0 == side && ray_dir_x < 0)
            {
                floor_x_wall = map_x + 1.0;
                floor_y_wall = map_y + wall_x;
            }
            else if (1 == side && ray_dir_y > 0)
            {
                floor_x_wall = map_x + wall_x;
                floor_y_wall = map_y;
            }
            else
            {
                floor_x_wall = map_x + wall_x;
                floor_y_wall = map_y + 1.0;
            }

            var dist_wall : Float = perp_wall_dist;
            var dist_player : Float = 0.0;
            var current_dist : Float = 0.0;

            if (draw_end < 0)
            {
                draw_end = h; // becomes < 0 when the integer overflows
            }

            // draw the floor from draw_end to the bottom of the screen
            for (y in draw_end + 1...h)
            {
                current_dist = h / (2.0 * y - h); // you could make a small lookup table for this instead

                var weight : Float = (current_dist - dist_player) / (dist_wall - dist_player);

                var current_floor_x : Float = weight * floor_x_wall + (1.0 - weight) * posX;
                var current_floor_y : Float = weight * floor_y_wall + (1.0 - weight) * posY;

                var floor_tex_x : Int = EffectUtils.ToInt(current_floor_x * TEXTURE_WIDTH) % TEXTURE_WIDTH;
                var floor_tex_y : Int = EffectUtils.ToInt(current_floor_y * TEXTURE_HEIGHT) % TEXTURE_HEIGHT;

                var checker_board_pattern : Int = (EffectUtils.ToInt(current_floor_x + current_floor_y)) % 2;
                var floor_texture : Int = 0 == checker_board_pattern ? 3 : 4;

                // floor
                bm.setPixel(x, y, EffectUtils.ColorDarker(textures[floor_texture][TEXTURE_WIDTH * floor_tex_y + floor_tex_x]));
                // ceiling (symmetrical!)
                bm.setPixel(x, h - y, textures[6][TEXTURE_WIDTH * floor_tex_y + floor_tex_x]);
            }
        }
    }
}