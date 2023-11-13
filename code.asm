;	set game state memory location
.equ    HEAD_X,         0x1000  ; Snake head's position on x
.equ    HEAD_Y,         0x1004  ; Snake head's position on y
.equ    TAIL_X,         0x1008  ; Snake tail's position on x
.equ    TAIL_Y,         0x100C  ; Snake tail's position on Y
.equ    SCORE,          0x1010  ; Score address
.equ    GSA,            0x1014  ; Game state array address

.equ    CP_VALID,       0x1200  ; Whether the checkpoint is valid.
.equ    CP_HEAD_X,      0x1204  ; Snake head's X coordinate. (Checkpoint)
.equ    CP_HEAD_Y,      0x1208  ; Snake head's Y coordinate. (Checkpoint)
.equ    CP_TAIL_X,      0x120C  ; Snake tail's X coordinate. (Checkpoint)
.equ    CP_TAIL_Y,      0x1210  ; Snake tail's Y coordinate. (Checkpoint)
.equ    CP_SCORE,       0x1214  ; Score. (Checkpoint)
.equ    CP_GSA,         0x1218  ; GSA. (Checkpoint)

.equ    LEDS,           0x2000  ; LED address
.equ    SEVEN_SEGS,     0x1198  ; 7-segment display addresses
.equ    RANDOM_NUM,     0x2010  ; Random number generator address
.equ    BUTTONS,        0x2030  ; Buttons addresses
.equ 	EDGE_CAPTURE, 	0x2034 ; edgecapture
.equ    STACK_BOTTOM,   0x2000  ; address of the bottom of the stack

; button state
.equ    BUTTON_NONE,    0
.equ    BUTTON_LEFT,    1
.equ    BUTTON_UP,      2
.equ    BUTTON_DOWN,    3
.equ    BUTTON_RIGHT,   4
.equ    BUTTON_CHECKPOINT,    5

; array state
.equ    DIR_LEFT,       1       ; leftward direction
.equ    DIR_UP,         2       ; upward direction
.equ    DIR_DOWN,       3       ; downward direction
.equ    DIR_RIGHT,      4       ; rightward direction
.equ    FOOD,           5       ; food

; constants
.equ    NB_ROWS,        8       ; number of rows
.equ    NB_COLS,        12      ; number of columns
.equ    NB_CELLS,       96      ; number of cells in GSA
.equ    RET_ATE_FOOD,   1       ; return value for hit_test when food was eaten
.equ    RET_COLLISION,  2       ; return value for hit_test when a collision was detected
.equ    ARG_HUNGRY,     0       ; a0 argument for move_snake when food wasn't eaten
.equ    ARG_FED,        1       ; a0 argument for move_snake when food was eaten

; initialize stack pointer
addi    sp, zero, STACK_BOTTOM

; main
; arguments
;     none
;
; return values
;     This procedure should never return.
main:
    ; TODO: Finish this procedure.
	;call clear_leds

	br move_loop_test

	move_loop_test:
		stw zero, HEAD_X(zero)
		stw zero, HEAD_Y(zero)
		stw zero, TAIL_X(zero)
		stw zero, TAIL_Y(zero)		
		addi t0, zero, 4
		stw t0, GSA(zero)

	move_loop:
			
			call clear_leds
			call get_input
			call move_snake
			call draw_array
			br move_loop

	draw_array_test:
		addi t0, zero, 3
		addi t1, zero, 0
		stw t0, GSA(t1)
		addi t0, zero, 2
		addi t1, zero, 4
		stw t0, GSA(t1)
		addi t0, zero, 0
		addi t1, zero, 8
		stw t0, GSA(t1)
		addi t0, zero, 4
		addi t1, zero, 12
		stw t0, GSA(t1)
		addi t0, zero, 5
		addi t1, zero, 16
		stw t0, GSA(t1)
		addi t0, zero, 3
		addi t1, zero, 48
		stw t0, GSA(t1)
		call draw_array
		call hit_test
		ret

	move_snake_test:
		addi t0, zero, 4
		addi t1, zero, 	108  ; (3,2) = 4*(3 + 2*12) = 108
		stw t0, GSA(t1)
		addi t0, zero, 4
		addi t1, zero, 	112
		stw t0, GSA(t1)
		addi t0, zero, 4
		addi t1, zero, 	116
		stw t0, GSA(t1)
		addi t0, zero, 3
		addi t1, zero, 120 
		stw t0, GSA(t1)
		addi t0, zero, 3
		addi t1, zero, 168  
		stw t0, GSA(t1)

		addi t0, zero, 3
		addi t1, zero, 2
		stw t0, TAIL_X(zero)
		stw t1, TAIL_Y(zero)
		addi t0, zero, 6
		addi t1, zero, 3
		stw t0, HEAD_X(zero)
		stw t1, HEAD_Y(zero)
		call clear_leds
		call move_snake
		call clear_leds
		call draw_array
		ret

; BEGIN: clear_leds
clear_leds:
	addi t0, zero, LEDS

	stw zero, LEDS(zero)
	stw zero, 4(t0)
	stw zero, 8(t0)

	ret
; END: clear_leds


; BEGIN: set_pixel
set_pixel:
	addi sp, sp, -4
	stw ra, 0(sp)	

	addi t0, zero, 4
    addi t1, zero, 8
    blt a0, t0, led0
    blt a0, t1, led1
    br led2
    
    led0:
        addi t4, zero, 0   ; Led array index
        ldw t5, LEDS(t4)    ; Led array
        add t7, zero, a0   ; Pixel relative row number
        br rows
    led1:
        addi t4, zero, 4
        ldw t5, LEDS(t4)
        addi t7, a0, -4
        br rows
    led2:
        addi t4, zero, 8
        ldw t5, LEDS(t4)
        addi t7, a0, -8

    rows:
        addi t0, zero, 1
        addi t1, zero, 2
        add t6, zero, a1    ; Pixel number
        beq t7, zero, done_setpixel
        beq t7, t0, row1
        beq t7, t1, row2
        br row3
    
    row1:
        addi t6, t6, 8
        br done_setpixel
    row2:
        addi t6, t6, 16
        br done_setpixel
    row3:
        addi t6, t6, 24

    done_setpixel:
        addi t7, zero, 1
        sll t7, t7, t6
        or t7, t7, t5
        stw t7, LEDS(t4)
		
		ldw ra, 0(sp)
		addi sp, sp, 4
		ret

    
; END: set_pixel


; BEGIN: display_score
display_score:

; END: display_score


; BEGIN: init_game
init_game:

; END: init_game


; BEGIN: create_food
create_food:

; END: create_food


; BEGIN: hit_test
hit_test:
	addi t3, zero, -1
	addi t7, zero, DIR_LEFT
	addi t6, zero, DIR_RIGHT
	addi t5, zero, DIR_UP
	addi t4, zero, DIR_DOWN
	
	ldw t0, HEAD_X(zero)
	ldw t1, HEAD_Y(zero)
	add t2, t1, t1
	add t2, t2, t1
	slli t2, t2, 2
	add t2, t2, t0
	slli t2, t2,2 
	ldw t2, GSA(t2)
	
	beq t2, t7, left
	beq t2, t6, right
	beq t2, t5, up
	beq t2, t4, down

left:
	addi t0, t0, -1
	beq t3, t0, wall
	
	add t2, t1, t1
	add t2, t2, t1
	slli t2, t2, 2
	add t2, t2, t0
	slli t2, t2,2 
	ldw t2, GSA(t2)	;getting the gsa of the new pos, NEXT: Testing
	jmpi testing	

right:
	addi t0, t0, 1
	addi t3, zero, 12  ;right limit
	beq t3, t0, wall
	
	add t2, t1, t1
	add t2, t2, t1
	slli t2, t2, 2
	add t2, t2, t0
	slli t2, t2,2 
	ldw t2, GSA(t2)
	jmpi testing

up:
	addi t1, t1, -1
	beq t3, t1, wall
	
	add t2, t1, t1
	add t2, t2, t1
	slli t2, t2, 2
	add t2, t2, t0
	slli t2, t2,2 
	ldw t2, GSA(t2) 
	jmpi testing
	
down:
	addi t1, t1, 1
	addi t3, zero, 8 ;down limit 
	beq t3, t1, wall
	
	add t2, t1, t1
	add t2, t2, t1
	slli t2, t2, 2
	add t2, t2, t0
	slli t2, t2,2 
	ldw t2, GSA(t2) 
	
testing:
	addi t3, zero, FOOD

	beq t2, t7, wall
	beq t2, t6, wall
	beq t2, t5, wall
	beq t2, t4, wall
	beq t2, t3, food
	
	add v0, zero, zero	;do nothing
	ret

wall: addi v0, zero, 2
	ret

food: addi v0, zero, 1
	ret

; END: hit_test


; BEGIN: get_input
get_input:
	addi sp, sp, -4
	stw ra, 0(sp)
	ldw t0, EDGE_CAPTURE(zero)
	addi t1, zero, 1    ; Constant
	addi t4, zero, BUTTON_CHECKPOINT 
	add t3, zero, zero   ; t3 is the current button that is examined
	
	shift:
		and t2, t0, t1   ; t2 selects the last bit of EDGE_CAPTURE
		bne t2, zero, then_get_input
		srl t0, t0, t1
		addi t3, t3, 1
		bge t3, t4, all_empty
		jmpi shift

	all_empty:
		addi v0, zero, 0
		stw zero, EDGE_CAPTURE(zero)
		br get_intput_return

	then_get_input:
		addi t0, zero, 1
		;sll v0, t0, t3
		add v0, t3, zero
		stw zero, EDGE_CAPTURE(zero)
		br update_head_movement

	update_head_movement:
		addi t7, zero, 1
		add t7, v0, t7
		
		ldw t0, HEAD_X(zero)
		ldw t1, HEAD_Y(zero)
		add t2, t1, t1
		add t2, t2, t1
		slli t2, t2, 2
		add t2, t2, t0
		slli t2, t2, 2
		stw t7, GSA(t2)

	get_intput_return:
		ldw ra, 0(sp)
		addi sp, sp, 4
		ret

; END: get_input



; BEGIN:draw_array
draw_array:
   
	addi sp, sp, -12  ; Allocating memory for previous return address
	stw ra, 0(sp)
	stw s0, 4(sp)
	stw s1, 8(sp)

	addi s0, zero, -1; t6 = x
	addi s1, zero, -1; t7 = y
	next_line:
		addi s1, s1, 1
		addi t3, zero, 8
		bge s1, t3, exit_loop

		addi s0, zero, -1
		next_pixel:
			addi s0, s0, 1
			addi t3, zero, 12
			bge s0, t3, next_line

			add t2, s1, s1
			add t2, t2, s1  ; Multiply y by 3
			slli t2, t2, 2  ; Multiply y by 4
			add t2, t2, s0   ; Add x
			slli t2, t2, 2   ; Multiply by 4
			ldw t2, GSA(t2)
			beq t2, zero, next_pixel
			add a0, zero, s0
			add a1, zero, s1
			call set_pixel
			br  next_pixel

		
	exit_loop:



	ldw ra, 0(sp) 
	ldw s0, 4(sp)
	ldw s1, 8(sp)
    addi sp, sp, 12  ; Liberating the memory we used
	ret
 
; END:draw_array
	
	
	
	
; END: draw_array


; BEGIN: move_snake
move_snake:
	addi sp, sp, -4  ; Allocating memory for previous return address
	
	stw ra, 0(sp)


;	1) Find next position of head and its vector movement using gsa
;      Convention used: we store row by row starting from (0,0)
	ldw t0, HEAD_X(zero)
	ldw t1, HEAD_Y(zero)
	add t2, t1, t1  ; Multiply t1 by 3, store in t2
	add t2, t2, t1
	slli t2, t2, 2  ; Multiply t2 by 4
	add t2, t2, t0
	slli t2, t2, 2
	
	ldw t2, GSA(t2)  ; t2 stores the head movement vector
	


;   2) Update head position
	addi t3, zero, 1
	beq t3, t2, left_movement
	addi t3, zero, 2
	beq t3, t2, up_movement
	addi t3, zero, 3
	beq t3, t2, down_movement
	addi t3, zero, 4
	beq t3, t2, right_movement

	left_movement:
		addi t0, t0, -1
		addi t1, t1, 0
		jmpi compute_tail
	right_movement:
		addi t0, t0, 1
		addi t1, t1, 0
		jmpi compute_tail
	up_movement:
		addi t0, t0, 0
		addi t1, t1, -1
		jmpi compute_tail
	down_movement:
		addi t0, t0, 0
		addi t1, t1, 1
		jmpi compute_tail


	compute_tail:
	stw t0, HEAD_X(zero)
	stw t1, HEAD_Y(zero)
	add t4, t1, t1
	add t4, t4, t1
	slli t4, t4, 2
	add t4, t4, t0
	slli t4, t4, 2
	stw t2, GSA(t4)
	



	ldw t0, TAIL_X(zero)
	ldw t1, TAIL_Y(zero)
	add t2, t1, t1  ; Multiply y by 3
	add t2, t2, t1
	slli t2, t2, 2  ; Mutlitply y by 4
	add t2, t2, t0
	slli t2, t2, 2   ; Multitply y by 4
	ldw t3, GSA(t2)  ; t3 stores the tail movement vector
	stw zero, GSA(t2)
	
	beq t3, zero, move_snake_return
	addi t4, zero, 1
	beq t4, t3, left_movement_tail
	addi t4, zero, 2
	beq t4, t3, up_movement_tail
	addi t4, zero, 3
	beq t4, t3, down_movement_tail
	addi t4, zero, 4
	beq t4, t3, right_movement_tail



	left_movement_tail:
		addi t0, t0, -1
		stw t0, TAIL_X(zero)
		br move_snake_return
	right_movement_tail:
		addi t0, t0, 1
		stw t0, TAIL_X(zero)
		br move_snake_return
	up_movement_tail:
		addi t1, t1, -1
		stw t1, TAIL_Y(zero)
		br move_snake_return
	down_movement_tail:
		addi t1, t1, 1
		stw t1, TAIL_Y(zero)
		br move_snake_return

	final_update_tail:


	move_snake_return:
		ldw ra, 0(sp)
		addi sp, sp, 4
		ret

	

; END: move_snake


; BEGIN: save_checkpoint
save_checkpoint:

; END: save_checkpoint


; BEGIN: restore_checkpoint
restore_checkpoint:

; END: restore_checkpoint


; BEGIN: blink_score
blink_score:

; END: blink_score
