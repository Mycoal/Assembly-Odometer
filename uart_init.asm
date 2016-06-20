;
; ==============================================
; Initialize USART for ATMEGA32 @8MHZ/57600 Baud
; ==============================================
;
.EQU UBRR_value = 51

initUSART:
ldi r27, high (UBRR_value) ;baud rate
out UBRRH, r27
ldi r27, low (UBRR_value)
out UBRRL, r27
;8data, 1 stop, no parity
ldi r27, (1 << URSEL)|(0 << UMSEL)|(0 << USBS)|(3 << UCSZ0)|(0 << UPM0)
out UCSRC, r27

ldi r27, (1 << RXEN)|(1 << TXEN)
out UCSRB, r27; enable receive and transmit
;USART initialization complete
clr r27

