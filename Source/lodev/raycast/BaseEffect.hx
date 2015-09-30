// @see http://lodev.org/cgtutor/raycasting.html

package lodev.raycast;

import openfl.display.Sprite;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;

class BaseEffect implements IEffect
{
    var keypressed : Array<Bool>;

    var posX : Float;
    var posY : Float;

    var dirX : Float;
    var dirY : Float;

    var planeX : Float;
    var planeY : Float;

    var world : Array<Array<Int>>;

    var width : Int;
    var height : Int;

	public function new(width : Int, height : Int)
    {
        keypressed = new Array<Bool>();
        this.width = width;
        this.height = height;
	}

    public function init() : Array<Array<Int>>
    {
        initPositions();

        world = initWorld();
        return EffectUtils.CreateBuffer(width, height, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        // cls
        EffectUtils.ClearBuffer(buffer, 0);

        raycast(buffer, width, height, world);

        return null;
    }

    public function keyboard(evt : KeyboardEvent) : Void
    {
        keypressed[evt.keyCode] = KeyboardEvent.KEY_DOWN == evt.type;
    }

    public function update(frame_time : Float) : Void
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

    private function raycast(buffer : Array<Array<Int>>, width : Int, height : Int, world : Array<Array<Int>>) : Void
    {
    }
}