;
; ==============================================
; DISPLAY INIT ROUTINE
; ==============================================
;
ldi r26, 0xFF
out DDRA, r27		;config porta as output
ldi r27, 0
out PORTA, r27		;clear porta
ldi r27, 0xFF
out DDRC, r26		;config portc as output
ldi r27, 0
out PORTC, r27		;clear portc
