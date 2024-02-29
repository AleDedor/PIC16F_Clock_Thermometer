	list		p=16f684		; list directive to define processor
	#include	<P16F684.inc>		; processor specific variable definitions
	
	__CONFIG    0x3FC4
	ORG		0x000			; processor reset vector
  	goto	inizio			; go to beginning of program
	ORG		0x004			; interrupt vector location

cblock 0x020
W_temp
STATUS_TEMP
conta
conta1
conta2
conta3
conta4
gradi
ug
dg
mezzog
temp_oro
minuti
ore
min1
min2
ora1
ora2
minu
or
tp
VALORE
somma 
media
endc

	goto	int
nop
nop
nop
nop
nop
nop							
inizio
	clrf	PORTA
	clrf	PORTC
	movlw	.7
	movwf	CMCON0
	bsf		STATUS,RP0
	movlw	b'10000100'
	movwf	OPTION_REG
	movlw	b'00000001'
	movwf	ANSEL
	movlw	b'00010000'
	movwf	ADCON1
	movlw	b'110000'
	movwf	TRISC
	movlw	b'001001'
	movwf	TRISA
	bcf		STATUS,RP0
	clrf	PORTC
	clrf	PORTA
	clrf	temp_oro
	clrf	minuti
	clrf	ore
	movlw	.125
	movwf	conta2
	movlw	.60
	movwf	conta3
	movlw	b'10100000'
	movwf	INTCON ;abilitazione interrupt TMR0
	movlw	b'10000001'
	movwf	ADCON0
programma
	btfsc	PORTC,4
	call	rminuti
	btfsc	PORTC,5
	call	rore
	btfss	PORTA,3
	goto	non
	btfsc	PORTA,3
	goto	$-1
	comf	temp_oro
non
	btfss	temp_oro,0
	goto	oro
	call	temperatura	
	goto 	programma
oro
	call	orologio	
	goto 	programma


;programma lettura temperatura
temperatura
	clrf	VALORE
	clrf	somma
	movlw	.5
	movwf	media
AD
	bsf		ADCON0,GO
	btfsc	ADCON0,GO
	goto	$-1	
	bsf 	STATUS,RP0
	movfw	ADRESL
	bcf 	STATUS,RP0
	movwf	gradi
;	clrf	mezzog
;	btfss	gradi,0
;	goto	ruota
;	movlw	.5
;	movwf	mezzog
ruota
	bcf		STATUS,C
	rrf		gradi,1	
	movfw	gradi
	addwf	somma,1
	decfsz	media,1
	goto	AD
average
	MOVLW	.5
	SUBWF	somma,1
	BTFSS	STATUS,C
	GOTO	binbcd
	INCF	VALORE,1
	GOTO	average
binbcd
	clrf	ug
	clrf	dg

bcd
	movfw	VALORE
	movwf	ug
	movlw	.10
	subwf	VALORE,1
	btfss	STATUS,C
	goto	porte
	incf	dg,1
	goto	bcd
porte
	movlw	b'011111'
	movwf	PORTA
	movlw	b'001100'
	movwf	PORTC

	movlw	b'101111'
	movwf	PORTA
	movlw	b'000000'
;	movfw	mezzog
	movwf	PORTC

	movlw	b'111011'
	movwf	PORTA
	movfw	ug
	movwf	PORTC

	movlw	b'111101'
	movwf	PORTA
	movfw	dg
	movwf	PORTC
	movlw	b'111111'
	movwf	PORTA
delay
	movlw	.10
	movwf	conta4
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
	decfsz	conta4 ,1
	goto	ciclo
	return
;programma orologio
;conversione BCD
orologio
	clrf	min2
	clrf	ora2
	movfw	minuti
	movwf	minu
	movfw	ore
	movwf	or
dividi
	movfw	minu
	movwf	min1	
	movlw	.10
	subwf	minu,1
	btfss	STATUS,C
	goto	decine
	incf	min2,1
	goto	dividi
decine
	movfw	or
	movwf	ora1
	movlw	.10
	subwf	or,1
	btfss	STATUS,C
	goto	esci
	incf	ora2,1
	goto	decine
esci
;scritte su display
	movlw	b'011111'
	movwf	PORTA
	movfw	min1
	movwf	PORTC

	movlw	b'101111'
	movwf	PORTA
	movfw	min2
	movwf	PORTC

	movlw	b'111011'
	movwf	PORTA
	movfw	ora1
	movwf	PORTC

	movlw	b'111101'
	movwf	PORTA
	movfw	ora2
	movwf	PORTC
	movlw	b'111111'
	movwf	PORTA

;ritardo
	movlw	.200
	movwf	conta1
	clrf	conta
ciclo1
	nop
	nop
	decfsz	conta,1
	goto	ciclo1
	decfsz	conta1,1
	goto	ciclo1
	return
;regola minuti
rminuti
	clrf	tp
cic
	nop
	nop
	decfsz	tp,1
	goto	cic
	btfsc	PORTC,4
	goto	$-1
	incf	minuti,1
	movlw	.60
	xorwf	minuti,0
	btfsc	STATUS,Z
	clrf	minuti	
	return
;regola ore
rore
	clrf	tp
cico
	nop
	nop
	decfsz	tp,1
	goto	cico
	btfsc	PORTC,5
	goto	$-1
	incf	ore,1
	movlw	.24
	xorwf	ore,0
	btfsc	STATUS,Z
	clrf	ore	
	return
;gestione interrupt
int
	movwf	W_temp
	swapf 	STATUS,W 
	clrf 	STATUS 
	movwf 	STATUS_TEMP
	bcf		INTCON,T0IF
	movlw	.6
	movwf	TMR0
	decfsz	conta2,1
	goto	ritorno
	movlw	.125
	movwf	conta2
	decfsz	conta3,1
	goto	ritorno
	movlw	.60
	movwf	conta3
	incf	minuti,1 
	movlw	.60
	xorwf	minuti,0
	btfss	STATUS,Z
	goto	ritorno
	clrf	minuti

	incf	ore,1
	movlw	.24
	xorwf	ore,0
	btfss	STATUS,Z
	goto	ritorno
	clrf	ore
ritorno
	swapf 	STATUS_TEMP,0 
	movwf	STATUS 
	swapf 	W_temp,1 
	swapf 	W_temp,0
	retfie

	END                       ; directive 'end of program'