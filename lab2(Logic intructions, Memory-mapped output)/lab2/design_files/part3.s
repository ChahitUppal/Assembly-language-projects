/* Program that counts consecutive 1's */

          .text                   // executable code follows
          .global _start                  
_start:                             
          MOV     R8, #TEST_NUM   // load the data word ...
          LDR     R1, [R8]        // into R8
		  MOV 	  SP, #0x20000
		  BL	  ONES			  //counts the largest sequence of 1s in R0
		  MOV	  R5,R0			  //entering the largest sequence in R5
		  BL	  ZEROS			  //counts the largest sequence of 0s
		  MOV	  R6,R0			  //putting the no of largest sequence of 0s in R6	  
		  BL	  ALTERNATE		  //checking of alternating pattern
		  MOV 	  R7,R0

END:      B       END  

ONES:     MOV     R0, #0          // R0 will hold the final result
		  MOV	  R3, #0		  //will use R3 to compare and store the value
		  PUSH    {R8}            //putting R8 in the stack
LOOP1:    CMP     R1, #0          // loop until the data contains no more 1's
          BEQ     DONE1             
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R3, #1          // count the string length so far
          B       LOOP1            
DONE1:	  CMP	  R0, R3		  //checks if sequence is larger than the previous one
		  MOVLT	  R0, R3		  //putting the value in R0 if greater
		  MOV	  R3,#0			  //resetting the curretn largest sequence value
		  ADD	  R8,#4			  //moving onto the next number
		  LDR	  R1, [R8]		  //loading new data in R1
		  CMP	  R1, #0		  //checking if the new data is 0
		  BNE	  LOOP1
		  POP	  {R8}
		  MOV	  PC,LR			  //moving back to the main code

ZEROS:    MOV     R0, #0          // R0 will hold the result
		  MOV	  R3, #0		  //will use R3 to compare and store the value
		  LDR     R1, [R8]        // getting the value in R1
		  CMP	  R1, #0		  //checking if corner case where first element is 0
		  BEQ	  CORNER		  
		  PUSH    {R8}            //putting R8 in the stack
LOOP2:    CMP     R1, #0xffffffff // loop until the data contains no more 0's
          BEQ     DONE2             
          ROR     R2, R1, #1      // perform SHIFT, followed by ORR
          ORR     R1, R1, R2      
          ADD     R3, #1          // count the string length so far
          B       LOOP2            
DONE2:	  CMP 	  R0, R3		  //checks if the sequence is larger than the previous
		  MOVLT	  R0, R3		  //put value in Ro if greater
		  MOV	  R3,#0			  //resetting the curretn largest sequence value
		  ADD	  R8, #4		  //moving onto the next element
		  LDR	  R1, [R8]		  //getting the new element in R1
		  CMP	  R1, #0		  //checking if the new data is 0
		  BNE	  LOOP2
		  POP	  {R8}
CORNER:   MOV	  PC,LR			  //moving back to the main code

ALTERNATE:MOV     R3, #0          // R3 will hold the total largest sequence
		  MOV	  R0, #0		  //R0 will hold the current largest sequence
		  PUSH    {R8,LR}		  //saving the link register and R8 on the stack
ANOTHER:  LDR	  R1, [R8]		  // loading he element into R1
		  CMP     R1, #0		  //checking if the element is 0
		  BEQ	  LAST
		  ASR     R2, R1, #1      // perform SHIFT, followed by AND
          EOR     R1, R1, R2   	  //XOR will give us a no with 1's sequence as alternate
		  BL	  ONES
		  ADD 	  R0, #1
		  CMP 	  R3, R0		  //comparing the current largest to the total largest
		  MOVLT	  R3, R0		  //updating R3 if necessary
		  ADD	  R8, #4		  //moving onto the next element
		  B		  ANOTHER
LAST:	  MOV     R0,R3			  //utting the final ans in R) from R3
		  POP	  {R8,LR}			  //getting the lr back from stack
		  MOV 	  PC,LR         


           

TEST_NUM: .word   0x55555555
		  .word   0
          .end                            
