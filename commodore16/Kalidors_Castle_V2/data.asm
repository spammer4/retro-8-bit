.setcpu		"6502"
.smart		on
.autoimport	on
.case		on
.debuginfo	off

.INCLUDE "macros.inc"
.INCLUDE "constants.inc"

.DATA
    screen_y_lookup:
        m_Gen_Screen_Lookup_Table $0C00
    colour_y_lookup:
        m_Gen_Screen_Lookup_Table $0800
    mult2_lookup: 
        m_Gen_Mult_Lookup_Table 2
    mult4_lookup: 
        m_Gen_Mult_Lookup_Table 4

.EXPORT screen_y_lookup, colour_y_lookup, mult2_lookup, mult4_lookup

