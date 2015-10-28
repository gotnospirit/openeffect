// @see http://insolitdust.sourceforge.net/code.html

package insolitdust;

class BurnCube implements IEffect
{
    var palette : Array<Int>;

    var ax : Float;
    var ay : Float;
    var az : Float;

    var r : Array<Int>; // Disturb on line for fire effect
    var mr : Array<Array<Float>>; // Rotation matrix
    var lx : Array<Int>; // Vectors
    var ly : Array<Int>;
    var lz : Array<Int>;

    // Cube faces
    var face : Array<Array<Int>>;

    // Transformations tables
    var lxn : Array<Float>;
    var lyn : Array<Float>;
    var lzn : Array<Float>;
    var xd : Array<Float>;
    var yd : Array<Float>;

    static inline var XRES = 320;
    static inline var YRES = 240;

    public function new()
    {
        ax = 0.0;
        ay = 0.0;
        az = 0.0;

        palette = initPalette();

        r = new Array<Int>();

        mr = [
            [0, 0, 0],
            [0, 0, 0],
            [0, 0, 0]
        ];

        lx = [1, 1, 1, 1, -1, -1, -1, -1];
        ly = [1, 1, -1, -1, 1, 1, -1, -1];
        lz = [1, -1, 1, -1, 1, -1, 1, -1];
        face = [
            [4, 0, 1, 5],
            [1, 0, 2, 3],
            [5, 1, 3, 7],
            [4, 5, 7, 6],
            [0, 4, 6, 2],
            [3, 2, 6, 7]
        ];

        lxn = [0, 0, 0, 0, 0, 0, 0, 0];
        lyn = [0, 0, 0, 0, 0, 0, 0, 0];
        lzn = [0, 0, 0, 0, 0, 0, 0, 0];
        xd = [0, 0, 0, 0, 0, 0, 0, 0];
        yd = [0, 0, 0, 0, 0, 0, 0, 0];
    }

    public function init(_, _) : Array<Array<Int>>
    {
        for (i in 0...XRES)
        {
            r[i] = 0;
        }
        return EffectUtils.CreateBuffer(XRES, YRES, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        doCube(buffer, XRES, YRES);
        doFire(buffer, XRES, YRES);
        return palette;
    }

    public function update(_) : Void
    {
    }

    public function keyboard(_) : Void
    {
    }

    // Blur screen to make the fire effect
    private inline function doFire(buffer : Array<Array<Int>>, width : Int, height : Int) : Void
    {
        for (a in 0...width)
        {
            for (b in 0...height - 1)
            {
                if (buffer[a][b + 1] > 0 || buffer[a][b] > 0)
                {
                    buffer[a][b] = ((buffer[a - 1][b + 1] +
                        buffer[a + 1][b + 1] +
                        buffer[a][b + 1] +
                        buffer[a][b + 2]) >> 2);
                }

                if (buffer[a][b] > 3)
                {
                    buffer[a][b] -= 2;
                }
            }
        }
    }

    // Rotate and draw cube on screen
    private inline function doCube(buffer : Array<Array<Int>>, width : Int, height : Int) : Void
    {
        ax += 0.04;
        ay += 0.036;
        az += 0.04;

        mr[0][0] = Math.cos(az) * Math.cos(ay);
        mr[1][0] = Math.sin(az) * Math.cos(ay);
        mr[2][0] = -Math.sin(ay);
        mr[0][1] = Math.cos(az) * Math.sin(ay) * Math.sin(ax) - Math.sin(az) * Math.cos(ax);
        mr[1][1] = Math.sin(az) * Math.sin(ay) * Math.sin(ax) + Math.cos(ax) * Math.cos(az);
        mr[2][1] = Math.sin(ax) * Math.cos(ay);
        mr[0][2] = Math.cos(az) * Math.sin(ay) * Math.cos(ax) + Math.sin(az) * Math.sin(ax);
        mr[1][2] = Math.sin(az) * Math.sin(ay) * Math.cos(ax) - Math.cos(az) * Math.sin(ax);
        mr[2][2] = Math.cos(ax) * Math.cos(ay);

        for (n in 0...8)
        {
            lxn[n] = lx[n] * mr[0][0] + ly[n] * mr[1][0] + lz[n] * mr[2][0];
            lyn[n] = lx[n] * mr[0][1] + ly[n] * mr[1][1] + lz[n] * mr[2][1];
            lzn[n] = lx[n] * mr[0][2] + ly[n] * mr[1][2] + lz[n] * mr[2][2] + 5.5;

            xd[n] = width / 2 + (width * lxn[n]) / lzn[n];
            yd[n] = height / 2 + (height * lyn[n]) / lzn[n];
        }

        for (n in 0...width)
        {
            r[n] = EffectUtils.Rand() % 100;
        }

        for (n in 1...6)
        {
            lineR(Std.int(xd[face[n][0]]), Std.int(yd[face[n][0]]), Std.int(xd[face[n][1]]), Std.int(yd[face[n][1]]), 80, buffer, width);
            lineR(Std.int(xd[face[n][1]]), Std.int(yd[face[n][1]]), Std.int(xd[face[n][2]]), Std.int(yd[face[n][2]]), 80, buffer, width);
            lineR(Std.int(xd[face[n][3]]), Std.int(yd[face[n][3]]), Std.int(xd[face[n][0]]), Std.int(yd[face[n][0]]), 80, buffer, width);
            lineR(Std.int(xd[face[n][2]]), Std.int(yd[face[n][2]]), Std.int(xd[face[n][3]]), Std.int(yd[face[n][3]]), 80, buffer, width);
        }
    }

    // Draw a line with a random rumors
    private function lineR(x1 : Int, y1 : Int, x2 : Int, y2 : Int, color : Int, buffer : Array<Array<Int>>, width : Int) : Void
    {
        var dx : Int = x2 - x1;
        var dy : Int = y2 - y1;
        var sdx : Int = (dx < 0) ? -1 : 1;
        var sdy : Int = (dy < 0) ? -1 : 1;

        dx = sdx * dx + 1;
        dy = sdy * dy + 1;

        var px : Int = x1;
        var py : Int = y1;

        if (dx >= dy)
        {
            var y : Int = 0;
            for (x in 0...dx)
            {
                buffer[px][py] = color + r[x];

                y += dy;

                if (y >= dx)
                {
                    y -= dx;
                    py += sdy;
                }

                px += sdx;
            }
        }
        else
        {
            var x : Int = 0;
            for (y in 0...dy)
            {
                buffer[px][py] = color + r[y];

                x += dx;

                if (x >= dy)
                {
                    x -= dy;
                    px += sdx;
                }

                py += sdy;
            }
        }
    }

    private inline function initPalette() : Array<Int>
    {
        var r : Int = 0;
        var g : Int = 0;
        var b : Int = 0;

        var result = new Array<Int>();
        for (i in 0...63)
        {
            result[i] = EffectUtils.ColorRGB(r++ * 4, 0, 0);
        }
        for (i in 63...127)
        {
            result[i] = EffectUtils.ColorRGB(63 * 4, g++ * 4, 0);
        }
        for (i in 127...190)
        {
            result[i] = EffectUtils.ColorRGB(63 * 4, 63 * 4, b++ * 4);
        }
        for (i in 190...256)
        {
            result[i] = 0;
        }
        return result;
    }
}