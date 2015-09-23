// @see http://lodev.org/cgtutor/raycasting.html

package raycast;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.ui.Keyboard;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.events.KeyboardEvent;

class Untextured implements IEffect
{
    var keypressed : Array<Bool>;

    var fps : TextField;

    var posX : Float;
    var posY : Float;

    var dirX : Float;
    var dirY : Float;

    var planeX : Float;
    var planeY : Float;

    var time : Float;
    var oldTime : Float;

    static var world : Array<Array<Int>>= [
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1],
        [1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1],
        [1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,0,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
    ];

	public function new()
    {
        keypressed = new Array<Bool>();

        fps = new TextField();
        fps.multiline = false;
        fps.mouseEnabled = false;
        fps.autoSize = TextFieldAutoSize.LEFT;
        var format : TextFormat = new TextFormat();
        format.size = 18;
        format.color = 0xffffff;
        fps.defaultTextFormat = format;
	}

    public function init(w : Int, h : Int, parent : Sprite) : Void
    {
        // x and y start position
        posX = 22;
        posY = 12;
        // initial direction vector
        dirX = -1;
        dirY = 0;
        // the 2d raycaster version of camera plane
        planeX = 0;
        planeY = 0.66;
        // time of current frame
        time = 0;
        // time of previous frame
        oldTime = 0;

        parent.addChild(fps);
    }

    public function render(frame : Bitmap) : Void
    {
        var bm : BitmapData = frame.bitmapData;

        var w : Int = bm.width;
        var h : Int = bm.height;

        bm.lock();

        // cls
        for (x in 0...w)
        {
            for (y in 0...h)
            {
                bm.setPixel(x, y, 0);
            }
        }

        for (x in 0...w)
        {
            // calculate ray position and direction
            var camera_x : Float = 2 * x / w - 1;   // x-coordinate in camera space
            var ray_pos_x : Float = posX;
            var ray_pos_y : Float = posY;
            var ray_dir_x : Float = dirX + planeX * camera_x;
            var ray_dir_y : Float = dirY + planeY * camera_x;

            // which box of the map we're in
            var map_x : Int = Math.ceil(ray_pos_x);
            var map_y : Int = Math.ceil(ray_pos_y);

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
            var draw_start : Int = Math.ceil(-line_height / 2 + h / 2);
            if (draw_start < 0)
            {
                draw_start = 0;
            }

            var draw_end : Int = Math.ceil(line_height / 2 + h / 2);
            if (draw_end >= h)
            {
                draw_end = h - 1;
            }

            var color : Int = 0;

            switch (world[map_x][map_y])
            {
                case 1:
                    color = ColorRGB(true, false, false, side);

                case 2:
                    color = ColorRGB(false, true, false, side);

                case 3:
                    color = ColorRGB(false, false, true, side);

                case 4:
                    color = ColorRGB(true, true, true, side);

                default:
                    color = ColorRGB(true, true, false, side);
            }

            for (y in draw_start...draw_end)
            {
                bm.setPixel(x, y, color);
            }
        }

        // timing for input and FPS counter
        oldTime = time;
        time = EffectUtils.getTime();
        // frame_time is the time this frame has taken, in seconds
        var frame_time : Float = (time - oldTime) / 1000.0;
        // FPS counter
        fps.text = "FPS: " + Std.string(Math.ceil(1.0 / frame_time));

        bm.unlock();

        update(frame_time);
    }

    public function keyboard(evt : KeyboardEvent) : Void
    {
        keypressed[evt.keyCode] = KeyboardEvent.KEY_DOWN == evt.type;
    }

    private inline function ColorRGB(r : Bool, g : Bool, b : Bool, side : Int) : Int
    {
        return 1 == side
            ? EffectUtils.ColorRGB(r ? 128 : 0, g ? 128 : 0, b ? 128 : 0)
            : EffectUtils.ColorRGB(r ? 255 : 0, g ? 255 : 0, b ? 255 : 0);
    }

    private inline function update(frame_time : Float) : Void
    {
        // the constant value is in squares / second
        var move_speed : Float = frame_time * 5.0;
        // the constant value is in radians / second
        var rot_speed : Float = frame_time * 3.0;

        // move forward if no wall in front of you
        if (keypressed[Keyboard.UP])
        {
            if (!isWall(posX + dirX * move_speed, posY))
            {
                posX += dirX * move_speed;
            }

            if (!isWall(posX, posY + dirY * move_speed))
            {
                posY += dirY * move_speed;
            }
        }
        // move backward if no wall behind you
        if (keypressed[Keyboard.DOWN])
        {
            if (!isWall(posX - dirX * move_speed, posY))
            {
                posX -= dirX * move_speed;
            }

            if (!isWall(posX, posY - dirY * move_speed))
            {
                posY -= dirY * move_speed;
            }
        }
        // rotate to the right
        if (keypressed[Keyboard.RIGHT])
        {
            // both camera direction and camera plane must be rotated
            var old_dir_x : Float = dirX;
            dirX = dirX * Math.cos(-rot_speed) - dirY * Math.sin(-rot_speed);
            dirY = old_dir_x * Math.sin(-rot_speed) + dirY * Math.cos(-rot_speed);

            var old_plane_x : Float = planeX;
            planeX = planeX * Math.cos(-rot_speed) - planeY * Math.sin(-rot_speed);
            planeY = old_plane_x * Math.sin(-rot_speed) + planeY * Math.cos(-rot_speed);
        }
        // rotate to the left
        if (keypressed[Keyboard.LEFT])
        {
            // both camera direction and camera plane must be rotated
            var old_dir_x : Float = dirX;
            dirX = dirX * Math.cos(rot_speed) - dirY * Math.sin(rot_speed);
            dirY = old_dir_x * Math.sin(rot_speed) + dirY * Math.cos(rot_speed);

            var old_plane_x : Float = planeX;
            planeX = planeX * Math.cos(rot_speed) - planeY * Math.sin(rot_speed);
            planeY = old_plane_x * Math.sin(rot_speed) + planeY * Math.cos(rot_speed);
        }
    }

    private inline function isWall(x : Float, y : Float) : Bool
    {
        return 0 != world[Math.ceil(x)][Math.ceil(y)];
    }

    private inline function abs(value : Float) : Int
    {
        return Math.ceil(value > 0 ? value : value * -1);
    }
}