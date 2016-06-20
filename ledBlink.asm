;
; ==============================================
; LED BLINK ROUTINE
; ==============================================
;
ledBlink:
	LDI        	R27, 0xFF
	LDI        	R28, 0x00
	;Set Data Direction for PORTB      
	OUT        	DDRB, R27
ledBlinkLoop:
    ;turn ON the PORTB leds    
    OUT  	    PORTB, R27
	;delay
 	rcall      	delay100MS_INIT
	;turn OFF the PORTB leds
	OUT 	   	PORTB, R28
    ;delay
 	rcall      	delay100MS_INIT
	;turn ON the PORTB leds    
    OUT  	    PORTB, R27
	;delay
 	rcall      	delay100MS_INIT
	;turn OFF the PORTB leds
	OUT 	   	PORTB, R28
    ;delay
 	rcall      	delay100MS_INIT
	;turn ON the PORTB leds    
    OUT  	    PORTB, R27
	;delay
 	rcall      	delay100MS_INIT
	;turn OFF the PORTB leds
	OUT 	   	PORTB, R28
    ;delay
 	rcall      	delay100MS_INIT
	;turn ON the PORTB leds    
    OUT  	    PORTB, R27
	;delay
 	rcall      	delay100MS_INIT
	;turn OFF the PORTB leds
	OUT 	   	PORTB, R28
    ;delay
 	rcall      	delay100MS_INIT
	;turn ON the PORTB leds    
    OUT  	    PORTB, R27
	;delay
 	rcall      	delay100MS_INIT
	;turn OFF the PORTB leds
	OUT 	   	PORTB, R28
    ;delay
 	rcall      	delay100MS_INIT
