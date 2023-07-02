namespace JACsharp
{
    public static class Converter
    {
        public static void SepiaTone(ref byte[] array)
        {
            byte maxValue = 255;
            var r = array[0] * 0.393f + array[1] * 0.769f + array[2] * 0.189f;
            var g = array[0] * 0.349f + array[1] * 0.686f + array[2] * 0.168f;
            var b = array[0] * 0.272f + array[1] * 0.534f + array[2] * 0.131f;

            if (r > maxValue)
            {
                array[0] = maxValue;
                 
            }
            else
            {
                array[0] = (byte)r;
            }

            if (g > maxValue)
            {
                array[1] = maxValue;
            }
            else
            {
                array[1] = (byte)g;
            }

            if (b > maxValue)
            {
                array[2] = maxValue;
            }
            else
            {
                array[2] = (byte)b;
            }
        }
    }
}
