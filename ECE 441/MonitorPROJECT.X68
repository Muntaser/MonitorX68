*-----------------------------------------------------------
* Program    : ECE 441 FINAL PROJECT
* Written by : MUNTASER KHAN
* Date       : 04/30/13
* Description: THIS PROGRAM WILL SIMULATE THE MONITOR PROGRAM
*	       with debugger commands,exception handlers.
*-----------------------------------------------------------




*STACK
	ORG	$3000
	DS.B	4096


*			START			          


*CODE STARTS AT $1000
	ORG	$1000
START:	JSR	EX_HANDLER	
	JSR	OUTPUT		*BRANCHES TO OUTPUT NAME
	JSR	PARSING	*BRANCHS TO PARSING TO CHECK SPACE,CHARACTER ARE LETTERS OR NOT ETC.
	BRA 	START		* LOOP BACK TO START
	
***********************************************************
*Start of Memory reservation and messages	          *
***********************************************************
START_BUF	DS.B	80		*START OF INPUT BUFFER 
END_BUF	DC.B	' ',0		*END OF INPUT BUFFER

PROG_NAME	DC.B	'MONITOR441> ',0		*PROGRAM NAME
ER_MES	DC.B	'INVALID INPUT',0	*ERROR MESSAGE


*CMD TABLES*
CMD_TABL	DC.B	'HELP ',0		*NEED 12 CMD'S
	DC.B	'EXIT ',0
	DC.B	'GOTO ',0
	DC.B	'CVR1 ',0
	DC.B	'CVR2 ',0
	DC.B	'MDSP ',0
	DC.B	'BLFI ',0
	DC.B	'MEMM ',0
	DC.B	'MSET ',0
	DC.B	'BLKM ',0
	DC.B	'BSRH ',0
	DC.B	'SORT ',0


*HELP TABLE
HEL_TABL	DC.B	'HELP MESSAGE                                   ',0
	DC.B	'_______________________________________________',0
	DC.B	'HELP: Displays the help message.               ',0
	DC.B	'      eg: HELP<CR>                             ',0
	DC.B	'EXIT: Exits the program.                       ',0
	DC.B	'      eg: EXIT<CR>                             ',0
	DC.B	'GOTO: Starts execution from a given address.   ',0
	DC.B	'      eg: GOTO $5000<CR>                       ',0
	DC.B	'CVR1: CONvert a 2 char hex number to a dec num.',0
	DC.B	'      eg: CVR1 $AA<CR>                         ',0
	DC.B	'CVR2: Convert a 2 dig dec number to a hex num. ',0
	DC.B	'      eg: CVR2 #33<CR>                         ',0
	DC.B	'MDSP: Displays the memory from a start location',0
	DC.B	'      to an end location in byte form.         ',0
	DC.B	'      eg: MDSP $0500 $0520<CR>                 ',0
	DC.B	'BLFI: Fills a block of memory with value.      ',0
	DC.B	'      eg: BLFI $0100 $0120 $3E<CR>             ',0
	DC.B	'MEMM: Changes the CONtents of the memory at a  ',0
	DC.B	'      start location. "." to exit.             ',0
	DC.B	'      eg: MEMM $4000<CR>                       ',0
	DC.B	'MSET: Changes the memory to a specified string ',0
	DC.B	'      of characters. Size is limited to buffer ',0
	DC.B	'      space.                                   ',0
	DC.B	'      eg: MSET $5000 MUNTASER<CR>           ',0
	DC.B	'BLKM: Moves Contents of memory in specified    ',0
	DC.B	'      range to memory at the new location. The ',0
	DC.B	'      new location can not be in between the   ',0
	DC.B	'      mem range specified. Only even locations.',0
	DC.B	'      eg: BLKM $4000 $5000 $6000<CR>           ',0
	DC.B	'BSRH: Searches the specified range of memory for',0
	DC.B	'      the given string entered.                ',0
	DC.B	'      eg: BSRH $6000 $7000 MUN<CR>           ',0
	DC.B	'SORT: Sorts Contents of specified range of mem ',0	
	DC.B	'      from greatest to least.(words at even ad)',0
	DC.B	'      eg: SORT $0000 $000E                     ',0
HELP_END DC.B	'                                               ',0
EN_LINE	DC.B	'                               ',0
TMP	DC.B	'                               ',0
TMP2	DC.B	'                                                               ',0
TMP3	DC.B	'                                                               ',0
TMP4	DC.B	'  :',0
TMP5	DC.B	'   ',0
TMP6	DC.B	'                               ',0
TMP7	DC.B	'                               ',0
TMP8	DC.B	'                               ',0
BLK_FOUND	DC.B	'BLOCK FOUND!',0
BLK_NFOUND	DC.B	'BLOCK NOT FOUND!',0
SORT_P	DC.B	'SORT IS DONE!',0
ER_MES2	DC.B	'THIS IS A RESTRICTED ADDRESS!',0




**Exception Messages
BUS_S	DC.B	'Bus Error Exception',0
ADDR_S	DC.B	'Address Error Exception',0
ILLEGAL_S	DC.B	'Illegal Instruction Exception',0
DIVZ_S	DC.B	'Divide by 0 Exception',0
PRIV_S	DC.B	'Privilage Violation Exception',0
LINA_S	DC.B	'Line A Exception',0
LINF_S	DC.B	'Line F Excetpion',0
CHE_S	DC.B	'CHECK Error Exception',0


					          




D_TABL	DC.B	'D0: ',0
	DC.B	'D1: ',0
	DC.B	'D2: ',0
	DC.B	'D3: ',0
	DC.B	'D4: ',0
	DC.B	'D5: ',0
	DC.B	'D6: ',0
	DC.B	'D7: ',0
	
A_TABL	DC.B	'A0: ',0
	DC.B	'A1: ',0
	DC.B	'A2: ',0
	DC.B	'A3: ',0
	DC.B	'A4: ',0
	DC.B	'A5: ',0
	DC.B	'A6: ',0
	DC.B	'A7: ',0
	



*Main program loops until THE USER INPUTS EXIT            



*Subroutines for buffer calls		                


OUTPUT	LEA	PROG_NAME,A1	*OUTPUTS 'MONITOR441> '
	MOVE.B	#14,D0
	TRAP	#15
	JSR	CLEAR_BUF		*CLEARS THE INPUT BUFFER
	LEA	START_BUF,A1	*INPUTS CMD
	MOVE.B	#2,D0
	TRAP 	#15
	RTS			*RETURN TO START
	
PARSING			*CHECK_1 SEES IF FIRST CHARACTERS ARE LETTERS
CHECK_1	CMP.B	#4,D1		*CHECKS IF INPUT IS LESS THAN 4 CHARACTERS
	BLT	ERROR		*IF INPUT IS LESS THAN 4 CHARACTERS GIVE AN ERROR
	CMP.L	#$40,D1		*CHECKS IF INPUT IS GREATER THAN $40  CHARACTERS WHICH IS BUFFER SIZE
	BGT	ERROR			*IF BIGGER, GIVE AN ERROR
	CMP.B	#$04,D1		*IF CMD IS ONLY 4 CHARACTERS ( EXIT,GOTO)
	BEQ	NEXT	
	BRA	S_CHECK		*OTHERWISE CHECKS IF THERE IS A SPACE IN MIDDLE
NEXT	CLR.L	D2		*CLEARS D2
CHARN	CMP.B	#4,D2		*IF D2 IS 4
	BEQ	CHECK_2		*TABLE LOOPUP
	ADDA.W	#1,A1		*INCREAMENTS ADDRESS BY 1
	ADDI.B	#1,D2		**INVREMENTS COUNTER BY 1
	BRA 	CHARN		*LOOP TO CHARN

S_CHECK	MOVEM.L	A1,-(A7)	*SAVE REGISTER A1
	ADDA.W	#4,A1		*GETS TO WHERE SPACE SHOULD BE BY ADDING 4
	CMP.B	#' ',(A1)	*IF EQUAL TO SPACE
	BNE	ERROR		*IF NOT EQUAL ERROR
	MOVEM.L	(A7)+,A1	*RESTORE REGISTER
	BRA	NEXT		*LOOP TO NEXT
	
*CLEARS THE BUFFER SPACE FOR INPUT	
CLEAR_BUF	MOVEM.L	A1/A2,-(A7)	*SAVE REGISTER A1 AND A2
	LEA	START_BUF,A1	*START ADDRESS
	LEA	END_BUF,A2	*END ADDRESS
CLEAR_CHECK	CMPA.L	A1,A2		*COMPARES THE START AND END
	BEQ	CLEAR_DONE		*IF EQUAL DONE
	MOVE.W	#$00,(A1)+	*MOVES 00 TO THE FIRST POS AND NEXT POSITIONS
	BRA 	CLEAR_CHECK		*LOOP TO CLEAR_CHECK
CLEAR_DONE	MOVEM.L	(A7)+,A1/A2	*LOAD REGISTERS A1 AND A2
	RTS

*Table Loopup
CHECK_2	LEA 	CMD_TABL,A2	  *COMMAND TABLE STARTS AT A2 AND ENDS AT A3
	LEA	START_BUF,A3	
	CLR.L	D2		*CLEAR D2 AS WE HAVE TO MOVE CHARACTERS IN IT
	CLR.L	D4		*COUNTER FOR NUM OF CMD'S 12
	MOVE.L	(A3),D2		*MOVES THE FIRST 4 CHAR INTO D2 FROM START OF BUFFER
CHECK_TABL	CMPI.L	#12,D4		*IF GREATER THAN MAX NUMBER OF CMD'S THEN GIVE AN ERROR MESSAGE
	BEQ	ERROR		*ERROR
	ADDI.L	#1,D4		*ADD 1 TO D4 TO GET TO COMMAND POSITION
	MOVE.L	(A2),D3		*MOVES THE FIRST CMD TO D3
	CMP.L	D2,D3		*COMPARS THE INPUTED CMD WITH THE TABLE CMD
	BEQ	CMD_EXEC		*IF EQUAL THEN EXECUTE COMMAND
	ADDA.L	#6,A2		*INCREMENTS TO NEXT CMD
	BRA	CHECK_TABL		*LOOP TO CHECK_TABL

***********************************************************
*Command Execution				          *
***********************************************************

CMD_EXEC	CMPI.L	#1,D4		*GOES TO HELP
	BEQ	HELP
	CMPI.L	#2,D4		*GOES TO EXIT
	BEQ	EXIT
	CMPI.L	#3,D4		*GOES TO GOTO
	BEQ	GOTO
	CMPI.L	#4,D4		*GOES TO CVR1
	BEQ	CVR1		
	CMPI.L	#5,D4		*GOES TO CVR2
	BEQ	CVR2
	CMPI.L	#6,D4		*GOES TO MDSP
	BEQ	MDSP
	CMPI.L	#7,D4		*GOES TO BLFI
	BEQ	BLFI
	CMPI.L	#8,D4		*MEMORY MODIFY
	BEQ	MEMM
	CMPI.L	#9,D4		*MEMORY SET
	BEQ	MSET		
	CMPI.L	#10,D4		*BLOCK MOVE
	BEQ	BLKM
	CMPI.L	#11,D4		*BLOCK SEARCH
	BEQ	BSRH
	CMPI.L	#12,D4		*BLOCK SORT
	BEQ	SORT
	RTS
	

	
*********************************************************
*Begining of the Main Command routines		        *
*********************************************************	

*************************
*	HELP		*
*************************
HELP	CMPI.L	#4,D1		*Length should be exactly 4
	BNE	ERROR		*if not error
	MOVEM.L	A1/A2,-(A7)	*Saves regs
	LEA	HEL_TABL,A1	*Loads start address of help menu
	LEA	HELP_END,A2	*Loads end address of help menu
HELPN	CMPA	A1,A2		*Compare the start and the end add.
	BEQ	HELPD		*If equal then help message done
	MOVE.B	#13,D0		*Prints out a line of the help message
	TRAP	#15		*Prints
	ADDA.L	#$30,A1		*Sets A1 to the start of the next line
	BRA 	HELPN		*Loops until end of message
HELPD	MOVEM.L	(A7)+,A1/A2	*Loads regs
	RTS
	
*************************
*	EXIT		*
*************************	
EXIT	CMPI.L	#4,D1		*LengTH should be extatly 4 FOR EXIT COMMAND
	BNE	ERROR		*If not error
	MOVE.B	#9,D0		*Moves 9 to D0
	TRAP	#15		*Exit



*	GOTO		*


GOTO	CLR.L	D2		*Clears D2
	CLR.L	D3		    *Clears D3
	ADDA.W	#1,A1		*GET TO $
	JSR	DO_CHECK		*Check if THERE IS $ SIGN
	ADDA.W	#1,A1		*GETS TO NUMBER
	MOVE.W	D1,D3		*PUTS SIZE(D1)-6
	SUBI.W	#6,D3		*Just the size of address
	JSR	HEX_TOASCCHECK		*Checks if valid hex address
	MOVE.L  (A1),D2		*Moves address in ascii to D2
	JSR	ASC_TOBIN		*Converts Ascii to Binary
	MOVEA.W	D6,A2		*Moves hex address to A2 register
		
	MOVE.L	A2,D2		*Checks if Address is in A Restricted access
	JSR	RES_CHECK1
	
	JMP	(A2)			*Jumps to program (A2)
	RTS


*	HEX TO DECIMAL	

CVR1	CLR.L	D2		*CLEAR D2
	CLR.L	D3			*Clear D3
	CMP.W	#8,D1		*Max size of instruction
	BGT	ERROR			*If greater than error
	ADDA.W	#1,A1		*GET TO $
	JSR	DO_CHECK		*Checks for $ sign on hex number
	ADDA.W	#1,A1		*GETS TO NUMBER
	MOVE.W	D1,D3		*Moves D1 to D3
	SUBI.W	#6,D3		*Gets size of number
	JSR	HEX_TOASCCHECK	*checks if proper hex number by going to this subroutine
	MOVE.L  (A1),D2		*Moves ascii hex to D2
	JSR	ASC_TODEC		*CVRverts ASC to deciamal
	MOVE.L	D6,D1		*Moves hex number to D1 for output
	JSR	CVR1_M			*Prints message
	RTS
	

	
*************************
*	MEMORY DISPLAY	*
*************************
		
MDSP	CLR.L	D2		*Clear D2
	CLR.L	D3		*Clear D3
	CLR.L	D4		*FIRST ADDRESS GETS STORED HERE
	CLR.L	D5		*SECVRD ADDRESS GETS STORED HERE
	CMP.W	#16,D1		*Greater than max?
	BGT	ERROR		*error
	MOVE.W	#4,D3		*Moves 4 to d3 for 4 char check
	JSR	ALL_CHECK		*Checks spaces and $ and Hex
	MOVEA.L	D6,A2		*FIRST ADDRESS STORED IN A2
	
	ADDA.W 	#4,A1		*increaments to 2nd address
	JSR	SP_CHECK		*space check
	MOVE.W	#4,D3		*Mvoes 4 to d3 for 4 char check
	JSR	ALL_CHECK		*checks spaces and $ and hex
	MOVEA.L	D6,A3		*SECVRD ADDRESS STORED IN A3
	
	CMPA.L	A2,A3		
	BLT	ERROR
	
	LEA	TMP2,A1	*Moves TMP2 address to a1
	LEA	TMP3,A6	*moves TMP3 address to A6
M_NEXT	MOVE.B	(A2)+,(A1)	*MOVES FIRST 2 BITS INTO (A1)
	JSR	HEX_TOASCASC		*CVRverts the hex numbers to ascii
	MOVEA.L	A6,A1		*Moves A6 to A1
	MOVE.B	#13,D0		*Prints the first byte
	TRAP 	#15		*prints
	CMPA	A2,A3		*A2=A3?
	BNE	M_NEXT		*no loop
M_DONE	RTS

*************************
*	BLOCK FILL	*
*************************
	
BLFI	CLR.L	D2		*Clears D2
	CLR.L	D3		*clear D3
	CLR.L	D4		*FIRST ADDRESS GETS STORED HERE
	CLR.L	D5		*SECVRD ADDRESS GETS STORED HERE
	CMP.W	#20,D1		*Greater than max?
	BGT	ERROR		*error
	MOVE.W	#4,D3		*Moves 4 to d3 for 4 char check
	JSR	ALL_CHECK		*checks first address
	MOVEA.L	D6,A2		*FIRST ADDRESS STORED IN A2
	
	MOVE.L	A2,D2		*Checks if first address is restricted
	JSR	RES_CHECK1
	
	ADDA.W 	#4,A1		*Goes to space
	JSR	SP_CHECK		*space check
	MOVE.W	#4,D3		*moveas 4 to d3 for 4 char check
	JSR	ALL_CHECK		
	MOVEA.L	D6,A3		*SECVRD ADDRESS STORED IN A3
		
	CMPA.L	A2,A3		
	BLT	ERROR	
		
	MOVE.L	A3,D2		*Checks if first address is restricted
	JSR	RES_CHECK1		*
		
	CLR.L	D4		*Clears D4
	CLR.L	D5		*Clears D5
	ADDA.W	#4,A1		*gets address to space
	JSR	SP_CHECK		*Space Check
	MOVE.W	#2,D3		*moves 2 to d3 for 2 char check
	JSR	ALL_CHECK		*all check
	MOVE.L	D6,D4		*Moves d6 to d4
	ROL.W	#8,D4		*rolls left by 8
	CLR.L	D6		*clears d6
	MOVE.B	D4,D6		*VALUE FOR FILL IN D6
	
B_NEXT	MOVE.B	D6,(A2)+	*moves d6 to (a2)
	CMPA	A2,A3		*checks start and end addrss
	BNE	B_NEXT		*until not equal loop
B_DONE	RTS

*************************
*	MEMORY SET	*
*************************

MSET	CLR.L	D2		*Clears D2
	CLR.L	D3		*Clears D3
	CLR.L	D4		*Clears D4
	CLR.L	D5		*Clears D5
	CMP.W	#40,D1		*checks if max input
	BGT	ERROR		*error
	MOVE.W	#4,D3		*Moves 4 to d3 for all check
	JSR	ALL_CHECK		*Checks for correct spaces and $
	MOVEA.L	D6,A2		*STARTING ADDRESS TO SET MEM
	
	MOVE.L	A2,D2		*Checks if address if restricted
	JSR	RES_CHECK1		*branch
	
	ADDA.W	#4,A1		*Gets to where space should be
	JSR	SP_CHECK		*Checks if space
	ADDA.W	#1,A1		*GETS TO ADDRESS OF START OF STRING
	
	MOVE.W	D1,D5		*D2 IS A COUNTER FOR STRING LENGTH
	SUBI.L	#11,D5		*Gets the Length of the Sting inputed
	
M_NEXT3	MOVE.B	(A1)+,(A2)+	*Moves String to Starting address
		
	MOVE.L	A2,D2		*Checks if address is restricted
	JSR	RES_CHECK1

	SUBI.L	#1,D5		*Dectrements the length of the string
	BNE	M_NEXT3		*Until zero loop
M_DONE3	RTS
		
*************************
*	MEMORY MODIFY	*
*************************

MEMM	CLR.L	D2		*Clear D2
	CLR.L	D3		*Clear D3
	CLR.L	D4		*FIRST ADDRESS GETS STORED in D4
	CLR.L	D5		*SECOND ADDRESS GETS STORED IN D5
	CMP.W	#10,D1		*CHECK IF IT IS Greater than Max
	BGT	ERROR		*error	
	MOVE.W	#4,D3		*Moves 4 to d3 for 4 char check
	JSR	ALL_CHECK		*Checks space, and hex
	MOVEA.L	D6,A2		*moves starting address to A2
	MOVEA.L	#$FFFF,A3	*A3 is the end address
	
	MOVE.L	A2,D2		*Checks if address is restricted
	JSR	RES_CHECK1
	
	LEA	TMP2,A1	*Loads TMP2 to A1
	LEA	TMP4,A6	*Loads TMP4 to A6
M_NEXT2	MOVE.B	(A2)+,(A1)	*MOVES FIRST 2 BITS INTO (A1)
	
	MOVE.L	A2,D2		*Checks if address is restriced
	JSR	RES_CHECK1

	JSR	HEX_TOASCASC		*Converts hex to ASCII
PRINTM	MOVEA.L	A6,A1		*OUTPUTS MEMORY
	MOVE.B	#14,D0			*print
	TRAP 	#15
	
	MOVEA.L	TMP5,A1	*Reads in a string into A1
	MOVE.B	#2,D0		*read
	TRAP 	#15
	
	CMP.B	#2,D1		*Compars #2 with D1
	BGT	ERROR2		*Checks to see if new mem in has at least 2 char
	
	MOVE.W	(A1),D3		*Moves data at A1 to D3
	ROR.W	#8,D3		*rolls let to get MSB
	CMP.B	#'.',D3		*Checks if a period
	BEQ	M_DONE2		*if period done
	
	MOVE.W	#2,D3		*Else move 2 to d3
	JSR	HEX_TOASCCHECK2	*for hex check
	MOVE.L	(A1),D2		*moves the new data to D2
	JSR	ASC_TOBIN		*CVRverts to Hex
	MOVE.L	D6,D4		*moves D6 to D4
	ROL.W	#8,D4		*gets the bit 3 and bit 2 of the word
	CLR.L	D6		*clears d6
	MOVE.B	D4,D6		*new input in D6
	
	SUBA.W	#1,A2		*subtract the address from A2
	MOVE.B	D6,(A2)+	*moves the new input to start address

	CMPA	A2,A3		*compares start adress and max end
	BNE	M_NEXT2		*if not equal bra.
M_DONE2	BRA	START		*if equal return to start


	
*************************
*	BLOCK MOVE	*
*************************
	
BLKM 	CLR.L	D2		*Clear D2
	CLR.L	D3		*Clear D3
	CLR.L	D4		*Clear D4
	CLR.L	D5		*Clear D5
	CMP.W	#22,D1		*Checks if max address
	BGT	ERROR		*Error	
	MOVE.B	#4,D3		*Moves 4 to D3 for all check
	JSR	ALL_CHECK		*All check
	MOVEA.L	D6,A2		*START A2
	
	MOVE.L	A2,D2		*checks if start address is restricted
	JSR	RES_CHECK1		*check
	
	ADDA.W	#4,A1		*gets to where space should be
	JSR	SP_CHECK		*space check
	MOVE.W	#4,D3		*Moves 4 to d3 for all check
	JSR	ALL_CHECK		*all check
	MOVEA.L	D6,A3		*END A3
	
	CMPA.L	A2,A3		
	BLT	ERROR
	
	MOVE.L	A3,D2		*check if end address is restricted
	JSR	RES_CHECK1		*Check
	
	ADDA.W	#4,A1		*gets to where space should be
	JSR	SP_CHECK		*space check
	MOVE.W	#4,D3		*moves 4 to d3 for all check
	JSR	ALL_CHECK		*all check
	MOVEA.L	D6,A4		*NEW START A4

	MOVE.L	A4,D2		*Checks if new start address is restriced
	JSR	RES_CHECK1		*Check
			
	JSR	A_CHECK		*checks if new start is between old start and old end 
	
B_TST	MOVE.W	(A2)+,(A4)+	*Moves mem at old start to mem at new start
	CMPA.W	A2,A3		*Compares old start and old end
	BNE	B_TST		*branch till equal
	
B_DONE4	RTS

*************************
*	DEC->HEX 	*
*************************
	
CVR2	CLR.L	D2		*CVRVERTS A 2 DIGIT DEC NUMBER TO HEX
	CLR.L	D3		*clears d3
	CMP.W	#8,D1		*Checks size of entire cmd
	BGT	ERROR		*branch to Error if larger than 
	ADDA.W	#1,A1		*GET TO #
	JSR	POUND_CHECK		*Pound sign check
	ADDA.W	#1,A1		*GETS TO NUMBER
	MOVE.W	D1,D3		*Moves size to d3
	SUBI.W	#6,D3		*subtract the header to just get size of input
	JSR	DEC_CHECK		*Checks for valued decimal number
	LEA	TMP6,A0	*Moves TMP6 address to a0
	MOVE.W	(A1),D2		*ASCII DEC IN D2
	LEA	TMP8,A1	*Loads TMP8 to a1
	JSR	DEC_HEX		*CVRverts 
	MOVE.B	D6,(A1)		*moves hex number to a1
	LEA	TMP8,A6	*for output
	JSR	HEX_TOASCASC		*Converts hex to ascii hex
	JSR	CVR2_M		*print	
	RTS


	
*************************
*	BLOCK SORT	*
*************************	
	
SORT	CLR.L	D2		*Clear D2
	CLR.L	D3		*clear d3
	CLR.L	D4		*Clear d4
	CLR.L	D5		*clear D5
	CMP.W	#16,D1		*Max amount of characters
	BGT	ERROR		*error
	MOVE.B	#4,D3		*move 4 to d3 for all check
	JSR	ALL_CHECK		*all check
	MOVEA.L	D6,A2		*START A2 POINTS TO FIRST ELEMENT
	
	MOVE.L	A2,D2		*check if start address is restricted
	JSR	RES_CHECK1		*check
		
	ADDA.W	#4,A1		*Gets to space
	JSR	SP_CHECK		*space check
	MOVE.W	#4,D3		*move 4 to d3 for all check
	JSR	ALL_CHECK		*all check
	MOVEA.L	D6,A3		*END A3	POINTS TO LAST ELEMENT
		
	CMPA.L	A2,A3		
	BLT	ERROR
	
		
	MOVE.L	A3,D2		*check if end address is restricted
	JSR	RES_CHECK1		*check
	
	MOVE.L	A2,D2		*Moves starting address to d2
	MOVE.L	A3,D3		*moves end address to d3
	SUB.L	D2,D3		*subtracts to 2 address
	ADDI.L	#2,D3		*adds 2
	DIVU.W	#2,D3		*Length of list

	MOVE.L	A2,A6		*Copy of start address in A6
	
*SORTS ONLY A LIST FROM LOW TO HIGH MOSTLY	
	CLR.L	D0		*clear
SORTLOW	MOVE.L 	A2,A4		*copy start address to a4
BEGIN	MOVE.L	A4,A2		*copy start address in a2
LOOPSORT	CMPM.W	(A2)+,(A4)+	* compare a2 and a4 then increment
	BHI	BIGGER		* if BIGGER, move to BIGGER
	SUBQ.L	#2,A2		* subtract 2 from a2
	CMP.L	A2,A3		*compare a2 and a3
	BNE	LOOPSORT		*if not equal loop again
	MOVE.L	A6,A2		*restores to a2
	MOVE.L	A6,A4		*restores to a2
	SUBI.L	#1,D3		*Subtrance counter
	CMP.W	#0,D3		*if zero 
	BEQ	SORT_M		*print sort message
	SUBA.W	#2,A3		*get to next address
	BRA	LOOPSORT		*Branchs back to begining
BIGGER	ADD.W	#2,A2		*adds 2 to A2
	SUB.L	#2,A4		*sub 2 from A4
	MOVE.L -(A2),D0		;restore registers
	SWAP.W 	D0		;swap first and last bytes in d0
	MOVE.L	D0,(A2)		;move d0 into Contents of a2
	BRA	BEGIN	

L_DONE	RTS



*************************
*	BLOCK SEARCH	*
*************************

BSRH	CLR.L	D2		*Clears D2
	CLR.L	D3		*cleard D3
	CLR.L	D4		*Clears D4
	CLR.L	D5		*clears D5
	CMP.W	#40,D1		*greater than max?
	BGT	ERROR		*error
	MOVE.B	#4,D3		*moves 4 to d3 for all check
	JSR	ALL_CHECK		*checks spaces and hex
	MOVEA.L	D6,A2		*START start A2
	
	MOVE.L	A2,D2		*checks if address is restricted
	JSR	RES_CHECK1		*branch
	
	ADDA.W	#4,A1		*goes to where space should be
	JSR	SP_CHECK		*Space check
	MOVE.W	#4,D3		*moves 4 to d3 for all check
	JSR	ALL_CHECK		*all check
	MOVEA.L	D6,A3		*END address A3	

	CMPA.L	A2,A3		
	BLT	ERROR

	MOVE.L	A3,D2		*checks if address is restriced
	JSR	RES_CHECK1		*branch
		
	ADDA.W	#4,A1		*adds 4 to get to where space should be at
	JSR	SP_CHECK		*space check
	ADDA.W	#1,A1		*A1 IS STARTING LOCATION OF STRING
	MOVEA.L	A1,A6		*A6 IS COPY OF STRING LOCATION

	MOVE.W	D1,D3		*D2 IS A COUNTER FOR STRING LENGTH
	SUBI.L	#17,D3		*D2 IS NOW THE SIZE OF THE STRING
	MOVE.L	D3,D4		*COPY OF D3

****
*A1:LOCATION OF STRING
*A2:START ADDRESS
*A4:END ADDRESS
*A6:COPY OF LOCATION OF STRING
*D2 IS THE SIZE OF THE STRING
*D3 IS THE COPY OF THE SIZE
****
SEARCH	CMPM.B	(A1)+,(A2)+	*Compares the String with the start mem
	BEQ	S_EQUAL		*if equal branch
	
	MOVE.L	A2,D2		*if not checks if address is restricted
	JSR	RES_CHECK1		*branch
	
	CMP.L	A2,A3		*checks if start and end are equal
	BEQ	BNFOUND_M		*if equal block not found
	MOVEA.L	A6,A1		*if not restore to the start of the string
	BRA	SEARCH		*loop to string
S_EQUAL	SUBQ.W	#1,D3		*if equal decrement the counter
	BEQ	BFOUND_M		*if counter is zero Block found
	CMPM.B	(A1)+,(A2)+	*increment both addresses
	BEQ	S_EQUAL		*if equal branch to S_EQUAL
	MOVEA.L	A6,A1		*RESETS A1 TO START
	MOVE.L	D4,D3		*restores counter
	BRA	SEARCH		*goes back to start
	RTS
	
*********************************************************
*Subroutines for checking if hex or dec values for input*
*********************************************************
*CONVERTS HEX INTO ASCI IN BYTE FORM
HEX_TOASCASC	MOVEM.L	D1-D5/A1/A6,-(A7)
	CLR.L	D2	*MSB IN D2
	CLR.L	D3	*LSB IN D3
	CLR.L	D4
	CLR.L	D5
	MOVE.B	(A1),D2
	ROL.W	#4,D2
	MOVE.B	D2,D3
	ROR.W	#8,D2
	ROR.B	#4,D3
	CMP.B	#9,D2
	BGT	ASCI_F1
	ADD.B	#$30,D2
HEXA_NEX  CMP.B	#9,D3
	BGT	ASCI_F2
	ADD.B	#$30,D3
	BRA 	HEXA_DON
ASCI_F1	ADD.B	#$37,D2
	BRA	HEXA_NEX
ASCI_F2	ADD.B	#$37,D3
HEXA_DON	MOVE.B	D2,(A6)+
	MOVE.B	D3,(A6)+
	MOVEM.L	(A7)+,D1-D5/A1/A6
	RTS

*ASCII TO BIN INPUT NUMBER INTO D2 -> OUTPUTED TO D6,
ASC_TOBIN	MOVEM.L	D1-D5/A1,-(A7)
	CLR.L	D2
	CLR.L	D3
	CLR.L	D4
	CLR.L	D5
	MOVE.B	(A1)+,D2
	MOVE.B	(A1)+,D3
	MOVE.B	(A1)+,D4
	MOVE.B	(A1)+,D5
BTST1	BTST.L	#5,D2
	BNE	BNUTEST1
	SUBI.B	#$37,D2
BTST2	BTST.L	#5,D3
	BNE	BNUTEST2
	SUBI.B	#$37,D3
BTST3	BTST.L	#5,D4
	BNE	BNUTEST3
	SUBI.B	#$37,D4
BTST4	BTST.L	#5,D5	
	BNE	BNUTEST4
	SUBI.B	#$37,D5
	BRA	BMUL
BNUTEST1	SUBI.B	#$30,D2
	BRA	BTST2
BNUTEST2	SUBI.B	#$30,D3
	BRA	BTST3
BNUTEST3	SUBI.B	#$30,D4
	BRA	BTST4
BNUTEST4	SUBI.B	#$30,D5
	BRA	BMUL
BMUL	MULU	#$1000,D2
	MULU	#$100,D3
	MULU	#$10,D4
	ADD.B	D5,D4
	ADD.B	D4,D3
	ADD.W	D3,D2
	MOVE.W	D2,D6
	MOVEM.L	(A7)+,D1-D5/A1
	RTS
	
*ASCII TO DEC INPUT NUMBER INTO D2 -> OUTPUTED TO D6
ASC_TODEC	MOVEM.L	D1-D5/A5,-(A7)	*saves reg
	MOVE.L	#TMP,A5	*Moves TMP address to a5
	CLR.L	(A5)		*clear TMP address
	MOVE.L	D2,(A5)		*Moves hex number to A5
	CLR.L	D2		*Clears D2
	CLR.L	D3		*Clears D3
	CLR.L	D4		*Clears D4
	CLR.L	D5		*Clears D5
	MOVE.B	(A5)+,D2	*Moves MSB IN D2
	MOVE.B	(A5)+,D3	*Moves LSB in D3

DTST1	BTST.L	#5,D2		*If number
	BNE	DNUTEST1		*sub by #$30
	SUBI.B	#$37,D2		*sub by #$37
DTST2	BTST.L	#5,D3		*if number
	BNE	DNUTEST2		*sub by #$30
	SUBI.B	#$37,D3		*sub by #$37
	BRA	DMUL		*Multiply
	
DNUTEST1	SUBI.B	#$30,D2		*sub by #$30
	BRA	DTST2		*loops to DTST2
DNUTEST2	SUBI.B	#$30,D3		*sub by #$30	
			
DMUL	CLR.L	D6		*Clears D6
	MULU.W	#16,D2		*multiplies MSB by 16
	ADD.W	D2,D6		*adds msb to d6
	ADD.W	D3,D6		*adds lsb to d6
	MOVEM.L	(A7)+,D1-D5/A5	*load reg
	RTS
	
*Number in D2
*Counter in d3
*Output to d6
DEC_HEX	MOVEM.L	D1-D3/A2-A3,-(A7)
	CLR.L	D3
	LEA	S_DH,A2
	LEA	E_DH,A3	
DH_L	CMP.W	A2,A3
	BEQ	ERROR
	CMP.W	(A2)+,D2
	BEQ	DH_DONE
	ADDI.L	#1,D3
	BRA	DH_L

DH_DONE	MOVE.W	D3,D6
	MOVEM.L	(A7)+,D1-D3/A2-A3
	RTS		
*********************************************************
*Subroutines for checking if hex or dec values for input*
*********************************************************

*put amount of times needed to run into D3	
HEX_TOASCCHECK MOVEM.L	A1,-(A7)
H_CHECK	CMP.B	#'0',(A1)
	BLT	ERROR
	CMP.B	#'F',(A1)
	BGT	ERROR
	SUBI.B	#1,D3
	ADDA.W	#1,A1
	CMP.B	#0,D3
	BNE	H_CHECK
	MOVEM.L	(A7)+,A1
	RTS
	
HEX_TOASCCHECK2  MOVEM.L	A1,-(A7)
H_CHECK2	CMP.B	#'0',(A1)
	BLT	ERROR2
	CMP.B	#'F',(A1)
	BGT	ERROR2
	SUBI.B	#1,D3
	ADDA.W	#1,A1
	CMP.B	#0,D3
	BNE	H_CHECK2
	MOVEM.L	(A7)+,A1
	RTS
	
DEC_CHECK	MOVEM.L	A1,-(A7)
D_CHECK	CMP.B	#'0',(A1)
	BLT	ERROR
	CMP.B	#'9',(A1)
	BGT	ERROR
	SUBI.B	#1,D3
	ADDA.W	#1,A1
	CMP.B	#0,D3
	BNE	D_CHECK
	MOVEM.L	(A7)+,A1
	RTS
	
SP_CHECK	CMP.B	#' ',(A1)
	BNE	ERROR
	RTS
	
DO_CHECK	CMP.B	#'$',(A1)
	BNE	ERROR
	RTS

POUND_CHECK	CMP.B	#'#',(A1)
	BNE	ERROR
	RTS

	*PUT SIZE OF INPUT IN D3 FOR HEX CHECK
ALL_CHECK MOVEM.L D1-D5,-(A7)
	ADDA.W	#1,A1
	JSR	DO_CHECK
	ADDA.W	#1,A1
	JSR	HEX_TOASCCHECK
	MOVE.L	(A1),D2
	JSR	ASC_TOBIN
	MOVEM.L	(A7)+,D1-D5
	RTS

A_CHECK	MOVEM.L	A2-A4,-(A7)
A_CHECK2	CMPA.W	A2,A4
	BEQ	ERROR
	ADDA.W	#2,A2
	CMPA.W	A2,A3
	BNE	A_CHECK2
	MOVEM.L	(A7)+,A2-A4
	RTS

*L_CHECK	MOVEM.L	D2/D3,-(A7)
*	CLR.L	D3
	


*D2 IS THE INPUT
RES_CHECK1	MOVEM.L	D2/D3,-(A7)
	CLR.L	D3
	CMP.L	#$1000,D2
	BLT	ADD1	
	
RA_NEX	CMP.L	#$3FFF,D2
	BGT	ADD2
	
RA_NEX2	CMPI.W	#1,D3
	BEQ	DONE
	BRA	ERROR3

ADD1	ADDI.W	#1,D3
	BRA	RA_NEX

ADD2	ADDI.W	#1,D3
	BRA	RA_NEX2

DONE	MOVEM.L	(A7)+,D2/D3
	RTS


S_DH	DC.B	'000203030405060708091011121314151617181920212223242526272829303132333435363738394041424344454647484950'
	DC.B	'42635354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979868',0
E_DH	


*********************************************************
*Output message subroutines for the commands and error  *
*********************************************************	
ERROR	LEA	ER_MES,A1	*PRINTS OUT ERROR MESSAGE
	MOVE.B	#13,D0
	TRAP	#15
	BRA	START
	
ERROR2	LEA	ER_MES,A1	*PRINTS OUT ERROR2 MESSAGE
	MOVE.B	#13,D0
	TRAP	#15
	BRA	PRINTM
	
ERROR3 	LEA	ER_MES2,A1	*PRINTS OUT ERROR2 MESSAGE
	MOVE.B	#13,D0
	TRAP	#15
	BRA	START

CVR1_M	CLR.L	D2
	MOVE.L	#10,D2
	MOVE.B	#15,D0
	TRAP	#15
	LEA	EN_LINE,A1
	MOVE.B	#13,D0
	TRAP	#15	
	RTS
	
CVR2_M	CLR.L	D2
	*MOVE.L	#16,D2
	*MOVE.B	#15,D0
	LEA	TMP8,A1
	MOVE.B	#13,D0	
	TRAP	#15
	LEA	EN_LINE,A1
	MOVE.B	#13,D0
	TRAP	#15
	RTS
	
BFOUND_M	LEA	BLK_FOUND,A1
	MOVE.B	#13,D0
	TRAP	#15
	RTS
	
BNFOUND_M	LEA	BLK_NFOUND,A1
	MOVE.B	#13,D0
	TRAP	#15
	RTS
	
SORT_M	LEA	SORT_P,A1
	MOVE.B	#13,D0
	TRAP	#15
	BRA	START

*Exceptions
EX_HANDLER		MOVE.L 	#BUS_ERROR,$8
		MOVE.L  #ADD_ERROR,$C
		MOVE.L  #ILL_INST,$10
		MOVE.L 	#DIV_ZERO,$14
		MOVE.L	#CHECK_EROR,$18
		MOVE.L 	#PRIV_VIOL,$20
		MOVE.L 	#LINE_A,$28
		MOVE.L 	#LINE_F,$2C
		RTS


BUS_ERROR	JSR	SAVE_ALL
		LEA	BUS_S,A1	*PRINTS OUT ERROR MESSAGE
		MOVE.B	#13,D0
		TRAP	#15
		JSR	PRINTD
		JSR	PRINTA
		JSR	LOAD_ALL
		BRA	START
		
ADD_ERROR	JSR	SAVE_ALL
		LEA	ADDR_S,A1	*PRINTS OUT ERROR MESSAGE
		MOVE.B	#13,D0
		TRAP	#15
		JSR	PRINTD
		JSR	PRINTA
		JSR	LOAD_ALL
		BRA	START	

ILL_INST	JSR	SAVE_ALL
		LEA	ILLEGAL_S,A1	*PRINTS OUT ERROR MESSAGE
		MOVE.B	#13,D0
		TRAP	#15
		JSR	PRINTD	
		JSR	PRINTA	
		JSR	LOAD_ALL
		BRA	START
		
		
DIV_ZERO	JSR	SAVE_ALL
		LEA	DIVZ_S,A1	*PRINTS OUT ERROR MESSAGE
		MOVE.B	#13,D0
		TRAP	#15
		JSR	PRINTD
		JSR	PRINTA
		JSR	LOAD_ALL
		BRA	START

CHECK_EROR	JSR	SAVE_ALL
		LEA	CHE_S,A1
		MOVE.B	#13,D0
		TRAP	#15
		JSR	PRINTD
		JSR	PRINTA		
		JSR	LOAD_ALL
		BRA 	START

PRIV_VIOL	JSR	SAVE_ALL
		LEA	PRIV_S,A1	*PRINTS OUT ERROR MESSAGE
		MOVE.B	#13,D0
		TRAP	#15
		JSR	PRINTD
		JSR	PRINTA
		JSR	LOAD_ALL
		BRA	START

LINE_A		JSR	SAVE_ALL
		LEA	LINA_S,A1	*PRINTS OUT ERROR MESSAGE
		MOVE.B	#13,D0
		TRAP	#15
		JSR	PRINTD
		JSR	PRINTA
		JSR	LOAD_ALL
		BRA	START

LINE_F		JSR	SAVE_ALL
		LEA	LINF_S,A1	*PRINTS OUT ERROR MESSAGE
		MOVE.B	#13,D0
		TRAP	#15
		JSR	PRINTD
		JSR	PRINTA
		JSR	LOAD_ALL
		BRA	START

SAVE_ALL	MOVE.L	A0,$3020	*A0 is being used save first
		MOVEA.L	#$3000,A0	*Start of stack
		MOVE.L	D0,(A0)+	*Saves D0
		MOVE.L	D1,(A0)+	*Saves D1
		MOVE.L	D2,(A0)+	*Saves D2
		MOVE.L	D3,(A0)+	*Saves D3
		MOVE.L	D4,(A0)+	*Saves D4
		MOVE.L	D5,(A0)+	*Saves D5
		MOVE.L	D6,(A0)+	*Saves D6
		MOVE.L	D7,(A0)+	*Saves D7
		ADDA.L	#4,A0		*A0 has already been saved
		MOVE.L	A1,(A0)+	*Saves A1
		MOVE.L	A2,(A0)+	*Saves A2
		MOVE.L	A3,(A0)+	*Saves A3
		MOVE.L	A4,(A0)+	*Saves A4
		MOVE.L	A5,(A0)+	*Saves A5
		MOVE.L	A6,(A0)+	*Saves A6
		MOVE.L	A7,(A0)+	*Saves A7
		RTS

LOAD_ALL	MOVEA.L	#$3000,A0	*Start of stack
		MOVE.L	(A0)+,D0	*Loads D0
		MOVE.L	(A0)+,D1	*Loads D1
		MOVE.L	(A0)+,D2	*Loads D2
		MOVE.L	(A0)+,D3	*Loads D3
		MOVE.L	(A0)+,D4	*Loads D4
		MOVE.L	(A0)+,D5	*Loads D5
		MOVE.L	(A0)+,D6	*Loads D6
		MOVE.L	(A0)+,D7	*Loads D7
		ADDA.L	#4,A0		*skips a0 for now
		MOVE.L	(A0)+,A1	*Loads A1
		MOVE.L	(A0)+,A2	*Loads A2
		MOVE.L	(A0)+,A3	*Loads A3
		MOVE.L	(A0)+,A4	*Loads A4
		MOVE.L	(A0)+,A5	*Loads A5
		MOVE.L	(A0)+,A6	*Loads A6
		MOVE.L	(A0)+,A7	*Loads A7
		MOVE.L	$3020,A0	*Loads A0
		RTS

PRINTD		MOVEA.L	#$3040,A6		*D REGISTERS ARE STORED FROM $3000-$3020
		MOVEA.L	#$3000,A1		*Start of Stack
		MOVEA.L	#$3020,A2		*End of Stack
CVRV_LOOP_D	JSR	HEX_TOASCASC			*Converts byte to ASCII
		ADDA.L	#1,A1			*next byte
		ADDA.L	#2,A6			*Next spot for ascii save
		CMPA.L	A1,A2			*Branches until equal
		BNE	CVRV_LOOP_D		*D REGS IN ASCII ARE STORED FROM $3040-$3080

		MOVEA.L	#$3040,A2		*Start of ascii Converted registers
		MOVEA.L	#$30C0,A3		*Start of ascii Converted registers + null for print
		MOVE.B	#8,D1			*counter for 8 registers
		
		LEA	D_TABL,A4		*Pointer to D0-D7 for output
		
PRINTLOOP_D	MOVEA.L	A4,A1			*Prints the header
		MOVE.B	#14,D0			*Print
		TRAP	#15
		
		MOVE.L	(A2)+,(A3)+		*moves ascii to new address
		MOVE.L	(A2)+,(A3)+		*to be null terminated
		MOVE.B	#$00,(A3)		*null terminated
		SUBA.L	#8,A3			*gets back to start of address
		
		MOVEA.L A3,A1			*Prints register value
		MOVE.B	#13,D0			*Print
		TRAP	#15
		
		ADDA.W	#5,A4			*gets to next address of header
		ADDA.L	#16,A3			*gets to next line
		SUB.W	#1,D1			*decrements count
		BNE	PRINTLOOP_D		*print until done
		RTS

PRINTA		MOVEA.L	#$3080,A6		*A REGISTERS ARE STORED FROM $3020-$3040
		MOVEA.L	#$3020,A1		*Start of a registers
		MOVEA.L	#$3040,A2		*gets to start of ascii 
CVRV_LOOP_A	JSR	HEX_TOASCASC			*Converts byte to ascii
		ADDA.L	#1,A1			*next byte
		ADDA.L	#2,A6			*next spot for ascii save
		CMPA.L	A1,A2			*branches until equal
		BNE	CVRV_LOOP_A		*branch
			
		MOVEA.L	#$3080,A2		*start of ascii Converted registers
		MOVEA.L	#$30C0,A3		*start of ascii Converted registers + null for rprint
		MOVE.B	#8,D1			*counter for 8 registers
		
		LEA	A_TABL,A4		*pointer to A0-a7 for output
		
PRINT_LOOP_A	MOVEA.L	A4,A1			*prints the header
		MOVE.B	#14,D0			*print
		TRAP	#15
		
		MOVE.L	(A2)+,(A3)+		*moves ascii to new address
		MOVE.L	(A2)+,(A3)+		*to be null terminated
		MOVE.B	#$00,(A3)		*null terminated
		SUBA.L	#8,A3			*gets back to start address
		
		MOVEA.L A3,A1			*prints ascii
		MOVE.B	#13,D0			*print
		TRAP	#15			
			
		ADDA.W	#5,A4			*gets to the next address of header
		ADDA.L	#16,A3			*gets to next line
		SUB.W	#1,D1			*Decrments counter
		BNE	PRINT_LOOP_A		*A REGISTERS ARE STROED FROM $3080-$30C0

		RTS			

*CHECK IF GOTO COMMAND WORKS

	ORG 	$0300
	LEA	TEST1,A1	
	MOVE.B	#13,D0
	TRAP	#15
	BRA	START

TEST1	DC.B	'first test successful',0

	ORG	$0500
	LEA	TEST2,A1	
	MOVE.B	#13,D0
	TRAP	#15
	BRA	START

TEST2	DC.B	'second test successful',0	

	ORG	$5000	
	LEA	TEST3,A1	
	MOVE.B	#13,D0
	TRAP	#15
	BRA	START

TEST3	DC.B	'third test successful',0	

	ORG	$6ABA	
	LEA	TEST4,A1	
	MOVE.B	#13,D0
	TRAP	#15
	BRA	START

TEST4	DC.B	'fourth test successful',0


*Bus Error Exception Test
	ORG	$6000
	MOVE.B	#$FF,D0
BUS_T	MOVE.B	$FFFFFF,D0
	BRA	BUS_T

*Address Error Exception Test
	ORG	$6020
	MOVE.B	#$FF,D0
ADD_T	MOVE.W	D0,A1
	MOVE.W	D1,(A1)+
	BRA	ADD_T

*Illegal Instruction Exception Test
	ORG	$6040		*To test move 4AFA to 6040

*Divide by Zero Exception Test
	ORG	$6050
	MOVE.W	#$0000,D1
	MOVE.W	#$2000,D2
DIV_T	DIVU	D1,D2
	BRA	DIV_T
	
*Privialge Violation Exception Test
	ORG	$6040
PIV_T	ANDI.W	#$0700,SR
	BRA	PIV_T

*Line A Exception
	ORG	$6060	*To test move A000 to $6060
	
*Line F Exception
	ORG	$6070	*To test move F000 to $6070

*CHECK exception Test
	ORG	$6080
	MOVE.W	#$3000,D6
	MOVE.W	#$3010,D7
CHECK_T	CHK.W	D6,D7
	BRA	CHECK_T		

	END 	START





























*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
