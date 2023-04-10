;
;__________________________________________________________
; Project 2
; ECE 109
; Nate Kersey
;__________________________________________________________
; 
    .ORIG x3000
        AND R0, R0, #0 ;
        AND R1, R1, #0 ;
        AND R2, R2, #0 ;
        AND R3, R3, #0 ;
        AND R4, R4, #0 ; 
        AND R5, R5, #0 ; 
        AND R6, R6, #0 ; 
        ; Now at x3007, registers 0-6 have been cleared
disp    AND R6, R6, #0
        STI R6, onesplace
        AND R6, R6, #0 ;clear ones
        STI R6, tensplace
        AND R6, R6, #0 ;clear tens
        STI R6, hundredsplace
        AND R6, R6, #0 ;clear hundreds
        STI R6, thousandsplace
        AND R6, R6, #0 ;clear thousands
JSR WIPE
JSR RESET
;-----------------------------------------------------------------------------------
; CHARACTER FUNCTION
LOOKCHAR        GETC          
                LD R2, hexq             ;check if q
                ADD R4, R2, R0
                BRz QUITMSG1             ;if q, quitmsg
                LD R2, hexr             ;check if r
                ADD R4, R2, R0
                BRz disp                ;if r, reset disp
                LD R2, hexu
                ADD R4, R2, R0
                BRz UP                  ;if u, add counter and add 1 to ones
                LD R2, hexd
                ADD R4, R2, R0
                BRz DOWN                ;if d, decrement counter and sub 1 to ones
                LD R2, hexp
                ADD R4, R2, R0
                BRz CURRENT1             ;if p, print current value
                BRnzp LOOKCHAR
;-----------------------------------------------------------------------------------

UP              LDI R6, onesplace
                JSR UPONE
                BRnzp LOOKCHAR

DOWN            LDI R6, onesplace
                JSR DOWNONE
                BRnzp LOOKCHAR


CURRENT1        LEA R0, now ;here will print current value in R3
                PUTS
                LDR R0, R6, #0 ;add value to print
                LD R4, deczero
                ADD R0, R0, R4
                OUT
                BRnzp LOOKCHAR              

QUITMSG1        LEA R0, quit
                PUTS
                HALT
       
        ;now need to check if one is a 10 or not
DOWNONE         ;START FUNCTION DOWNONE
;--------------------------------------------------------------------------------------------
            ADD R6, R6, #-1
            BRn ld0
            BRz startsub
    ;this means they clicked u, need to add 1 to display
        ; r5 is at location for 0
        ;the remaining needs to right the stuff for add one to overall count and display
startsub        STI R6, onesplace
;==================
ld0             LD R5, loc0
                LD R4, thous
subtract        ADD R6, R6, #-1
                BRn clear
                ADD R5, R5, R4
                BRnzp subtract
;====================

clear       JSR lastbox     ;clears ones place
            LD R0, COLOR ;blue is now in R0
            LD R1, TOPL4 ;location of 0 is now in R1
            LD R2, COLS1 ;25 is now in R2
            LD R3, ROW ;103 is now in R3
            LD R4, FORTY

downbot        ADD R4, R4, #0
                BRz LOOKCHAR            ;if at bottom, go to next input
                LDR R6, R5, #0      ; load r6 with the address in R5 (digits.obj 0 or 1)
                BRp paintdown           ; if a 1, go store color
                ADD R5, R5, #1      ;if not, go to next hex in digits.obj
                ADD R1, R1, #1      ;next location on display
                ADD R2, R2, #-1     ;decrement counter
                BRz subrow
                BRp downbot
		
paintdown	LD R0, COLOR
                STR R0, R1, #0		; write pixel (put blue to adress R1)
                ADD R1, R1, #1      ; increment to next location on display (in display)
                ADD R5, R5, #1		; increment to next location in digits.obj (add 1 to address)
	        ADD R2, R2, #-1		; decrement counter (subtract 1 from 25)
	        BRp downbot            ; if positive, keep going until at end of row
subrow  ADD R1, R1, R3      ; add row to location (add 103 to address)
        LD R2, COLS1        ; reset pixel count to 25
        ADD R4, R4, #-1     ; decrement column number
        BRp downbot            ; whatever, go look at if it should print or not 
        ; END FUNCTION ONESUP
;--------------------------------------------------------------------------------------------
        BRnzp LOOKCHAR
        RET

UPONE          ;START FUNCTION UPONE
;--------------------------------------------------------------------------------------------
            ADD R6, R6, #1
            LD R0, negten
            ADD R6, R6, R0
            BRz addten
            BRn startadd
            RET
    ;this means they clicked u, need to add 1 to display
        ; r5 is at location for 0
        ;the remaining needs to right the stuff for add one to overall count and display
addten  STI R6, onesplace
        LDI R6, tensplace
        ADD R6, R6, #1
        LD R0, negten
        ADD R6, R6, R0
        BRz addhund
        BRn goten
goten   LD R0, ten
        ADD R6, R6, R0
        STI R6, tensplace   ;stores in tens place
;==================
        LD R5, loc0
        LD R4, thous
sub10   ADD R6, R6, #-1
        BRn godraw
        ADD R5, R5, R4
        BRnzp sub10
;===================

addhund  HALT

startadd    LD R0, ten
            ADD R6, R6, R0
            STI R6, onesplace
;==================
        LD R5, loc0
        LD R4, thous
plus    ADD R6, R6, #-1
        BRn erase
        ADD R5, R5, R4
        BRnzp plus
;====================            

erase   JSR lastbox    ;clears ones place
        LD R0, COLOR ;blue is now in R0
        LD R1, TOPL4 ;location of 0 is now in R1
        LD R2, COLS1 ;25 is now in R2
        LD R3, ROW ;103 is now in R3
        LD R4, FORTY
        BRnzp checkbot

godraw  JSR nextbox2
        JSR ONESZERO
        LD R1, TOPL3 ;location of 0 is now in R1
        LD R2, COLS1 ;25 is now in R2
        LD R3, ROW ;103 is now in R3
        LD R4, FORTY

checkbot        ADD R4, R4, #0
                BRz finishup            ;if at bottom, go to next input
                LDR R6, R5, #0      ; load r6 with the address in R5 (digits.obj 0 or 1)
                BRp paint           ; if a 1, go store color
                ADD R5, R5, #1      ;if not, go to next hex in digits.obj
                ADD R1, R1, #1      ;next location on display
                ADD R2, R2, #-1     ;decrement counter
                BRz addrow
                BRp checkbot
		
paint	LD R0, COLOR
        STR R0, R1, #0		; write pixel (put blue to adress R1)
        ADD R1, R1, #1      ; increment to next location on display (in display)
        ADD R5, R5, #1		; increment to next location in digits.obj (add 1 to address)
	    ADD R2, R2, #-1		; decrement counter (subtract 1 from 25)
	    BRp checkbot            ; if positive, keep going until at end of row
addrow  ADD R1, R1, R3      ; add row to location (add 103 to address)
        LD R2, COLS1        ; reset pixel count to 25
        ADD R4, R4, #-1     ; decrement column number
        BRp checkbot            ; whatever, go look at if it should print or not 
        ; END FUNCTION ONEUP
;--------------------------------------------------------------------------------------------        
finishup        RET

ONESZERO
        LD R0, COLOR ;blue is now in R0
        LD R1, TOPL4 ;location of 0 is now in R1
        LD R2, COLS1 ;25 is now in R2
        LD R3, ROW ;103 is now in R3
        LD R4, FORTY
        LD R5, loc0
botnum  ADD R4, R4, #0
        BRz finish            ;if at bottom, go to next input
        LDR R6, R5, #0      ; load r6 with the address in R5 (digits.obj 0 or 1)
        BRp draw0           ; if a 1, go store color
        ADD R5, R5, #1      ;if not, go to next hex in digits.obj
        ADD R1, R1, #1      ;next location on display
        ADD R2, R2, #-1     ;decrement counter
        BRz nextrow
        BRp botnum
draw0	LD R0, COLOR
        STR R0, R1, #0		; write pixel (put blue to adress R1)
        ADD R1, R1, #1      ; increment to next location on display (in display)
        ADD R5, R5, #1		; increment to next location in digits.obj (add 1 to address)
	ADD R2, R2, #-1		; decrement counter (subtract 1 from 25)
	BRp botnum            ; if positive, keep going until at end of row
nextrow  ADD R1, R1, R3      ; add row to location (add 103 to address)
        LD R2, COLS1        ; reset pixel count to 25
        ADD R4, R4, #-1     ; decrement column number
        BRp botnum            ; whatever, go look at if it should print or not
finish  RET

;---------------------------------------------------------------------------------------------
; variables
        now     .STRINGZ "\n The current value is:"
        quit    .STRINGZ "\n \nLater Yall!!\n"
	COLOR   .FILL x001F
        BLANK   .FILL x0000
        TOPL1   .FILL xD508
        TOPL2   .FILL xD523
        TOPL3   .FILL xD544
        TOPL4   .FILL xD55F
        COLS1   .FILL #25
        ROW	.FILL #103
        FORTY  .FILL #40
        hexq    .FILL #-113
        hexr    .FILL #-114 
        hexu    .FILL #-117 
        hexd    .FILL #-100 
        hexp    .FILL #-112
        deczero   .FILL x30
        thous   .FILL #1000
        hund    .FILL #100
        negten    .FILL #-10
        ten     .FILL #10
        HOMES  .BLKW #10
        loc0 .FILL x5000
        loc1 .FILL x53E8
        loc2 .FILL x57D0
        loc3 .FILL x5BB8
        loc4 .FILL x5FA0
        loc5 .FILL x6388
        loc6 .FILL x6770
        loc7 .FILL x6B58
        loc8 .FILL x6F40
        loc9 .FILL x7328

        onesplace .FILL x4000
        tensplace .FILL x4001
        hundredsplace .FILL x4002
        thousandsplace .FILL x4003
; ------------------------------------------------------------------------

;-----------------------------------------------------------------------------------
;        \/\/\/\/\/\/\/\/  WIPE AND RESET FUNCTION BELOW \/\/\/\/\/\/\/\/\/\/
;----------------------------------------------------------------------------------- 

;DISPLAY gets wiped hERE
WIPE
;----------------------------------------------------------------------------------------------------------------------------------
        LD R0, BLANK ;black is now in R0
        LD R1, TOPL1 ;location of 0 is now in R1
        LD R2, COLS1 ;25 is now in R2
        LD R3, ROW ;103 is now in R3
        LD R4, FORTY
        
onemo   ADD R4, R4, #0      ;check if at bottom of digit
        BRz nextbox            ;if at bottom, go to next box
        BRp draw           ; if a 1, go store color
		
draw	LD R0, BLANK
        STR R0, R1, #0		; write pixel (put blue to adress R1)
        ADD R1, R1, #1      ; increment to next location on display (in display)
	ADD R2, R2, #-1		; decrement counter (subtract 1 from 25)
	BRp onemo            ; if positive, keep going until at end of row
line    ADD R1, R1, R3      ; add row to location (add 103 to address)
        LD R2, COLS1        ; reset pixel count to 25
        ADD R4, R4, #-1     ; decrement column number
        BRp onemo
        RET
nextbox 
        LD R2, COLS1 ;25 is now in R2
        LD R3, ROW ;103 is now in R3
        LD R4, FORTY
        LD R1, TOPL2
        BRnzp onemo2

onemo2  ADD R4, R4, #0      ;check if at bottom of digit
        BRz nextbox2            ;if at bottom, go to next box
        BRp draw2           ; if a 1, go store color
		
draw2	LD R0, BLANK
        STR R0, R1, #0		; write pixel (put blue to adress R1)
        ADD R1, R1, #1      ; increment to next location on display (in display)
	ADD R2, R2, #-1		; decrement counter (subtract 1 from 25)
	BRp onemo2            ; if positive, keep going until at end of row
line2   ADD R1, R1, R3      ; add row to location (add 103 to address)
        LD R2, COLS1        ; reset pixel count to 25
        ADD R4, R4, #-1     ; decrement column number
        BRp onemo2
        RET

nextbox2        LD R2, COLS1 ;25 is now in R2
                LD R3, ROW ;103 is now in R3
                LD R4, FORTY
                LD R1, TOPL3
                BRnzp onemo3

onemo3   ADD R4, R4, #0      ;check if at bottom of digit
        BRz lastbox            ;if at bottom, go to next box
        BRp draw3           ; if a 1, go store color
		
draw3	LD R0, BLANK
        STR R0, R1, #0		; write pixel (put blue to adress R1)
        ADD R1, R1, #1      ; increment to next location on display (in display)
	ADD R2, R2, #-1		; decrement counter (subtract 1 from 25)
	BRp onemo3            ; if positive, keep going until at end of row
line3   ADD R1, R1, R3      ; add row to location (add 103 to address)
        LD R2, COLS1        ; reset pixel count to 25
        ADD R4, R4, #-1     ; decrement column number
        BRp onemo3

lastbox LD R2, COLS1 ;25 is now in R2
        LD R3, ROW ;103 is now in R3
        LD R4, FORTY
        LD R1, TOPL4
        BRnzp onemof

onemof  ADD R4, R4, #0      ;check if at bottom of digit
        BRz wipeEND          ;if at bottom, go to next box
        BRp drawf           ; if a 1, go store color
		
drawf	LD R0, BLANK
        STR R0, R1, #0		; write pixel (put blue to adress R1)
        ADD R1, R1, #1      ; increment to next location on display (in display)
	ADD R2, R2, #-1		; decrement counter (subtract 1 from 25)
	BRp onemof            ; if positive, keep going until at end of row
linef   ADD R1, R1, R3      ; add row to location (add 103 to address)
        LD R2, COLS1        ; reset pixel count to 25
        ADD R4, R4, #-1     ; decrement column number
        BRp onemof
;------------------------------------------------------------------------------------------------------------------------------
wipeEND     AND R6, R6, #0
            RET         ;END OF WIPE FUNCTION   

RESET           ;START FUNCTION RESET (SET DISPLAY 0000)
;-----------------------------------------------------------------------------------
        LD R5, loc0
        LD R0, COLOR ;blue is now in R0
        LD R1, TOPL1 ;location of 0 is now in R1
        LD R2, COLS1 ;25 is now in R2
        LD R3, ROW ;103 is now in R3
        LD R4, FORTY
        
look    ADD R4, R4, #0      ;check if at bottom of digit
        BRz NEXT            ;if at bottom, go to next
        LDR R6, R5, #0      ; load r6 with the address in R5 (digits.obj 0 or 1)
        BRp first           ; if a 1, go store color
        ADD R5, R5, #1      ;if not, go to next hex in digits.obj
        ADD R1, R1, #1      ;next location on display
        ADD R2, R2, #-1     ;decrement counter
        BRz ROWS1
        BRp look
		
first	LD R0, COLOR
        STR R0, R1, #0		; write pixel (put blue to adress R1)
        ADD R1, R1, #1      ; increment to next location on display (in display)
        ADD R5, R5, #1		; increment to next location in digits.obj (add 1 to address)
	ADD R2, R2, #-1		; decrement counter (subtract 1 from 25)
	BRp look            ; if positive, keep going until at end of row
ROWS1   ADD R1, R1, R3      ; add row to location (add 103 to address)
        LD R2, COLS1        ; reset pixel count to 25
        ADD R4, R4, #-1     ; decrement column number
        BRp look            ; whatever, go look at if it should print or not
        
NEXT    LD R1, TOPL2
        LD R4, FORTY
        LD R5, loc0
look2   ADD R4, R4, #0      ;check if at bottom of digit
        BRz NEXT2            ;if at bottom, go to next
ok100   LDR R6, R5, #0      ; load r6 with the address in R5 (digits.obj 0 or 1)
        BRp second           ; if a 1, go store color
        ADD R5, R5, #1      ;if not, go to next hex in digits.obj
        ADD R1, R1, #1      ;next location on display
        ADD R2, R2, #-1     ;decrement counter
        BRz ROWS2
        BRp look2
		
second	LD R0, COLOR
        STR R0, R1, #0		; write pixel (put blue to adress R1)
        ADD R1, R1, #1      ; increment to next location on display (in display)
        ADD R5, R5, #1		; increment to next location in digits.obj (add 1 to address)
	ADD R2, R2, #-1		; decrement counter (subtract 1 from 25)
	BRp look2            ; if positive, keep going until at end of row
ROWS2   ADD R1, R1, R3      ; add row to location (add 103 to address)
        LD R2, COLS1        ; reset pixel count to 25
        ADD R4, R4, #-1     ; decrement column number
        BRp look2            ; whatever, go look at if it should print or not

NEXT2   LD R1, TOPL3
        LD R4, FORTY
        LD R5, loc0
look3   ADD R4, R4, #0      ;check if at bottom of digit
        BRz LAST            ;if at bottom, go to next
ok10    LDR R6, R5, #0      ; load r6 with the address in R5 (digits.obj 0 or 1)
        BRp third           ; if a 1, go store color
        ADD R5, R5, #1      ;if not, go to next hex in digits.obj
        ADD R1, R1, #1      ;next location on display
        ADD R2, R2, #-1     ;decrement counter
        BRz ROWS3
        BRp look3
		
third	LD R0, COLOR
        STR R0, R1, #0		; write pixel (put blue to adress R1)
        ADD R1, R1, #1      ; increment to next location on display (in display)
        ADD R5, R5, #1		; increment to next location in digits.obj (add 1 to address)
	ADD R2, R2, #-1		; decrement counter (subtract 1 from 25)
	BRp look3            ; if positive, keep going until at end of row
ROWS3   ADD R1, R1, R3      ; add row to location (add 103 to address)
        LD R2, COLS1        ; reset pixel count to 25
        ADD R4, R4, #-1     ; decrement column number
        BRp look3            ; whatever, go look at if it should print or not

LAST    LD R1, TOPL4
        LD R4, FORTY
        LD R5, loc0
look4   ADD R4, R4, #0      ;check if at bottom of digit
        BRz INPUT            ;if at bottom, go to next
ok1     LDR R6, R5, #0      ; load r6 with the address in R5 (digits.obj 0 or 1)
        BRp fourth           ; if a 1, go store color
        ADD R5, R5, #1      ;if not, go to next hex in digits.obj
        ADD R1, R1, #1      ;next location on display
        ADD R2, R2, #-1     ;decrement counter
        BRz ROWS4
        BRp look4
		
fourth	LD R0, COLOR
        STR R0, R1, #0		; write pixel (put blue to adress R1)
        ADD R1, R1, #1      ; increment to next location on display (in display)
        ADD R5, R5, #1		; increment to next location in digits.obj (add 1 to address)
	ADD R2, R2, #-1		; decrement counter (subtract 1 from 25)
	BRp look4            ; if positive, keep going until at end of row
ROWS4   ADD R1, R1, R3      ; add row to location (add 103 to address)
        LD R2, COLS1        ; reset pixel count to 25
        ADD R4, R4, #-1     ; decrement column number
        BRp look4            ; whatever, go look at if it should print or not

INPUT   RET       ;END OF RESET FUNCTION (ALL 0000)


        .END