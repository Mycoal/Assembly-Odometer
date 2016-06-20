;
; ==============================================
; PROGRAM INIT ROUTINE
; ==============================================
;
.include "uart_init.asm"
.include "display_init.asm"
.include "timer_init.asm"
.DEF ADR = R24 ;HOLDS EEPROM ADDRESS

;initialize Stack
ldi r27, LOW( RAMEND ) 
out SPL, r27
ldi r27, HIGH( RAMEND )
out SPH, r27

;Set some things to 0
ldi r27, 0
sts	digit0,r27			;digit = 0
sts	digit1,r27			;digit1 = 0
sts number0,r27
sts number1,r27
sts	portd_index,r27 	;portd_index = 0
ldi r27, 0x00
sts portd_array0, r27
sts portd_array1, r27
sts portd_array2, r27
sts portd_array3, r27

;Shifter
ldi	r27,1				;shifter = 1
sts	shifter,r27	

clr r27
clr r2
