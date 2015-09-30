package;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Matrix;

import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;

import openfl.events.Event;
import openfl.events.KeyboardEvent;

class Main extends Sprite
{
    var bmp : Bitmap;
    var buffer : Array<Array<Int>>;
    var effect : IEffect;

    var buffer_width : Int;
    var buffer_height : Int;
    var scale_x : Float;
    var scale_y : Float;

    var debug : TextField;

    var time : Float;
    var oldTime : Float;

	public function new()
    {
		super();

        effect = new lodev.tunnel.BlueXOR();

        debug = new TextField();
        debug.multiline = true;
        debug.mouseEnabled = false;
        debug.autoSize = TextFieldAutoSize.LEFT;

        var format : TextFormat = new TextFormat();
        format.size = 15;
        format.color = 0xffffff;
        debug.defaultTextFormat = format;

        // time of current frame
        time = 0;
        // time of previous frame
        oldTime = 0;

        this.addEventListener(Event.ADDED_TO_STAGE, onOpened);
	}

    private function onOpened(e : Event) : Void
    {
        this.removeEventListener(Event.ADDED_TO_STAGE, onOpened);

        bmp = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight));
        this.addChild(bmp);

        this.addChild(debug);

        buffer = effect.init(stage.stageWidth, stage.stageHeight);

        buffer_width = buffer.length;
        buffer_height = buffer[0].length;
        scale_x = stage.stageWidth / buffer_width;
        scale_y = stage.stageHeight / buffer_height;

        stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
    }

    private function onEnterFrame(_) : Void
    {
        var scaled : Bool = scale_x != 1 || scale_y != 1;

        var palette : Array<Int> = effect.render(buffer);

        var bm : BitmapData;
        if (scaled)
        {
            bm = new BitmapData(buffer_width, buffer_height);
        }
        else
        {
            bm = bmp.bitmapData;
        }

        bm.lock();
        for (x in 0...buffer_width)
        {
            for (y in 0...buffer_height)
            {
                if (null != palette)
                {
                    bm.setPixel(x, y, palette[buffer[x][y]]);
                }
                else
                {
                    bm.setPixel(x, y, buffer[x][y]);
                }
            }
        }
        bm.unlock();

        if (scaled)
        {
            // Scale to fullscreen
            var matrix = new Matrix();
            matrix.scale(scale_x, scale_y);

            bmp.bitmapData.draw(bm, matrix);
        }

        // timing for input and FPS counter
        oldTime = time;
        time = EffectUtils.GetTime();

        // frame_time is the time this frame has taken, in seconds
        var frame_time : Float = (time - oldTime) / 1000.0;
        // FPS counter
        debug.text = "FPS: " + Std.string(EffectUtils.ToInt(1.0 / frame_time));

        effect.update(frame_time);
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