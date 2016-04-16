;程序员       : enjoy5512
;最后修改时间 : 2016年4月16日 16:27:23
;程序说明     : 本程序用于接受用户输入的两个八位无符号数据,输出两个的数据的和

 
assume cs:code, ds:stack, ss:stack, es:stack

;数据段,堆栈用同一个栈基址,方便后面的输出
stack segment stack
    str1 db "please input the fisrt num   a  : $"
    str2 db "please input thr second num  b  : $"
    str3 db "a + b = $"
    str4 db "just support 8bit Num(below 255): $"
    db 512 dup(0)
stack ends

code segment
begin:
    mov ax,stack
    mov ds,ax
    mov ss,ax
    mov es,ax                   ;准备好代码段基址,堆栈段基址,附加数据段基址
    
main:
    push bp
    mov bp,sp
    sub sp,10h   
    lea di,[bp-10h]
    mov cx,8h
    mov ax,0cccch
    rep stosw                  ;主程序申请10个字节的数据空间并初始化为cc(int 3)
    
    mov byte ptr [bp-1],0      ;初始化三个一个字节的变量,用于存储输入的两个数据和两个数据的和
    mov byte ptr [bp-2],0
    mov byte ptr [bp-3],0
    
    lea dx,str1                ;输出提示字符
    mov ah,9h
    int 21h
    
    lea dx,[bp-1]              ;输入一个数据,输入参数为变量的地址
    push dx
    call InputNum
    
    mov ah,2h                  ;换行
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    
    lea dx,str2                ;;输出第二个提示符
    mov ah,9h
    int 21h
    
    lea bx,[bp-2]              ;;输入第二个数据
    push bx
    call InputNum
    
    mov ah,2h                  ;;换行
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    
    mov al,[bp-1]              ;计算两个数据的和,输入参数为两个数据的值
    mov ah,0
    push ax
    mov dl,[bp-2]
    mov dh,0
    push dx
    call sum
    mov [bp-3],al              ;;将结果保存
    
    lea dx,str3                ;;第三个提示符
    mov ah,9h
    int 21h
    
    mov ax,0                   ;输出数据,输入参数为需要输出的数据的值
    mov al,[bp-3]
    push ax
    call OutputNum
    
    mov ah,2                   ;换行
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    
    mov ax,4c00h               ;结束程序
    int 21h
    
;函数说明:
;       这个函数用于求两个数据的和,结果保存在al中
;输入参数:
;       从后面开始将两个数据的值压栈
;输出参数:
;       al : 保存两个数据的和
sum proc
    push bp
    mov bp,sp
    sub sp,10h
    push di
    
    lea di,[bp-10h]         ;初始化堆栈
    mov ax,0cccch
    mov cx,8h
    rep stosw
    
    mov byte ptr [bp-1],0   ;申请一个变量保存两个数据的值
    
    mov ax,0
    mov dx,0
    mov al,[bp+4]           ;第一个参数
    mov dl,[bp+6]           ;第二个参数
    add ax,dx
    cmp ax,0ffh
    ja SumError
    mov [bp-1],al
    mov al,[bp-1]           ;将结果保存在al中
    
    pop di
    mov sp,bp
    pop bp
    ret
   
SumError:
    lea dx,str4
    mov ah,9h
    int 21h
    
    mov ah,2h
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    
    mov ax,4c00h
    int 21h
sum endp

;函数说明:
;       这个函数用于输入一个一字节的数
;输入参数:
;       要输入的变量地址
;输出参数:
;       无
InputNum proc
    push bp
    mov bp,sp
    sub sp,10h
    push di
    
    lea di,[bp-10h]             ;初始化栈
    mov ax,0cccch
    mov cx,8h
    rep stosw
    
    mov byte ptr [bp-1],0       ;保存最后结果
    mov byte ptr [bp-2],0       ;保存刚刚输入的值

    mov ax,0
InputLoop:
    mov ah,1
    int 21h
    cmp al,0dh                 ;循环接收输入,遇到回车结束
    jz InputExit
    cmp al,30h
    jb InputError
    cmp al,39h
    ja InputError
    sub al,30h
    mov ah,0
    mov [bp-2],al
    mov al,[bp-1]
    mov dl,0ah
    mul dl
    mov dh,0
    mov dl,[bp-2]
    add ax,dx             ;高位和低位合并
    cmp ax,0ffh
    ja InputError
    mov [bp-1],al             ;结果保存在第一个变量
    jmp InputLoop
    
InputExit:
    mov al,[bp-1]  
    mov bx,[bp+4]            ;将结果保存
    mov [bx],al
    pop di
    mov sp,bp
    pop bp
    ret
    
InputError:
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    
    lea dx,str4
    mov ah,9h
    int 21h
    
    mov ax,0
    mov byte ptr [bp-1],0   ;还原变量的值
    mov byte ptr [bp-2],0 
    jmp InputLoop           ;;提示出错,返回重新输入
InputNum endp

;函数说明:
;       这个函数用于输出一个字节
;输入参数:
;       需要输出的值
;输出参数:
;       无

OutputNum proc
    push bp
    mov bp,sp
    sub sp,10h
    push di
    
    lea di,[bp-10h]    ;;准备栈
    mov ax,0cccch
    mov cx,8h
    rep stosw
    mov al,[bp+4]
    mov [bp-1],al      ;将要输出的数据保存在局部变量里
    
    mov dx,0
    mov ax,0
Get3rdbit:             ;输出百位上的数字
    mov al,[bp-1]
    mov dl,64h
    div dl
    mov [bp-1],ah
    test al,al
    jz Get2ndbit       ;如果百位为0,则跳至十位数字的输出处
    mov dl,al
    add dl,30h
    mov ah,2h
    int 21h
    mov dh,1

Get2ndbit:    
    mov ah,0
    mov al,[bp-1]
    mov dl,0ah
    div dl
    mov [bp-1],ah     
    test dh,dh
    jnz Output2ndbit  ;如果百位不为0,则输出后面的数字
    test al,al        ;否则检查十位上的数字是否为0,如果是则什么也不做,否则输出十位上的数字
    jz Get1stbit
Output2ndbit:
    mov dl,al
    add dl,30h
    mov ah,2h
    int 21h

Get1stbit:    
    mov al,[bp-1]     ;输出个位上的数字
    mov dl,al
    add dl,30h
    mov ah,2h
    int 21h
    
    pop di
    mov sp,bp
    pop bp
    ret
OutputNum endp

code ends
end begin