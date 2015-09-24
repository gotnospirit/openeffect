// @see http://lodev.org/cgtutor/raycasting.html

package raycast;

import openfl.display.BitmapData;

typedef Sprite = {
    var x : Float;
    var y : Float;
    var texture : Int;
    var scale : Int;
    var move : Float;
    var opacity : Float;
};

class Sprites extends WolfTextured
{
    var sprites : Array<Sprite>;
    // 1D Zbuffer
    var zBuffer : Array<Float>;
    // arrays used to sort the sprites
    var spriteOrder : Array<Int>;
    var spriteDistance : Array<Float>;

    static inline var TEXTURE_WIDTH : Int = 64;
    static inline var TEXTURE_HEIGHT : Int = 64;

    public function new()
    {
        super();

        // load some sprite textures
        assets.push("barrel.png");
        assets.push("pillar.png");
        assets.push("greenlight.png");

        sprites = [
            { x: 20.5, y: 11.5, texture: 10, scale: 1, move: 0.0, opacity: 1.0 }, // green light in front of playerstart

            // green lights in every room
            { x: 18.5, y: 4.5, texture: 10, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 10.0, y: 4.5, texture: 10, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 10.0, y: 12.5, texture: 10, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 3.5, y: 6.5, texture: 10, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 3.5, y: 20.5, texture: 10, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 3.5, y: 14.5, texture: 10, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 14.5, y: 20.5, texture: 10, scale: 1, move: 0.0, opacity: 1.0 },

            // row of pillars in front of wall: fisheye test
            { x: 18.5, y: 10.5, texture: 9, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 18.5, y: 11.5, texture: 9, scale: 1, move: 0.0, opacity: 0.75 },
            { x: 18.5, y: 12.5, texture: 9, scale: 1, move: 0.0, opacity: 1.0 },

            // some barrels around the map
            { x: 21.5, y: 1.5, texture: 8, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 15.5, y: 1.5, texture: 8, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 16.0, y: 1.8, texture: 8, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 16.2, y: 1.2, texture: 8, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 3.5,  y: 2.5, texture: 8, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 9.5, y: 15.5, texture: 8, scale: 1, move: 0.0, opacity: 1.0 },
            { x: 10.0, y: 15.1, texture: 8, scale: 2, move: 128.0, opacity: 1.0 },
            { x: 10.5, y: 15.8, texture: 8, scale: 1, move: 0.0, opacity: 1.0 },
        ];

        zBuffer = new Array<Float>();
        spriteOrder = new Array<Int>();
        spriteDistance = new Array<Float>();
    }

    override private function initWorld() : Array<Array<Int>>
    {
        // generate some textures
        textures = generateTextures(TEXTURE_WIDTH, TEXTURE_HEIGHT);

        return [
            [8,8,8,8,8,8,8,8,8,8,8,4,4,6,4,4,6,4,6,4,4,4,6,4],
            [8,0,0,0,0,0,0,0,0,0,8,4,0,0,0,0,0,0,0,0,0,0,0,4],
            [8,0,3,3,0,0,0,0,0,8,8,4,0,0,0,0,0,0,0,0,0,0,0,6],
            [8,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,6],
            [8,0,3,3,0,0,0,0,0,8,8,4,0,0,0,0,0,0,0,0,0,0,0,4],
            [8,0,0,0,0,0,0,0,0,0,8,4,0,0,0,0,0,6,6,6,0,6,4,6],
            [8,8,8,8,0,8,8,8,8,8,8,4,4,4,4,4,4,6,0,0,0,0,0,6],
            [7,7,7,7,0,7,7,7,7,0,8,0,8,0,8,0,8,4,0,4,0,6,0,6],
            [7,7,0,0,0,0,0,0,7,8,0,8,0,8,0,8,8,6,0,0,0,0,0,6],
            [7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,6,0,0,0,0,0,4],
            [7,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,6,0,6,0,6,0,6],
            [7,7,0,0,0,0,0,0,7,8,0,8,0,8,0,8,8,6,4,6,0,6,6,6],
            [7,7,7,7,0,7,7,7,7,8,8,4,0,6,8,4,8,3,3,3,0,3,3,3],
            [2,2,2,2,0,2,2,2,2,4,6,4,0,0,6,0,6,3,0,0,0,0,0,3],
            [2,2,0,0,0,0,0,2,2,4,0,0,0,0,0,0,4,3,0,0,0,0,0,3],
            [2,0,0,0,0,0,0,0,2,4,0,0,0,0,0,0,4,3,0,0,0,0,0,3],
            [1,0,0,0,0,0,0,0,1,4,4,4,4,4,6,0,6,3,3,0,0,0,3,3],
            [2,0,0,0,0,0,0,0,2,2,2,1,2,2,2,6,6,0,0,5,0,5,0,5],
            [2,2,0,0,0,0,0,2,2,2,0,0,0,2,2,0,5,0,5,0,0,0,5,5],
            [2,0,0,0,0,0,0,0,2,0,0,0,0,0,2,5,0,5,0,5,0,5,0,5],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5],
            [2,0,0,0,0,0,0,0,2,0,0,0,0,0,2,5,0,5,0,5,0,5,0,5],
            [2,2,0,0,0,0,0,2,2,2,0,0,0,2,2,0,5,0,5,0,0,0,5,5],
            [2,2,2,2,1,2,2,2,2,2,2,1,2,2,2,5,5,5,5,5,5,5,5,5]
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

            // set the z-buffer for the sprite casting
            zBuffer[x] = perp_wall_dist;

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

                // floor
                bm.setPixel(x, y, EffectUtils.ColorDarker(textures[3][TEXTURE_WIDTH * floor_tex_y + floor_tex_x]));
                // ceiling (symmetrical!)
                bm.setPixel(x, h - y, textures[6][TEXTURE_WIDTH * floor_tex_y + floor_tex_x]);
            }
        }

        // Sprite casting
        // sort sprites from far to close
        for (i in 0...sprites.length)
        {
            spriteOrder[i] = i;
            spriteDistance[i] = ((posX - sprites[i].x) * (posX - sprites[i].x) + (posY - sprites[i].y) * (posY - sprites[i].y)); // sqrt not taken, unneeded
        }

        combSort(spriteOrder, spriteDistance, sprites.length);

        // after sorting the sprites, do the projection and draw them
        for (i in 0...sprites.length)
        {
            // translate sprite position to relative to camera
            var sprite_x : Float = sprites[spriteOrder[i]].x - posX;
            var sprite_y : Float = sprites[spriteOrder[i]].y - posY;

            // transform sprite with the inverse camera matrix
            // [ planeX   dirX ] -1                                       [ dirY      -dirX ]
            // [               ]       =  1/(planeX*dirY-dirX*planeY) *   [                 ]
            // [ planeY   dirY ]                                          [ -planeY  planeX ]

            var inv_det : Float = 1.0 / (planeX * dirY - dirX * planeY); // required for correct matrix multiplication

            var transform_x : Float = inv_det * (dirY * sprite_x - dirX * sprite_y);
            var transform_y : Float = inv_det * (-planeY * sprite_x + planeX * sprite_y); // this is actually the depth inside the screen, that what Z is in 3D

            var sprite_screen_x : Int = EffectUtils.ToInt((w / 2) * (1 + transform_x / transform_y));

            var v_move_screen : Int = EffectUtils.ToInt(sprites[spriteOrder[i]].move / transform_y);

            // calculate height of the sprite on screen
            var sprite_height : Int = EffectUtils.ToInt(abs(h / transform_y) / sprites[spriteOrder[i]].scale); // using "transform_y" instead of the real distance prevents fisheye

            // calculate lowest and highest pixel to fill in current stripe
            var draw_start_y : Int = EffectUtils.ToInt(-sprite_height / 2 + h / 2 + v_move_screen);
            if (draw_start_y < 0)
            {
                draw_start_y = 0;
            }

            var draw_end_y : Int = EffectUtils.ToInt(sprite_height / 2 + h / 2 + v_move_screen);
            if (draw_end_y >= h)
            {
                draw_end_y = h - 1;
            }

            // calculate width of the sprite
            var sprite_width : Int = EffectUtils.ToInt(abs(h / transform_y) / sprites[spriteOrder[i]].scale);

            var draw_start_x : Int = EffectUtils.ToInt(-sprite_width / 2 + sprite_screen_x);
            if (draw_start_x < 0)
            {
                draw_start_x = 0;
            }

            var draw_end_x : Int = EffectUtils.ToInt(sprite_width / 2 + sprite_screen_x);
            if (draw_end_x >= w)
            {
                draw_end_x = w - 1;
            }

            // loop through every vertical stripe of the sprite on screen
            for (stripe in draw_start_x...draw_end_x)
            {
                var tex_x : Int = EffectUtils.ToInt(EffectUtils.ToInt(256 * (stripe - (-sprite_width / 2 + sprite_screen_x)) * TEXTURE_WIDTH / sprite_width) / 256);
                // the conditions in the if are:
                // 1) it's in front of camera plane so you don't see things behind you
                // 2) it's on the screen (left)
                // 3) it's on the screen (right)
                // 4) zBuffer, with perpendicular distance
                if (transform_y > 0 && stripe > 0 && stripe < w && transform_y < zBuffer[stripe])
                {
                    for (y in draw_start_y...draw_end_y) // for every pixel of the current stripe
                    {
                        var d : Int = EffectUtils.ToInt((y - v_move_screen) * 256 - h * 128 + sprite_height * 128); // 256 and 128 factors to avoid floats
                        var tex_y : Int = EffectUtils.ToInt(((d * TEXTURE_HEIGHT) / sprite_height) / 256);
                        var color : Int = textures[sprites[spriteOrder[i]].texture][TEXTURE_WIDTH * tex_y + tex_x]; // get current color from the texture

                        if ((color & 0x00FFFFFF) != 0) // paint pixel if it isn't black, black is the invisible color
                        {
                            drawPixel(bm, stripe, y, color, sprites[spriteOrder[i]].opacity);
                        }
                    }
                }
            }
        }
    }

    private inline function drawPixel(bm : BitmapData, x : Int, y : Int, color : Int, opacity : Float) : Void
    {
        opacity = clamp(opacity, 0.0, 1.0);

        var old_color : Int = bm.getPixel(x, y);
        var new_color : Int = AddColor(MulColor(old_color, 1.0 - opacity), MulColor(color, opacity));

        bm.setPixel(x, y, new_color);
    }

    static private inline function clamp(value : Float, min : Float, max : Float) : Float
    {
        if (value > max)
        {
            value = max;
        }
        else if (value < min)
        {
            value = min;
        }
        return value;
    }

    static private inline function AddColor(color1 : Int, color2 : Int) : Int
    {
        var b1 : Int = color1 & 255;
        var g1 : Int = (color1 >> 8) & 255;
        var r1 : Int = (color1 >> 16) & 255;

        var b2 : Int = color2 & 255;
        var g2 : Int = (color2 >> 8) & 255;
        var r2 : Int = (color2 >> 16) & 255;

        return EffectUtils.ColorRGB(r1 + r2, g1 + g2, b1 + b2);
    }

    static private inline function MulColor(color : Int, factor : Float) : Int
    {
        var b : Int = color & 255;
        var g : Int = (color >> 8) & 255;
        var r : Int = (color >> 16) & 255;

        return EffectUtils.ColorRGB(EffectUtils.ToInt(r * factor), EffectUtils.ToInt(g * factor), EffectUtils.ToInt(b * factor));
    }

    private inline function combSort(order : Array<Int>, dist : Array<Float>, amount : Int) : Void
    {
        var gap : Int = amount;
        var swapped : Bool = false;
        var tmpo : Int = 0;
        var tmpd : Float = 0.0;

        while (gap > 1 || swapped)
        {
            // shrink factor 1.3
            gap = EffectUtils.ToInt((gap * 10) / 13);

            if (9 == gap || 10 == gap)
            {
                gap = 11;
            }
            if (gap < 1)
            {
                gap = 1;
            }

            swapped = false;

            for (i in 0...amount - gap)
            {
                var j : Int = i + gap;

                if (dist[i] < dist[j])
                {
                    tmpd = dist[i];
                    dist[i] = dist[j];
                    dist[j] = tmpd;

                    tmpo = order[i];
                    order[i] = order[j];
                    order[j] = tmpo;

                    swapped = true;
                }
            }
        }
    }
}