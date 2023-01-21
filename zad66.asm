; Program linie.asm
; Wyœwietlanie znaków * w takt przerwañ zegarowych
; Uruchomienie w trybie rzeczywistym procesora x86
; lub na maszynie wirtualnej
; zakoñczenie programu po naciœniêciu dowolnego klawisza
; asemblacja (MASM 4.0): masm gwiazdki.asm,,,;
; konsolidacja (LINK 3.60): link gwiazdki.obj;

.386
rozkazy		SEGMENT use16
		ASSUME cs:rozkazy

linia	PROC

; przechowanie rejestrów
	push ax
	push bx
	push cx
	push dx
	push es

	mov ax, 0A000H ; adres pamiêci ekranu dla trybu 13H
	mov es, ax
	mov cx, 0
	mov dx, cs:licznik

	mov bx, cs:adres_piksela ; adres bie¿¹cy piksela
	mov cs:kolor, 14
	
	mov al, cs:kolor
	cmp dx, 3
	jb dalej
	cmp al, 14
	je zmiana

back:
dalej:
	add dx, 1
	mov cs:licznik, dx
	mov dx, 6000

next_line:
	mov cx, 100

pozioma:
	mov bx, dx
	add bx, cx
	mov es:[bx], al
	inc cx

	cmp cx, 200
	jb pozioma

	add dx, 320
	cmp dx, 38000
	jb next_line
	

koniec:
; odtworzenie rejestrów
	 pop es
	 pop dx
	 pop cx
	 pop bx
	 pop ax

; skok do oryginalnego podprogramu obs³ugi przerwania
; zegarowego
	jmp dword PTR cs:wektor8

zmiana:
	mov al, 16
	mov cs:kolor, al
	cmp dx, 4
	je reset

	jmp back

reset:
	mov dx, 0
	jmp back

; zmienne procedury
	kolor db 14 ; bie¿¹cy numer koloru                        zolty - 14, czarny - 16
	adres_piksela dw 10 ; bie¿¹cy adres piksela
	przyrost dw 0
	counter dw 0
	wektor8 dd ?
	licznik dw 0

linia ENDP



; INT 10H, funkcja nr 0 ustawia tryb sterownika graficznego
zacznij:
	mov ah, 0
	mov al, 13H ; nr trybu
	int 10H

	mov bx, 0
	mov es, bx ; zerowanie rejestru ES
	mov eax, es:[32] ; odczytanie wektora nr 8
	mov cs:wektor8, eax; zapamiêtanie wektora nr 8

; adres procedury 'linia' w postaci segment:offset
	mov ax, SEG linia
	mov bx, OFFSET linia

	cli ; zablokowanie przerwañ
; zapisanie adresu procedury 'linia' do wektora nr 8
	mov es:[32], bx
	mov es:[32+2], ax

	sti ; odblokowanie przerwañ

czekaj:
	mov ah, 1 ; sprawdzenie czy jest jakiœ znak
	int 16h ; w buforze klawiatury
	jz czekaj

	mov ah, 0
	int 16H
	cmp al, 'x'
	jne czekaj

	mov ah, 0 ; funkcja nr 0 ustawia tryb sterownika
	mov al, 3H ; nr trybu
	int 10H

; odtworzenie oryginalnej zawartoœci wektora nr 8
	mov eax, cs:wektor8
	mov es:[32], eax

; zakoñczenie wykonywania programu
	mov ax, 4C00H
	int 21H
rozkazy ENDS

stosik SEGMENT stack
	db 256 dup (?)
stosik ENDS

END zacznij
