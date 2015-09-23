package;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.events.KeyboardEvent;

interface IEffect
{
    public function init(w : Int, h : Int, parent : Sprite) : Void;

    public function render(frame : Bitmap) : Void;

    public function keyboard(evt : KeyboardEvent) : Void;
}