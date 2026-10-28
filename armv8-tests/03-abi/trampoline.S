// AAPCS64 checking trampolines for Jasmin export functions.
//
// uint64_t abi_call(void *fn, uint64_t a0, uint64_t a1, uint64_t *status)
//   Loads magic values into every callee-saved register (x19-x29, d8-d15),
//   calls fn(a0, a1), and sets *status to a bit mask of the registers that
//   were not preserved (bit i-19 for x_i, bits 11-18 for d8-d15, bit 19 for
//   SP). Returns fn's result (x0).
//
// uint64_t abi_call_dirty32(void *fn, uint64_t a0, uint64_t a1)
//   Calls fn(a0, a1) after setting the upper 32 bits of x0 and x1 to
//   garbage: AAPCS64 leaves them unspecified for 32-bit arguments.
//
// void stack_snapshot(void *fn, uint64_t arg, uint64_t depth, uint64_t *out)
//   Fills `depth` bytes below the current SP with 0xAA, calls fn(arg), and
//   copies that area (what fn left on the stack) to out[0 .. depth/8).

        .text

        .global abi_call
        .type   abi_call, %function
abi_call:
        stp     x29, x30, [sp, #-176]!
        stp     x19, x20, [sp, #16]
        stp     x21, x22, [sp, #32]
        stp     x23, x24, [sp, #48]
        stp     x25, x26, [sp, #64]
        stp     x27, x28, [sp, #80]
        stp     d8,  d9,  [sp, #96]
        stp     d10, d11, [sp, #112]
        stp     d12, d13, [sp, #128]
        stp     d14, d15, [sp, #144]
        str     x3, [sp, #160]          // status pointer
        mov     x9, sp
        str     x9, [sp, #168]          // SP before the call

        mov     x16, x0                 // fn
        mov     x0, x1
        mov     x1, x2
        ldr     x19, =0x1919191919191919
        ldr     x20, =0x2020202020202020
        ldr     x21, =0x2121212121212121
        ldr     x22, =0x2222222222222222
        ldr     x23, =0x2323232323232323
        ldr     x24, =0x2424242424242424
        ldr     x25, =0x2525252525252525
        ldr     x26, =0x2626262626262626
        ldr     x27, =0x2727272727272727
        ldr     x28, =0x2828282828282828
        ldr     x29, =0x2929292929292929
        ldr     x9,  =0x0808080808080808
        fmov    d8, x9
        add     x9, x9, #1
        fmov    d9, x9
        add     x9, x9, #1
        fmov    d10, x9
        add     x9, x9, #1
        fmov    d11, x9
        add     x9, x9, #1
        fmov    d12, x9
        add     x9, x9, #1
        fmov    d13, x9
        add     x9, x9, #1
        fmov    d14, x9
        add     x9, x9, #1
        fmov    d15, x9

        blr     x16

        mov     x10, #0                 // status mask
        mov     x12, #0                 // bit index
        .macro  chk reg, magic
        ldr     x11, =\magic
        cmp     \reg, x11
        cset    x13, ne
        lsl     x13, x13, x12
        orr     x10, x10, x13
        add     x12, x12, #1
        .endm
        chk     x19, 0x1919191919191919
        chk     x20, 0x2020202020202020
        chk     x21, 0x2121212121212121
        chk     x22, 0x2222222222222222
        chk     x23, 0x2323232323232323
        chk     x24, 0x2424242424242424
        chk     x25, 0x2525252525252525
        chk     x26, 0x2626262626262626
        chk     x27, 0x2727272727272727
        chk     x28, 0x2828282828282828
        chk     x29, 0x2929292929292929
        .macro  chkd dreg, magic
        fmov    x14, \dreg
        chk     x14, \magic
        .endm
        chkd    d8,  0x0808080808080808
        chkd    d9,  0x0808080808080809
        chkd    d10, 0x080808080808080a
        chkd    d11, 0x080808080808080b
        chkd    d12, 0x080808080808080c
        chkd    d13, 0x080808080808080d
        chkd    d14, 0x080808080808080e
        chkd    d15, 0x080808080808080f
        mov     x9, sp
        ldr     x11, [sp, #168]
        cmp     x9, x11
        cset    x13, ne
        lsl     x13, x13, x12
        orr     x10, x10, x13

        ldr     x3, [sp, #160]
        str     x10, [x3]
        ldp     x19, x20, [sp, #16]
        ldp     x21, x22, [sp, #32]
        ldp     x23, x24, [sp, #48]
        ldp     x25, x26, [sp, #64]
        ldp     x27, x28, [sp, #80]
        ldp     d8,  d9,  [sp, #96]
        ldp     d10, d11, [sp, #112]
        ldp     d12, d13, [sp, #128]
        ldp     d14, d15, [sp, #144]
        ldp     x29, x30, [sp], #176
        ret
        .ltorg
        .size   abi_call, .-abi_call

        .global abi_call_dirty32
        .type   abi_call_dirty32, %function
abi_call_dirty32:
        stp     x29, x30, [sp, #-16]!
        mov     x16, x0
        mov     w0, w1                  // clears the upper half ...
        mov     w1, w2
        ldr     x9, =0xdeadbeef00000000 // ... then fills it with garbage
        orr     x0, x0, x9
        ldr     x9, =0xcafebabe00000000
        orr     x1, x1, x9
        blr     x16
        ldp     x29, x30, [sp], #16
        ret
        .ltorg
        .size   abi_call_dirty32, .-abi_call_dirty32

        .global stack_snapshot
        .type   stack_snapshot, %function
stack_snapshot:
        stp     x29, x30, [sp, #-32]!
        stp     x19, x20, [sp, #16]
        mov     x19, x0                 // fn
        mov     x20, x2                 // depth (multiple of 8)
        mov     x29, x3                 // out
        mov     x0, x1                  // arg
        // fill [sp - depth, sp) with 0xAA
        ldr     x9, =0xaaaaaaaaaaaaaaaa
        mov     x10, sp
        sub     x11, x10, x20
1:      str     x9, [x11], #8
        cmp     x11, x10
        b.lo    1b
        blr     x19
        // copy [sp - depth, sp) to out
        mov     x10, sp
        sub     x11, x10, x20
2:      ldr     x12, [x11], #8
        str     x12, [x29], #8
        cmp     x11, x10
        b.lo    2b
        ldp     x19, x20, [sp, #16]
        ldp     x29, x30, [sp], #32
        ret
        .ltorg
        .size   stack_snapshot, .-stack_snapshot

        .section .note.GNU-stack, "", %progbits
