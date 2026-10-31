/* Tắt AWAC, bật RTC legacy (RTC._STA phụ thuộc STAS == 1) */
DefinitionBlock ("", "SSDT", 2, "KXINT", "AwacOff", 0x00000000)
{
    External (STAS, IntObj)
    Scope (_SB)
    {
        Method (_INI, 0, NotSerialized)
        {
            If (_OSI ("Darwin")) { STAS = One }
        }
    }
}
