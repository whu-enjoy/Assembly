;����Ա       : enjoy5512
;����޸�ʱ�� : 2016��4��16�� 16:27:23
;����˵��     : ���������ڽ����û������������λ�޷�������,������������ݵĺ�

 
assume cs:code, ds:stack, ss:stack, es:stack

;���ݶ�,��ջ��ͬһ��ջ��ַ,�����������
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
    mov es,ax                   ;׼���ô���λ�ַ,��ջ�λ�ַ,�������ݶλ�ַ
    
main:
    push bp
    mov bp,sp
    sub sp,10h   
    lea di,[bp-10h]
    mov cx,8h
    mov ax,0cccch
    rep stosw                  ;����������10���ֽڵ����ݿռ䲢��ʼ��Ϊcc(int 3)
    
    mov byte ptr [bp-1],0      ;��ʼ������һ���ֽڵı���,���ڴ洢������������ݺ��������ݵĺ�
    mov byte ptr [bp-2],0
    mov byte ptr [bp-3],0
    
    lea dx,str1                ;�����ʾ�ַ�
    mov ah,9h
    int 21h
    
    lea dx,[bp-1]              ;����һ������,�������Ϊ�����ĵ�ַ
    push dx
    call InputNum
    
    mov ah,2h                  ;����
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    
    lea dx,str2                ;;����ڶ�����ʾ��
    mov ah,9h
    int 21h
    
    lea bx,[bp-2]              ;;����ڶ�������
    push bx
    call InputNum
    
    mov ah,2h                  ;;����
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    
    mov al,[bp-1]              ;�����������ݵĺ�,�������Ϊ�������ݵ�ֵ
    mov ah,0
    push ax
    mov dl,[bp-2]
    mov dh,0
    push dx
    call sum
    mov [bp-3],al              ;;���������
    
    lea dx,str3                ;;��������ʾ��
    mov ah,9h
    int 21h
    
    mov ax,0                   ;�������,�������Ϊ��Ҫ��������ݵ�ֵ
    mov al,[bp-3]
    push ax
    call OutputNum
    
    mov ah,2                   ;����
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    
    mov ax,4c00h               ;��������
    int 21h
    
;����˵��:
;       ��������������������ݵĺ�,���������al��
;�������:
;       �Ӻ��濪ʼ���������ݵ�ֵѹջ
;�������:
;       al : �����������ݵĺ�
sum proc
    push bp
    mov bp,sp
    sub sp,10h
    push di
    
    lea di,[bp-10h]         ;��ʼ����ջ
    mov ax,0cccch
    mov cx,8h
    rep stosw
    
    mov byte ptr [bp-1],0   ;����һ�����������������ݵ�ֵ
    
    mov ax,0
    mov dx,0
    mov al,[bp+4]           ;��һ������
    mov dl,[bp+6]           ;�ڶ�������
    add ax,dx
    cmp ax,0ffh
    ja SumError
    mov [bp-1],al
    mov al,[bp-1]           ;�����������al��
    
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

;����˵��:
;       ���������������һ��һ�ֽڵ���
;�������:
;       Ҫ����ı�����ַ
;�������:
;       ��
InputNum proc
    push bp
    mov bp,sp
    sub sp,10h
    push di
    
    lea di,[bp-10h]             ;��ʼ��ջ
    mov ax,0cccch
    mov cx,8h
    rep stosw
    
    mov byte ptr [bp-1],0       ;���������
    mov byte ptr [bp-2],0       ;����ո������ֵ

    mov ax,0
InputLoop:
    mov ah,1
    int 21h
    cmp al,0dh                 ;ѭ����������,�����س�����
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
    add ax,dx             ;��λ�͵�λ�ϲ�
    cmp ax,0ffh
    ja InputError
    mov [bp-1],al             ;��������ڵ�һ������
    jmp InputLoop
    
InputExit:
    mov al,[bp-1]  
    mov bx,[bp+4]            ;���������
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
    mov byte ptr [bp-1],0   ;��ԭ������ֵ
    mov byte ptr [bp-2],0 
    jmp InputLoop           ;;��ʾ����,������������
InputNum endp

;����˵��:
;       ��������������һ���ֽ�
;�������:
;       ��Ҫ�����ֵ
;�������:
;       ��

OutputNum proc
    push bp
    mov bp,sp
    sub sp,10h
    push di
    
    lea di,[bp-10h]    ;;׼��ջ
    mov ax,0cccch
    mov cx,8h
    rep stosw
    mov al,[bp+4]
    mov [bp-1],al      ;��Ҫ��������ݱ����ھֲ�������
    
    mov dx,0
    mov ax,0
Get3rdbit:             ;�����λ�ϵ�����
    mov al,[bp-1]
    mov dl,64h
    div dl
    mov [bp-1],ah
    test al,al
    jz Get2ndbit       ;�����λΪ0,������ʮλ���ֵ������
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
    jnz Output2ndbit  ;�����λ��Ϊ0,��������������
    test al,al        ;������ʮλ�ϵ������Ƿ�Ϊ0,�������ʲôҲ����,�������ʮλ�ϵ�����
    jz Get1stbit
Output2ndbit:
    mov dl,al
    add dl,30h
    mov ah,2h
    int 21h

Get1stbit:    
    mov al,[bp-1]     ;�����λ�ϵ�����
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