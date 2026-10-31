/*
 * Touchpad ELAN06FA (\_SB.PC00.I2C0.TPAD) cho VoodooI2C.
 * _CRS gốc: OSYS < Win8 -> chỉ trả APIC 0x44 (không có I2C); nhánh GPIO bị khoá "If (Zero)".
 * Cần ACPI patch đổi TPAD._CRS -> XCRS. XCRS vẫn được gọi để nạp ADR0 (địa chỉ I2C) vào SBFB.
 * Trả I2cSerialBus + GpioInt (\_SB.GPI0 chân 0xC4, có sẵn trong SBFG của firmware).
 */
DefinitionBlock ("", "SSDT", 2, "KXINT", "TPAD", 0x00000000)
{
    External (_SB_.PC00.I2C0.TPAD, DeviceObj)
    External (_SB_.PC00.I2C0.TPAD.XCRS, MethodObj)
    External (_SB_.PC00.I2C0.TPAD.SBFB, BuffObj)
    External (_SB_.PC00.I2C0.TPAD.SBFG, BuffObj)

    Scope (\_SB.PC00.I2C0.TPAD)
    {
        Method (_CRS, 0, Serialized)
        {
            If (_OSI ("Darwin"))
            {
                Local0 = \_SB.PC00.I2C0.TPAD.XCRS ()
                Return (ConcatenateResTemplate (\_SB.PC00.I2C0.TPAD.SBFB, \_SB.PC00.I2C0.TPAD.SBFG))
            }

            Return (\_SB.PC00.I2C0.TPAD.XCRS ())
        }
    }
}
