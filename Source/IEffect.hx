package;

import openfl.events.KeyboardEvent;

interface IEffect
{
    public function init() : Array<Array<Int>>;

    public function render(buffer : Array<Array<Int>>) : Array<Int>;

    public function update(frame_time : Float) : Void;

    public function keyboard(evt : KeyboardEvent) : Void;
}