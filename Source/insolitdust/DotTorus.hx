// @see http://insolitdust.sourceforge.net/code.html

package insolitdust;

class DotTorus implements IEffect
{
    var palette : Array<Int>;
    var Sin : Array<Float>;
    var Cos : Array<Float>;

    var Phi : Int;

    // Intensity of single big torus block
    static inline var K : Int = 15;
    // Number of color used
    static inline var COLORS : Int = 163;

    static inline var XRES = 320;
    static inline var YRES = 240;

    static inline var A : Int = 318;
    static inline var XOFF : Int = 160; // XRES / 2
    static inline var YOFF : Int = 120; // YRES / 2

    // Big 5x5 torus block
    static var TORUS : Array<Array<Int>> = [
       [ K * 0, K * 3, K * 3, K * 3, K * 0 ],
       [ K * 2, K * 4, K * 4, K * 4, K * 2 ],
       [ K * 3, K * 4, K * 5, K * 4, K * 3 ],
       [ K * 2, K * 4, K * 4, K * 4, K * 2 ],
       [ K * 0, K * 3, K * 3, K * 3, K * 0 ]
    ];

    // Points of torus
    static var POINT : Array<Array<Int>> = [
        [ 19, 0, -13 ],
        [ 8, 0, -21 ],
        [ -7, 0, -22 ],
        [ -18, 0, -13 ],
        [ -22, 0, 1 ],
        [ -18, 0, 14 ],
        [ -7, 0, 22 ],
        [ 7, 0, 22 ],
        [ 19, 0, 14 ],
        [ 23, 0, 1 ],
        [ 4, 47, -13 ],
        [ -6, 41, -21 ],
        [ -17, 32, -22 ],
        [ -26, 26, -13 ],
        [ -30, 23, 0 ],
        [ -26, 26, 14 ],
        [ -17, 32, 22 ],
        [ -6, 41, 22 ],
        [ 3, 47, 14 ],
        [ 7, 50, 0 ],
        [ -37, 77, -13 ],
        [ -40, 66, -21 ],
        [ -45, 53, -22 ],
        [ -48, 42, -13 ],
        [ -50, 37, 0 ],
        [ -48, 42, 14 ],
        [ -45, 52, 22 ],
        [ -40, 66, 22 ],
        [ -37, 77, 14 ],
        [ -35, 81, 0 ],
        [ -87, 77, -13 ],
        [ -83, 66, -21 ],
        [ -79, 53, -22 ],
        [ -75, 42, -13 ],
        [ -74, 37, 0 ],
        [ -75, 42, 14 ],
        [ -79, 52, 22 ],
        [ -83, 66, 22 ],
        [ -87, 77, 14 ],
        [ -88, 81, 0 ],
        [ -127, 47, -13 ],
        [ -118, 41, -21 ],
        [ -106, 32, -22 ],
        [ -97, 26, -13 ],
        [ -94, 23, 0 ],
        [ -97, 26, 14 ],
        [ -106, 32, 22 ],
        [ -118, 41, 22 ],
        [ -127, 47, 14 ],
        [ -130, 50, 0 ],
        [ -142, 0, -13 ],
        [ -131, 0, -21 ],
        [ -117, 0, -22 ],
        [ -105, 0, -13 ],
        [ -101, 0, 0 ],
        [ -105, 0, 14 ],
        [ -117, 0, 22 ],
        [ -131, 0, 22 ],
        [ -142, 0, 14 ],
        [ -147, 0, 0 ],
        [ -127, -47, -13 ],
        [ -118, -41, -21 ],
        [ -106, -32, -22 ],
        [ -97, -26, -13 ],
        [ -94, -23, 0 ],
        [ -97, -26, 14 ],
        [ -106, -32, 22 ],
        [ -118, -41, 22 ],
        [ -127, -47, 14 ],
        [ -130, -50, 0 ],
        [ -87, -77, -13 ],
        [ -83, -66, -21 ],
        [ -79, -53, -22 ],
        [ -75, -42, -13 ],
        [ -74, -37, 0 ],
        [ -75, -42, 14 ],
        [ -79, -52, 22 ],
        [ -83, -66, 22 ],
        [ -87, -77, 14 ],
        [ -88, -81, 0 ],
        [ -37, -77, -13 ],
        [ -40, -66, -21 ],
        [ -45, -53, -22 ],
        [ -48, -42, -13 ],
        [ -50, -37, 0 ],
        [ -48, -42, 14 ],
        [ -45, -52, 22 ],
        [ -40, -66, 22 ],
        [ -37, -77, 14 ],
        [ -35, -81, 0 ],
        [ 4, -47, -13 ],
        [ -6, -41, -21 ],
        [ -17, -32, -22 ],
        [ -26, -26, -13 ],
        [ -30, -23, 0 ],
        [ -26, -26, 14 ],
        [ -17, -32, 22 ],
        [ -6, -41, 22 ],
        [ 3, -47, 14 ],
        [ 7, -50, 0 ]
    ];

    public function new()
    {
        palette = initPalette();
        Sin = new Array<Float>();
        Cos = new Array<Float>();

        Phi = 0;
    }

    public function init(_, _) : Array<Array<Int>>
    {
        // Calculate the moving tables...
        for (i in 0...721)
        {
            Sin[i] = Math.sin(i * 2 * Math.PI / 720) * 0.7;
            Cos[i] = Math.cos(i * 2 * Math.PI / 720);
        }
        return EffectUtils.CreateBuffer(XRES, YRES, 0);
    }

    public function render(buffer : Array<Array<Int>>) : Array<Int>
    {
        showTorus(buffer);
        return palette;
    }

    public function update(_) : Void
    {
    }

    public function keyboard(_) : Void
    {
    }

    private function initPalette() : Array<Int>
    {
        var result = new Array<Int>();
        var R : Int = 0;
        var G : Int = 0;
        var B : Int = 0;

        for (i in 0...COLORS)
        {
            if (i > 0)
            {
                var Log : Float = Math.log(i / (COLORS - 10));

                R = EffectUtils.IntClamp(EffectUtils.ToInt(163 * Math.exp(7 * Log)), 0, 163);
                G = EffectUtils.IntClamp(EffectUtils.ToInt(163 * Math.exp(2 * Log)), 0, 163);
                B = EffectUtils.IntClamp(EffectUtils.ToInt(163 * Math.exp(2 * Log)), 0, 163);
            }

            result[i] = EffectUtils.ColorRGB(R, G, B);
        }
        return result;
    }

    // Draw torus on screen, update rotation and blur screen
    private function showTorus(buffer : Array<Array<Int>>) : Void
    {
        for (index in Phi...Phi + 17)
        {
            for (i in 0...100)
            {
                var x : Float = POINT[i][0] + 77;
                var y : Float = POINT[i][1];
                var z : Float = POINT[i][2] + 50;

                var sin : Float = Sin[index];
                var cos : Float = Cos[index];

                // Rotate on Z
                var Tmp1 : Float = x * cos - y * sin;
                var Tmp2 : Float = x * sin + y * cos;

                x = Tmp1;
                y = Tmp2;

                // Rotate on X
                Tmp1 = y * cos - z * sin;
                Tmp2 = y * sin + z * cos;

                y = Tmp1;
                z = Tmp2;

                // Rotate on Y
                Tmp1 = x * cos + z * sin;
                Tmp2 = -x * sin + z * cos;

                x = Tmp1;
                z = Tmp2;

                drawBlob(
                    buffer,
                    EffectUtils.ToInt(x * A / (z - A)) + XOFF,
                    EffectUtils.ToInt(y * A / (z - A)) + YOFF
                );
            }
        }

        Phi += 6;
        Phi %= 720;

        EffectUtils.BlurBuffer(buffer, XRES, YRES);
    }

    // Draw a single big torus block
    private function drawBlob(buffer : Array<Array<Int>>, x : Int, y : Int) : Void
    {
        for (i in 0...5)
        {
            for (j in 0...5)
            {
                buffer[x + j][y] = EffectUtils.IntClamp(buffer[x + j][y] + TORUS[i][j], 0, COLORS - 1);
            }
        }
    }
}