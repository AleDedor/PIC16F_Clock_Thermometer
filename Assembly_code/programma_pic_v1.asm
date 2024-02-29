list p=16f684
	#include <p16f684.inc>
	__CONFIG 0X3FC4
	
	#define PRESCALER B'10000100'
	#define INTERRUPT B'10100000'
	#define TRISAX B'001001'
	#define TRISCX B'110000'

	cblock 0x020
	FUNZIONE
	H
	ORE
	ORE1
	ORE2
	M
	MINUTI
	MINUTI1
	MINUTI2
	CONTA
	APPOGGIO
	SECONDI
	TEMPO
	TEMPO1
	STATUS_TEMP
	VALORE
	UNITA
	DECINE
	INCREMENTOM
	INCREMENTOH
	gradi
	mezzog
	conta
	conta1
	endc

	org 0x00
	goto inizializzazione
	org 0x04

	;programma interrupt
	movwf APPOGGIO
	swapf STATUS,W 
	clrf STATUS 
	movwf STATUS_TEMP
	bcf INTCON,T0IF
	movlw .6 ;PARTENZA TMR0
	movwf TMR0
	INCF CONTA,1
	
	MOVLW .125 ;RIPETIZIONE OVERFLOW
	XORWF CONTA,0
	BTFSS STATUS,Z
	goto test
	incf SECONDI,1
	CLRF CONTA
	
	MOVLW .60
	XORWF SECONDI,0
	BTFSS STATUS,Z
	goto test
	incf MINUTI,1
	CLRF SECONDI
	
	MOVLW .60
	XORWF MINUTI,0
	BTFSS STATUS,Z
	goto test
	incf ORE,1
	CLRF MINUTI
	
	INCF ORE,1
	MOVLW .24
	XORWF ORE,0
	BTFSS STATUS,Z
	GOTO test
	CLRF ORE
	CLRF MINUTI
	CLRF SECONDI

test

	swapf 	STATUS_TEMP,0 
	movwf	STATUS 
	swapf 	APPOGGIO,1 
	swapf 	APPOGGIO,0
	RETFIE
	;fine interrupt

inizializzazione
	CLRF						PORTA
	CLRF						PORTC
	MOVLW						.7
	MOVWF						CMCON0	
	bsf STATUS,RP0
	movlw TRISAX
	movwf TRISA
	movlw TRISCX
	movwf TRISC
	movlw PRESCALER
	movwf OPTION_REG
	MOVLW						B'00000001'	
	MOVWF						ANSEL
	bcf STATUS,RP0
	MOVLW 						B'10000001'
	MOVWF 						ADCON0
	clrf FUNZIONE
	movlw INTERRUPT
	movwf INTCON
	CLRF CONTA
	CLRF SECONDI
	CLRF FUNZIONE
	CLRF ORE1
	CLRF ORE2
	CLRF MINUTI1
	CLRF MINUTI2
	CLRF MINUTI
	CLRF ORE

inizio
	btfss PORTA,3
	goto $-1
	btfsc PORTA,3
	goto $-1

	btfss FUNZIONE,0
	goto OROLOGIO
	goto TERMOMETRO

OROLOGIO 	;inserendo un numero in una porta, 
			;la porta assume il valore di uscita già codificato
			;in BINARIO(BCD)

	MOVFW MINUTI
	MOVWF M
	MOVFW ORE
	MOVWF H
dividi1
	movfw	M
	movwf	MINUTI2
	movlw	.10
	subwf	M,1
	btfss	STATUS,C
	goto	dividi2
	incf	MINUTI1,1
	goto	dividi1
dividi2
	movfw	H
	movwf	ORE2
	movlw	.10
	subwf	H,1
	btfss	STATUS,C
	goto	scrittura
	incf	ORE1,1
	goto	dividi2

scrittura
	MOVLW B'111111'
	MOVWF PORTA

	MOVFW MINUTI1
	MOVWF PORTC
	MOVLW B'101111'
	MOVWF PORTA	
	MOVLW B'111111'
	MOVWF PORTA

	MOVFW MINUTI2
	MOVWF PORTC
	MOVLW B'011111' ;LetchEnable porta ra1,ra4,ra2,ra5
	MOVWF PORTA
	MOVLW B'111111'
	MOVWF PORTA

	MOVFW ORE1
	MOVWF PORTC
	MOVLW B'111101'
	MOVWF PORTA
	MOVLW B'111111'
	MOVWF PORTA

	MOVFW ORE2
	MOVWF PORTC
	MOVLW B'111011' ;LetchEnable porta ra1,ra4,ra2,ra5
	MOVWF PORTA
	MOVLW B'111111'
	MOVWF PORTA

	BTFSS PORTC,5
	GOTO $+2
	CALL INCREMENTOORE

	BTFSS PORTC,4
	GOTO $+2
	CALL INCREMENTOMINUTI

	bsf FUNZIONE,0
	btfss PORTA,3
	GOTO OROLOGIO
	goto inizio

TERMOMETRO
;programma termometro

	bsf		ADCON0,GO
	btfsc	ADCON0,GO
	goto	$-1	
	bsf 	STATUS,RP0
	movfw	ADRESL
	bcf 	STATUS,RP0
	movwf	VALORE
	clrf	mezzog
	btfss	VALORE,0
	goto	ruota
	movlw	.10
	movwf	mezzog
ruota
	bcf		STATUS,C
	rrf		VALORE,1	
	clrf	UNITA
	clrf	DECINE
bcd
	movfw	VALORE
	movwf	UNITA
	movlw	.10
	subwf	VALORE,1
	btfss	STATUS,C
	goto	porte
	incf	DECINE,1
	goto	bcd
porte
	movlw	b'011111'
	movwf	PORTA
	movlw	b'000000'
	movwf	PORTC

	movlw	b'101111'
	movwf	PORTA
	movfw	mezzog
	movwf	PORTC

	movlw	b'111011'
	movwf	PORTA
	movfw	UNITA
	movwf	PORTC

	movlw	b'111101'
	movwf	PORTA
	movfw	DECINE
	movwf	PORTC
	movlw	b'111111'
	movwf	PORTA

delay
	movlw	.200
	movwf	conta1
	clrf	conta
ciclo
	nop
	nop
	decfsz	conta,1
	goto	ciclo
	decfsz	conta1,1
	goto	ciclo

	bcf FUNZIONE,0
	btfss PORTA,3
	GOTO TERMOMETRO
	goto inizio
	

INCREMENTOORE
	btfss PORTC,5
	goto $-1
	btfsc PORTC,5
	goto $-1
BCF INTCON,6
	INCF ORE,1

BSF INTCON,6	
	RETURN

INCREMENTOMINUTI
	btfss PORTC,4
	goto $-1
	btfsc PORTC,4
	goto $-1
BCF INTCON,6
	INCF MINUTI,1

BSF INTCON,6
	RETURN


	END