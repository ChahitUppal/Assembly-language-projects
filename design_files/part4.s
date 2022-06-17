.global _start
.equ  KEY_BASE, 0xFF200050
.equ  HEX_BASE, 0xFF200020
.equ  MPCORE_PRIV_TIMER, 0xFFFEC600 // base of private timer


// program to turn LED 0 on and off in 
// response to key2 button being pressed and released

_start:   ldr 	R10, =KEY_BASE		// set r4 to base KEY port
	 	  ldr 	R8, =HEX_BASE		// set r5 to base of HEX port
		  LDR	R11, =MPCORE_PRIV_TIMER
		  ldr 	r3, =2000000	   // counter will be loaded with 2M -> 1 sec count down
		  str 	r3, [r11]
		
	      mov	r3, #0b011	    // turn on A and E bits in counter control register
	      str 	r3, [r11,#8]		    // store in timer control reg
	 	  mov 	R2, #1			// first value of LEDR output
		 
		  MOV	R6,#0			//hundreths of sec
		  MOV	R7,#0			//sec in R7
		   
DO_DELAY: LDR	R5, [R10]
		  CMP	R5, #0
		  BNE	DO_DELAY
		  ldr   r3,[r11,#0xC]	   // get the full status register
		  ands r3, #0x1		  	   // isolate bit 0
		  beq  DO_DELAY	   		   // wait till F bit is 1
		 
		  str  r3,[r11,#0xC]	   // arrive here only if r3 bit 0 = 1
                  		   		// write that 1 into 0xffec50C
			           			// to turn off F flag in status reg
		  ADD	R6,#1			//increment
		  CMP 	R6, #100
		  BEQ	SETZERO
		  B		BRDIS
		  
		  
BRDIS: 	  BL	DISPLAY			//displaying R6 every time it decrements
		  B		DO_DELAY
		  BL	DISPLAY			//displaying the number on HEX


SETZERO:  MOV	R6, #0
		  ADD	R7, #1			//incrementing R7 everytime R6 reached max
		  CMP	R7, #60			//sec reach max
		  BEQ	SETZERO1		
		  B		BRDIS

SETZERO1: MOV	R7, #0			//resetting sec
		  MOV	R6, #0			//resetting hindreds of sec
		  B		BRDIS			//going back home

//display algorithm from part 4 of lab 2
//hundreths of a second in R6 and sec in R7
DISPLAY:	PUSH    {R4,R6,R9,LR}
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
			
            MOV     R0, R7          // display R7 on HEX3-2
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE   
			LSL		R0, #16
            ORR     R4, R0          // save bit code
            MOV     R0, R9          // retrieve the tens digit, get bit
                                    // code
            BL      SEG7_CODE       
            LSL     R0, #24
            ORR     R4, R0

            STR     R4, [R8]        // display the numbers from R6 and R5
			POP		{R4,R6,R9,LR}	//goin back home
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




poll:	ldr r1, [r0,#0xC]		// load edge capture reg
	ands r1,#0x4			// 'select' bit for Key2
	beq	poll			// if 0, loop
		 
	str r2, [r4]			// turn on/off LED
	eor r2, #1			// invert r2 for next time
		 
	mov  r3, #0x4			// turn off edge capture bit
	str r3, [r0,#0xC]		// by writing 1 into bit 2 
		 
	b	poll			// go back to poll loop
	
