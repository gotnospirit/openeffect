package;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import openfl.events.Event;
import openfl.events.KeyboardEvent;

class Main extends Sprite
{
    var effect : IEffect;
    var bmp : Bitmap;

	public function new()
    {
		super();

        effect = new noise.Clouds();

        this.addEventListener(Event.ADDED_TO_STAGE, onOpened);
	}

    private function init() : Void
    {
        var w : Int = stage.stageWidth;
        var h : Int = stage.stageHeight;

        bmp = new Bitmap(new BitmapData(w, h));
        this.addChild(bmp);

        effect.init(w, h, this);

        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
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

    private function onKeyDown(evt : KeyboardEvent) : Void
    {
        effect.keyboard(evt);
    }

    private function onKeyUp(evt : KeyboardEvent) : Void
    {
        effect.keyboard(evt);
    }
}