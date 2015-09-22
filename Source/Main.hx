package;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import openfl.events.Event;

class Main extends Sprite
{
    var effect : IEffect;
    var bmp : Bitmap;

	public function new()
    {
		super();

        effect = new plasma.RGB();

        this.addEventListener(Event.ADDED_TO_STAGE, onOpened);
	}

    private function init() : Void
    {
        var w : Int = stage.stageWidth;
        var h : Int = stage.stageHeight;

        effect.init(w, h);

        bmp = new Bitmap(new BitmapData(w, h));
        this.addChild(bmp);

		this.addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    private function onOpened(e:Event) : Void
    {
        this.removeEventListener(Event.ADDED_TO_STAGE, onOpened);

        init();
    }

    private function onEnterFrame(_) : Void
    {
        effect.render(bmp);
    }
}