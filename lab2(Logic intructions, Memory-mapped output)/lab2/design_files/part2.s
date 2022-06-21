/* Program that counts consecutive 1's */

          .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     R1, #TEST_NUM   // load the data word ...
          LDR     R8, [R1]        // into R8

          MOV     R0, #0          // R0 will hold the word result
		  MOV     R5, #0          // R5 will hold the main result
		  
		  BL      ONES
		  
END:      B       END

LOOP:     CMP     R5, R0          // Check if R5 < R0
		  MOVLT   R5, R0          // If R0 < R5, store R0 in R5
		  CMP     R8, #0          // Check if end of list. If so, then branch to done.
		  BEQ     DONE
		  ADD     R1, #4
		  LDR     R8, [R1]
		  MOV     R0, #0          // Reset R0 for the next word
		  B       ONES
		  
ONES:     MOV     R6, R8
CONT:     CMP     R6, #0          // Check if R6 is 0 yet, loop until data no longer contains 1s
		  BEQ     LOOP            // Once done with this subroutine, go back to loop
		  LSR     R7, R6, #1      // Perform LSR-AND command
		  AND     R6, R6, R7
		  ADD     R0, #1
		  B       CONT
		  
DONE: 	  B       END
		  

TEST_NUM: .word   0x00000001
		  .word   0x00000002
		  .word   0xFFFFFFFD
		  .word   0xFFFFFFFC
		  .word   0xFFFFFFFB
		  .word   0xFFFFFFFA
		  .word   0xFFFFFFF9
		  .word   0xFFFFFFF8
		  .word   0xFFFFFFF7
		  .word   0xFFFFFFF6
		  .word   0x00000000
		  
          .end                            
