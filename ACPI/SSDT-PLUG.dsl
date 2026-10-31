/* XCPM plugin-type cho CPU đầu tiên (\_SB.PR00) */
DefinitionBlock ("", "SSDT", 2, "KXINT", "CpuPlug", 0x00003000)
{
    External (_SB_.PR00, ProcessorObj)
    Scope (\_SB.PR00)
    {
        If (_OSI ("Darwin"))
        {
            Method (_DSM, 4, NotSerialized)
            {
                If (!Arg2) { Return (Buffer (One) { 0x03 }) }
                Return (Package (0x02) { "plugin-type", One })
            }
        }
    }
}
