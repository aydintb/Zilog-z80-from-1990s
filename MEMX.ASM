	title	Aydin Turabi Bakir,	MEMORY MANEGMENT

		.MODEL	HUGE
		.CODE

PUBLIC		_my_allocmem
_my_allocmem	PROC	FAR
		arg	segPtr:dword
		push	bp
		mov	bp,sp
		les	di,segPtr
		mov	bx,word ptr es:[di]

		mov	ah,48h
		int	21h
		jnb	tamam

		mov	es:word ptr [di],ax     ; segment addres into Arg
		mov	ax,bx					; return size

		pop	bp
		ret
_my_allocmem	ENDP


PUBLIC		_my_freemem
_my_freemem	PROC	FAR
		arg	segmptr:word
		push	bp
		mov	bp,sp

		mov	es,segmptr
		mov	ah,49h
		int	21h

		pop	bp
		ret
_my_freemem	ENDP


PUBLIC		_my_modifymem
_my_modifymem	PROC	FAR
		arg	NewSize:word, SegAddress:word
		push	bp
		mov	bp,sp

		mov	bx, NewSize
		mov	es, SegAddress
		mov	ah,4ah		; modify new segment size.
		int	21h

		pop	bp
		ret
_my_modifymem	ENDP

		END
