section .data

ld_epsilon: db "%ls%ls%lf",0
ld_order: db "%ls%ls%ld",0
ld_coeff_word:db "%s",0
ld_coeff_first_part: db "%ld%ls",0
ld_coeff_second_part: db "%lf%lf",0
ld_init: db "%ls%ls%lf%lf",0
print_decimal: db "%ld",10,0
print_float: db "%.40lf",10,0
ld_float: db "%lf",0
print_result: db "root = %.40lf %.40e",10,0
coeffw: db "coeff",0
ld_init1: db  "%ls%lf%lf",0

section .bss

epsilon: resq 1
order: resq 1
func_re_arr: resq 1
func_im_arr: resq 1
derive_re_arr: resq 1
derive_im_arr: resq 1
init_re: resq 1
init_im: resq 1
delimiter: resq 1
wrd: resb 1
idx: resq 1
working_re1: resq 1
working_im1: resq 1
working_re2: resq 1
working_im2: resq 1
working_re3: resq 1
working_im3: resq 1
re_ans: resq 1
im_ans: resq 1
eval1_re: resq 1
eval1_im: resq 1
eval2_re: resq 1
eval2_im: resq 1
power: resq 1
x0: resq 1
flg: resb 1

extern scanf
extern printf
extern malloc
extern free

global main
global comapareword
section .text
main:
    nop
    enter 0, 0
    
    ;ld epsilon
    mov rdi, ld_epsilon
    mov rsi, delimiter
    mov rdx, delimiter
    mov rcx, epsilon
    mov rax, 0
    call scanf
    ;ld order
    mov rdi, ld_order; 
    mov rsi, delimiter
    mov rdx, delimiter
    mov rcx, order
    mov rax, 0
    call scanf
    inc qword[order] ; n+1 items
    ;initialize re array
    mov rdi, qword[order]
    imul rdi, 8
    call malloc
    mov qword[func_re_arr], rax
    ;initialize im array
    mov rdi, qword[order]
    imul rdi, 8
    call malloc
    mov qword[func_im_arr], rax
    ;ld coeff's
    mov rcx, qword[order]
    mov rbx, 0
    jmp check_test0
    init0:
        push rcx
        push rbx
        mov rdi, ld_coeff_word
        mov rsi, wrd
        mov rax, 0
        call scanf
        call comapareword
        mov al ,byte[flg]
        cmp rax,0
        ja keep
        mov rbx,rcx
        jmp check_test0
      keep:  
        mov rdi, ld_coeff_first_part
        mov rsi, idx
        mov rdx, delimiter
        mov rax, 0
        call scanf
        pop rbx
        pop rcx
        mov rdi, ld_coeff_second_part
        mov rsi, qword[func_re_arr]
        mov rax, qword[idx] ; rax = 8*idx
        imul rax, 8
        add rsi, rax
        mov rdx, qword[func_im_arr]
        mov rax, qword[idx] ; rax = 8*idx
        imul rax, 8
        add rdx, rax
        mov rax, 0
        push rcx
        push rbx
        call scanf
        pop rbx
        pop rcx
        
        inc rbx
        check_test0:
        cmp rbx, rcx
        jl init0
        
    ;ld initial
    mov al,byte[flg]
    cmp rax,0
    je dontreadinit
    mov rdi, ld_init
    mov rsi, delimiter
    mov rdx, delimiter
    mov rcx, init_re
    mov r8, init_im
    mov rax, 0
    call scanf
    jmp con
    dontreadinit:
    mov rdi, ld_init1
    mov rsi, delimiter
    mov rdx, init_re
    mov rcx, init_im
    mov rax, 2
    call scanf
    ;get the derive of the function *start*
    ; initialize power and working_im2 to 0
    con:
    finit
    fldz
    fst qword[power]
    fstp qword[working_im2]
    ;create a derive arrays (one for re's and other for im's)
    mov rdi, qword[order]
    dec rdi ; the derive of the polynom is of size n (since we increased the order val to be n+1)
    imul rdi, 8
    call malloc
    mov qword[derive_re_arr], rax
    ;
    mov rdi, qword[order]
    dec rdi ; the derive of the polynom is of size n (since we increased the order val to be n+1)
    imul rdi, 8
    call malloc
    mov qword[derive_im_arr], rax
    
    mov rcx, qword[order]
    mov rbx, 0 ;derive index
    mov rdx, 1 ; function index
    jmp check_test1
    init1:
        mov rax, 8
        imul rax, rdx
        
        mov rdi, qword[func_re_arr]
        add rdi, rax 
        mov rsi, qword[rdi]
        mov qword[working_re1], rsi ; fetch next function element (re)
        
        mov rdi, qword[func_im_arr]
        add rdi, rax 
        mov rsi, qword[rdi]
        mov qword[working_im1], rsi ; fetch next function element (im)
        
        finit
        fld qword[power]
        fld1
        fadd
        fstp qword[power]
        
        mov rax, qword[power]
        mov qword[working_re2], rax ; ld working num2 with the current power 
        
        call _mul_cplx
        
        mov rax, 8
        imul rax, rbx
        
        mov rdi, qword[derive_re_arr]
        add rdi, rax
        mov rsi, qword[re_ans]
        mov qword[rdi], rsi
        
        mov rdi, qword[derive_im_arr]
        add rdi, rax
        mov rsi, qword[im_ans]
        mov qword[rdi], rsi
        
        inc rbx
        inc rdx
    
        check_test1:
        cmp rdx, rcx
        jl init1
    ;get the derive of the function *end*
        
    ;calc root *start*
    jmp check_test2
    init2:
        ;eval1 = evaluate(func, init)
        mov rax, qword[init_re]
        mov qword[working_re1], rax
        mov rax, qword[init_im]
        mov qword[working_im1], rax
        call _evaluate_func
        mov rax, qword[re_ans]
        mov qword[eval1_re], rax
        mov rax, qword[im_ans]
        mov qword[eval1_im], rax
        ;eval2 = evaluate(derive, init)
        mov rax, qword[init_re]
        mov qword[working_re1], rax
        mov rax, qword[init_im]
        mov qword[working_im1], rax
        call _evaluate_derive
        mov rax, qword[re_ans]
        mov qword[eval2_re], rax
        mov rax, qword[im_ans]
        mov qword[eval2_im], rax
        ;num1 <= eval1
        mov rax, qword[eval1_re]
        mov qword[working_re1], rax
        mov rax, qword[eval1_im]
        mov qword[working_im1], rax
        ;num2 <= eval2
        mov rax, qword[eval2_re]
        mov qword[working_re2], rax
        mov rax, qword[eval2_im]
        mov qword[working_im2], rax
        ;y = div_cplx(eval1, eval2);
        call _div_cplx
        ;num1 <= init
        mov rax, qword[init_re]
        mov qword[working_re1], rax
        mov rax, qword[init_im]
        mov qword[working_im1], rax
        ;num2 <= y
        mov rax, qword[re_ans]
        mov qword[working_re2], rax
        mov rax, qword[im_ans]
        mov qword[working_im2], rax
        ;init = sub_cplx(init, div);
        call _sub_cplx
        mov rax, qword[re_ans]
        mov qword[init_re], rax
        mov rax, qword[im_ans]
        mov qword[init_im], rax
    
        check_test2:
                ;num1 <= init
                mov rax, qword[init_re]
                mov qword[working_re1], rax
                mov rax, qword[init_im]
                mov qword[working_im1], rax
                call _evaluate_func
                
                finit         ; x = (init->re * init->re) + (init->im * init->im)
                              ; if( sqrt(x) < epsilon ){ return true; } else return false;
                fld qword[re_ans]
                fmul st0, st0
                fld qword[im_ans]
                fmul st0, st0
                fadd
                fsqrt
                fld qword[epsilon]
                fcomi; st0 = epsilon, st1 = sqrt(x)
                ja .finish
                jmp init2
        
    .finish:
    ;the root is the init
    
    mov rdi, print_result
    movsd xmm0, qword[init_re]
    movsd xmm1, qword[init_im]
    mov rax, 2
    call printf
    
    ;calc root *end*
    
    ;free allocated memory
    mov rdi, qword[func_re_arr]
    call free
    mov rdi, qword[func_im_arr]
    call free
    mov rdi, qword[derive_re_arr]
    call free
    mov rdi, qword[derive_im_arr]
    call free
    
    leave

_evaluate_func: ; assumes x0 is in working num1
    nop
    enter 0, 0
    
    finit
    fldz
    fst qword[working_re2]
    fstp qword[working_im2]
    
    mov rbx, qword[order]
    dec rbx
    jmp check_test4
    init4: ; we iterate in a reverse order (from msb to lsb)
        mov rax, 8
        imul rax, rbx
        mov rdi, qword[func_re_arr]
        add rdi, rax
        mov rsi, qword[rdi]
        mov qword[working_re3], rsi
        
        mov rdi, qword[func_im_arr]
        add rdi, rax
        mov rsi, qword[rdi]
        mov qword[working_im3], rsi
        
        push qword[working_re1]
        push qword[working_im1]
        
        call _ABc_cplx
        
        pop qword[working_im1]
        pop qword[working_re1]
        
        mov rax, qword[re_ans]
        mov qword[working_re2], rax
        mov rax, qword[im_ans]
        mov qword[working_im2], rax
        
        dec rbx
        check_test4:
        cmp rbx, 0
        jge init4
    
    leave
    ret
    
_evaluate_derive: ; assumes x0 is in working num1
    nop
    enter 0, 0
    
    finit
    fldz
    fst qword[working_re2]
    fstp qword[working_im2]
    
    mov rbx, qword[order]
    sub rbx, 2
    jmp check_test5
    init5: ; we iterate in a reverse order (from msb to lsb)
        mov rax, 8
        imul rax, rbx
        mov rdi, qword[derive_re_arr]
        add rdi, rax
        mov rsi, qword[rdi]
        mov qword[working_re3], rsi
        
        mov rdi, qword[derive_im_arr]
        add rdi, rax
        mov rsi, qword[rdi]
        mov qword[working_im3], rsi
        
        push qword[working_re1]
        push qword[working_im1]
        
        call _ABc_cplx
        
        pop qword[working_im1]
        pop qword[working_re1]
        
        mov rax, qword[re_ans]
        mov qword[working_re2], rax
        mov rax, qword[im_ans]
        mov qword[working_im2], rax
        
        dec rbx
        check_test5:
        cmp rbx, 0
        jge init5
    
    leave
    ret
    
    
_ABc_cplx:
    
    nop
    enter 0, 0
    
    call _mul_cplx
    ;move num1 <- res
    mov rax, qword[re_ans]
    mov qword[working_re1], rax
    mov rax, qword[im_ans]
    mov qword[working_im1], rax
    ;move num2 <- num3
    mov rax, qword[working_re3]
    mov qword[working_re2], rax
    mov rax, qword[working_im3]
    mov qword[working_im2], rax
    call _add_cplx
    
    leave
    ret
    
_add_cplx:;(a+bi)+(c+di)= (a+c)+(b+d)i
    nop
    enter 0, 0  ; prepare a frame

    finit
    fld qword[working_re1]
    fld qword[working_re2]
    fadd
    fstp qword[re_ans]
    
    fld qword[working_im1]
    fld qword[working_im2]
    fadd
    fstp qword[im_ans]
    

    leave       ; dump the top frame
    ret         ; return from main
    
_sub_cplx:;(a+bi)-(c+di)= (a-c)+(b-d)i
    nop
    enter 0, 0  ; prepare a frame

    finit
    fld qword[working_re1]
    fld qword[working_re2]
    fsub
    fstp qword[re_ans]
    
    fld qword[working_im1]
    fld qword[working_im2]
    fsub
    fstp qword[im_ans]
    

    leave       ; dump the top frame
    ret         ; return from main
    
_mul_cplx:;(a+bi)*(c+di)= (ac-bd)+(ad+bc)i
    nop
    enter 0, 0  ; prepare a frame

    finit
    fld qword[working_re1]
    fld qword[working_re2]
    fmul ;ac
    fld qword[working_im1]
    fld qword[working_im2]
    fmul ;bd
    fsub ; ac-bd
    fstp qword[re_ans]
    
    fld qword[working_re1]
    fld qword[working_im2]
    fmul ;ad
    fld qword[working_im1]
    fld qword[working_re2]
    fmul ;bc
    fadd ; ad+bc
    fstp qword[im_ans]
    
    leave       ; dump the top frame
    ret         ; return from main
    
_div_cplx:;(a+bi)/(c+di) = [(ac+bd)/(cc+dd)] + [(bc-ad)/(cc+dd)]i
    nop
    enter 0, 0  ; prepare a frame

    finit
    fld qword[working_re1]
    fld qword[working_re2]
    fmul ;ac
    fld qword[working_im1]
    fld qword[working_im2]
    fmul ;bd
    fadd ; ac+bd
    fld qword[working_re2]
    fmul st0, st0 ;cc
    fld qword[working_im2]
    fmul st0, st0 ;dd
    fadd ;cc+dd
    fdiv ; (ac+bd)/(cc+dd)
    fstp qword[re_ans]
    
    fld qword[working_im1]
    fld qword[working_re2]
    fmul ;bc
    fld qword[working_re1]
    fld qword[working_im2]
    fmul ;ad
    fsub ; bc-ad
    fld qword[working_re2]
    fmul st0, st0 ;cc
    fld qword[working_im2]
    fmul st0, st0 ;dd
    fadd ;cc+dd
    fdiv ; (bc-ad)/(cc+dd)
    fstp qword[im_ans]
    
    leave       ; dump the top frame
    ret         ; return from main
comapareword:
            enter 0,0
            ;mov rsi,"wrd :%ls"
            ;mov rdi ,wrd
            ;mov rax, 0
            ;call printf
            mov rsi,wrd
            mov rdi,coeffw
            push rcx
            push rbx
            push rdx
            mov rax,0
            mov byte[flg],al
            mov rcx, 6
            work:
                mov bl,byte[rsi]
                mov dl, byte[rdi]
                dec rcx
                inc rsi
                inc rdi
                cmp bl,dl
                jne cont
                cmp rcx,0
                ja work
                mov byte[flg],1
                cont:
                    pop rdx
                    pop rbx
                    pop rcx
                    leave
             
            
            
            
            
            
            