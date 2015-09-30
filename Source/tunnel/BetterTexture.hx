// @see http://lodev.org/cgtutor/tunnel.html

package tunnel;

class BetterTexture extends BlueXOR
{
    override private function generateTexture() : Array<Array<Int>>
    {
        return EffectUtils.GetAssetPixels("assets/tunnelstonetex.png");
    }
}