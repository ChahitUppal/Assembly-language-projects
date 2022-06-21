		.global _start
_start:
		LDR 	R2, =0xFF200000     // I/O Base Address, push bt
MAIN:	MOV		R0, #0			    // starting with zero
		MOV		R5,#0				//COUNTER
	 	BL		SEG7_CODE			//getting the bit code

LOOP:	STR		R0, [R2, #0x20]	    // write pattern to HEX3-0
		MOV		R8, #0x100000        // delay value
DELAY:	SUBS	R8, #1
		BNE		DELAY

// check for KEY press
  
WAIT:	LDR     R1, [R2, #0x50]     // load KEYs
        CMP     R1, #0              // any pressed?
        BEQ     WAIT
//check which key is pulled and act accordingly
		CMP		R1, #0b0001
		BEQ		KEY0				//go to key0
        CMP     R1, #0b0010
        BEQ     KEY1                //go to key1 
		CMP		R1, #0b0100			
		BEQ		KEY2				//go to key2
		CMP		R1,#0b1000			
		BEQ		KEY3				//go to key3
		B		WAIT
		
		
//code for key 0 with wait till unpushed
KEY0: 	LDR     R1, [R2, #0x50]     // load KEYs
        CMP     R1, #0              // any pressed?
		BNE		KEY0
		MOV		R5, #0				//reseting counter
		MOV		R0, R5				//getting the counter value in R0 to display
		BL		SEG7_CODE
		B		LOOP


//code for key 1 with wait till unpushed
KEY1: 	CMP		R5,#9				//incase already reached the limit
		BEQ		WAIT1				//skip over if reached the limit
		ADD		R5,#1				//increment counter
WAIT1:	MOV		R0,R5				//enter required value in R0
		LDR     R1, [R2, #0x50]     // load KEYs
        CMP     R1, #0              // any pressed?
		BNE		WAIT1
		BL		SEG7_CODE			//getting the bit code
		B		LOOP	
		
//code for key 2 with wait till unpushed
KEY2: 	CMP		R5,#0				//incase already reached the limit
		BEQ		WAIT2				//skip over if reached the limit
		BLT		NEG					//corner case when R5 is negative
		SUB		R5,#1				//increment counter
WAIT2:	MOV		R0,R5				//enter required value in R0
		LDR     R1, [R2, #0x50]     // load KEYs
        CMP     R1, #0              // any pressed?
		BNE		WAIT2
		BL		SEG7_CODE			//getting the bit code
		B		LOOP
		
NEG:	MOV		R5,#0				//resetting R5
		B		WAIT2				//back on track
		
//code for key 3 with wait till unpushed
KEY3:	LDR     R1, [R2, #0x50]     // load KEYs
        CMP     R1, #0              // any pressed?
		BNE		KEY3
		MOV		R0,#0b00000000
		MOV		R5, #-1				//reseting counter
		B		LOOP
		


		
//displaying code
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment
