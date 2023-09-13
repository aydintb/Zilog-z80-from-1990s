
TITLE			AYDIN T.BAKIR. BITIRME ODEVI ICIN YETERLi XMS LIBRARY.
;	Bu Program Aydin Turabi Bakir tarafindan yazilmistir.
;	Programin yazimi sirasinda gereken bilgiler XMS300.DOC adinda
;	LOTUS, INTEL, MICROSOFT ve AST Research Corparation tarafindan 
;	hazirlanmis shareware-document fileden alinmistir.
;	
;
		.MODEL	HUGE
		.CODE

   XMSControl	dd	?		; for API call

   OldDs	dw	?		; Hide old DS
   OldEs	dw	?		; Hide old ES, if I need?
   _MoveError	dw	?		; Memory move error...

 ;Extended Memory Move Structure Definition:

 extrn	_EMMS 



 PUBLIC _XMSInstalled
 PROC	_XMSInstalled			; Is an XMS driver installed?
		mov     ax,4300h
		int     2Fh
		cmp	al,80h
		mov	ax,0
		jne	NOXMS
                mov     ax,4310h
		int     2Fh
		mov     cs:word ptr [XMSControl],bx    ; XMSControl is a DWORD
		mov     cs:word ptr [XMSControl+2],es
		mov	ax,1
		NOXMS:  nop
		ret
 ENDP   _XMSInstalled


PUBLIC	_XMSVersion		; Get the XMS driver's version number
PROC	_XMSVersion
		mov     ah,00h
		call    dword ptr cs:XMSControl  ; Get XMS Version Number
		ret
ENDP	_XMSVersion


PUBLIC	_XMSMemory
PROC  	_XMSMemory
		push	bp
		mov	bp,sp		; NOTE: last parameter will be used
					; first.
		mov	ah,08h
		call	dword ptr cs:XMSControl

		leS	di,[bp+10]	; Argument DX	addr = 2(bp)+4(r)+4(ax)
		mov	es:[di],dx

		leS	di,[bp+6]	;          AX	addr = 2 + 4
		mov	es:[di],ax

		pop	bp

;	RETS:	AX = Size of the largest free extended memory block in K-bytes
;		DX = Total amount of free extended memory in K-bytes
;
;	ERRS:	BL = 80h if the function is not implemented
;		BL = 81h if a VDISK device is detected
;		BL = A0h if all extended memory is allocated
		ret
ENDP	_XMSMemory


PUBLIC	_XMSAlloc
PROC	_XMSAlloc
		push	bp
		mov	bp,sp

		mov	ah,09h

		les	di,[bp+6]
		mov	dx,es:[di]

		call	dword ptr cs:XMSControl

		mov	es:[di],dx

		pop	bp

;Allocate Extended Memory Block (Function 09h):
;	ARGS:	AH = 09h
;		DX = Amount of extended memory being requested in K-bytes
;
;	RETS:	AX = 0001h if the block is allocated, 0000h otherwise
;		DX = 16-bit handle to the allocated block
;
;	ERRS:	BL = 80h if the function is not implemented
;		BL = 81h if a VDISK device is detected
;		BL = A0h if all available extended memory is allocated
;		BL = A1h if all available extended memory handles are in use
;
		ret
ENDP	_XMSAlloc

PUBLIC	_XMSFree
PROC	_XMSFree
		push	bp
		mov	bp,sp

		mov	ah,0ah
		les	di,[bp+6]
		mov	dx,es:[di]

		call	dword ptr cs:XMSControl

		mov	es:[di],ax

		pop	bp
;Free Extended Memory Block (Function 0Ah):
;
;	ARGS:	AH = 0Ah
;		DX = Handle to the allocated block which should be freed
;
;	RETS:	AX = 0001h if the block is successfully freed, 0000h otherwise
;
;	ERRS:	BL = 80h if the function is not implemented
;		BL = 81h if a VDISK device is detected
;		BL = A2h if the handle is invalid
;		BL = ABh if the handle is locked
;
		ret
ENDP	_XMSFree


PUBLIC	_XMSMove
PROC	_XMSMove
		push	bp
		mov	bp,sp

		mov	cs:word ptr OldDs,ds

		lds	si,[bp+6]	; _EMMS Pointer.
                mov	ah,0Bh

		call	dword ptr cs:XMSControl

		mov     cs:word ptr _MoveError, ax
		mov	ds,word ptr cs:OldDs

		pop	bp

;Move Extended Memory Block (Function 0Bh):
;
;	ARGS:	AH = 0Bh
;		DS:SI = Pointer to an Extended Memory Move Structure (see below)
;
;	RETS:	AX = 0001h if the move is successful, 0000h otherwise
;
;	ERRS:	BL = 80h if the function is not implemented
;		BL = 81h if a VDISK device is detected
;		BL = 82h if an A20 error occurs
;		BL = A3h if the SourceHandle is invalid
;		BL = A4h if the SourceOffset is invalid
;		BL = A5h if the DestHandle is invalid
;		BL = A6h if the DestOffset is invalid
;		BL = A7h if the Length is invalid
;		BL = A8h if the move has an invalid overlap
;		BL = A9h if a parity error occurs
;
;Extended Memory Move Structure Definition:
;
;	ExtMemMoveStruct    struc
;	    Length              dd  ?   ; 32-bit number of bytes to transfer
;	    SourceHandle        dw  ?   ; Handle of source block
;	    SourceOffset        dd  ?   ; 32-bit offset into source
;	    DestHandle          dw  ?   ; Handle of destination block
;	    DestOffset          dd  ?   ; 32-bit offset into destination block
;	ExtMemMoveStruct    ends
;
;
;NOTE: If SourceHandle is set to 0000h, the SourceOffset is interpreted
;as a standard segment:offset air which refers to memory that is directly
;accessible by the processor.  The segment:offset pair is stored in Intel
;DWORD notation. The same is true for DestHandle and DestOffset.

		ret
ENDP	_XMSMove


	end

