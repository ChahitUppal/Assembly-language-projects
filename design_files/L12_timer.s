// program to turn LED 0 on and off every second
// using the A9 private timer

.global _start

.equ  LEDR_BASE, 0xFF200000  // base address of LEDR port
.equ  MPCORE_PRIV_TIMER, 0xFFFEC600 // base of private timer

_start: ldr r0,=LEDR_BASE	  // base address of LED
	mov r2, #1
	ldr r8, =MPCORE_PRIV_TIMER  // base address of a9 private timer
		
	ldr r3,=200000000	   // counter will be loaded with 2M -> 1 sec count down
	str r3, [r8]
		
	mov	r3, #0b011	    // turn on A and E bits in counter control register
	str r3, [r8,#8]		    // store in timer control reg
		
display: str r2, [r0]		    // send value to LED 0
	 eor r2, #1		    // invert value
		
// poll the timer to wait till 1s has passed

wait:	ldr r3,[r8,#0xC]	   // get the full status register
	ands r3, #0x1		   // isolate bit 0
	beq  wait		   // wait till F bit is 1
		 
	str  r3,[r8,#0xC]	   // arrive here only if r3 bit 0 = 1
                  		   // write that 1 into 0xffec50C
			           // to turn off F flag in status reg
	b display
	
	
