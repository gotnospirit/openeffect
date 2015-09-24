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

class BaseEffect implements IEffect
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

    var world : Array<Array<Int>>;

	public function new()
    {
        keypressed = new Array<Bool>();

        fps = new TextField();
        fps.multiline = true;
        fps.mouseEnabled = false;
        fps.autoSize = TextFieldAutoSize.LEFT;

        var format : TextFormat = new TextFormat();
        format.size = 15;
        format.color = 0xffffff;
        fps.defaultTextFormat = format;
	}

    public function init(w : Int, h : Int, parent : Sprite) : Void
    {
        initPositions();

        // time of current frame
        time = 0;
        // time of previous frame
        oldTime = 0;

        parent.addChild(fps);

        world = initWorld();
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

        raycast(bm, w, h, world);

        // timing for input and FPS counter
        oldTime = time;
        time = EffectUtils.getTime();
        // frame_time is the time this frame has taken, in seconds
        var frame_time : Float = (time - oldTime) / 1000.0;
        // FPS counter
        fps.text = "FPS: " + Std.string(EffectUtils.ToInt(1.0 / frame_time));

        bm.unlock();

        update(frame_time);
    }

    public function keyboard(evt : KeyboardEvent) : Void
    {
        keypressed[evt.keyCode] = KeyboardEvent.KEY_DOWN == evt.type;
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
        return 0 != world[EffectUtils.ToInt(x)][EffectUtils.ToInt(y)];
    }

    private inline function abs(value : Float) : Int
    {
        return EffectUtils.ToInt(value > 0 ? value : value * -1);
    }

    private function initPositions() : Void
    {
    }

    private function initWorld() : Array<Array<Int>>
    {
        return null;
    }

    private function raycast(bm : BitmapData, w : Int, h : Int, world : Array<Array<Int>>) : Void
    {
    }
}