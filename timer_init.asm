;
; ==============================================
; TIMER INIT ROUTINE
; ==============================================
;
//ClkI/O/64 (From prescaler)		
//Timer0 overflow interrupt enable
ldi R16, ( 1 << CS00 ) | ( 1 << CS01 ) | ( 0 << CS02 )
out TCCR0, R16
ldi R16, 78
out OCR0, R16
ldi R16, ( 1 << TOIE0 )
out TIMSK, R16
SEI	;Enable global interrupts
clr r16