.global _start
.equ  KEY_BASE, 0xFF200050
.equ  HEX_BASE, 0xFF200020

// program to turn LED 0 on and off in 
// response to key2 button being pressed and released

_start:   ldr R10,=KEY_BASE		// set r4 to base KEY port
	 	  ldr R8,=HEX_BASE		// set r5 to base of HEX port
	 	  mov  R2, #1			// first value of LEDR output
		 
BEG:	  MOV	R6,#99			//counter
		  BL	DISPLAY			//display 99
		  
DO_DELAY: LDR	R7, =500000		//arm is 200000000
		  
SUB_LOOP: SUBS	R7, R7, #1
		  BNE   SUB_LOOP
		  SUB	R6,#1			//decrement 
		  BL	POLL			//checking if anything is pressed
BACK:	  BL	DISPLAY			//displaying R6 every time it decrements
		  CMP	R6,#0
		  BEQ	BEG
		  B		DO_DELAY

//condition of poll
POLL:	PUSH	{LR}
		ldr 	r1, [r10,#0xC]		// load edge capture reg
		ands 	r1,#0x4			    // 'select' bit for Key2
		beq		GOOD				// if 0, go back to displaying it
		 
		mov  r3, #0x4			// turn off edge capture bit
		str r3, [r10,#0xC]		// by writing 1 into bit 2 
		
		//looping till changed again
RECHECK:ldr 	r1, [r10,#0xC]		// load edge capture reg
		ands 	r1,#0x4				// 'select' bit for Key2
		beq		RECHECK				// if 0, go back to displaying it
		//now the edge reg has been changed again
		mov  	r3, #0x4			// turn off edge capture bit
		str 	r3, [r10,#0xC]		// by writing 1 into bit 2 
		 
		b		GOOD			    // go back to poll loop
		
		
GOOD:	POP		{LR}
		mov 	pc,lr			//going back to main loop
	


//Display algorithm from lab 2 part 3
DISPLAY:    PUSH    {R4,R6,R9,LR}
			MOV     R0, R6          // display R6 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit
                                    // code
            BL      SEG7_CODE       
            LSL     R0, #8
            ORR     R4, R0
			
            STR     R4, [R8]        // display the numbers from R6 and R5
			POP		{R4,R6,R9,LR}
			MOV		PC,LR


//Standard divide code to get two separate numbers from the counter
DIVIDE:     MOV    R2, #0
CONT:       CMP    R0, #10
            BLT    DIV_END
            SUB    R0, #10
            ADD    R2, #1
            B      CONT
DIV_END:    MOV    R1, R2     // quotient in R1 (remainder in R0)
            MOV    PC, LR

//standard code to get the display code bits

SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment



	
