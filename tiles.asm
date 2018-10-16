.model small 
.stack 100h 
	TILESIZE EQU 16 
	TILEMAPW EQU 32
	SCREENWIDTH EQU 320
	SCREENHEIGHT EQU 200
.data 
	Tilefile DB 'tiles.raw$', 00h
	Mapfile DB 'level1.map$', 00h
	Filehandle DW 0	
	TileBuffer DB 300h dup(?)
	MapBuffer DB 3e8h dup(?)
	x DW 0
	y DW 0
	counter DW 0
.code

printchar MACRO char
	mov dl, char
	mov ah, 2h
	int 21h
ENDM

PAL MACRO num, r, g, b
	mov ax, 1010h
	mov bx, num
	mov ch, g
	mov cl, b
	mov dh, r
	int 10h
ENDM

LOADDATA macro file, buffer, readsize
	mov bx, readsize
	push bx
	lea bx, buffer
	push bx
	lea bx, file
	push bx
	call loadFile
ENDM

main proc
	mov ax, 0013h ; enter mode13h
	int 10h

	mov ax, 0a000h ;graphics segment
	mov es, ax

	call setPalette
	
	mov ax, @data
	mov ds, ax

	LOADDATA TileFile, TileBuffer, 300h
	LOADDATA Mapfile, MapBuffer, 3e8h

	call drawMap

	xor ah, ah ; wait for input
	int 16h
	
	mov ax, 0003h ; exit mode13h
	int 10h
	
	mov al, 0 ; exit program
	mov ah, 04ch
	int 21h
	ret
main endp

drawMap proc
	mov counter, 0
	mov y, 0
	loopY:
		mov x, 0	
		loopX:					
			mov bx, counter
			mov al, MapBuffer[bx] 
			xor ah, ah
			mov bx, ax

			call drawTile

			add counter, 1
			add x, TILESIZE
			cmp x, SCREENWIDTH
			jl loopX
		
		add y, TILESIZE
		cmp y, SCREENHEIGHT-16
		jl loopY

	ret
drawMap endp

drawTile proc
	cld
	lea si, TileBuffer ;src	 - DS:SI
	add si, bx
	mov di, 0 ; dest	ES:DI
	mov bx, 0
drawLine:
	mov ax, bx
	add ax, y
	mov cx, SCREENWIDTH 
	mul cx
	add ax, x
	mov di, ax

	mov cx, TILESIZE/2
	rep movsw
	
	add si, TILEMAPW 
	inc bx
	cmp bx, TILESIZE
	jl drawLine

	ret
drawTile endp
	
loadFile proc 
	push bp
	mov bp, sp

	mov dx, [bp+4]
	mov cx, [bp+8]
	mov ah, 3dh
	mov al, 0
	int 21h
	jc OpenError
	mov Filehandle, ax

	mov ah, 3fh
	mov dx, [bp+6] 
	mov bx, Filehandle
	int 21h
	jc ReadError
	cmp ax, cx
	jne	EOF

EOF:	
	mov bx, Filehandle ;close file
	mov ah, 3eh

	pop bp
	ret 6

ReadError:
	printchar 'r' ; r as in read error of course!
	jmp EOF

OpenError:
	printchar 'o' ; o as in open error of course!
	jmp EOF

loadFile endp

setPalette proc
	PAL 0, 0, 0, 0
	PAL 1, 4, 30, 43
	PAL 2, 6, 20, 12
	PAL 3, 6, 35, 51
	PAL 4, 8, 22, 12
	PAL 5, 8, 37, 55
	PAL 6, 10, 24, 10
	PAL 7, 10, 39, 57
	PAL 8, 10, 39, 59
	PAL 9, 10, 41, 59
	PAL 10, 12, 12, 8
	PAL 11, 12, 28, 8
	PAL 12, 14, 12, 8
	PAL 13, 16, 12, 8
	PAL 14, 16, 37, 6
	PAL 15, 18, 14, 8
	PAL 16, 22, 16, 10
	PAL 17, 24, 43, 53
	PAL 18, 24, 45, 55
	PAL 19, 26, 45, 57
	PAL 20, 28, 47, 55
	PAL 21, 28, 47, 57
	PAL 22, 30, 47, 57
	PAL 23, 30, 49, 59
	PAL 24, 33, 49, 57
	PAL 25, 33, 49, 59
	ret
setPalette endp

END main