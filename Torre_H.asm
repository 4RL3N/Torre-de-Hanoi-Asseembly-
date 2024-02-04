section .data ;lida com os dados na mem?ria principal
   
    mensagem_inicial db 'Digite a quantidade de discos: ', 0xa
    len_mensagem equ $ - mensagem_inicial
    
    exibir1 db 'Algoritmo da Torre de Hanoi com "'
    len_exb1 equ $ - exibir1
    
    exibir2 db '" discos', 0xa
    len_exb2 equ $ - exibir2
    
    inv db 'Caracter invalido!', 0xa
    len_inv equ $ - inv

    mensagem_final:
                          db "Mova o disco "                      
        n_disco:          db " "
                          db " da torre "
        torre_origem:     db " "
                          db " para a torre "     
        torre_destino:    db " ", 0xa
    len_f equ $ - mensagem_final
        
    concluido db 'Concluido!', 0xa
    len_c equ $ - concluido

section .bss
    n resb 5 ;reserva o espaco na memoria para o numero que o usuario vai digitar

section .text ;instrucoes
    global _start ;declarar como global serve para que a funcao fique visivel fora do arquivo "principal"
    global str_to_int ;aqui no caso declarar como global ou n?o n?o afetaria o programa
    global torre_hanoi ;pois ele ? um arquivo apenas
    global fim
    global imprime

_start:                                                         
    push ebp                        
    mov ebp, esp                    

    ;Solicita o n?mero ao usu?rio
    mov eax, 4 ;padrao para escrever na tela
    mov ebx, 1  ;"          "
    mov ecx, mensagem_inicial ;mensagem para escrever na tela
    mov edx, len_mensagem ;tamanho da mensagem
    int 0x80 ;chama o kernel

    ;Ler o n?mero do usu?rio
    mov eax, 3
    mov ebx, 0
    mov ecx, n
    mov edx, 8
    int 0x80
    
    ;escreve a mensagem "torre de hanoi com n discos"
    mov eax, 4
    mov ebx, 1
    mov ecx, exibir1
    mov edx, len_exb1
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, n
    mov edx, 2
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, exibir2
    mov edx, len_exb2
    int 0x80
    
    mov edx, n                  
    call str_para_int
    
    ;3 pilhas
    push dword 18 ;torre auxiliar, o valor ? o endereco da pilha
    push dword 19 ;torre destino
    push dword 17 ;torre de origem
    push eax ;eax na pilha

    call torre_hanoi
    
    ;imprime a mensagem "concluido!"
    mov eax, 4
    mov ebx, 1
    mov ecx, concluido
    mov edx, len_c
    int 0x80

    ;finaliza o programa
    mov eax, 1                      
    mov ebx, 0                      
    int 0x80                        

str_para_int:
    xor eax, eax ;limpando o registrador eax
    mov ebx, 10
    
    .loop:
        movzx ecx, byte [edx]
        inc edx
        cmp ecx, '0'
        jb .done ;se for menor, va para .done
        cmp ecx, '9'
        ja .done ;caso for maior, va para .done
        
        sub ecx, '0' ;subtrai a "string" de "zero", ir? "transformar em int"
        imul eax, ebx ;multiplica por EBX
        add eax, ecx
        jmp .loop
    
    .done:
        test eax, eax
        jz invalido
        ret

invalido:
    mov eax, 4
    mov ebx, 1
    mov ecx, inv
    mov edx, len_inv
    int 0x80
    
    jmp _start

torre_hanoi:
    push ebp ;salva o registrador ebp na pilha
    mov ebp,esp ;ebp recebe o endere?o do topo da pilha

    mov eax,[ebp+8] ;pega o a posi??o do primeiro elemento
    cmp eax, 0
    jle fim ;caso eax for menor ou igual a 0, vai para o fim
    
    dec eax
    push dword [ebp+16] ;coloca na pilha a torre auxiliar
    push dword [ebp+20] ;coloca na pilha a torre destino
    push dword [ebp+12] ;coloca na pilha a torre de origem
    push dword eax ;poe eax na pilha
    call torre_hanoi

    add esp,12 ;libera 12 bits de espa?o
    push dword [ebp+16] ;pega o pino de origem referenciado pelo par?metro ebp+16
    push dword [ebp+12] ;coloca na pilha o pino de origem
    push dword [ebp+8] ;coloca na pilha o numero de disco inicial
    call imprime

    add esp,12 ;libera mais 12 bits de espa?o
    push dword [ebp+12] ;coloca na pilha a torre origem
    push dword [ebp+16] ;coloca na pilha a torre auxiliar
    push dword [ebp+20] ;coloca na pilha a torre destino
    mov eax,[ebp+8] ;coloca no registrador o espa?o do n?mero de discos atuais
    dec eax

    push dword eax ;poe eax na pilha
    call torre_hanoi

fim:
    mov esp, ebp
    pop ebp ;desempilha
    ret ;retorna

imprime:
    push ebp ;empilha
    mov ebp, esp ;recebe o endereco do topo da pilha
    
    mov eax, [ebp + 8] ;exibindo qual disco estamos movendo
    add al, '0' ;convertendo para ASCII
    mov [n_disco], al
    
    mov eax, [ebp + 12] ;torre de origem
    add al, '0' 
    mov [torre_origem], al ;movendo o disco de al para torre de origem
    
    mov eax, [ebp + 16] ;torre de destino
    add al, '0'
    mov [torre_destino], al ;movendo o disco de al para a torre de destino
    
    ;mostrando a mensagem "mova o disco n..."
    mov eax, 4
    mov ebx, 1
    mov ecx, mensagem_final
    mov edx, len_f
    int 0x80 ;chama o kernel do linux

    mov esp, ebp
    pop ebp ;pega o valor do topo da pilha e coloca em EBP
    ret ;retorna