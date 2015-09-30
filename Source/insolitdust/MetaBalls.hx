// @see http://insolitdust.sourceforge.net/code.html

package insolitdust;

class MetaBall
{
    public var A : Float;
    public var B : Float;
    public var Radius : Float;
    public var Da : Float;
    public var Db : Float;

    public function new(r : Float)
    {
        A = 0.0;
        B = 0.0;
        Radius = r;
        Da = 0.0;
        Db = 0.0;
    }

    public function findBall(x : Int, y : Int, deler : Float) : Float
    {
        return Radius / ((x - A) * (x - A) + (y - B) * (y - B));
    }
}

class MetaBalls implements IEffect
{
    var palette : Array<Int>;

    var F : Array<Float>;
    var Sin : Array<Float>;
    var Cos : Array<Float>;
    var Phi : Int;
    var MBalls : Array<MetaBall>;

	static inline var FACE_RED : Int = 63; //63
	static inline var FACE_GREEN : Int = 72; //72
	static inline var FACE_BLUE : Int = 128; //128
	static inline var LIGHT : Int = 350;
	static inline var REFLECT : Int = 130;
	static inline var AMBIENT : Int = 0;

    static inline var XRES = 320;
    static inline var YRES = 240;

    public function new()
    {
        palette = initPalette();

        F = new Array<Float>();

        Sin = new Array<Float>();
        Cos = new Array<Float>();
        for (i in 0...360)
        {
            Sin[i] = Math.sin(i / 180.0 * Math.PI);
            Cos[i] = Math.cos(i / 180.0 * Math.PI);
        }

        Phi = 0;

        MBalls = [
            new MetaBall(20 * 80),
            new MetaBall(35 * 140),
            new MetaBall(25 * 100),
            new MetaBall(10 * 80),
            new MetaBall(23 * 80),
            new MetaBall(35 * 110),
            new MetaBall(37 * 90),
            new MetaBall(140 * 80)
        ];
    }

    public function init(_, _) : Array<Array<Int>>
    {
        for (i in 0...XRES * YRES)
        {
            F[i] = 0;
        }
        return EffectUtils.CreateBuffer(XRES, YRES, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        // cls
        EffectUtils.ClearBuffer(buffer, 0);

        renderBalls(buffer, XRES, YRES);
        blurScreen(buffer, XRES, YRES);
        return palette;
    }

    public function update(_) : Void
    {
        Phi += 3;
        Phi %= 360;

        clearF();
        updateBalls(Phi);
    }

    public function keyboard(_) : Void
    {
    }

    private function renderBalls(buffer : Array<Array<Int>>, width : Int, height : Int) : Void
    {
        for (x in 0...width - 1)
        {
            for (y in 0...height - 1)
            {
                var App : Int = x + y * width;

                for (j in 0...8)
                {
                    F[App] += MBalls[j].findBall(x, y, 1);
                }

                var Color : Int = (F[App] * 20 < 255)
                    ? Std.int(F[App] * 20) : 255;

                if (F[App] > 1)
                {
                    buffer[x][y] = Color;
                    buffer[x + 1][y] = Color;
                    buffer[x][y + 1] = Color;
                    buffer[x + 1][y + 1] = Color;
                }
            }
        }
    }

    private function blurScreen(buffer : Array<Array<Int>>, width : Int, height : Int) : Void
    {
        for (y in 1...height - 1)
        {
            buffer[0][y - 1] = 0;
            buffer[0][y] = 0;
            buffer[0][y + 1] = 0;

            for (x in 1...width - 1)
            {
                var Color : Int = (buffer[x][y - 1] + buffer[x][y + 1] + buffer[x - 1][y] + buffer[x + 1][y]) >> 2;
                Color -= 2;

                if (Color < 0)
                {
                    Color = 0;
                }

                buffer[x][y] = Color;
            }

            buffer[width - 1][y - 1] = 0;
            buffer[width - 1][y] = 0;
            buffer[width - 1][y + 1] = 0;
        }
    }

    private function clearF() : Void
    {
        for (i in 0...F.length)
        {
            F[i] = 0;
        }
    }

    private function updateBalls(Phi : Int) : Void
    {
        MBalls[0].A = Sin[Phi] * 120 + (320 / 2);
        MBalls[0].B = Cos[Phi] * 80 + (240 / 2);
        MBalls[1].A = Sin[Phi] * 80 + (320 / 2);
        MBalls[1].B = Sin[Phi] * 100 + (240 / 2);
        MBalls[2].A = Cos[Phi] * 160 + (320 / 2);
        MBalls[2].B = Sin[(Phi + Phi) % 360] * 100 + (240 / 2);
        MBalls[3].A = Cos[Phi] * 80 + (320 / 2);
        MBalls[3].B = Cos[(Phi + Phi) % 360] * 100 + ((240 / 2) + 20);

        MBalls[4].A = Cos[Phi] * 60 + (320 / 2);
        MBalls[4].B = Cos[(Phi + Phi) % 360] * 70 + ((240 / 2) + 10);
        MBalls[5].B = Sin[Phi] * 120 + (240 / 2);
        MBalls[5].A = Cos[Phi] * 260 + (320 / 2);
        MBalls[6].B = Sin[Phi] * 150 + (240 / 2);
        MBalls[6].A = Cos[Phi] * 100 + (320 / 2);
        MBalls[7].B = Sin[Phi] * 60 + (240 / 2);
        MBalls[7].A = Cos[Phi] * 70 + (320 / 2);
    }

    private function initPalette() : Array<Int>
    {
        var result = new Array<Int>();
        for (i in 0...256)
        {
            var Intensity : Float = Math.cos((255 - i) / 512.0 * Math.PI);

            var Temp1 : Int = EffectUtils.IntClamp(Std.int(FACE_RED * AMBIENT / 255.0 + FACE_RED * Intensity + Math.pow(Intensity, REFLECT) * LIGHT), 0, 255);
            var Temp2 : Int = EffectUtils.IntClamp(Std.int(FACE_GREEN * AMBIENT / 255.0 + FACE_GREEN * Intensity + Math.pow(Intensity, REFLECT) * LIGHT), 0, 255);
            var Temp3 : Int = EffectUtils.IntClamp(Std.int(FACE_BLUE * AMBIENT / 255.0 + FACE_BLUE * Intensity + Math.pow(Intensity, REFLECT) * LIGHT), 0, 255);

            result[i] = EffectUtils.ColorRGB(Temp1, Temp2, Temp3);
        }
        return result;
    }
}