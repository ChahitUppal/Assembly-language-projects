.global _start
.equ  KEY_BASE, 0xFF200050
.equ  LEDR_BASE, 0xFF200000

// program to turn LED 0 on and off in 
// response to key2 button being pressed and released

_start:  ldr r0,=KEY_BASE		// set r0 to base KEY port
	 ldr r4,=LEDR_BASE		// set r4 to base of LEDR port
	 mov  r2, #1			// first value of LEDR output

poll:	ldr r1, [r0,#0xC]		// load edge capture reg
	ands r1,#0x4			// 'select' bit for Key2
	beq	poll			// if 0, loop
		 
	str r2, [r4]			// turn on/off LED
	eor r2, #1			// invert r2 for next time
		 
	mov  r3, #0x4			// turn off edge capture bit
	str r3, [r0,#0xC]		// by writing 1 into bit 2 
		 
	b	poll			// go back to poll loop
	
