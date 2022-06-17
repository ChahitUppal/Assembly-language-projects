		.global _start
_start:
		LDR 	R2, =0xFF200000     // I/O Base Address, push bt
MAIN:	LDR		R1, =0x01010101	    // pattern
		LDR		R6, =6			    // index

LOOP:	STR		R1, [R2, #0x20]	    // write pattern to HEX3-0

// check for KEY press
        LDR     R0, [R2, #0x50]     // load KEYs
        CMP     R0, #0              // any pressed?
        BEQ     NO_KEY

WAIT:   LDR     R0, [R2, #0x50]     // poll the KEYs
        CMP     R0, #0
        BNE     WAIT                // wait for KEY release

NO_KEY: LSL		R1, #1			    // shift left

        MOV		R8, #0x80000        // delay value
DELAY:	SUBS	R8, #1
		BNE		DELAY

		SUBS 	R6, #1
		BNE		LOOP
		
		B		MAIN	
		
//displaying code
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment
