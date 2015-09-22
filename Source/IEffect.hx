package;

import openfl.display.Bitmap;

interface IEffect
{
    public function init(w : Int, h : Int) : Void;

    public function render(frame : Bitmap) : Void;
}