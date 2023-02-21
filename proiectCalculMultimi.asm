.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem msvcrt.lib, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern printf: proc
extern scanf: proc
extern fread: proc
extern fprintf: proc
extern fopen: proc
extern fclose: proc
extern exit: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
  m_1 db 100 dup(0)
  nr_elem db 0

;pentru verificare
  flag_repetare db 0 ; este 1 daca elementele multimii se repeta/nu sunt unice
    ap db 100 dup(0) ;vector de aparitii
  

;pentru apartenenta:
  
  flag_element db 0 ; este 1 daca se gaseste elementul e
  e db 0 ;pentru apatenenta lui e in multime
  op db 0 ;operatia aleasa
  var_citire db 0  ;det cand se termina citirea multimii
  elem db 0 ; pentru a pune fiecare element in multime 

;mesajele de afisat:

mesaj_eroare db "eroare", 0
   m_2 db 100 dup(0)
mesaj_elemente_repetate db "elementele se repeta",10, 0
mesaj_elemente_unice db "elemente unice",10, 0

mesaj_introducere db "Introduceti o operatie cu multimi: ", 10, "1. Verificare", 10, "2. Apartenenta", 10, "3. Diferenta", 10, "4. Produs cartezian", 10,0
mesaj_e db "e = ", 0
mesaj_multime db "Multime: ",10,0
mesaj_nr_elemente db "nr elemente: ",  0
mesaj_rezultat db "Rezultat: ", 0
mesaj_apartine db "apartine", 10, 0
mesaj_nu_apartine db "nu apartine", 10, 0
mesaj_fisier_rezultat db " Fisier rezultat: rezultat.txt", 0

mesaj_nr_elemente_1 db "nr elemente M1: ", 0
mesaj_nr_elemente_2 db "nr elemente M2: ", 0
mesaj_multime_1 db "Multime1: ",10, 0
mesaj_multime_2 db "Multime2: ",10, 0

;pentru diferenta:
   nr_elem_1 db 0
   nr_elem_2 db 0
   elem1 db 0
   elem2 db 0


;formate:
format_m2 db "%d", 0
format_d db "%d", 0
format_sir db "%s", 0
format_m1 db "%d", 0

;pentru diferenta
flag_diferenta db 1 ; este 1 daca elementul din M2 nu se gaseste in M1
m_3 db 100 dup(0)   ; multimea diferenta M1\M2
var_diferenta db 0
var_m1 db 0
var_m2 db 0
nr_elem_3 db 0
var_m3 dd 0
var_m3_1 db 0
format_m3 db "%d ", 0
mesaj_m3 db "Multimea diferenta este: ", 0
mesaj_multime_vida db "multimea vida ", 0

;pentru produs:
elem_1 dd 0   ;perechile de numere 
elem_2 dd 0
format_produs db "(%d, %d);", 0
var_m1_p db 0
var_m2_p db 0

;fisier
mode_write db "w", 0
file db "rezultat.txt", 0
mesaj_op_1 db "1",10, 0
mesaj_op_2 db "2",10, 0
mesaj_op_3 db "3",10, 0
mesaj_op_4 db "4",10, 0
file2 db "rezultat_in.txt", 0
aux dd 0
count db 0
space db " ", 0
mesaj_multimef db " Multime: ", 0
retine_eax dd 0
retine_edi dd 0

;operatie invalida
 mesaj_eroare_operatie db "Operatie invalida", 10,0

.code
start:
    
    oper:
    push offset mesaj_introducere
	call printf
	add esp, 4
	
	;alegem operatia
	push offset op
	push offset format_d
	call scanf
	add esp, 8
	
	;daca op este 1
	cmp op, 1
	je verificare
	;daca op este 2
	cmp op, 2
	je apartenenta
	;daca op este 3
	cmp op, 3
	je diferenta
	;daca op este 4
	cmp op, 4
	je produs
	push offset mesaj_eroare_operatie
	call printf
	add esp, 4
	jmp oper
	
verificare:
    
    ;citim nr de elemente ale multimii
	push offset mesaj_nr_elemente
	call printf
	add esp, 4
	push offset nr_elem
	push offset format_d
	call scanf
	add esp, 8
	
	;initializam registrii
	xor ecx, ecx
	xor eax, eax ; in al numar cate elemente am de citit
	xor ebx, ebx ; in bl punem elementul citit pentru a fi transferat in vector
	xor esi,esi 
	xor edx, edx
	
	push offset mesaj_multime
	call printf
	add esp, 4
	
	citire_multime_v:
	push offset elem
	push offset format_d
	call scanf
	add esp, 8
	
	mov bl, elem
	mov m_1[esi], bl
	;verificam folosind un vector de aparitii
	inc ap[ebx]
	;daca apare de mai mult de o data, multimea nu are elemente unice
	cmp ap[ebx], 1
	jg se_repeta
	
	inc esi
	inc var_citire  ;pt a afla cand se termina citirea elementelor
	mov al, var_citire
	cmp al, nr_elem
	jl citire_multime_v
	je unice
	
	se_repeta:
	mov flag_repetare, 1

	push offset mesaj_rezultat
	call printf
	add esp, 4
	push offset mesaj_elemente_repetate
	call printf
	add esp, 4
	push offset mesaj_fisier_rezultat
	call printf
	add esp, 4
	
	;afisare fisier:
	push offset mode_write
    push offset file
    call fopen
    add ESP, 8
	mov edi,eax
    
	push offset mesaj_introducere
	push edi
	call fprintf
	add esp, 8

	push offset mesaj_op_1
	push edi
	call fprintf
	add esp, 8
	
	push offset mesaj_multimef
	push edi
	call fprintf
	add esp, 8
	
	xor esi, esi
	xor edx, edx
	;scriem multimea in fisier
	vector_1:
	xor eax, eax
	xor edx, edx
	mov al, m_1[esi]
	mov aux, eax
	push aux
	push offset format_d
	push edi
	call fprintf
	add esp, 12
	push offset space
	push edi
	call fprintf
	add esp, 8
	inc esi
	inc count
	mov dl, count
	cmp nr_elem, dl
	jne vector_1
	
    push offset mesaj_rezultat
	push edi
	call fprintf
	add esp, 8
	
	push offset mesaj_elemente_repetate
	push edi
	call fprintf
	add esp, 8	
	
	push edi
    call fclose
    add ESP, 4

	
    jmp final
	
	unice:
	mov flag_repetare, 0
	push offset mesaj_rezultat
	call printf
	add esp, 4
	push offset mesaj_elemente_unice
	call printf
	add esp, 4
	push offset mesaj_fisier_rezultat
	call printf
	add esp, 4
	
	;afisare fisier:
	push offset mode_write
    push offset file
    call fopen
    add ESP, 8
	mov edi,eax
    
	push offset mesaj_introducere
	push edi
	call fprintf
	add esp, 8

	push offset mesaj_op_1
	push edi
	call fprintf
	add esp, 8
	
	push offset mesaj_multimef
	push edi
	call fprintf
	add esp, 8
	
	xor esi, esi
	xor edx, edx
	;scriem multimea in fisier
	vector_1_1:
	xor eax, eax
	xor edx, edx
	mov al, m_1[esi]
	mov aux, eax
	push aux
	push offset format_d
	push edi
	call fprintf
	add esp, 12
	push offset space
	push edi
	call fprintf
	add esp, 8
	inc esi
	inc count
	mov dl, count
	cmp nr_elem, dl
	jne vector_1_1
	
    push offset mesaj_rezultat
	push edi
	call fprintf
	add esp, 8
	
	push offset mesaj_elemente_unice
	push edi
	call fprintf
	add esp, 8	
	
	push edi
    call fclose
    add ESP, 4
	;sarim la final
	
    jmp final
	
	
apartenenta:
	push offset mesaj_e
	call printf
	add esp, 4
	
	;citim elementul pe care vrem sa il cautam
	push offset e 
	push offset format_d
	call scanf
	add esp, 8
	
	;citim nr de elemente ale multimii
	push offset mesaj_nr_elemente
	call printf
	add esp, 4
	push offset nr_elem
	push offset format_d
	call scanf
	add esp, 8
	
	push offset mesaj_multime
	call printf
	add esp, 4
	;dam multimea
	xor ecx, ecx
	xor eax, eax ; in al numar cate elemente am de citit
	xor ebx, ebx ; in bl punem elementul citit pentru a fi transferat in vector
	xor esi,esi 
	xor edx, edx  ; in dl il punem pe e
	
	citire_multime_a:
	push offset elem
	push offset format_d
	call scanf
	add esp, 8
	
	mov bl, elem
	mov m_1[esi], bl
	;verificam daca elementul este egal cu cel dat:
	mov bl, e
	cmp m_1[esi], bl
	je apartine
	
	inc esi
	inc var_citire  ;pt a afla cand se termina citirea elementelor
	mov al, var_citire
	cmp al, nr_elem
	jl citire_multime_a
	je nu_apartine ; daca nu se gaseste elementul, flag_element ramane 0
	
	apartine:
	mov flag_element, 1
	push offset mesaj_rezultat
	call printf
	add esp, 4
	push offset mesaj_apartine
	call printf
	add esp, 4
	push offset mesaj_fisier_rezultat
	call printf
	add esp, 4
	
	;afisare fisier:
	push offset mode_write
    push offset file
    call fopen
    add ESP, 8
	mov edi,eax
    
	push offset mesaj_introducere
	push edi
	call fprintf
	add esp, 8

	push offset mesaj_op_2
	push edi
	call fprintf
	add esp, 8
	
	push offset mesaj_e
	push edi
	call fprintf
	add esp, 8
	
	xor eax, eax
	mov al,elem
	mov aux, eax
	push aux
	push offset format_d
	push edi
	call fprintf
	add esp, 12
	
	push offset mesaj_multimef
	push edi
	call fprintf
	add esp, 8
	
	xor esi, esi
	xor edx, edx
	;scriem multimea in fisier
	vector_2:
	xor eax, eax
	xor edx, edx
	mov al, m_1[esi]
	mov aux, eax
	push aux
	push offset format_d
	push edi
	call fprintf
	add esp, 12
	push offset space
	push edi
	call fprintf
	add esp, 8
	inc esi
	inc count
	mov dl, count
	cmp nr_elem, dl
	jne vector_2
	
    push offset mesaj_rezultat
	push edi
	call fprintf
	add esp, 8
	
	push offset mesaj_apartine
	push edi
	call fprintf
	add esp, 8	
	
	push edi
    call fclose
    add ESP, 4
	
    jmp final
	
	nu_apartine:
	mov flag_element, 0
	push offset mesaj_rezultat
	call printf
	add esp, 4
	push offset mesaj_nu_apartine
	call printf
	add esp, 4
	push offset mesaj_fisier_rezultat
	call printf
	add esp, 4
	
	;afisare fisier:
	push offset mode_write
    push offset file
    call fopen
    add ESP, 8
	mov edi,eax
    
	push offset mesaj_introducere
	push edi
	call fprintf
	add esp, 8

	push offset mesaj_op_2
	push edi
	call fprintf
	add esp, 8
	
	push offset mesaj_e
	push edi
	call fprintf
	add esp, 8
	
	xor eax, eax
	mov al,elem
	mov aux, eax
	push aux
	push offset format_d
	push edi
	call fprintf
	add esp, 12
	
	push offset mesaj_multimef
	push edi
	call fprintf
	add esp, 8
	
	xor esi, esi
	xor edx, edx
	;scriem multimea in fisier
	vector_2_1:
	xor eax, eax
	xor edx, edx
	mov al, m_1[esi]
	mov aux, eax
	push aux
	push offset format_d
	push edi
	call fprintf
	add esp, 12
	push offset space
	push edi
	call fprintf
	add esp, 8
	inc esi
	inc count
	mov dl, count
	cmp nr_elem, dl
	jne vector_2_1
	
    push offset mesaj_rezultat
	push edi
	call fprintf
	add esp, 8
	
	push offset mesaj_nu_apartine
	push edi
	call fprintf
	add esp, 8	
	
	push edi
    call fclose
    add ESP, 4
	jmp final
	
diferenta:
    ;citim nr de elemente ale multimii_1
	push offset mesaj_nr_elemente_1
	call printf
	add esp, 4
	push offset nr_elem_1
	push offset format_d
	call scanf
	add esp, 8
	
	push offset mesaj_multime_1
	call printf
	add esp, 4
	
	;initializam registrii
	xor ecx, ecx
	xor eax, eax ; in al numar cate elemente am de citit
	xor ebx, ebx ; in bl punem elementul citit pentru a fi transferat in vector
	xor esi,esi 
	xor edx, edx
	
	citire_multime_d_1:
	push offset elem1
	push offset format_d
	call scanf
	add esp, 8
	
	mov bl, elem1
	mov m_1[esi], bl
	
	inc esi
	inc var_citire  ;pt a afla cand se termina citirea elementelor
	mov al, var_citire
	cmp al, nr_elem_1
	jl citire_multime_d_1

	
	;citim nr de elemente ale multimii_2
	push offset mesaj_nr_elemente_2
	call printf
	add esp, 4
	push offset nr_elem_2
	push offset format_d
	call scanf
	add esp, 8
	
	push offset mesaj_multime_2
	call printf
	add esp, 4
	
	;initializam registrii
	xor ecx, ecx
	xor eax, eax ; in al numar cate elemente am de citit
	xor ebx, ebx ; in bl punem elementul citit pentru a fi transferat in vector
	xor esi,esi 
	xor edx, edx
	;reinitializam var_citire
	mov var_citire, 0
	
	citire_multime_d_2:
	push offset elem2
	push offset format_m1
	call scanf
	add esp, 8
	
	mov bl, elem2
	mov m_2[esi], bl
	
	inc esi
	inc var_citire  ;pt a afla cand se termina citirea elementelor
	mov al, var_citire
	cmp al, nr_elem_2
	jl citire_multime_d_2
	
    ;verificam pt fiecare elemente al multimii M1 daca apare in M2
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx ;contor m_2
	xor esi, esi ;contor m_1
	xor edi, edi ;contor m_3
	bucla_1:
	mov al, m_1[esi]
	xor edx, edx
	mov var_m2, 0
	;mov var_diferenta, al  ; punem in var_diferenta valoarea lui m_1[i]
	  bucla_2:
	  ;verificam cu fiecare m_2[j]
	  cmp al, m_2[edx]
	  je egale
	  ;daca nu sunt egale, flagul ramane 1
	  mov flag_diferenta, 1
	  inc edx
	  inc var_m2
	  mov bl, var_m2
	  cmp bl, nr_elem_2
	  je bucla_1_f
	  jmp bucla_2
	  
	  egale:
	  mov flag_diferenta, 0
	  jmp bucla_1_f
	  
	bucla_1_f:
	cmp flag_diferenta, 0 ;daca flagul nu e 1, sarim peste adaugarea altui element in m3
	je m3_0
	;adaugam in M3:
	mov m_3[edi], al
	inc edi
	inc nr_elem_3
	
	m3_0:
	inc esi
	inc var_m1
	mov bl, var_m1
	cmp bl, nr_elem_1
	je final_bucla_1
	jmp bucla_1
	
	final_bucla_1:
	;scriem elementele multimii m_3
	push offset mesaj_rezultat
	call printf
	add esp, 4
	
	push offset mesaj_m3
	call printf
	add esp, 4
	;daca nu s-a gasit niciun element in M3, atunci afisam multimea vida
	cmp nr_elem_3, 0
	jne continua
	push offset mesaj_multime_vida
	call printf
	add esp, 4
	jmp final_bucla_3
	
	continua:
	xor esi, esi  ;contor m3
	xor eax, eax 
	xor edx, edx
	
	;deschidem fisier
	push offset mode_write
    push offset file
    call fopen
    add ESP, 8
	mov edi, eax
    ;scriem datele de intrare in fisier
    push offset mesaj_introducere
	push edi
	call fprintf
	add esp, 8

	push offset mesaj_op_3
	push edi
	call fprintf
	add esp, 8
	
	push offset mesaj_multimef
	push edi
	call fprintf
	add esp, 8
	
	xor esi, esi
	xor edx, edx
	;scriem multimea1 in fisier
	vector_3:
	xor eax, eax
	xor edx, edx
	mov al, m_1[esi]
	mov aux, eax
	push aux
	push offset format_d
	push edi
	call fprintf
	add esp, 12
	push offset space
	push edi
	call fprintf
	add esp, 8
	inc esi
	inc count
	mov dl, count
	cmp nr_elem_1, dl
	jne vector_3

    xor esi, esi
	xor edx, edx
    mov count, dl
    push offset mesaj_multimef
	push edi
	call fprintf
	add esp, 8
	;scriem multimea2 in fisier
	vector_3_1:
	xor eax, eax
	xor edx, edx
	mov al, m_2[esi]
	mov aux, eax
	push aux
	push offset format_d
	push edi
	call fprintf
	add esp, 12
	push offset space
	push edi
	call fprintf
	add esp, 8
	inc esi
	inc count
	mov dl, count
	cmp nr_elem_2, dl
	jne vector_3_1

	push offset mesaj_m3
	push edi
	call fprintf
	add esp, 8

    xor esi,esi
    xor eax, eax
	bucla_3:
	xor edx, edx
	mov dl, m_3[esi]
	mov var_m3, edx
	push var_m3
	push offset format_m3
	call printf
	add esp, 8
	;scriem si in fisier
	push var_m3
	push offset format_m3
	push edi
	call fprintf
	add esp, 12
	
	inc esi
    inc var_m3_1
	mov al, var_m3_1
	cmp nr_elem_3, al
    je final_bucla_3	
	jmp bucla_3
	
	
	final_bucla_3:
	push offset mesaj_fisier_rezultat
	call printf
	add esp, 4
	
	;inchidem fisier
	push edi
    call fclose
    add ESP, 4
	
	jmp final
		
produs:
    ; citim multimile, ca la diferenta:
	
	;citim nr de elemente ale multimii_1
	push offset mesaj_nr_elemente_1
	call printf
	add esp, 4
	push offset nr_elem_1
	push offset format_d
	call scanf
	add esp, 8
	
	push offset mesaj_multime_1
	call printf
	add esp, 4
	
	;initializam registrii
	xor ecx, ecx
	xor eax, eax ; in al numar cate elemente am de citit
	xor ebx, ebx ; in bl punem elementul citit pentru a fi transferat in vector
	xor esi,esi 
	xor edx, edx
	
	citire_multime_p_1:
	push offset elem1
	push offset format_d
	call scanf
	add esp, 8
	
	mov bl, elem1
	mov m_1[esi], bl
	
	inc esi
	inc var_citire  ;pt a afla cand se termina citirea elementelor
	mov al, var_citire
	cmp al, nr_elem_1
	jl citire_multime_p_1

	
	;citim nr de elemente ale multimii_2
	push offset mesaj_nr_elemente_2
	call printf
	add esp, 4
	push offset nr_elem_2
	push offset format_d
	call scanf
	add esp, 8
	
	push offset mesaj_multime_2
	call printf
	add esp, 4
	
	;initializam registrii
	xor ecx, ecx
	xor eax, eax ; in al numar cate elemente am de citit
	xor ebx, ebx ; in bl punem elementul citit pentru a fi transferat in vector
	xor esi,esi 
	xor edx, edx
	;reinitializam var_citire
	mov var_citire, 0
	
	citire_multime_p_2:
	push offset elem2
	push offset format_m1
	call scanf
	add esp, 8
	
	mov bl, elem2
	mov m_2[esi], bl
	
	inc esi
	inc var_citire  ;pt a afla cand se termina citirea elementelor
	mov al, var_citire
	cmp al, nr_elem_2
	jl citire_multime_p_2
    
    ;scriem in fisier
    ;deschidem fisier
	push offset mode_write
    push offset file
    call fopen
    add ESP, 8
	mov edi, eax
    mov retine_eax, eax
    ;scriem datele de intrare in fisier
    push offset mesaj_introducere
	push edi
	call fprintf
	add esp, 8

	push offset mesaj_op_4
	push edi
	call fprintf
	add esp, 8
	
	push offset mesaj_multimef
	push edi
	call fprintf
	add esp, 8
	
	xor esi, esi
	xor edx, edx
	;scriem multimea1 in fisier
	vector_4:
	xor eax, eax
	xor edx, edx
	mov al, m_1[esi]
	mov aux, eax
	push aux
	push offset format_d
	push edi
	call fprintf
	add esp, 12
	push offset space
	push edi
	call fprintf
	add esp, 8
	inc esi
	inc count
	mov dl, count
	cmp nr_elem_1, dl
	jne vector_4

    xor esi, esi
	xor edx, edx
    mov count, dl
    push offset mesaj_multimef
	push edi
	call fprintf
	add esp, 8
	;scriem multimea2 in fisier
	vector_4_1:
	xor eax, eax
	xor edx, edx
	mov al, m_2[esi]
	mov aux, eax
	push aux
	push offset format_d
	push edi
	call fprintf
	add esp, 12
	push offset space
	push edi
	call fprintf
	add esp, 8
	inc esi
	inc count
	mov dl, count
	cmp nr_elem_2, dl
	jne vector_4_1
    

    push offset mesaj_rezultat
	push edi
	call fprintf
	add esp, 8


	push offset mesaj_rezultat
	call printf
	add esp, 4
    ;imperechem fiecare element al primei multimi cu fiecare din a doua folosind doua bucle
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx 
	xor esi, esi ;contor m_1
	xor edi, edi ;contor m_2
	bucla_1_p:
	xor eax, eax
	mov al, m_1[esi]
	mov elem_1, eax
	xor edi, edi
	mov var_m2_p, 0
	  bucla_2_p:
	  xor ebx, ebx
	  mov bl, m_2[edi]
	  mov elem_2, ebx
	  ;afisam elementele, doua cate doua
	  push elem_2
	  push elem_1
	  push offset format_produs
	  call printf
	  add esp, 12
      ;la fel si in fisier
      mov retine_edi, edi
      mov edi, retine_eax
      push elem_2
	  push elem_1
	  push offset format_produs
      push edi
	  call fprintf
	  add esp, 16
      mov edi, retine_edi
      
	   
	  inc edi
	  inc var_m2_p       ;pt a determina cand se termina bucla2
	  mov bl, var_m2_p
	  cmp bl, nr_elem_2
	  je bucla_1_f_p
	  jmp bucla_2_p
	      
	bucla_1_f_p:
	inc esi
	inc var_m1_p        ;pt a determina cand se termina bucla1
	mov dl, var_m1_p
	cmp dl, nr_elem_1
	je final_bucla_1_p
	jmp bucla_1_p
	
	final_bucla_1_p:
	push offset mesaj_fisier_rezultat
	call printf
	add esp, 4

    mov edi, retine_eax
    push edi
    call fclose
    add ESP, 4

	
	jmp final
	
    final:
	
	push 0
	call exit
end start