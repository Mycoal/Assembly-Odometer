;
; ********************************************
; * [FINAL]
;	
; * [REQUIRED]
;		These switches must be toggled to the right
;		SW10.1, SW10.2					Enables EEPROM RX and TX
;		SW10.6 							Enables LEDS on PORTB
;		SW8.1, SW8.2, SW8.3, SW8.4		Enables Seven Segment Display
;
; * [DESCRIPTION]		
;		The application is an odometer that has external
;		communications and long term storage. It also 
;		displays the current odometer on the 7 segment 
;		display for a visual feedback.	
;
;		UART communication is configured for a 9600 baud rate
;
; * [NOTE]
; 		A shortcut to skip to odometer count 9995 has been included.
;		It is located in the RESET: label.
;		To enable the shortcut, simply uncomment the code block.
;		The shortcut will quickly demonstrate the roll over and ledBlink event.
;
; * (C)2016 by Mycoal Campo *
; ********************************************
;
; Included header file for target AVR type
.NOLIST
.INCLUDE "m32def.inc" ; Header for ATMega32
.LIST
;
; ============================================
;
; S R A M D E F I N I T I O N S
;
; ============================================
;
.DSEG
.ORG 0X0060
portd_index:
	.byte	1
digit0:
	.byte	1
digit1:
	.byte	1
shifter:
	.byte	1
portd_array0:
	.byte	1
portd_array1:
	.byte	1
portd_array2:
	.byte	1
portd_array3:
	.byte	1
number0:
	.byte	1
number1:
	.byte	1
;
; ============================================
;
; R E S E T A N D I N T V E C T O R S
;
; ============================================
;
.CSEG
.ORG $0000
jmp RESET 		; Reset Handler
jmp EXT_INT0 	; IRQ0 Handler
jmp EXT_INT1 	; IRQ1 Handler
jmp EXT_INT2 	; IRQ2 Handler
jmp TIM2_COMP 	; Timer2 Compare Handler
jmp TIM2_OVF 	; Timer2 Overflow Handler
jmp TIM1_CAPT 	; Timer1 Capture Handler
jmp TIM1_COMPA 	; Timer1 CompareA Handler
jmp TIM1_COMPB 	; Timer1 CompareB Handler
jmp TIM1_OVF 	; Timer1 Overflow Handler
jmp TIM0_COMP 	; Timer0 Compare Handler
jmp TIM0_OVF 	; Timer0 Overflow Handler
jmp SPI_STC 	; SPI Transfer Complete Handler
jmp USART_RXC 	; USART RX Complete Handler
jmp USART_UDRE 	; UDR Empty Handler
jmp USART_TXC 	; USART TX Complete Handler
;jmp ADC 		; ADC Conversion Complete Handler
jmp EE_RDY 		; EEPROM Ready Handler
jmp ANA_COMP 	; Analog Comparator Handler
jmp TWI 		; Two-wire Serial Interface Handler
jmp SPM_RDY 	; Store Program Memory Ready Handler
;
; ============================================
;
; I N T E R R U P T S E R V I C E S
;
; ============================================
;
RESET:					;Reset Handler			
.include "program_init.asm"	;System Init

	clr ADR				;Begin from previously saved number
	rcall EEPROM_read
	sts number0, r16	;restore previous data
	rcall EEPROM_read
	sts number1, r16	;restore previous data

; =========
; SHORTCUT
; =========
	/*
	ldi r27, 11			;Begin at 9995
	sts number0, r27
	ldi r27, 39
	sts number1, r27
	*/

rjmp MAIN
RETI

EXT_INT0:    			;IRQ0 Handler
.include "ledBlink.asm"	;flashing leds event
RETI

EXT_INT1: 				;IRQ1 Handler
RETI

EXT_INT2: 				;IRQ2 Handler
RETI

TIM2_COMP: 				;Timer2 Compare Handler
RETI

TIM2_OVF: 				;Timer2 Overflow Handler
RETI

TIM1_CAPT: 				;Timer1 Capture Handler
RETI

TIM1_COMPA: 			;Timer1 CompareA Handler
RETI

TIM1_COMPB: 			;Timer1 CompareB Handler
RETI

TIM1_OVF: 				;Timer1 Overflow Handler
RETI

TIM0_COMP: 				;Timer0 Compare Handler
RETI

TIM0_OVF: 				;Timer0 Overflow Handler
	CLI					;disable interrupts
	push	r16			;push registers to stack
	push	r17
	push	r18
	push	r30
	push	r31
	push	r27
	in		r27,SREG	;preserve current Status registers
	push	r27
	;(1)Calculate data
	ldi	r17,100			;Find appropriate value to PORTC
	ldi	r18,0			;PORTC = portd_array[portd_index]
	lds	r16,portd_index	;load direct from data space
	mov	r30,r16			;copy register
	ldi	r31,0
	add	r30,r17			;add registers
	adc	r31,r18			;add with carry
	ld	r16,Z
	out	PORTC,r16		;out to i/o

	;(2)and find where to put it
	lds	r16,shifter		;turn on appropriate 7seg. display
	out	PORTA,r16		;PORTA = shifter
	mov	r17,r16			;shifter <<= 1	
	lsl	r17				;logical shift left
	sts	shifter,r17		;store new data
	ldi	r16,8			;if (shifter > 8)
	cp	r16,r17			;compare
	brcc TIM0_OVF_ISR0	;branch if carry cleared
	ldi	r27,1			;shifter = 1
	sts	shifter,r27		;store new data

TIM0_OVF_ISR0:
	lds	r16,portd_index	;load direct from data space
	mov	r17,r16			;copy register
	subi	r17,0xFF	;subtract immediate
	sts	portd_index,r17	;store new data
	ldi	r16,3			;if (portd_index > 3)
	cp	r16,r17			;compare
	brcc TIM0_OVF_ISR1	;branch if carry cleared
	ldi	r27,0			;turn on 1st, turn off 2nd 7seg.		
	sts	portd_index,r27	;portd_index = 0

TIM0_OVF_ISR1:
	pop	r27				;restore previous program state
	out	SREG,r27
	pop	r27
	pop	r31
	pop	r30
	pop	r18
	pop	r17
	pop	r16
	SEI					;enable interrupts
RETI

SPI_STC: 				;SPI Transfer Complete Handler
RETI

USART_RXC: 				;USART RX Complete Handler
RETI

USART_UDRE: 			;UDR Empty Handler
	sbis UCSRA, UDRE	;wait for Tx buffer to be empty
	rjmp USART_UDRE 	;not ready yet
RETI

USART_TXC: 				;USART TX Complete Handler
	out UDR, r17		;transmit character	
RETI

;ADC: 					;ADC Conversion Complete Handler
;RETI

EE_RDY: 				;EEPROM Ready Handler
	sbic EECR,EEWE		;Wait for completion of previous write
	rjmp EE_RDY			;loop until ready
RETI

ANA_COMP: 				;Analog Comparator Handler
RETI

TWI: 					;Two-wire Serial Interface Handler
RETI

SPM_RDY: 				;Store Program Memory Ready Handler
RETI
;
; ============================================
;
; M A I N
;
; ============================================
;
MAIN:
	;Store the current number being displayed to EEPROM
	clr ADR				;reset current address in eeprom
	lds r16, number0	;write data
	rcall EEPROM_write
	lds r16, number1
	rcall EEPROM_write
	
	;begin extracting digit data
	ldi	r20,232		;digit = number / 1000u
	ldi	r21,3
	lds	r16,number0
	lds	r17,number1
	rcall	div16u	;Do some division and extract thousands digit
	movw	r16,r24
	sts	digit0,r16	;store new data
	sts	digit1,r17
	rcall transmit	;convert to ascii
	mov	r2,r16		;and store it to PORTC array	
	rcall CUR_NUM	;find correct number to display 
					;portd_array[3] = mask(digit)
	push r16		;correct number found, save for later

	;next digit
	ldi	r20,100		;digit = (number / 100u) % 10u
	ldi	r21,0
	lds	r16,number0
	lds	r17,number1
	rcall	div16u	;Do some division and extract hundreds digit
	movw	r16,r24
	ldi	r20,10
	ldi	r21,0
	rcall	div16u	;Do some division
	movw	r16,r26
	sts	digit0,r16	;store new data
	sts	digit1,r17
	rcall transmit	;convert to ascii
	mov	r2,r16		;and store it to PORTC array	
	rcall	CUR_NUM	;find correct number to display
					;portd_array[2] = mask(digit)
	push r16		;correct number found, save for later

	;next digit
	ldi	r20,10		;digit = (number / 10u) % 10u
	ldi	r21,0
	lds	r16,number0
	lds	r17,number1
	rcall	div16u	;Do some division and extract tens digit
 	movw	r16,r24
	ldi	r20,10
	ldi	r21,0
	rcall	div16u	;Do some division
	movw	r16,r26
	sts	digit0,r16	;store new data
	sts	digit1,r17
	rcall transmit	;convert to ascii
	mov	r2,r16		;and store it to PORTC array
	rcall	CUR_NUM	;find correct number to display
					;portd_array[1] = mask(digit)
	push r16		;correct number found, save for later

	;next digit
	ldi	r20,10		;digit = number % 10u
	ldi	r21,0
	lds	r16,number0
	lds	r17,number1
	 rcall	div16u	;Do some division and extract ones digit
	movw	r16,r26
	sts	digit0,r16	;store new data
	sts	digit1,r17
	rcall transmit	;convert to ascii
	mov	r2,r16		;and store it to PORTC array
	rcall	CUR_NUM	;find correct number to display
	 				;portd_array[0] = mask(digit)
	push r16		;correct number found, save for later

	;store digits in PORTC array
	pop r16			
	sts portd_array0, r16	;ones digit
	pop r16					
	sts portd_array1, r16	;tens digit
	pop r16
	sts portd_array2, r16	;hundreds digit
	pop r16
	sts portd_array3, r16	;thousands digit

	rcall delay1SEC_INIT	;wait 1 sec
	
	;check if rollover is necessary, else go to Loop:
	lds	r16,number0	 
	lds	r17,number1		
	movw	r18,r16	;Copy Register Word
	subi	r18,0xFF;Subtract Constant from Register
	sbci	r19,0xFF;Subtract with Carry Constant from Reg.
	sts	number0,r18	;store new data
	sts	number1,r19		
	ldi	r16,0x0F	;(1)IF (number > 9999)
	ldi	r17,0x27
	cp	r16,r18		;compare
	cpc	r17,r19		;compare with carry
	brcc LOOP		;branch if carry cleared

	ldi	r27,0		;(2)THEN number = 0

	sts	number0,r27	;store new data
	sts	number1,r27
	;rolled over to 0
	rcall EXT_INT0	;trigger LED Event

					;(3)ELSE continue to Loop:
;
; ============================================
;
; P R O G R A M L O O P
;
; ============================================
;
LOOP:				;This creates a new line on the UART for each iteration
	ldi r17, 0x0B	;Transmits a vertical tab 
	rcall USART_UDRE
	rcall USART_TXC
	ldi r17, 0x0D	;and carriage return to UART
	rcall USART_UDRE
	rcall USART_TXC
rjmp MAIN			;Loop forever
;
; ============================================
;
; R O U T I N E S
;
; ============================================
;
delay1SEC_INIT:		;Delay_ms(1000)
	ldi	r18,41
	ldi	r17,150
	ldi	r16,128
delay1SEC:		
	dec	r16
	brne	delay1SEC
	dec	r17
	brne	delay1SEC
	dec	r18
	brne	delay1SEC
RET
;
;
;
;
;
delay100MS_INIT:	;Delay_ms(100)
	ldi	r18,5
	ldi	r17,15
	ldi	r16,242
delay100MS:		
	dec	r16
	brne	delay100MS
	dec	r17
	brne	delay100MS
	dec	r18
	brne	delay100MS
RET
;
;
;
;
;
transmit:			;Convert data to ASCII and send to USART RDY Handler
	push r16
	push r17
	push r18
	push r19
	push r20
	push r21
	push r22
	push r23
	push r24
	lds r16, digit0
	ori r16, 0x30
	MOV R17, R16
	rcall USART_UDRE
	rcall USART_TXC
	pop r24
	pop r23
	pop r22
	pop r21
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16
ret
;
;
;
;
;
div16u:					;Division routine
	movw	r24,r16		;copy register pair
	movw	r22,r20
	sub	r26,r26			;subtract without carry
	sub	r27,r27
	ldi	r21,17
	rjmp	d16u_2
d16u_1:
	rol	r26				;rotate left through carry
	rol	r27
	cp	r26,r22			;compare
	cpc	r27,r23			;compare with carry
	brcs	d16u_2		;branch if carry set
	sub	r26,r22
	sbc	r27,r23			;subtract with carry
d16u_2:
	rol	r24
	rol	r25
	dec	r21
	brne	d16u_1
	com	r24				;ones complement
	com	r25				
ret
;
;
;
;
;
CUR_NUM:				;Compare 0 - 9 to current number and branch to appropriate mask 
	;
	ldi	r27,0			;Check if zero
	cp	r2,r27
	breq	ZERO
	;
	ldi	r27,1			;Check if one
	cp	r2,r27
	breq	ONE	
	;
	ldi	r27,2			;Check if two
	cp	r2,r27
	breq	TWO	
	;
	ldi	r27,3			;Check if three
	cp	r2,r27
	breq	THREE
	;	
	ldi	r27,4			;Check if four
	cp	r2,r27
	breq	FOUR
	;	
	ldi	r27,5			;Check if five
	cp	r2,r27
	 breq	FIVE
	;	
	ldi	r27,6			;Check if six
	cp	r2,r27
	breq	SIX	
	;
	ldi	r27,7			;Check if seven
	cp	r2,r27
	breq	SEVEN
	;	
	ldi	r27,8			;Check if eight
	cp	r2,r27
	breq	EIGHT
	;	
	ldi	r27,9			;Check if nine
	cp	r2,r27
	breq	NINE
;	 
;
;
;
;
;number definitions
ZERO:
	ldi	r16,0x3f
	ret
ONE:
	ldi	r16,0x06
	ret
TWO:
	ldi	r16,0x5b
	ret
THREE:
	ldi	r16,0x4f
	ret
FOUR:
	ldi	r16,0x66
	ret
FIVE:
	ldi	r16,0x6d
	ret
SIX:
	ldi	r16,0x7d
	ret
SEVEN:
	ldi	r16,0x07
	ret
EIGHT:
	ldi	r16,0x7f
	ret
NINE:
	ldi	r16,0x6f
ret
;
;
;
;
;
EEPROM_read:		;Reads data stored in EEPROM in to r16
	rcall EE_RDY	;Wait for completion of previous write
	out EEARL, ADR	;Start eeprom read by writing EERE
	sbi EECR,EERE
	in r16,EEDR		;Read data from data register
	inc ADR			;Increment current address
ret
;
;
;
;
;

EEPROM_write:		;Writes data in register to EEPROM
	rcall EE_RDY	;Wait for completion of previous write
	out EEARL, ADR
	out EEDR, r16	;Write data (r16) to data register
	CLI				;Disable Interrupts
	sbi EECR,EEMWE	;Write logical one to EEMWE
	sbi EECR,EEWE	;Start eeprom write by setting EEWE
	SEI				;Enable Interrupts
	inc ADR			;Increment current address
ret
;
; ============================================
;
; E N D P R O G R A M
;
; ============================================
