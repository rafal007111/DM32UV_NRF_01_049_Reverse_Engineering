
; 0300c000 startup_entry
0300c000  2c 11  lrw r1,0x300c0b0
0300c002  01 c0 20 64  mtcr r1,cr<psr,0x0>
0300c006  ec 11  lrw r7,0x300c0b4
0300c008  9f 6f  mov sp,r7
0300c00a  ec 11  lrw r7,0x300c0b8
0300c00c  07 c0 21 64  mtcr r7,cr<vbr,0x0>
0300c010  88 ea 2b 00  lrw r8,0x300c0bc
0300c014  01 37  movi r7,0x1
0300c016  e8 dc 01 20  st.w r7,(r8,0x4)
0300c01a  04 37  movi r7,0x4
0300c01c  e8 dc 00 20  st.w r7,(r8,0x0)
0300c020  e8 11  lrw r7,0x300c0c0
0300c022  e8 dc 02 20  st.w r7,(r8,0x8)
0300c026  e8 d8 00 20  ld.w r7,(r8,0x0)
0300c02a  a0 3f  bseti r7,0x0
0300c02c  e8 dc 00 20  st.w r7,(r8,0x0)
0300c030  e5 11  lrw r7,0x300c0c4
0300c032  c6 11  lrw r6,0x300c0c8
0300c034  a6 11  lrw r5,0x300c0cc
0300c036  9c 65  cmphs r7,r6
0300c038  07 08  bt 0x0300c046
0300c03a  80 95  ld.w r4,(r5,0x0)
0300c03c  80 b7  st.w r4,(r7,0x0)
0300c03e  03 25  addi r5,0x4
0300c040  03 27  addi r7,0x4
0300c042  9c 65  cmphs r7,r6
0300c044  fb 0f  bf 0x0300c03a
0300c046  e3 11  lrw r7,0x300c0d0
0300c048  c3 11  lrw r6,0x300c0d4
0300c04a  a4 11  lrw r5,0x300c0d8
0300c04c  9c 65  cmphs r7,r6
0300c04e  07 08  bt 0x0300c05c
0300c050  80 95  ld.w r4,(r5,0x0)
0300c052  80 b7  st.w r4,(r7,0x0)
0300c054  03 25  addi r5,0x4
0300c056  03 27  addi r7,0x4
0300c058  9c 65  cmphs r7,r6
0300c05a  fb 0f  bf 0x0300c050
0300c05c  e0 11  lrw r7,0x300c0dc
0300c05e  c1 11  lrw r6,0x300c0e0
0300c060  9e 61  subu r6,r7
0300c062  c2 4e  lsri r6,r6,0x2
0300c064  40 3e  cmpnei r6,0x0
0300c066  07 0c  bf 0x0300c074
0300c068  00 35  movi r5,0x0
0300c06a  a0 b7  st.w r5,(r7,0x0)
0300c06c  03 27  addi r7,0x4
0300c06e  26 c4 86 10  decne r6,r6,0x1
0300c072  fc 0b  bt 0x0300c06a
0300c074  81 e2 80 10  bsr 0x0002e174
0300c078  00 00  bkpt
0300c07a  00 00  bkpt
0300c07c  3c 78  rts

; 0302e144 FUN_0302e144
0302e144  d1 14  push r4,lr
0302e146  84 ea 89 00  lrw r4,0x302e368
0302e14a  83 ea 89 00  lrw r3,0x302e36c
0302e14e  48 83  ld.b r2,(r3,0x8)
0302e150  22 c4 41 54  zext r1,r2,0x2,0x1
0302e154  70 84  ld.b r3,(r4,0x10)
0302e156  61 c4 21 5c  ins r3,r1,0x1,0x1
0302e15a  82 c4 e2 54  zext r2,r2,0x7,0x4
0302e15e  62 c4 23 5c  ins r3,r2,0x1,0x3
0302e162  70 a4  st.b r3,(r4,0x10)
0302e164  83 ea 83 00  lrw r3,0x302e370
0302e168  03 d8 29 00  ld.b r0,(r3,0x29)
0302e16c  23 d8 26 00  ld.b r1,(r3,0x26)
0302e170  01 e0 4e 42  bsr 0x0305660c
0302e174  04 dc 2c 10  st.h r0,(r4,0x58)
0302e178  91 14  pop r4,lr

; 0302e1a4 FUN_0302e1a4
0302e1a4  d7 14  push r4,r5,r6,r7,r8,r9,r10,lr
0302e1a6  32 14  subi sp,sp,0x48
0302e1a8  00 75  zextb r4,r0
0302e1aa  00 32  movi r2,0x0
0302e1ac  6f 13  lrw r3,0x302e368
0302e1ae  43 dc 5c 00  st.b r2,(r3,0x5c)
0302e1b2  24 e9 04 00  bnez r4,0x0302e1ba
0302e1b6  41 a3  st.b r2,(r3,0x1)
0302e1b8  c7 05  br 0x0302e546
0302e1ba  11 30  movi r0,0x11
0302e1bc  ff e3 ec 09  bsr 0x0300f594
0302e1c0  83 6d  mov r6,r0
0302e1c2  00 2c  subi r4,0x1
0302e1c4  63 44  lsli r3,r4 ,0x3
0302e1c6  71 5b  subu r3,r3,r4
0302e1c8  63 43  lsli r3,r3 ,0x3
0302e1ca  90 5b  addu r4,r3,r4
0302e1cc  11 75  zexth r4,r4
0302e1ce  24 e4 0b 00  addi r1,r4,0xc
0302e1d2  a9 13  lrw r5,0x302e374
0302e1d4  45 74  zexth r1,r1
0302e1d6  97 6c  mov r2,r5
0302e1d8  04 33  movi r3,0x4
0302e1da  ff e3 a1 0a  bsr 0x0300f71c
0302e1de  60 85  ld.b r3,(r5,0x0)
0302e1e0  01 2b  subi r3,0x2
0302e1e2  cc 74  zextb r3,r3
0302e1e4  0e 3b  cmphsi r3,0xf
0302e1e6  b0 09  bt 0x0302e546
0302e1e8  24 e4 0f 00  addi r1,r4,0x10
0302e1ec  e3 13  lrw r7,0x302e378
0302e1ee  1b 6c  mov r0,r6
0302e1f0  45 74  zexth r1,r1
0302e1f2  9f 6c  mov r2,r7
0302e1f4  07 33  movi r3,0x7
0302e1f6  ff e3 93 0a  bsr 0x0300f71c
0302e1fa  24 e4 18 00  addi r1,r4,0x19
0302e1fe  b7 5f  subi r5,r7,0x6
0302e200  61 85  ld.b r3,(r5,0x1)
0302e202  1b 6c  mov r0,r6
0302e204  45 74  zexth r1,r1
0302e206  47 e4 0f 00  addi r2,r7,0x10
0302e20a  61 43  lsli r3,r3 ,0x1
0302e20c  ff e3 88 0a  bsr 0x0300f71c
0302e210  65 d8 2a 10  ld.h r3,(r5,0x54)
0302e214  6b ad  st.h r3,(r5,0x16)
0302e216  62 85  ld.b r3,(r5,0x2)
0302e218  83 c4 e3 54  zext r3,r3,0x7,0x4
0302e21c  22 3b  cmplti r3,0x3
0302e21e  07 08  bt 0x0302e22c
0302e220  72 12  lrw r3,0x302e368
0302e222  42 83  ld.b r2,(r3,0x2)
0302e224  00 31  movi r1,0x0
0302e226  41 c4 64 5c  ins r2,r1,0x3,0x4
0302e22a  42 a3  st.b r2,(r3,0x2)
0302e22c  22 5c  addi r1,r4,0x1
0302e22e  b4 12  lrw r5,0x302e37c
0302e230  1b 6c  mov r0,r6
0302e232  45 74  zexth r1,r1
0302e234  97 6c  mov r2,r5
0302e236  0b 33  movi r3,0xb
0302e238  ff e3 72 0a  bsr 0x0300f71c
0302e23c  35 2d  subi r5,0x36
0302e23e  00 33  movi r3,0x0
0302e240  65 dc 41 00  st.b r3,(r5,0x41)
0302e244  65 dc 42 00  st.b r3,(r5,0x42)
0302e248  44 8d  ld.h r2,(r5,0x8)
0302e24a  fa 33  movi r3,0xfa
0302e24c  64 43  lsli r3,r3 ,0x4
0302e24e  8c 64  cmphs r3,r2
0302e250  0f 08  bt 0x0302e26e
0302e252  66 12  lrw r3,0x302e368
0302e254  64 83  ld.b r3,(r3,0x4)
0302e256  63 e4 0f 20  andi r3,r3,0xf
0302e25a  42 3b  cmpnei r3,0x2
0302e25c  09 08  bt 0x0302e26e
0302e25e  63 12  lrw r3,0x302e368
0302e260  44 83  ld.b r2,(r3,0x4)
0302e262  00 31  movi r1,0x0
0302e264  41 c4 60 5c  ins r2,r1,0x3,0x0
0302e268  41 c4 64 5c  ins r2,r1,0x3,0x4
0302e26c  44 a3  st.b r2,(r3,0x4)
0302e26e  00 32  movi r2,0x0
0302e270  09 1b  addi r3,sp,0x24
0302e272  40 ab  st.h r2,(r3,0x0)
0302e274  7d 11  lrw r3,0x302e368
0302e276  64 83  ld.b r3,(r3,0x4)
0302e278  63 e4 0f 20  andi r3,r3,0xf
0302e27c  41 3b  cmpnei r3,0x1
0302e27e  06 08  bt 0x0302e28a
0302e280  7a 11  lrw r3,0x302e368
0302e282  4b 8b  ld.h r2,(r3,0x16)
0302e284  09 1b  addi r3,sp,0x24
0302e286  40 ab  st.h r2,(r3,0x0)
0302e288  07 04  br 0x0302e296
0302e28a  42 3b  cmpnei r3,0x2
0302e28c  05 08  bt 0x0302e296
0302e28e  77 11  lrw r3,0x302e368
0302e290  44 8b  ld.h r2,(r3,0x8)
0302e292  09 1b  addi r3,sp,0x24
0302e294  40 ab  st.h r2,(r3,0x0)
0302e296  75 11  lrw r3,0x302e368
0302e298  64 83  ld.b r3,(r3,0x4)
0302e29a  63 e4 0f 20  andi r3,r3,0xf
0302e29e  63 e9 08 00  blsz r3,0x0302e2ae
0302e2a2  72 11  lrw r3,0x302e368
0302e2a4  43 d8 5c 00  ld.b r2,(r3,0x5c)
0302e2a8  00 22  addi r2,0x1
0302e2aa  43 dc 5c 00  st.b r2,(r3,0x5c)
0302e2ae  6f 11  lrw r3,0x302e368
0302e2b0  09 1a  addi r2,sp,0x24
0302e2b2  40 8a  ld.h r2,(r2,0x0)
0302e2b4  44 ab  st.h r2,(r3,0x8)
0302e2b6  64 83  ld.b r3,(r3,0x4)
0302e2b8  63 e4 0f 30  andni r3,r3,0xf
0302e2bc  cc 74  zextb r3,r3
0302e2be  50 3b  cmpnei r3,0x10
0302e2c0  06 08  bt 0x0302e2cc
0302e2c2  6a 11  lrw r3,0x302e368
0302e2c4  4b 8b  ld.h r2,(r3,0x16)
0302e2c6  09 1b  addi r3,sp,0x24
0302e2c8  40 ab  st.h r2,(r3,0x0)
0302e2ca  08 04  br 0x0302e2da
0302e2cc  43 eb 20 00  cmpnei r3,0x20
0302e2d0  05 08  bt 0x0302e2da
0302e2d2  66 11  lrw r3,0x302e368
0302e2d4  45 8b  ld.h r2,(r3,0xa)
0302e2d6  09 1b  addi r3,sp,0x24
0302e2d8  40 ab  st.h r2,(r3,0x0)
0302e2da  64 11  lrw r3,0x302e368
0302e2dc  64 83  ld.b r3,(r3,0x4)
0302e2de  83 c4 e3 54  zext r3,r3,0x7,0x4
0302e2e2  63 e9 08 00  blsz r3,0x0302e2f2
0302e2e6  61 11  lrw r3,0x302e368
0302e2e8  43 d8 5c 00  ld.b r2,(r3,0x5c)
0302e2ec  00 22  addi r2,0x1
0302e2ee  43 dc 5c 00  st.b r2,(r3,0x5c)
0302e2f2  7e 10  lrw r3,0x302e368
0302e2f4  09 1a  addi r2,sp,0x24
0302e2f6  40 8a  ld.h r2,(r2,0x0)
0302e2f8  45 ab  st.h r2,(r3,0xa)
0302e2fa  62 83  ld.b r3,(r3,0x2)
0302e2fc  63 e4 0f 30  andni r3,r3,0xf
0302e300  cc 74  zextb r3,r3
0302e302  43 eb 20 00  cmpnei r3,0x20
0302e306  3d 08  bt 0x0302e380
0302e308  f8 10  lrw r7,0x302e368
0302e30a  0e e5 01 00  addi r8,sp,0x2
0302e30e  03 8f  ld.h r0,(r7,0x6)
0302e310  63 6c  mov r1,r8
0302e312  bb 6c  mov r2,sp
0302e314  01 e0 14 3d  bsr 0x03055d3c
0302e318  08 d8 00 00  ld.b r0,(r8,0x0)
0302e31c  2e d8 00 10  ld.h r1,(sp,0x0)
0302e320  47 e4 41 00  addi r2,r7,0x42
0302e324  0b 33  movi r3,0xb
0302e326  ff e3 2d 0a  bsr 0x0300f780
0302e32a  03 8f  ld.h r0,(r7,0x6)
0302e32c  63 6c  mov r1,r8
0302e32e  bb 6c  mov r2,sp
0302e330  01 e0 ce 3c  bsr 0x03055ccc
0302e334  2e d8 00 10  ld.h r1,(sp,0x0)
0302e338  07 21  addi r1,0x8
0302e33a  ae e4 44 00  addi r5,sp,0x45
0302e33e  08 d8 00 00  ld.b r0,(r8,0x0)
0302e342  45 74  zexth r1,r1
0302e344  97 6c  mov r2,r5
0302e346  01 33  movi r3,0x1
0302e348  ff e3 1c 0a  bsr 0x0300f780
0302e34c  40 85  ld.b r2,(r5,0x0)
0302e34e  22 c4 41 54  zext r1,r2,0x2,0x1
0302e352  70 87  ld.b r3,(r7,0x10)
0302e354  61 c4 21 5c  ins r3,r1,0x1,0x1
0302e358  46 4a  lsri r2,r2,0x6
0302e35a  62 c4 23 5c  ins r3,r2,0x1,0x3
0302e35e  70 a7  st.b r3,(r7,0x10)
0302e360  63 8f  ld.h r3,(r7,0x6)
0302e362  67 dc 2c 10  st.h r3,(r7,0x58)
0302e366  2a 04  br 0x0302e3ba
0302e380  a4 13  lrw r5,0x302e510
0302e382  e5 13  lrw r7,0x302e514
0302e384  17 6c  mov r0,r5
0302e386  5f 6c  mov r1,r7
0302e388  11 32  movi r2,0x11
0302e38a  7f e2 d7 e7  bsr 0x0002b338
0302e38e  41 2d  subi r5,0x42
0302e390  1f 2f  subi r7,0x20
0302e392  48 87  ld.b r2,(r7,0x8)
0302e394  22 c4 41 54  zext r1,r2,0x2,0x1
0302e398  70 85  ld.b r3,(r5,0x10)
0302e39a  61 c4 21 5c  ins r3,r1,0x1,0x1
0302e39e  82 c4 e2 54  zext r2,r2,0x7,0x4
0302e3a2  62 c4 23 5c  ins r3,r2,0x1,0x3
0302e3a6  70 a5  st.b r3,(r5,0x10)
0302e3a8  7c 12  lrw r3,0x302e518
0302e3aa  03 d8 29 00  ld.b r0,(r3,0x29)
0302e3ae  23 d8 26 00  ld.b r1,(r3,0x26)
0302e3b2  01 e0 2d 41  bsr 0x0305660c
0302e3b6  05 dc 2c 10  st.h r0,(r5,0x58)
0302e3ba  00 32  movi r2,0x0
0302e3bc  78 12  lrw r3,0x302e51c
0302e3be  43 dc 4c 00  st.b r2,(r3,0x4c)
0302e3c2  24 e4 16 00  addi r1,r4,0x17
0302e3c6  1b 6c  mov r0,r6
0302e3c8  45 74  zexth r1,r1
0302e3ca  4e e4 45 00  addi r2,sp,0x46
0302e3ce  02 33  movi r3,0x2
0302e3d0  ff e3 a6 09  bsr 0x0300f71c
0302e3d4  73 12  lrw r3,0x302e520
0302e3d6  68 83  ld.b r3,(r3,0x8)
0302e3d8  63 e4 0f 30  andni r3,r3,0xf
0302e3dc  cc 74  zextb r3,r3
0302e3de  03 e9 08 00  bez r3,0x0302e3ee
0302e3e2  6e e4 45 00  addi r3,sp,0x46
0302e3e6  40 8b  ld.h r2,(r3,0x0)
0302e3e8  a0 3a  bseti r2,0x0
0302e3ea  40 ab  st.h r2,(r3,0x0)
0302e3ec  06 04  br 0x0302e3f8
0302e3ee  6e e4 45 00  addi r3,sp,0x46
0302e3f2  40 8b  ld.h r2,(r3,0x0)
0302e3f4  80 3a  bclri r2,0x0
0302e3f6  40 ab  st.h r2,(r3,0x0)
0302e3f8  69 12  lrw r3,0x302e51c
0302e3fa  83 d9 01 00  ld.b r12,(r3,0x1)
0302e3fe  0c e9 97 00  bez r12,0x0302e52c
0302e402  6e e4 45 00  addi r3,sp,0x46
0302e406  c0 8b  ld.h r6,(r3,0x0)
0302e408  65 12  lrw r3,0x302e51c
0302e40a  0b 8b  ld.h r0,(r3,0x16)
0302e40c  e4 8b  ld.h r7,(r3,0x8)
0302e40e  03 d9 05 10  ld.h r8,(r3,0xa)
0302e412  00 32  movi r2,0x0
0302e414  cb 6c  mov r3,r2
0302e416  4b 6f  mov r13,r2
0302e418  0b 6d  mov r4,r2
0302e41a  a1 12  lrw r5,0x302e51c
0302e41c  4e e5 03 00  addi r10,sp,0x4
0302e420  2e e5 23 00  addi r9,sp,0x24
0302e424  02 04  br 0x0302e428
0302e426  8f 6c  mov r2,r3
0302e428  66 c4 81 40  asr r1,r6,r3
0302e42c  21 e4 01 20  andi r1,r1,0x1
0302e430  01 e9 1f 00  bez r1,0x0302e46e
0302e434  23 e4 09 00  addi r1,r3,0xa
0302e438  24 59  addu r1,r1,r1
0302e43a  24 5d  addu r1,r5,r1
0302e43c  21 89  ld.h r1,(r1,0x2)
0302e43e  06 64  cmpne r1,r0
0302e440  0c 0c  bf 0x0302e458
0302e442  03 e9 0d 00  bez r3,0x0302e45c
0302e446  c6 65  cmpne r1,r7
0302e448  31 0c  bf 0x0302e4aa
0302e44a  06 66  cmpne r1,r8
0302e44c  2f 0c  bf 0x0302e4aa
0302e44e  89 d4 41 04  str.h r1,(r9,r4<<1)
0302e452  00 24  addi r4,0x1
0302e454  10 75  zextb r4,r4
0302e456  2a 04  br 0x0302e4aa
0302e458  23 e9 29 00  bnez r3,0x0302e4aa
0302e45c  c6 65  cmpne r1,r7
0302e45e  26 0c  bf 0x0302e4aa
0302e460  06 66  cmpne r1,r8
0302e462  24 0c  bf 0x0302e4aa
0302e464  89 d4 40 04  str.h r0,(r9,r4<<1)
0302e468  00 24  addi r4,0x1
0302e46a  10 75  zextb r4,r4
0302e46c  1f 04  br 0x0302e4aa
0302e46e  23 e4 09 00  addi r1,r3,0xa
0302e472  24 59  addu r1,r1,r1
0302e474  24 5d  addu r1,r5,r1
0302e476  21 89  ld.h r1,(r1,0x2)
0302e478  42 64  cmpne r0,r1
0302e47a  0d 0c  bf 0x0302e494
0302e47c  03 e9 0e 00  bez r3,0x0302e498
0302e480  5e 64  cmpne r7,r1
0302e482  14 0c  bf 0x0302e4aa
0302e484  62 64  cmpne r8,r1
0302e486  12 0c  bf 0x0302e4aa
0302e488  aa d5 41 04  str.h r1,(r10,r13<<1)
0302e48c  ad e5 00 00  addi r13,r13,0x1
0302e490  74 77  zextb r13,r13
0302e492  0c 04  br 0x0302e4aa
0302e494  23 e9 0b 00  bnez r3,0x0302e4aa
0302e498  5e 64  cmpne r7,r1
0302e49a  08 0c  bf 0x0302e4aa
0302e49c  62 64  cmpne r8,r1
0302e49e  06 0c  bf 0x0302e4aa
0302e4a0  aa d5 40 04  str.h r0,(r10,r13<<1)
0302e4a4  ad e5 00 00  addi r13,r13,0x1
0302e4a8  74 77  zextb r13,r13
0302e4aa  62 5a  addi r3,r2,0x1
0302e4ac  cc 74  zextb r3,r3
0302e4ae  0c 67  cmphs r3,r12
0302e4b0  bb 0f  bf 0x0302e426
0302e4b2  00 32  movi r2,0x0
0302e4b4  6e e4 44 00  addi r3,sp,0x45
0302e4b8  40 a3  st.b r2,(r3,0x0)
0302e4ba  0d e9 11 00  bez r13,0x0302e4dc
0302e4be  01 1b  addi r3,sp,0x4
0302e4c0  59 10  lrw r2,0x302e524
0302e4c2  0d e4 00 10  subi r0,r13,0x1
0302e4c6  00 74  zextb r0,r0
0302e4c8  2e e4 05 00  addi r1,sp,0x6
0302e4cc  01 c4 20 08  ixh r0,r1,r0
0302e4d0  20 8b  ld.h r1,(r3,0x0)
0302e4d2  20 aa  st.h r1,(r2,0x0)
0302e4d4  01 23  addi r3,0x2
0302e4d6  01 22  addi r2,0x2
0302e4d8  0e 64  cmpne r3,r0
0302e4da  fb 0b  bt 0x0302e4d0
0302e4dc  00 32  movi r2,0x0
0302e4de  6e e4 44 00  addi r3,sp,0x45
0302e4e2  40 a3  st.b r2,(r3,0x0)
0302e4e4  04 e9 27 00  bez r4,0x0302e532
0302e4e8  09 1b  addi r3,sp,0x24
0302e4ea  4d e4 09 00  addi r2,r13,0xa
0302e4ee  48 5a  addu r2,r2,r2
0302e4f0  2e 10  lrw r1,0x302e528
0302e4f2  44 5a  addu r2,r2,r1
0302e4f4  03 5c  subi r0,r4,0x1
0302e4f6  00 74  zextb r0,r0
0302e4f8  2e e4 25 00  addi r1,sp,0x26
0302e4fc  01 c4 20 08  ixh r0,r1,r0
0302e500  20 8b  ld.h r1,(r3,0x0)
0302e502  20 aa  st.h r1,(r2,0x0)
0302e504  01 23  addi r3,0x2
0302e506  01 22  addi r2,0x2
0302e508  0e 64  cmpne r3,r0
0302e50a  fb 0b  bt 0x0302e500
0302e50c  13 04  br 0x0302e532
0302e52c  0d ea 00 00  movi r13,0x0
0302e530  37 6d  mov r4,r13
0302e532  50 63  addu r13,r4
0302e534  74 77  zextb r13,r13
0302e536  64 13  lrw r3,0x302e6c4
0302e538  a3 dd 01 00  st.b r13,(r3,0x1)
0302e53c  43 d8 5c 00  ld.b r2,(r3,0x5c)
0302e540  48 63  addu r13,r2
0302e542  a3 dd 5c 00  st.b r13,(r3,0x5c)
0302e546  12 14  addi sp,sp,0x48
0302e548  97 14  pop r4,r5,r6,r7,r8,r9,r10,lr

; 0302edc8 FUN_0302edc8
0302edc8  d2 14  push r4,r5,lr
0302edca  ff e3 8b ff  bsr 0x0302ece0
0302edce  03 6d  mov r4,r0
0302edd0  73 12  lrw r3,0x302ef1c
0302edd2  60 83  ld.b r3,(r3,0x0)
0302edd4  63 e4 40 20  andi r3,r3,0x40
0302edd8  cc 74  zextb r3,r3
0302edda  23 e9 8e 02  bnez r3,0x0302f2f6
0302edde  00 e9 8c 02  bez r0,0x0302f2f6
0302ede2  01 e0 d5 78  bsr 0x0305df8c
0302ede6  20 e9 06 00  bnez r0,0x0302edf2
0302edea  ff e3 5b ff  bsr 0x0302eca0
0302edee  00 e8 84 02  br 0x0302f2f6
0302edf2  41 3c  cmpnei r4,0x1
0302edf4  79 08  bt 0x0302eee6
0302edf6  6b 12  lrw r3,0x302ef20
0302edf8  63 d8 5c 00  ld.b r3,(r3,0x5c)
0302edfc  01 3b  cmphsi r3,0x2
0302edfe  15 08  bt 0x0302ee28
0302ee00  69 12  lrw r3,0x302ef24
0302ee02  63 d8 2d 00  ld.b r3,(r3,0x2d)
0302ee06  63 e4 04 20  andi r3,r3,0x4
0302ee0a  cc 74  zextb r3,r3
0302ee0c  03 e9 0e 00  bez r3,0x0302ee28
0302ee10  66 12  lrw r3,0x302ef28
0302ee12  75 83  ld.b r3,(r3,0x15)
0302ee14  63 e4 04 20  andi r3,r3,0x4
0302ee18  cc 74  zextb r3,r3
0302ee1a  23 e9 07 00  bnez r3,0x0302ee28
0302ee1e  00 30  movi r0,0x0
0302ee20  ff e3 40 ff  bsr 0x0302eca0
0302ee24  00 e8 69 02  br 0x0302f2f6
0302ee28  61 12  lrw r3,0x302ef2c
0302ee2a  61 83  ld.b r3,(r3,0x1)
0302ee2c  63 e4 03 20  andi r3,r3,0x3
0302ee30  23 e9 63 02  bnez r3,0x0302f2f6
0302ee34  5f 11  lrw r2,0x302ef30
0302ee36  72 82  ld.b r3,(r2,0x12)
0302ee38  00 23  addi r3,0x1
0302ee3a  cc 74  zextb r3,r3
0302ee3c  72 a2  st.b r3,(r2,0x12)
0302ee3e  31 32  movi r2,0x31
0302ee40  c8 64  cmphs r2,r3
0302ee42  60 e8 5a 02  bt 0x0302f2f6
0302ee46  7f e2 47 f8  bsr 0x0002ded4
0302ee4a  76 11  lrw r3,0x302ef20
0302ee4c  50 83  ld.b r2,(r3,0x10)
0302ee4e  40 c4 25 5c  ins r2,r0,0x1,0x5
0302ee52  50 a3  st.b r2,(r3,0x10)
0302ee54  75 11  lrw r3,0x302ef28
0302ee56  75 83  ld.b r3,(r3,0x15)
0302ee58  63 e4 04 20  andi r3,r3,0x4
0302ee5c  cc 74  zextb r3,r3
0302ee5e  03 e9 09 00  bez r3,0x0302ee70
0302ee62  71 11  lrw r3,0x302ef24
0302ee64  43 d8 26 00  ld.b r2,(r3,0x26)
0302ee68  6e 11  lrw r3,0x302ef20
0302ee6a  43 dc 2b 10  st.h r2,(r3,0x56)
0302ee6e  0b 04  br 0x0302ee84
0302ee70  6d 11  lrw r3,0x302ef24
0302ee72  03 d8 29 00  ld.b r0,(r3,0x29)
0302ee76  23 d8 26 00  ld.b r1,(r3,0x26)
0302ee7a  01 e0 c9 3b  bsr 0x0305660c
0302ee7e  69 11  lrw r3,0x302ef20
0302ee80  03 dc 2b 10  st.h r0,(r3,0x56)
0302ee84  67 11  lrw r3,0x302ef20
0302ee86  43 d8 2b 10  ld.h r2,(r3,0x56)
0302ee8a  43 dc 2d 10  st.h r2,(r3,0x5a)
0302ee8e  47 11  lrw r2,0x302ef28
0302ee90  02 82  ld.b r0,(r2,0x2)
0302ee92  43 6c  mov r1,r0
0302ee94  20 c4 22 5c  ins r1,r0,0x1,0x2
0302ee98  22 a2  st.b r1,(r2,0x2)
0302ee9a  00 31  movi r1,0x0
0302ee9c  45 11  lrw r2,0x302ef30
0302ee9e  32 a2  st.b r1,(r2,0x12)
0302eea0  45 11  lrw r2,0x302ef34
0302eea2  00 30  movi r0,0x0
0302eea4  00 b2  st.w r0,(r2,0x0)
0302eea6  43 d8 5d 00  ld.b r2,(r3,0x5d)
0302eeaa  01 31  movi r1,0x1
0302eeac  41 c4 00 5c  ins r2,r1,0x0,0x0
0302eeb0  43 dc 5d 00  st.b r2,(r3,0x5d)
0302eeb4  61 83  ld.b r3,(r3,0x1)
0302eeb6  23 e9 0e 00  bnez r3,0x0302eed2
0302eeba  7c 10  lrw r3,0x302ef28
0302eebc  75 83  ld.b r3,(r3,0x15)
0302eebe  63 e4 04 20  andi r3,r3,0x4
0302eec2  cc 74  zextb r3,r3
0302eec4  23 e9 07 00  bnez r3,0x0302eed2
0302eec8  76 10  lrw r3,0x302ef20
0302eeca  4f 83  ld.b r2,(r3,0xf)
0302eecc  41 c4 05 5c  ins r2,r1,0x0,0x5
0302eed0  4f a3  st.b r2,(r3,0xf)
0302eed2  03 30  movi r0,0x3
0302eed4  ff e3 e6 fe  bsr 0x0302eca0
0302eed8  ff e3 48 5c  bsr 0x0301a768
0302eedc  18 30  movi r0,0x18
0302eede  ff e3 9f 96  bsr 0x03021c1c
0302eee2  00 e8 0a 02  br 0x0302f2f6
0302eee6  43 3c  cmpnei r4,0x3
0302eee8  1a 09  bt 0x0302f11c
0302eeea  72 10  lrw r3,0x302ef30
0302eeec  52 83  ld.b r2,(r3,0x12)
0302eeee  00 22  addi r2,0x1
0302eef0  88 74  zextb r2,r2
0302eef2  52 a3  st.b r2,(r3,0x12)
0302eef4  6a 10  lrw r3,0x302ef1c
0302eef6  60 83  ld.b r3,(r3,0x0)
0302eef8  63 e4 20 20  andi r3,r3,0x20
0302eefc  cc 74  zextb r3,r3
0302eefe  03 e9 1d 00  bez r3,0x0302ef38
0302ef02  68 10  lrw r3,0x302ef20
0302ef04  70 83  ld.b r3,(r3,0x10)
0302ef06  63 e4 01 20  andi r3,r3,0x1
0302ef0a  23 e9 17 00  bnez r3,0x0302ef38
0302ef0e  00 32  movi r2,0x0
0302ef10  68 10  lrw r3,0x302ef30
0302ef12  52 a3  st.b r2,(r3,0x12)
0302ef14  04 30  movi r0,0x4
0302ef16  ff e3 c5 fe  bsr 0x0302eca0
0302ef1a  ee 05  br 0x0302f2f6
0302ef38  05 33  movi r3,0x5
0302ef3a  8c 64  cmphs r3,r2
0302ef3c  dd 09  bt 0x0302f2f6
0302ef3e  00 32  movi r2,0x0
0302ef40  77 12  lrw r3,0x302f09c
0302ef42  52 a3  st.b r2,(r3,0x12)
0302ef44  77 12  lrw r3,0x302f0a0
0302ef46  6c 83  ld.b r3,(r3,0xc)
0302ef48  03 e9 06 00  bez r3,0x0302ef54
0302ef4c  06 30  movi r0,0x6
0302ef4e  ff e3 a9 fe  bsr 0x0302eca0
0302ef52  d2 05  br 0x0302f2f6
0302ef54  74 12  lrw r3,0x302f0a4
0302ef56  43 83  ld.b r2,(r3,0x3)
0302ef58  00 31  movi r1,0x0
0302ef5a  41 c4 06 5c  ins r2,r1,0x0,0x6
0302ef5e  43 a3  st.b r2,(r3,0x3)
0302ef60  72 12  lrw r3,0x302f0a8
0302ef62  63 d8 2d 00  ld.b r3,(r3,0x2d)
0302ef66  63 e4 04 20  andi r3,r3,0x4
0302ef6a  cc 74  zextb r3,r3
0302ef6c  23 e9 09 00  bnez r3,0x0302ef7e
0302ef70  6c 12  lrw r3,0x302f0a0
0302ef72  75 83  ld.b r3,(r3,0x15)
0302ef74  63 e4 04 20  andi r3,r3,0x4
0302ef78  cc 74  zextb r3,r3
0302ef7a  03 e9 c0 00  bez r3,0x0302f0fa
0302ef7e  6c 12  lrw r3,0x302f0ac
0302ef80  63 d8 5c 00  ld.b r3,(r3,0x5c)
0302ef84  01 3b  cmphsi r3,0x2
0302ef86  08 08  bt 0x0302ef96
0302ef88  66 12  lrw r3,0x302f0a0
0302ef8a  75 83  ld.b r3,(r3,0x15)
0302ef8c  63 e4 04 20  andi r3,r3,0x4
0302ef90  cc 74  zextb r3,r3
0302ef92  03 e9 b2 01  bez r3,0x0302f2f6
0302ef96  63 12  lrw r3,0x302f0a0
0302ef98  67 83  ld.b r3,(r3,0x7)
0302ef9a  63 e4 08 20  andi r3,r3,0x8
0302ef9e  cc 74  zextb r3,r3
0302efa0  23 e9 ab 01  bnez r3,0x0302f2f6
0302efa4  62 12  lrw r3,0x302f0ac
0302efa6  50 83  ld.b r2,(r3,0x10)
0302efa8  01 31  movi r1,0x1
0302efaa  41 c4 00 5c  ins r2,r1,0x0,0x0
0302efae  50 a3  st.b r2,(r3,0x10)
0302efb0  64 83  ld.b r3,(r3,0x4)
0302efb2  03 e9 37 00  bez r3,0x0302f020
0302efb6  5b 11  lrw r2,0x302f0a0
0302efb8  55 82  ld.b r2,(r2,0x15)
0302efba  42 e4 04 20  andi r2,r2,0x4
0302efbe  88 74  zextb r2,r2
0302efc0  22 e9 30 00  bnez r2,0x0302f020
0302efc4  5a 11  lrw r2,0x302f0ac
0302efc6  4f 82  ld.b r2,(r2,0xf)
0302efc8  22 e4 20 20  andi r1,r2,0x20
0302efcc  44 74  zextb r1,r1
0302efce  01 e9 78 00  bez r1,0x0302f0be
0302efd2  23 e4 0f 30  andni r1,r3,0xf
0302efd6  01 e9 1b 00  bez r1,0x0302f00c
0302efda  63 e4 0f 20  andi r3,r3,0xf
0302efde  03 e9 1e 00  bez r3,0x0302f01a
0302efe2  62 e4 10 20  andi r3,r2,0x10
0302efe6  cc 74  zextb r3,r3
0302efe8  03 e9 0a 00  bez r3,0x0302effc
0302efec  70 11  lrw r3,0x302f0ac
0302efee  05 8b  ld.h r0,(r3,0xa)
0302eff0  4f 83  ld.b r2,(r3,0xf)
0302eff2  00 31  movi r1,0x0
0302eff4  41 c4 04 5c  ins r2,r1,0x0,0x4
0302eff8  4f a3  st.b r2,(r3,0xf)
0302effa  19 04  br 0x0302f02c
0302effc  6c 11  lrw r3,0x302f0ac
0302effe  04 8b  ld.h r0,(r3,0x8)
0302f000  4f 83  ld.b r2,(r3,0xf)
0302f002  01 31  movi r1,0x1
0302f004  41 c4 04 5c  ins r2,r1,0x0,0x4
0302f008  4f a3  st.b r2,(r3,0xf)
0302f00a  11 04  br 0x0302f02c
0302f00c  63 e4 0f 20  andi r3,r3,0xf
0302f010  03 e9 05 00  bez r3,0x0302f01a
0302f014  66 11  lrw r3,0x302f0ac
0302f016  04 8b  ld.h r0,(r3,0x8)
0302f018  11 04  br 0x0302f03a
0302f01a  65 11  lrw r3,0x302f0ac
0302f01c  05 8b  ld.h r0,(r3,0xa)
0302f01e  0e 04  br 0x0302f03a
0302f020  63 11  lrw r3,0x302f0ac
0302f022  4f 83  ld.b r2,(r3,0xf)
0302f024  00 30  movi r0,0x0
0302f026  40 c4 05 5c  ins r2,r0,0x0,0x5
0302f02a  4f a3  st.b r2,(r3,0xf)
0302f02c  60 11  lrw r3,0x302f0ac
0302f02e  6f 83  ld.b r3,(r3,0xf)
0302f030  63 e4 20 20  andi r3,r3,0x20
0302f034  cc 74  zextb r3,r3
0302f036  03 e9 0f 00  bez r3,0x0302f054
0302f03a  ff e3 57 fe  bsr 0x0302ece8
0302f03e  7c 10  lrw r3,0x302f0ac
0302f040  61 83  ld.b r3,(r3,0x1)
0302f042  03 e9 55 00  bez r3,0x0302f0ec
0302f046  7a 10  lrw r3,0x302f0ac
0302f048  4f 83  ld.b r2,(r3,0xf)
0302f04a  00 31  movi r1,0x0
0302f04c  41 c4 05 5c  ins r2,r1,0x0,0x5
0302f050  4f a3  st.b r2,(r3,0xf)
0302f052  4d 04  br 0x0302f0ec
0302f054  73 10  lrw r3,0x302f0a0
0302f056  75 83  ld.b r3,(r3,0x15)
0302f058  63 e4 04 20  andi r3,r3,0x4
0302f05c  cc 74  zextb r3,r3
0302f05e  03 e9 30 00  bez r3,0x0302f0be
0302f062  53 10  lrw r2,0x302f0ac
0302f064  6e 82  ld.b r3,(r2,0xe)
0302f066  00 23  addi r3,0x1
0302f068  cc 74  zextb r3,r3
0302f06a  6e a2  st.b r3,(r2,0xe)
0302f06c  0a 32  movi r2,0xa
0302f06e  c8 64  cmphs r2,r3
0302f070  04 08  bt 0x0302f078
0302f072  01 32  movi r2,0x1
0302f074  6e 10  lrw r3,0x302f0ac
0302f076  4e a3  st.b r2,(r3,0xe)
0302f078  4d 10  lrw r2,0x302f0ac
0302f07a  6e 82  ld.b r3,(r2,0xe)
0302f07c  6a aa  st.h r3,(r2,0x14)
0302f07e  4b 10  lrw r2,0x302f0a8
0302f080  62 dc 26 00  st.b r3,(r2,0x26)
0302f084  42 d8 2d 00  ld.b r2,(r2,0x2d)
0302f088  42 e4 7f 30  andni r2,r2,0x7f
0302f08c  88 74  zextb r2,r2
0302f08e  22 e9 11 00  bnez r2,0x0302f0b0
0302f092  46 10  lrw r2,0x302f0a8
0302f094  62 dc 2a 00  st.b r3,(r2,0x2a)
0302f098  0f 04  br 0x0302f0b6
0302f0b0  40 13  lrw r2,0x302f230
0302f0b2  62 dc 2b 00  st.b r3,(r2,0x2b)
0302f0b6  02 30  movi r0,0x2
0302f0b8  00 e0 54 0a  bsr 0x03030560
0302f0bc  18 04  br 0x0302f0ec
0302f0be  9e 12  lrw r4,0x302f234
0302f0c0  6e 84  ld.b r3,(r4,0xe)
0302f0c2  09 23  addi r3,0xa
0302f0c4  6c 5b  addu r3,r3,r3
0302f0c6  6c 5c  addu r3,r4,r3
0302f0c8  01 8b  ld.h r0,(r3,0x2)
0302f0ca  ff e3 0f fe  bsr 0x0302ece8
0302f0ce  6e 84  ld.b r3,(r4,0xe)
0302f0d0  00 23  addi r3,0x1
0302f0d2  cc 74  zextb r3,r3
0302f0d4  6e a4  st.b r3,(r4,0xe)
0302f0d6  41 84  ld.b r2,(r4,0x1)
0302f0d8  8c 64  cmphs r3,r2
0302f0da  03 0c  bf 0x0302f0e0
0302f0dc  00 32  movi r2,0x0
0302f0de  4e a4  st.b r2,(r4,0xe)
0302f0e0  75 12  lrw r3,0x302f234
0302f0e2  4f 83  ld.b r2,(r3,0xf)
0302f0e4  01 31  movi r1,0x1
0302f0e6  41 c4 05 5c  ins r2,r1,0x0,0x5
0302f0ea  4f a3  st.b r2,(r3,0xf)
0302f0ec  72 12  lrw r3,0x302f234
0302f0ee  50 83  ld.b r2,(r3,0x10)
0302f0f0  00 31  movi r1,0x0
0302f0f2  41 c4 00 5c  ins r2,r1,0x0,0x0
0302f0f6  50 a3  st.b r2,(r3,0x10)
0302f0f8  ff 04  br 0x0302f2f6
0302f0fa  8f 12  lrw r4,0x302f234
0302f0fc  6f 84  ld.b r3,(r4,0xf)
0302f0fe  00 35  movi r5,0x0
0302f100  65 c4 05 5c  ins r3,r5,0x0,0x5
0302f104  6f a4  st.b r3,(r4,0xf)
0302f106  04 d8 5d 00  ld.b r0,(r4,0x5d)
0302f10a  00 e4 01 20  andi r0,r0,0x1
0302f10e  ff e3 f5 fd  bsr 0x0302ecf8
0302f112  70 84  ld.b r3,(r4,0x10)
0302f114  65 c4 00 5c  ins r3,r5,0x0,0x0
0302f118  70 a4  st.b r3,(r4,0x10)
0302f11a  ee 04  br 0x0302f2f6
0302f11c  44 3c  cmpnei r4,0x4
0302f11e  32 08  bt 0x0302f182
0302f120  46 12  lrw r2,0x302f238
0302f122  72 82  ld.b r3,(r2,0x12)
0302f124  00 23  addi r3,0x1
0302f126  cc 74  zextb r3,r3
0302f128  72 a2  st.b r3,(r2,0x12)
0302f12a  45 12  lrw r2,0x302f23c
0302f12c  48 82  ld.b r2,(r2,0x8)
0302f12e  42 e4 0f 30  andni r2,r2,0xf
0302f132  88 74  zextb r2,r2
0302f134  50 3a  cmpnei r2,0x10
0302f136  1e 31  movi r1,0x1e
0302f138  64 30  movi r0,0x64
0302f13a  41 c4 40 0c  movt r2,r1
0302f13e  40 c4 20 0c  movf r2,r0
0302f142  c8 64  cmphs r2,r3
0302f144  0c 0c  bf 0x0302f15c
0302f146  ff e3 df fd  bsr 0x0302ed04
0302f14a  00 e9 d6 00  bez r0,0x0302f2f6
0302f14e  00 32  movi r2,0x0
0302f150  7a 11  lrw r3,0x302f238
0302f152  52 a3  st.b r2,(r3,0x12)
0302f154  06 30  movi r0,0x6
0302f156  ff e3 a5 fd  bsr 0x0302eca0
0302f15a  ce 04  br 0x0302f2f6
0302f15c  00 32  movi r2,0x0
0302f15e  77 11  lrw r3,0x302f238
0302f160  52 a3  st.b r2,(r3,0x12)
0302f162  78 11  lrw r3,0x302f240
0302f164  43 83  ld.b r2,(r3,0x3)
0302f166  00 31  movi r1,0x0
0302f168  41 c4 06 5c  ins r2,r1,0x0,0x6
0302f16c  43 a3  st.b r2,(r3,0x3)
0302f16e  72 11  lrw r3,0x302f234
0302f170  50 83  ld.b r2,(r3,0x10)
0302f172  01 31  movi r1,0x1
0302f174  41 c4 00 5c  ins r2,r1,0x0,0x0
0302f178  50 a3  st.b r2,(r3,0x10)
0302f17a  03 30  movi r0,0x3
0302f17c  ff e3 92 fd  bsr 0x0302eca0
0302f180  bb 04  br 0x0302f2f6
0302f182  46 3c  cmpnei r4,0x6
0302f184  ae 08  bt 0x0302f2e0
0302f186  6c 11  lrw r3,0x302f234
0302f188  6f 83  ld.b r3,(r3,0xf)
0302f18a  63 e4 40 20  andi r3,r3,0x40
0302f18e  cc 74  zextb r3,r3
0302f190  03 e9 1a 00  bez r3,0x0302f1c4
0302f194  68 11  lrw r3,0x302f234
0302f196  62 83  ld.b r3,(r3,0x2)
0302f198  63 e4 0f 30  andni r3,r3,0xf
0302f19c  cc 74  zextb r3,r3
0302f19e  50 3b  cmpnei r3,0x10
0302f1a0  06 08  bt 0x0302f1ac
0302f1a2  09 11  lrw r0,0x302f244
0302f1a4  29 11  lrw r1,0x302f248
0302f1a6  11 32  movi r2,0x11
0302f1a8  7f e2 c8 e0  bsr 0x0002b338
0302f1ac  82 11  lrw r4,0x302f234
0302f1ae  64 d8 2a 10  ld.h r3,(r4,0x54)
0302f1b2  64 dc 2b 10  st.h r3,(r4,0x56)
0302f1b6  ff e3 d9 5a  bsr 0x0301a768
0302f1ba  6f 84  ld.b r3,(r4,0xf)
0302f1bc  00 32  movi r2,0x0
0302f1be  62 c4 06 5c  ins r3,r2,0x0,0x6
0302f1c2  6f a4  st.b r3,(r4,0xf)
0302f1c4  ff e3 a0 fd  bsr 0x0302ed04
0302f1c8  00 e9 67 00  bez r0,0x0302f296
0302f1cc  79 10  lrw r3,0x302f230
0302f1ce  63 d8 2d 00  ld.b r3,(r3,0x2d)
0302f1d2  63 e4 04 20  andi r3,r3,0x4
0302f1d6  cc 74  zextb r3,r3
0302f1d8  23 e9 09 00  bnez r3,0x0302f1ea
0302f1dc  7c 10  lrw r3,0x302f24c
0302f1de  75 83  ld.b r3,(r3,0x15)
0302f1e0  63 e4 04 20  andi r3,r3,0x4
0302f1e4  cc 74  zextb r3,r3
0302f1e6  03 e9 06 00  bez r3,0x0302f1f2
0302f1ea  00 32  movi r2,0x0
0302f1ec  73 10  lrw r3,0x302f238
0302f1ee  48 ab  st.h r2,(r3,0x10)
0302f1f0  83 04  br 0x0302f2f6
0302f1f2  78 10  lrw r3,0x302f250
0302f1f4  60 83  ld.b r3,(r3,0x0)
0302f1f6  23 e9 2f 00  bnez r3,0x0302f254
0302f1fa  50 10  lrw r2,0x302f238
0302f1fc  68 8a  ld.h r3,(r2,0x10)
0302f1fe  00 23  addi r3,0x1
0302f200  cd 74  zexth r3,r3
0302f202  68 aa  st.h r3,(r2,0x10)
0302f204  4c 10  lrw r2,0x302f234
0302f206  23 82  ld.b r1,(r2,0x3)
0302f208  32 32  movi r2,0x32
0302f20a  84 7c  mult r2,r1
0302f20c  8d 64  cmplt r3,r2
0302f20e  74 08  bt 0x0302f2f6
0302f210  00 32  movi r2,0x0
0302f212  6a 10  lrw r3,0x302f238
0302f214  48 ab  st.h r2,(r3,0x10)
0302f216  03 30  movi r0,0x3
0302f218  ff e3 44 fd  bsr 0x0302eca0
0302f21c  66 10  lrw r3,0x302f234
0302f21e  50 83  ld.b r2,(r3,0x10)
0302f220  01 31  movi r1,0x1
0302f222  41 c4 00 5c  ins r2,r1,0x0,0x0
0302f226  50 a3  st.b r2,(r3,0x10)
0302f228  ff e3 a0 5a  bsr 0x0301a768
0302f22c  65 04  br 0x0302f2f6
0302f254  41 3b  cmpnei r3,0x1
0302f256  05 08  bt 0x0302f260
0302f258  00 32  movi r2,0x0
0302f25a  78 12  lrw r3,0x302f3b8
0302f25c  48 ab  st.h r2,(r3,0x10)
0302f25e  4c 04  br 0x0302f2f6
0302f260  00 30  movi r0,0x0
0302f262  ff e3 1f fd  bsr 0x0302eca0
0302f266  00 32  movi r2,0x0
0302f268  75 12  lrw r3,0x302f3bc
0302f26a  4e a3  st.b r2,(r3,0xe)
0302f26c  ff e3 80 58  bsr 0x0301a36c
0302f270  74 12  lrw r3,0x302f3c0
0302f272  40 83  ld.b r2,(r3,0x0)
0302f274  21 83  ld.b r1,(r3,0x1)
0302f276  28 41  lsli r1,r1 ,0x8
0302f278  84 6c  or r2,r1
0302f27a  22 83  ld.b r1,(r3,0x2)
0302f27c  30 41  lsli r1,r1 ,0x10
0302f27e  84 6c  or r2,r1
0302f280  03 83  ld.b r0,(r3,0x3)
0302f282  18 40  lsli r0,r0 ,0x18
0302f284  70 12  lrw r3,0x302f3c4
0302f286  23 d8 2d 00  ld.b r1,(r3,0x2d)
0302f28a  08 6c  or r0,r2
0302f28c  e1 c4 e1 54  zext r1,r1,0x7,0x7
0302f290  00 e0 34 0b  bsr 0x030308f8
0302f294  31 04  br 0x0302f2f6
0302f296  49 12  lrw r2,0x302f3b8
0302f298  68 8a  ld.h r3,(r2,0x10)
0302f29a  00 23  addi r3,0x1
0302f29c  cd 74  zexth r3,r3
0302f29e  68 aa  st.h r3,(r2,0x10)
0302f2a0  47 12  lrw r2,0x302f3bc
0302f2a2  23 82  ld.b r1,(r2,0x3)
0302f2a4  32 32  movi r2,0x32
0302f2a6  84 7c  mult r2,r1
0302f2a8  8d 64  cmplt r3,r2
0302f2aa  26 08  bt 0x0302f2f6
0302f2ac  00 32  movi r2,0x0
0302f2ae  63 12  lrw r3,0x302f3b8
0302f2b0  48 ab  st.h r2,(r3,0x10)
0302f2b2  66 12  lrw r3,0x302f3c8
0302f2b4  43 83  ld.b r2,(r3,0x3)
0302f2b6  00 31  movi r1,0x0
0302f2b8  41 c4 06 5c  ins r2,r1,0x0,0x6
0302f2bc  43 a3  st.b r2,(r3,0x3)
0302f2be  03 30  movi r0,0x3
0302f2c0  ff e3 f0 fc  bsr 0x0302eca0
0302f2c4  7e 11  lrw r3,0x302f3bc
0302f2c6  50 83  ld.b r2,(r3,0x10)
0302f2c8  01 31  movi r1,0x1
0302f2ca  41 c4 00 5c  ins r2,r1,0x0,0x0
0302f2ce  50 a3  st.b r2,(r3,0x10)
0302f2d0  7f 11  lrw r3,0x302f3cc
0302f2d2  60 83  ld.b r3,(r3,0x0)
0302f2d4  cc 74  zextb r3,r3
0302f2d6  23 e9 10 00  bnez r3,0x0302f2f6
0302f2da  ff e3 47 5a  bsr 0x0301a768
0302f2de  0c 04  br 0x0302f2f6
0302f2e0  42 3c  cmpnei r4,0x2
0302f2e2  0a 08  bt 0x0302f2f6
0302f2e4  7a 11  lrw r3,0x302f3cc
0302f2e6  60 83  ld.b r3,(r3,0x0)
0302f2e8  cc 74  zextb r3,r3
0302f2ea  43 eb 4d 00  cmpnei r3,0x4d
0302f2ee  04 08  bt 0x0302f2f6
0302f2f0  06 30  movi r0,0x6
0302f2f2  ff e3 d7 fc  bsr 0x0302eca0
0302f2f6  92 14  pop r4,r5,lr

; 0302f2f8 FUN_0302f2f8
0302f2f8  d1 14  push r4,lr
0302f2fa  71 11  lrw r3,0x302f3bc
0302f2fc  43 d8 2a 10  ld.h r2,(r3,0x54)
0302f300  64 8b  ld.h r3,(r3,0x8)
0302f302  8e 64  cmpne r3,r2
0302f304  30 0c  bf 0x0302f364
0302f306  6e 11  lrw r3,0x302f3bc
0302f308  65 8b  ld.h r3,(r3,0xa)
0302f30a  8e 64  cmpne r3,r2
0302f30c  2e 0c  bf 0x0302f368
0302f30e  6c 11  lrw r3,0x302f3bc
0302f310  83 d9 01 00  ld.b r12,(r3,0x1)
0302f314  02 33  movi r3,0x2
0302f316  0c 67  cmphs r3,r12
0302f318  2a 08  bt 0x0302f36c
0302f31a  69 11  lrw r3,0x302f3bc
0302f31c  6e 83  ld.b r3,(r3,0xe)
0302f31e  03 e9 13 00  bez r3,0x0302f344
0302f322  0c 67  cmphs r3,r12
0302f324  10 08  bt 0x0302f344
0302f326  26 11  lrw r1,0x302f3bc
0302f328  43 e4 08 00  addi r2,r3,0x9
0302f32c  48 5a  addu r2,r2,r2
0302f32e  08 59  addu r0,r1,r2
0302f330  43 e4 09 00  addi r2,r3,0xa
0302f334  48 5a  addu r2,r2,r2
0302f336  48 59  addu r2,r1,r2
0302f338  41 8a  ld.h r2,(r2,0x2)
0302f33a  41 a8  st.h r2,(r0,0x2)
0302f33c  00 23  addi r3,0x1
0302f33e  cc 74  zextb r3,r3
0302f340  0c 67  cmphs r3,r12
0302f342  f3 0f  bf 0x0302f328
0302f344  9e 10  lrw r4,0x302f3bc
0302f346  8c e5 00 10  subi r12,r12,0x1
0302f34a  84 dd 01 00  st.b r12,(r4,0x1)
0302f34e  03 30  movi r0,0x3
0302f350  ff e3 a8 fc  bsr 0x0302eca0
0302f354  ff e3 0a 5a  bsr 0x0301a768
0302f358  70 84  ld.b r3,(r4,0x10)
0302f35a  01 30  movi r0,0x1
0302f35c  60 c4 00 5c  ins r3,r0,0x0,0x0
0302f360  70 a4  st.b r3,(r4,0x10)
0302f362  06 04  br 0x0302f36e
0302f364  00 30  movi r0,0x0
0302f366  04 04  br 0x0302f36e
0302f368  00 30  movi r0,0x0
0302f36a  02 04  br 0x0302f36e
0302f36c  00 30  movi r0,0x0
0302f36e  91 14  pop r4,lr

; 0302f370 FUN_0302f370
0302f370  d0 14  push lr
0302f372  02 30  movi r0,0x2
0302f374  ff e3 96 fc  bsr 0x0302eca0
0302f378  03 30  movi r0,0x3
0302f37a  00 e0 f3 08  bsr 0x03030560
0302f37e  00 32  movi r2,0x0
0302f380  6f 10  lrw r3,0x302f3bc
0302f382  4e a3  st.b r2,(r3,0xe)
0302f384  90 14  pop lr

; 0302f388 FUN_0302f388
0302f388  d1 14  push r4,lr
0302f38a  ff e3 ab fc  bsr 0x0302ece0
0302f38e  00 e9 13 00  bez r0,0x0302f3b4
0302f392  8b 10  lrw r4,0x302f3bc
0302f394  71 84  ld.b r3,(r4,0x11)
0302f396  01 32  movi r2,0x1
0302f398  62 c4 00 5c  ins r3,r2,0x0,0x0
0302f39c  71 a4  st.b r3,(r4,0x11)
0302f39e  02 30  movi r0,0x2
0302f3a0  ff e3 e8 ff  bsr 0x0302f370
0302f3a4  00 30  movi r0,0x0
0302f3a6  ff e3 7d fc  bsr 0x0302eca0
0302f3aa  71 84  ld.b r3,(r4,0x11)
0302f3ac  00 32  movi r2,0x0
0302f3ae  62 c4 00 5c  ins r3,r2,0x0,0x0
0302f3b2  71 a4  st.b r3,(r4,0x11)
0302f3b4  91 14  pop r4,lr

; 0302f3d0 FUN_0302f3d0
0302f3d0  60 13  lrw r3,0x302f550
0302f3d2  69 83  ld.b r3,(r3,0x9)
0302f3d4  63 e4 3f 20  andi r3,r3,0x3f
0302f3d8  43 e4 3e 00  addi r2,r3,0x3f
0302f3dc  42 e4 3f 20  andi r2,r2,0x3f
0302f3e0  1f 3a  cmphsi r2,0x20
0302f3e2  12 08  bt 0x0302f406
0302f3e4  03 e9 13 00  bez r3,0x0302f40a
0302f3e8  5b 12  lrw r2,0x302f554
0302f3ea  40 82  ld.b r2,(r2,0x0)
0302f3ec  c9 64  cmplt r2,r3
0302f3ee  10 08  bt 0x0302f40e
0302f3f0  79 12  lrw r3,0x302f554
0302f3f2  63 d8 5c 00  ld.b r3,(r3,0x5c)
0302f3f6  01 32  movi r2,0x1
0302f3f8  c8 64  cmphs r2,r3
0302f3fa  0c 08  bt 0x0302f412
0302f3fc  10 32  movi r2,0x10
0302f3fe  c8 64  cmphs r2,r3
0302f400  00 c4 00 05  mvc r0
0302f404  08 04  br 0x0302f414
0302f406  00 30  movi r0,0x0
0302f408  06 04  br 0x0302f414
0302f40a  00 30  movi r0,0x0
0302f40c  04 04  br 0x0302f414
0302f40e  00 30  movi r0,0x0
0302f410  02 04  br 0x0302f414
0302f412  00 30  movi r0,0x0
0302f414  3c 78  rts

; 0302f418 FUN_0302f418
0302f418  d3 14  push r4,r5,r6,lr
0302f41a  2d 14  subi sp,sp,0x34
0302f41c  03 6d  mov r4,r0
0302f41e  20 e9 0c 00  bnez r0,0x0302f436
0302f422  ff e3 5f fc  bsr 0x0302ece0
0302f426  42 38  cmpnei r0,0x2
0302f428  07 08  bt 0x0302f436
0302f42a  6a 12  lrw r3,0x302f550
0302f42c  69 83  ld.b r3,(r3,0x9)
0302f42e  63 e4 3f 20  andi r3,r3,0x3f
0302f432  43 e9 a5 00  bhz r3,0x0302f57c
0302f436  00 30  movi r0,0x0
0302f438  ff e3 34 fc  bsr 0x0302eca0
0302f43c  67 12  lrw r3,0x302f558
0302f43e  63 d8 2d 00  ld.b r3,(r3,0x2d)
0302f442  63 e4 04 20  andi r3,r3,0x4
0302f446  cc 74  zextb r3,r3
0302f448  03 e9 16 00  bez r3,0x0302f474
0302f44c  64 12  lrw r3,0x302f55c
0302f44e  75 83  ld.b r3,(r3,0x15)
0302f450  63 e4 04 20  andi r3,r3,0x4
0302f454  cc 74  zextb r3,r3
0302f456  23 e9 0f 00  bnez r3,0x0302f474
0302f45a  7e 11  lrw r3,0x302f550
0302f45c  09 83  ld.b r0,(r3,0x9)
0302f45e  00 e4 3f 20  andi r0,r0,0x3f
0302f462  60 e4 3e 00  addi r3,r0,0x3f
0302f466  63 e4 3f 20  andi r3,r3,0x3f
0302f46a  1f 3b  cmphsi r3,0x20
0302f46c  82 08  bt 0x0302f570
0302f46e  ff e3 9b f6  bsr 0x0302e1a4
0302f472  88 04  br 0x0302f582
0302f474  ff e3 68 f6  bsr 0x0302e144
0302f478  85 04  br 0x0302f582
0302f47a  78 11  lrw r3,0x302f558
0302f47c  63 d8 2d 00  ld.b r3,(r3,0x2d)
0302f480  63 e4 04 20  andi r3,r3,0x4
0302f484  cc 74  zextb r3,r3
0302f486  03 e9 09 00  bez r3,0x0302f498
0302f48a  75 11  lrw r3,0x302f55c
0302f48c  75 83  ld.b r3,(r3,0x15)
0302f48e  63 e4 04 20  andi r3,r3,0x4
0302f492  cc 74  zextb r3,r3
0302f494  03 e9 70 00  bez r3,0x0302f574
0302f498  04 e9 09 00  bez r4,0x0302f4aa
0302f49c  6e 11  lrw r3,0x302f554
0302f49e  50 83  ld.b r2,(r3,0x10)
0302f4a0  01 31  movi r1,0x1
0302f4a2  41 c4 07 5c  ins r2,r1,0x0,0x7
0302f4a6  50 a3  st.b r2,(r3,0x10)
0302f4a8  72 04  br 0x0302f58c
0302f4aa  6b 11  lrw r3,0x302f554
0302f4ac  70 83  ld.b r3,(r3,0x10)
0302f4ae  63 e4 7f 30  andni r3,r3,0x7f
0302f4b2  cc 74  zextb r3,r3
0302f4b4  23 e9 6c 00  bnez r3,0x0302f58c
0302f4b8  5f 04  br 0x0302f576
0302f4ba  48 11  lrw r2,0x302f558
0302f4bc  42 d8 2d 00  ld.b r2,(r2,0x2d)
0302f4c0  42 e4 7f 30  andni r2,r2,0x7f
0302f4c4  88 74  zextb r2,r2
0302f4c6  22 e9 19 00  bnez r2,0x0302f4f8
0302f4ca  66 11  lrw r3,0x302f560
0302f4cc  40 83  ld.b r2,(r3,0x0)
0302f4ce  00 31  movi r1,0x0
0302f4d0  41 c4 03 5c  ins r2,r1,0x0,0x3
0302f4d4  40 a3  st.b r2,(r3,0x0)
0302f4d6  84 11  lrw r4,0x302f564
0302f4d8  7b 6d  mov r5,sp
0302f4da  3b 6c  mov r0,sp
0302f4dc  00 e0 be 10  bsr 0x03031658
0302f4e0  33 36  movi r6,0x33
0302f4e2  13 6c  mov r0,r4
0302f4e4  7b 6c  mov r1,sp
0302f4e6  9b 6c  mov r2,r6
0302f4e8  02 e0 50 0b  bsr 0x03070b88
0302f4ec  19 10  lrw r0,0x302f550
0302f4ee  53 6c  mov r1,r4
0302f4f0  9b 6c  mov r2,r6
0302f4f2  02 e0 4b 0b  bsr 0x03070b88
0302f4f6  25 04  br 0x0302f540
0302f4f8  63 e4 10 20  andi r3,r3,0x10
0302f4fc  cc 74  zextb r3,r3
0302f4fe  03 e9 21 00  bez r3,0x0302f540
0302f502  76 10  lrw r3,0x302f558
0302f504  63 d8 2d 00  ld.b r3,(r3,0x2d)
0302f508  63 e4 7f 30  andni r3,r3,0x7f
0302f50c  cc 74  zextb r3,r3
0302f50e  03 e9 19 00  bez r3,0x0302f540
0302f512  74 10  lrw r3,0x302f560
0302f514  40 83  ld.b r2,(r3,0x0)
0302f516  00 31  movi r1,0x0
0302f518  41 c4 04 5c  ins r2,r1,0x0,0x4
0302f51c  40 a3  st.b r2,(r3,0x0)
0302f51e  93 10  lrw r4,0x302f568
0302f520  7b 6d  mov r5,sp
0302f522  3b 6c  mov r0,sp
0302f524  01 31  movi r1,0x1
0302f526  00 e0 99 10  bsr 0x03031658
0302f52a  33 36  movi r6,0x33
0302f52c  13 6c  mov r0,r4
0302f52e  7b 6c  mov r1,sp
0302f530  9b 6c  mov r2,r6
0302f532  02 e0 2b 0b  bsr 0x03070b88
0302f536  07 10  lrw r0,0x302f550
0302f538  53 6c  mov r1,r4
0302f53a  9b 6c  mov r2,r6
0302f53c  02 e0 26 0b  bsr 0x03070b88
0302f540  01 30  movi r0,0x1
0302f542  ff e3 af fb  bsr 0x0302eca0
0302f546  00 32  movi r2,0x0
0302f548  69 10  lrw r3,0x302f56c
0302f54a  4f a3  st.b r2,(r3,0xf)
0302f54c  00 33  movi r3,0x0
0302f54e  14 04  br 0x0302f576
0302f570  01 33  movi r3,0x1
0302f572  02 04  br 0x0302f576
0302f574  01 33  movi r3,0x1
0302f576  40 3b  cmpnei r3,0x0
0302f578  03 64  mvcv r0
0302f57a  02 04  br 0x0302f57e
0302f57c  00 30  movi r0,0x0
0302f57e  0d 14  addi sp,sp,0x34
0302f580  93 14  pop r4,r5,r6,lr
0302f582  ff e3 27 ff  bsr 0x0302f3d0
0302f586  20 e9 89 ff  bnez r0,0x0302f498
0302f58a  78 07  br 0x0302f47a
0302f58c  68 13  lrw r3,0x302f72c
0302f58e  60 83  ld.b r3,(r3,0x0)
0302f590  43 e4 08 20  andi r2,r3,0x8
0302f594  88 74  zextb r2,r2
0302f596  22 e9 92 ff  bnez r2,0x0302f4ba
0302f59a  af 07  br 0x0302f4f8

; 0302f780 FUN_0302f780
0302f780  d3 14  push r4,r5,r6,lr
0302f782  23 14  subi sp,sp,0xc
0302f784  11 30  movi r0,0x11
0302f786  fe e3 07 ff  bsr 0x0300f594
0302f78a  80 75  zextb r6,r0
0302f78c  3b 6d  mov r4,sp
0302f78e  1b 6c  mov r0,r6
0302f790  e0 31  movi r1,0xe0
0302f792  24 41  lsli r1,r1 ,0x4
0302f794  bb 6c  mov r2,sp
0302f796  09 33  movi r3,0x9
0302f798  fe e3 c2 ff  bsr 0x0300f71c
0302f79c  4e d8 00 00  ld.b r2,(sp,0x0)
0302f7a0  7a 12  lrw r3,0x302f908
0302f7a2  40 a3  st.b r2,(r3,0x0)
0302f7a4  ba 12  lrw r5,0x302f90c
0302f7a6  01 30  movi r0,0x1
0302f7a8  22 95  ld.w r1,(r5,0x8)
0302f7aa  0e c4 22 00  addu r2,sp,r0
0302f7ae  ff e3 99 f4  bsr 0x0302e0e0
0302f7b2  00 30  movi r0,0x0
0302f7b4  23 95  ld.w r1,(r5,0xc)
0302f7b6  4e e4 02 00  addi r2,sp,0x3
0302f7ba  ff e3 93 f4  bsr 0x0302e0e0
0302f7be  01 30  movi r0,0x1
0302f7c0  20 95  ld.w r1,(r5,0x0)
0302f7c2  4e e4 04 00  addi r2,sp,0x5
0302f7c6  ff e3 8d f4  bsr 0x0302e0e0
0302f7ca  00 30  movi r0,0x0
0302f7cc  21 95  ld.w r1,(r5,0x4)
0302f7ce  4e e4 06 00  addi r2,sp,0x7
0302f7d2  ff e3 87 f4  bsr 0x0302e0e0
0302f7d6  6e d8 03 00  ld.b r3,(sp,0x3)
0302f7da  2e 12  lrw r1,0x302f910
0302f7dc  44 43  lsli r2,r3 ,0x4
0302f7de  40 a1  st.b r2,(r1,0x0)
0302f7e0  4e d8 04 00  ld.b r2,(sp,0x4)
0302f7e4  44 42  lsli r2,r2 ,0x4
0302f7e6  64 4b  lsri r3,r3,0x4
0302f7e8  c8 6c  or r3,r2
0302f7ea  61 a1  st.b r3,(r1,0x1)
0302f7ec  6e d8 01 00  ld.b r3,(sp,0x1)
0302f7f0  62 a1  st.b r3,(r1,0x2)
0302f7f2  6e d8 02 00  ld.b r3,(sp,0x2)
0302f7f6  63 a1  st.b r3,(r1,0x3)
0302f7f8  01 30  movi r0,0x1
0302f7fa  ff e3 55 ff  bsr 0x0302f6a4
0302f7fe  6e d8 07 00  ld.b r3,(sp,0x7)
0302f802  25 12  lrw r1,0x302f914
0302f804  44 43  lsli r2,r3 ,0x4
0302f806  40 a1  st.b r2,(r1,0x0)
0302f808  4e d8 08 00  ld.b r2,(sp,0x8)
0302f80c  44 42  lsli r2,r2 ,0x4
0302f80e  64 4b  lsri r3,r3,0x4
0302f810  c8 6c  or r3,r2
0302f812  61 a1  st.b r3,(r1,0x1)
0302f814  6e d8 05 00  ld.b r3,(sp,0x5)
0302f818  62 a1  st.b r3,(r1,0x2)
0302f81a  6e d8 06 00  ld.b r3,(sp,0x6)
0302f81e  63 a1  st.b r3,(r1,0x3)
0302f820  00 30  movi r0,0x0
0302f822  ff e3 41 ff  bsr 0x0302f6a4
0302f826  1b 6c  mov r0,r6
0302f828  e1 31  movi r1,0xe1
0302f82a  24 41  lsli r1,r1 ,0x4
0302f82c  bb 6c  mov r2,sp
0302f82e  01 33  movi r3,0x1
0302f830  fe e3 76 ff  bsr 0x0300f71c
0302f834  b9 11  lrw r5,0x302f918
0302f836  6e d8 00 00  ld.b r3,(sp,0x0)
0302f83a  65 dc 5e 00  st.b r3,(r5,0x5e)
0302f83e  11 30  movi r0,0x11
0302f840  00 31  movi r1,0x0
0302f842  97 6c  mov r2,r5
0302f844  01 33  movi r3,0x1
0302f846  fe e3 9d ff  bsr 0x0300f780
0302f84a  40 85  ld.b r2,(r5,0x0)
0302f84c  20 33  movi r3,0x20
0302f84e  8c 64  cmphs r3,r2
0302f850  03 08  bt 0x0302f856
0302f852  20 32  movi r2,0x20
0302f854  40 a5  st.b r2,(r5,0x0)
0302f856  71 11  lrw r3,0x302f918
0302f858  50 83  ld.b r2,(r3,0x10)
0302f85a  00 31  movi r1,0x0
0302f85c  41 c4 07 5c  ins r2,r1,0x0,0x7
0302f860  50 a3  st.b r2,(r3,0x10)
0302f862  06 32  movi r2,0x6
0302f864  43 a3  st.b r2,(r3,0x3)
0302f866  03 14  addi sp,sp,0xc
0302f868  93 14  pop r4,r5,r6,lr

; 0304d07c FUN_0304d07c
0304d07c  d3 14  push r4,r5,r6,lr
0304d07e  22 14  subi sp,sp,0x8
0304d080  6c 12  lrw r3,0x304d1b0
0304d082  60 83  ld.b r3,(r3,0x0)
0304d084  63 e4 02 20  andi r3,r3,0x2
0304d088  cc 74  zextb r3,r3
0304d08a  23 e9 bf 01  bnez r3,0x0304d408
0304d08e  6e 12  lrw r3,0x304d1c4
0304d090  42 83  ld.b r2,(r3,0x2)
0304d092  6e 12  lrw r3,0x304d1c8
0304d094  6c 5a  addu r3,r2,r3
0304d096  62 83  ld.b r3,(r3,0x2)
0304d098  23 e9 3a 00  bnez r3,0x0304d10c
0304d09c  66 12  lrw r3,0x304d1b4
0304d09e  60 83  ld.b r3,(r3,0x0)
0304d0a0  23 e9 1c 00  bnez r3,0x0304d0d8
0304d0a4  01 30  movi r0,0x1
0304d0a6  ff e3 b9 11  bsr 0x0302f418
0304d0aa  20 e9 12 00  bnez r0,0x0304d0ce
0304d0ae  1b 30  movi r0,0x1b
0304d0b0  fe e3 b6 a5  bsr 0x03021c1c
0304d0b4  66 12  lrw r3,0x304d1cc
0304d0b6  43 d8 30 00  ld.b r2,(r3,0x30)
0304d0ba  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304d0be  65 12  lrw r3,0x304d1d0
0304d0c0  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0304d0c4  00 30  movi r0,0x0
0304d0c6  20 93  ld.w r1,(r3,0x0)
0304d0c8  ff e3 16 6a  bsr 0x0303a4f4
0304d0cc  ce 05  br 0x0304d468
0304d0ce  00 30  movi r0,0x0
0304d0d0  01 31  movi r1,0x1
0304d0d2  ff e3 cb 46  bsr 0x03035e68
0304d0d6  c9 05  br 0x0304d468
0304d0d8  9f 11  lrw r4,0x304d1d4
0304d0da  60 84  ld.b r3,(r4,0x0)
0304d0dc  01 36  movi r6,0x1
0304d0de  66 c4 02 5c  ins r3,r6,0x0,0x2
0304d0e2  60 a4  st.b r3,(r4,0x0)
0304d0e4  ff e3 52 11  bsr 0x0302f388
0304d0e8  60 84  ld.b r3,(r4,0x0)
0304d0ea  00 35  movi r5,0x0
0304d0ec  65 c4 02 5c  ins r3,r5,0x0,0x2
0304d0f0  60 a4  st.b r3,(r4,0x0)
0304d0f2  19 30  movi r0,0x19
0304d0f4  fe e3 94 a5  bsr 0x03021c1c
0304d0f8  78 11  lrw r3,0x304d1d8
0304d0fa  50 83  ld.b r2,(r3,0x10)
0304d0fc  45 c4 07 5c  ins r2,r5,0x0,0x7
0304d100  50 a3  st.b r2,(r3,0x10)
0304d102  17 6c  mov r0,r5
0304d104  5b 6c  mov r1,r6
0304d106  ff e3 b1 46  bsr 0x03035e68
0304d10a  af 05  br 0x0304d468
0304d10c  41 3b  cmpnei r3,0x1
0304d10e  38 08  bt 0x0304d17e
0304d110  69 11  lrw r3,0x304d1b4
0304d112  60 83  ld.b r3,(r3,0x0)
0304d114  23 e9 2e 00  bnez r3,0x0304d170
0304d118  71 11  lrw r3,0x304d1dc
0304d11a  60 b8  st.w r3,(sp,0x0)
0304d11c  04 ea ff ff  movi r4,0xffff
0304d120  81 b8  st.w r4,(sp,0x4)
0304d122  08 30  movi r0,0x8
0304d124  28 31  movi r1,0x28
0304d126  18 32  movi r2,0x18
0304d128  48 33  movi r3,0x48
0304d12a  fe e3 27 5e  bsr 0x03018d78
0304d12e  6d 11  lrw r3,0x304d1e0
0304d130  60 b8  st.w r3,(sp,0x0)
0304d132  81 b8  st.w r4,(sp,0x4)
0304d134  08 30  movi r0,0x8
0304d136  28 31  movi r1,0x28
0304d138  18 32  movi r2,0x18
0304d13a  48 33  movi r3,0x48
0304d13c  fe e3 1e 5e  bsr 0x03018d78
0304d140  ff e3 b6 69  bsr 0x0303a4ac
0304d144  32 30  movi r0,0x32
0304d146  00 31  movi r1,0x0
0304d148  ff e3 08 f0  bsr 0x0304b158
0304d14c  66 11  lrw r3,0x304d1e4
0304d14e  09 83  ld.b r0,(r3,0x9)
0304d150  00 e4 3f 20  andi r0,r0,0x3f
0304d154  ff e3 28 08  bsr 0x0302e1a4
0304d158  60 11  lrw r3,0x304d1d8
0304d15a  61 83  ld.b r3,(r3,0x1)
0304d15c  01 3b  cmphsi r3,0x2
0304d15e  85 09  bt 0x0304d468
0304d160  ff e3 c0 0d  bsr 0x0302ece0
0304d164  00 e9 82 01  bez r0,0x0304d468
0304d168  00 30  movi r0,0x0
0304d16a  ff e3 9b 0d  bsr 0x0302eca0
0304d16e  7d 05  br 0x0304d468
0304d170  5e 10  lrw r2,0x304d1e8
0304d172  60 a2  st.b r3,(r2,0x0)
0304d174  1c 30  movi r0,0x1c
0304d176  01 31  movi r1,0x1
0304d178  ff e3 78 46  bsr 0x03035e68
0304d17c  76 05  br 0x0304d468
0304d17e  47 5b  subi r2,r3,0x2
0304d180  88 74  zextb r2,r2
0304d182  01 3a  cmphsi r2,0x2
0304d184  65 08  bt 0x0304d24e
0304d186  42 3b  cmpnei r3,0x2
0304d188  03 65  mvcv r4
0304d18a  13 6c  mov r0,r4
0304d18c  38 10  lrw r1,0x304d1ec
0304d18e  ff e3 8b 12  bsr 0x0302f6a4
0304d192  00 e9 47 00  bez r0,0x0304d220
0304d196  41 3c  cmpnei r4,0x1
0304d198  2e 08  bt 0x0304d1f4
0304d19a  16 10  lrw r0,0x304d1f0
0304d19c  34 10  lrw r1,0x304d1ec
0304d19e  04 32  movi r2,0x4
0304d1a0  7e e2 cc f0  bsr 0x0002b338
0304d1a4  52 30  movi r0,0x52
0304d1a6  00 31  movi r1,0x0
0304d1a8  ff e3 d8 ef  bsr 0x0304b158
0304d1ac  2d 04  br 0x0304d206
0304d1f4  02 13  lrw r0,0x304d37c
0304d1f6  23 13  lrw r1,0x304d380
0304d1f8  04 32  movi r2,0x4
0304d1fa  7e e2 9f f0  bsr 0x0002b338
0304d1fe  53 30  movi r0,0x53
0304d200  00 31  movi r1,0x0
0304d202  ff e3 ab ef  bsr 0x0304b158
0304d206  60 13  lrw r3,0x304d384
0304d208  43 d8 30 00  ld.b r2,(r3,0x30)
0304d20c  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304d210  7e 12  lrw r3,0x304d388
0304d212  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0304d216  01 30  movi r0,0x1
0304d218  20 93  ld.w r1,(r3,0x0)
0304d21a  ff e3 6d 69  bsr 0x0303a4f4
0304d21e  25 05  br 0x0304d468
0304d220  41 3c  cmpnei r4,0x1
0304d222  06 08  bt 0x0304d22e
0304d224  01 30  movi r0,0x1
0304d226  3a 12  lrw r1,0x304d38c
0304d228  ff e3 3e 12  bsr 0x0302f6a4
0304d22c  05 04  br 0x0304d236
0304d22e  00 30  movi r0,0x0
0304d230  33 12  lrw r1,0x304d37c
0304d232  ff e3 39 12  bsr 0x0302f6a4
0304d236  74 12  lrw r3,0x304d384
0304d238  43 d8 30 00  ld.b r2,(r3,0x30)
0304d23c  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304d240  00 30  movi r0,0x0
0304d242  74 12  lrw r3,0x304d390
0304d244  43 d0 81 08  ldr.w r1,(r3,r2<<2)
0304d248  ff e3 56 69  bsr 0x0303a4f4
0304d24c  0e 05  br 0x0304d468
0304d24e  44 3b  cmpnei r3,0x4
0304d250  15 08  bt 0x0304d27a
0304d252  57 30  movi r0,0x57
0304d254  70 12  lrw r3,0x304d394
0304d256  20 83  ld.b r1,(r3,0x0)
0304d258  ff e3 80 ef  bsr 0x0304b158
0304d25c  ff e3 6a a1  bsr 0x03041530
0304d260  69 12  lrw r3,0x304d384
0304d262  43 d8 30 00  ld.b r2,(r3,0x30)
0304d266  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304d26a  68 12  lrw r3,0x304d388
0304d26c  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0304d270  01 30  movi r0,0x1
0304d272  20 93  ld.w r1,(r3,0x0)
0304d274  ff e3 40 69  bsr 0x0303a4f4
0304d278  f8 04  br 0x0304d468
0304d27a  53 5b  subi r2,r3,0x5
0304d27c  88 74  zextb r2,r2
0304d27e  01 3a  cmphsi r2,0x2
0304d280  92 08  bt 0x0304d3a4
0304d282  66 12  lrw r3,0x304d398
0304d284  63 83  ld.b r3,(r3,0x3)
0304d286  63 e4 7f 30  andni r3,r3,0x7f
0304d28a  cc 74  zextb r3,r3
0304d28c  03 e9 10 00  bez r3,0x0304d2ac
0304d290  62 12  lrw r3,0x304d398
0304d292  43 83  ld.b r2,(r3,0x3)
0304d294  00 30  movi r0,0x0
0304d296  40 c4 07 5c  ins r2,r0,0x0,0x7
0304d29a  43 a3  st.b r2,(r3,0x3)
0304d29c  44 83  ld.b r2,(r3,0x4)
0304d29e  40 c4 00 5c  ins r2,r0,0x0,0x0
0304d2a2  44 a3  st.b r2,(r3,0x4)
0304d2a4  01 31  movi r1,0x1
0304d2a6  ff e3 e1 45  bsr 0x03035e68
0304d2aa  df 04  br 0x0304d468
0304d2ac  76 11  lrw r3,0x304d384
0304d2ae  63 d8 2d 00  ld.b r3,(r3,0x2d)
0304d2b2  63 e4 04 20  andi r3,r3,0x4
0304d2b6  cc 74  zextb r3,r3
0304d2b8  03 e9 2d 00  bez r3,0x0304d312
0304d2bc  78 11  lrw r3,0x304d39c
0304d2be  63 d8 5e 00  ld.b r3,(r3,0x5e)
0304d2c2  03 e9 04 00  bez r3,0x0304d2ca
0304d2c6  42 3b  cmpnei r3,0x2
0304d2c8  1a 08  bt 0x0304d2fc
0304d2ca  76 11  lrw r3,0x304d3a0
0304d2cc  51 83  ld.b r2,(r3,0x11)
0304d2ce  32 83  ld.b r1,(r3,0x12)
0304d2d0  28 41  lsli r1,r1 ,0x8
0304d2d2  48 6c  or r1,r2
0304d2d4  33 a3  st.b r1,(r3,0x13)
0304d2d6  48 49  lsri r2,r1,0x8
0304d2d8  54 a3  st.b r2,(r3,0x14)
0304d2da  01 30  movi r0,0x1
0304d2dc  ff e3 e2 1f  bsr 0x030312a0
0304d2e0  6f 11  lrw r3,0x304d39c
0304d2e2  63 d8 5e 00  ld.b r3,(r3,0x5e)
0304d2e6  42 3b  cmpnei r3,0x2
0304d2e8  3f 08  bt 0x0304d366
0304d2ea  4e 11  lrw r2,0x304d3a0
0304d2ec  71 82  ld.b r3,(r2,0x11)
0304d2ee  32 82  ld.b r1,(r2,0x12)
0304d2f0  28 41  lsli r1,r1 ,0x8
0304d2f2  00 30  movi r0,0x0
0304d2f4  4c 6c  or r1,r3
0304d2f6  ff e3 d5 1f  bsr 0x030312a0
0304d2fa  36 04  br 0x0304d366
0304d2fc  41 3b  cmpnei r3,0x1
0304d2fe  34 08  bt 0x0304d366
0304d300  48 11  lrw r2,0x304d3a0
0304d302  71 82  ld.b r3,(r2,0x11)
0304d304  32 82  ld.b r1,(r2,0x12)
0304d306  28 41  lsli r1,r1 ,0x8
0304d308  00 30  movi r0,0x0
0304d30a  4c 6c  or r1,r3
0304d30c  ff e3 ca 1f  bsr 0x030312a0
0304d310  2b 04  br 0x0304d366
0304d312  63 11  lrw r3,0x304d39c
0304d314  63 d8 5e 00  ld.b r3,(r3,0x5e)
0304d318  03 e9 04 00  bez r3,0x0304d320
0304d31c  42 3b  cmpnei r3,0x2
0304d31e  1a 08  bt 0x0304d352
0304d320  60 11  lrw r3,0x304d3a0
0304d322  51 83  ld.b r2,(r3,0x11)
0304d324  32 83  ld.b r1,(r3,0x12)
0304d326  28 41  lsli r1,r1 ,0x8
0304d328  48 6c  or r1,r2
0304d32a  33 a3  st.b r1,(r3,0x13)
0304d32c  48 49  lsri r2,r1,0x8
0304d32e  54 a3  st.b r2,(r3,0x14)
0304d330  01 30  movi r0,0x1
0304d332  ff e3 19 20  bsr 0x03031364
0304d336  7a 10  lrw r3,0x304d39c
0304d338  63 d8 5e 00  ld.b r3,(r3,0x5e)
0304d33c  42 3b  cmpnei r3,0x2
0304d33e  14 08  bt 0x0304d366
0304d340  58 10  lrw r2,0x304d3a0
0304d342  71 82  ld.b r3,(r2,0x11)
0304d344  32 82  ld.b r1,(r2,0x12)
0304d346  28 41  lsli r1,r1 ,0x8
0304d348  00 30  movi r0,0x0
0304d34a  4c 6c  or r1,r3
0304d34c  ff e3 0c 20  bsr 0x03031364
0304d350  0b 04  br 0x0304d366
0304d352  41 3b  cmpnei r3,0x1
0304d354  09 08  bt 0x0304d366
0304d356  53 10  lrw r2,0x304d3a0
0304d358  71 82  ld.b r3,(r2,0x11)
0304d35a  32 82  ld.b r1,(r2,0x12)
0304d35c  28 41  lsli r1,r1 ,0x8
0304d35e  00 30  movi r0,0x0
0304d360  4c 6c  or r1,r3
0304d362  ff e3 01 20  bsr 0x03031364
0304d366  ff e3 a3 68  bsr 0x0303a4ac
0304d36a  08 30  movi r0,0x8
0304d36c  ff e3 fa 18  bsr 0x03030560
0304d370  00 30  movi r0,0x0
0304d372  01 31  movi r1,0x1
0304d374  ff e3 7a 45  bsr 0x03035e68
0304d378  78 04  br 0x0304d468
0304d3a4  47 3b  cmpnei r3,0x7
0304d3a6  1a 08  bt 0x0304d3da
0304d3a8  6a 13  lrw r3,0x304d550
0304d3aa  40 83  ld.b r2,(r3,0x0)
0304d3ac  6a 13  lrw r3,0x304d554
0304d3ae  43 dc 5e 00  st.b r2,(r3,0x5e)
0304d3b2  11 30  movi r0,0x11
0304d3b4  e1 31  movi r1,0xe1
0304d3b6  24 41  lsli r1,r1 ,0x4
0304d3b8  fe e3 38 13  bsr 0x0300fa28
0304d3bc  ff e3 ba a0  bsr 0x03041530
0304d3c0  66 13  lrw r3,0x304d558
0304d3c2  43 d8 30 00  ld.b r2,(r3,0x30)
0304d3c6  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304d3ca  65 13  lrw r3,0x304d55c
0304d3cc  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0304d3d0  01 30  movi r0,0x1
0304d3d2  20 93  ld.w r1,(r3,0x0)
0304d3d4  ff e3 90 68  bsr 0x0303a4f4
0304d3d8  48 04  br 0x0304d468
0304d3da  62 13  lrw r3,0x304d560
0304d3dc  60 83  ld.b r3,(r3,0x0)
0304d3de  03 e9 06 00  bez r3,0x0304d3ea
0304d3e2  61 13  lrw r3,0x304d564
0304d3e4  60 83  ld.b r3,(r3,0x0)
0304d3e6  45 3b  cmpnei r3,0x5
0304d3e8  0b 08  bt 0x0304d3fe
0304d3ea  60 13  lrw r3,0x304d568
0304d3ec  40 83  ld.b r2,(r3,0x0)
0304d3ee  60 13  lrw r3,0x304d56c
0304d3f0  62 d0 20 00  ldr.b r0,(r2,r3<<0)
0304d3f4  00 74  zextb r0,r0
0304d3f6  00 31  movi r1,0x0
0304d3f8  ff e3 38 45  bsr 0x03035e68
0304d3fc  36 04  br 0x0304d468
0304d3fe  1c 30  movi r0,0x1c
0304d400  01 31  movi r1,0x1
0304d402  ff e3 33 45  bsr 0x03035e68
0304d406  31 04  br 0x0304d468
0304d408  7a 12  lrw r3,0x304d570
0304d40a  42 83  ld.b r2,(r3,0x2)
0304d40c  7a 12  lrw r3,0x304d574
0304d40e  6c 5a  addu r3,r2,r3
0304d410  62 83  ld.b r3,(r3,0x2)
0304d412  44 3b  cmpnei r3,0x4
0304d414  26 08  bt 0x0304d460
0304d416  05 33  movi r3,0x5
0304d418  58 12  lrw r2,0x304d578
0304d41a  60 a2  st.b r3,(r2,0x0)
0304d41c  58 12  lrw r2,0x304d57c
0304d41e  60 a2  st.b r3,(r2,0x0)
0304d420  6c 12  lrw r3,0x304d550
0304d422  60 83  ld.b r3,(r3,0x0)
0304d424  02 3b  cmphsi r3,0x3
0304d426  0d 08  bt 0x0304d440
0304d428  56 12  lrw r2,0x304d580
0304d42a  23 82  ld.b r1,(r2,0x3)
0304d42c  00 30  movi r0,0x0
0304d42e  20 c4 03 5c  ins r1,r0,0x0,0x3
0304d432  20 c4 04 5c  ins r1,r0,0x0,0x4
0304d436  23 a2  st.b r1,(r2,0x3)
0304d438  1a 23  addi r3,0x1b
0304d43a  53 12  lrw r2,0x304d584
0304d43c  60 a2  st.b r3,(r2,0x0)
0304d43e  0c 04  br 0x0304d456
0304d440  50 12  lrw r2,0x304d580
0304d442  23 82  ld.b r1,(r2,0x3)
0304d444  01 30  movi r0,0x1
0304d446  20 c4 03 5c  ins r1,r0,0x0,0x3
0304d44a  20 c4 04 5c  ins r1,r0,0x0,0x4
0304d44e  23 a2  st.b r1,(r2,0x3)
0304d450  1a 23  addi r3,0x1b
0304d452  4d 12  lrw r2,0x304d584
0304d454  60 a2  st.b r3,(r2,0x0)
0304d456  62 30  movi r0,0x62
0304d458  01 31  movi r1,0x1
0304d45a  ff e3 07 45  bsr 0x03035e68
0304d45e  05 04  br 0x0304d468
0304d460  1c 30  movi r0,0x1c
0304d462  01 31  movi r1,0x1
0304d464  ff e3 02 45  bsr 0x03035e68
0304d468  02 14  addi sp,sp,0x8
0304d46a  93 14  pop r4,r5,r6,lr

; 0304d970 FUN_0304d970
0304d970  d0 14  push lr
0304d972  72 12  lrw r3,0x304dab8
0304d974  42 83  ld.b r2,(r3,0x2)
0304d976  72 12  lrw r3,0x304dabc
0304d978  6c 5a  addu r3,r2,r3
0304d97a  62 83  ld.b r3,(r3,0x2)
0304d97c  41 3b  cmpnei r3,0x1
0304d97e  22 08  bt 0x0304d9c2
0304d980  6a 12  lrw r3,0x304daa8
0304d982  60 83  ld.b r3,(r3,0x0)
0304d984  23 e9 1b 00  bnez r3,0x0304d9ba
0304d988  ff e3 92 65  bsr 0x0303a4ac
0304d98c  32 30  movi r0,0x32
0304d98e  6b 12  lrw r3,0x304dab8
0304d990  23 83  ld.b r1,(r3,0x3)
0304d992  ff e3 e3 eb  bsr 0x0304b158
0304d996  6b 12  lrw r3,0x304dac0
0304d998  09 83  ld.b r0,(r3,0x9)
0304d99a  00 e4 3f 20  andi r0,r0,0x3f
0304d99e  ff e3 03 04  bsr 0x0302e1a4
0304d9a2  69 12  lrw r3,0x304dac4
0304d9a4  61 83  ld.b r3,(r3,0x1)
0304d9a6  01 3b  cmphsi r3,0x2
0304d9a8  0d 08  bt 0x0304d9c2
0304d9aa  ff e3 9b 09  bsr 0x0302ece0
0304d9ae  00 e9 0a 00  bez r0,0x0304d9c2
0304d9b2  00 30  movi r0,0x0
0304d9b4  ff e3 76 09  bsr 0x0302eca0
0304d9b8  05 04  br 0x0304d9c2
0304d9ba  23 30  movi r0,0x23
0304d9bc  01 31  movi r1,0x1
0304d9be  ff e3 55 42  bsr 0x03035e68
0304d9c2  90 14  pop lr

; 0304d9c4 FUN_0304d9c4
0304d9c4  d2 14  push r4,r5,lr
0304d9c6  22 14  subi sp,sp,0x8
0304d9c8  7c 11  lrw r3,0x304dab8
0304d9ca  43 83  ld.b r2,(r3,0x3)
0304d9cc  7f 11  lrw r3,0x304dac8
0304d9ce  6c 5a  addu r3,r2,r3
0304d9d0  62 83  ld.b r3,(r3,0x2)
0304d9d2  42 3b  cmpnei r3,0x2
0304d9d4  1b 08  bt 0x0304da0a
0304d9d6  7e 11  lrw r3,0x304dacc
0304d9d8  80 83  ld.b r4,(r3,0x0)
0304d9da  7e 11  lrw r3,0x304dad0
0304d9dc  20 8b  ld.h r1,(r3,0x0)
0304d9de  00 21  addi r1,0x1
0304d9e0  13 6c  mov r0,r4
0304d9e2  45 74  zexth r1,r1
0304d9e4  00 e0 8a 48  bsr 0x03056af8
0304d9e8  43 6c  mov r1,r0
0304d9ea  13 6c  mov r0,r4
0304d9ec  00 e0 1e 49  bsr 0x03056c28
0304d9f0  6f 11  lrw r3,0x304daac
0304d9f2  43 d8 30 00  ld.b r2,(r3,0x30)
0304d9f6  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304d9fa  77 11  lrw r3,0x304dad4
0304d9fc  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0304da00  01 30  movi r0,0x1
0304da02  20 93  ld.w r1,(r3,0x0)
0304da04  ff e3 78 65  bsr 0x0303a4f4
0304da08  a5 04  br 0x0304db52
0304da0a  43 3b  cmpnei r3,0x3
0304da0c  9f 08  bt 0x0304db4a
0304da0e  73 11  lrw r3,0x304dad8
0304da10  60 83  ld.b r3,(r3,0x0)
0304da12  4a 3b  cmpnei r3,0xa
0304da14  9f 08  bt 0x0304db52
0304da16  72 11  lrw r3,0x304dadc
0304da18  60 83  ld.b r3,(r3,0x0)
0304da1a  43 3b  cmpnei r3,0x3
0304da1c  8b 08  bt 0x0304db32
0304da1e  71 11  lrw r3,0x304dae0
0304da20  25 83  ld.b r1,(r3,0x5)
0304da22  00 32  movi r2,0x0
0304da24  22 c4 05 5c  ins r1,r2,0x0,0x5
0304da28  25 a3  st.b r1,(r3,0x5)
0304da2a  0f 11  lrw r0,0x304dae4
0304da2c  4b 6c  mov r1,r2
0304da2e  fb 6c  mov r3,sp
0304da30  00 e0 1e f1  bsr 0x0306bc6c
0304da34  00 33  movi r3,0x0
0304da36  0f 2b  subi r3,0x10
0304da38  4c 11  lrw r2,0x304dae8
0304da3a  60 a2  st.b r3,(r2,0x0)
0304da3c  6c 11  lrw r3,0x304daec
0304da3e  60 83  ld.b r3,(r3,0x0)
0304da40  23 e9 0f 00  bnez r3,0x0304da5e
0304da44  7a 10  lrw r3,0x304daac
0304da46  43 d8 30 00  ld.b r2,(r3,0x30)
0304da4a  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304da4e  69 11  lrw r3,0x304daf0
0304da50  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0304da54  00 30  movi r0,0x0
0304da56  20 93  ld.w r1,(r3,0x0)
0304da58  ff e3 4e 65  bsr 0x0303a4f4
0304da5c  7b 04  br 0x0304db52
0304da5e  04 11  lrw r0,0x304daec
0304da60  00 e0 8e 49  bsr 0x03056d7c
0304da64  00 e9 0e 00  bez r0,0x0304da80
0304da68  71 10  lrw r3,0x304daac
0304da6a  43 d8 30 00  ld.b r2,(r3,0x30)
0304da6e  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304da72  00 30  movi r0,0x0
0304da74  60 11  lrw r3,0x304daf4
0304da76  43 d0 81 08  ldr.w r1,(r3,r2<<2)
0304da7a  ff e3 3d 65  bsr 0x0303a4f4
0304da7e  6a 04  br 0x0304db52
0304da80  1e 10  lrw r0,0x304daf8
0304da82  3b 10  lrw r1,0x304daec
0304da84  10 32  movi r2,0x10
0304da86  7e e2 59 ec  bsr 0x0002b338
0304da8a  69 10  lrw r3,0x304daac
0304da8c  63 d8 2d 00  ld.b r3,(r3,0x2d)
0304da90  63 e4 7f 30  andni r3,r3,0x7f
0304da94  cc 74  zextb r3,r3
0304da96  23 e9 35 00  bnez r3,0x0304db00
0304da9a  19 10  lrw r0,0x304dafc
0304da9c  34 10  lrw r1,0x304daec
0304da9e  10 32  movi r2,0x10
0304daa0  7e e2 4c ec  bsr 0x0002b338
0304daa4  33 04  br 0x0304db0a
0304db00  06 13  lrw r0,0x304dc98
0304db02  27 13  lrw r1,0x304dc9c
0304db04  10 32  movi r2,0x10
0304db06  7e e2 19 ec  bsr 0x0002b338
0304db0a  66 13  lrw r3,0x304dca0
0304db0c  00 83  ld.b r0,(r3,0x0)
0304db0e  00 20  addi r0,0x1
0304db10  ae e4 05 00  addi r5,sp,0x6
0304db14  01 1c  addi r4,sp,0x4
0304db16  00 74  zextb r0,r0
0304db18  57 6c  mov r1,r5
0304db1a  93 6c  mov r2,r4
0304db1c  00 e0 ba 40  bsr 0x03055c90
0304db20  00 85  ld.b r0,(r5,0x0)
0304db22  20 8c  ld.h r1,(r4,0x0)
0304db24  5e 12  lrw r2,0x304dc9c
0304db26  10 33  movi r3,0x10
0304db28  fe e3 a8 0e  bsr 0x0300f878
0304db2c  ff e3 c0 64  bsr 0x0303a4ac
0304db30  11 04  br 0x0304db52
0304db32  00 e0 7b 69  bsr 0x0305ae28
0304db36  7c 12  lrw r3,0x304dca4
0304db38  40 83  ld.b r2,(r3,0x0)
0304db3a  7c 12  lrw r3,0x304dca8
0304db3c  62 d0 20 00  ldr.b r0,(r2,r3<<0)
0304db40  00 74  zextb r0,r0
0304db42  00 31  movi r1,0x0
0304db44  ff e3 92 41  bsr 0x03035e68
0304db48  05 04  br 0x0304db52
0304db4a  23 30  movi r0,0x23
0304db4c  01 31  movi r1,0x1
0304db4e  ff e3 8d 41  bsr 0x03035e68
0304db52  02 14  addi sp,sp,0x8
0304db54  92 14  pop r4,r5,lr

; 0305680c FUN_0305680c
0305680c  d8 14  push r4,r5,r6,r7,r8,r9,r10,r11,lr
0305680e  29 14  subi sp,sp,0x24
03056810  00 74  zextb r0,r0
03056812  04 76  zextb r8,r1
03056814  c8 75  zextb r7,r2
03056816  04 1b  addi r3,sp,0x10
03056818  00 32  movi r2,0x0
0305681a  40 b3  st.w r2,(r3,0x0)
0305681c  41 b3  st.w r2,(r3,0x4)
0305681e  42 b3  st.w r2,(r3,0x8)
03056820  43 b3  st.w r2,(r3,0xc)
03056822  50 a3  st.b r2,(r3,0x10)
03056824  07 e9 a1 00  bez r7,0x03056966
03056828  08 c4 84 00  subu r4,r8,r0
0305682c  00 24  addi r4,0x1
0305682e  10 75  zextb r4,r4
03056830  8b 6d  mov r6,r2
03056832  43 5f  subi r2,r7,0x1
03056834  41 b8  st.w r2,(sp,0x4)
03056836  89 ea 58 00  lrw r9,0x3056994
0305683a  8a ea 58 00  lrw r10,0x3056998
0305683e  53 6d  mov r5,r4
03056840  d7 6e  mov r11,r5
03056842  e2 b8  st.w r7,(sp,0x8)
03056844  61 98  ld.w r3,(sp,0x4)
03056846  d5 64  cmplt r5,r3
03056848  2b 0c  bf 0x0305689e
0305684a  02 5d  addi r0,r5,0x1
0305684c  03 1c  addi r4,sp,0xc
0305684e  00 74  zextb r0,r0
03056850  2e e4 0d 00  addi r1,sp,0xe
03056854  93 6c  mov r2,r4
03056856  ff e3 1d fa  bsr 0x03055c90
0305685a  0e d8 0e 00  ld.b r0,(sp,0xe)
0305685e  20 8c  ld.h r1,(r4,0x0)
03056860  04 1a  addi r2,sp,0x10
03056862  10 33  movi r3,0x10
03056864  fd e3 8e c7  bsr 0x0300f780
03056868  16 66  cmpne r5,r8
0305686a  0d 08  bt 0x03056884
0305686c  04 1c  addi r4,sp,0x10
0305686e  02 5e  addi r0,r6,0x1
03056870  53 6c  mov r1,r4
03056872  01 32  movi r2,0x1
03056874  fe e3 fe 11  bsr 0x03018c70
03056878  09 12  lrw r0,0x305699c
0305687a  53 6c  mov r1,r4
0305687c  10 32  movi r2,0x10
0305687e  7e e2 5d a5  bsr 0x0002b338
03056882  06 04  br 0x0305688e
03056884  02 5e  addi r0,r6,0x1
03056886  04 19  addi r1,sp,0x10
03056888  00 32  movi r2,0x0
0305688a  fe e3 f3 11  bsr 0x03018c70
0305688e  02 33  movi r3,0x2
03056890  44 12  lrw r2,0x30569a0
03056892  60 a2  st.b r3,(r2,0x0)
03056894  02 5e  addi r0,r6,0x1
03056896  6f 6c  mov r1,r11
03056898  ff e3 ce 1a  bsr 0x03039e34
0305689c  38 04  br 0x0305690c
0305689e  69 d8 30 00  ld.b r3,(r9,0x30)
030568a2  63 e4 40 20  andi r3,r3,0x40
030568a6  cc 74  zextb r3,r3
030568a8  23 e9 0b 00  bnez r3,0x030568be
030568ac  04 1c  addi r4,sp,0x10
030568ae  13 6c  mov r0,r4
030568b0  3d 11  lrw r1,0x30569a4
030568b2  08 32  movi r2,0x8
030568b4  7e e2 42 a5  bsr 0x0002b338
030568b8  00 33  movi r3,0x0
030568ba  68 a4  st.b r3,(r4,0x8)
030568bc  09 04  br 0x030568ce
030568be  04 1c  addi r4,sp,0x10
030568c0  13 6c  mov r0,r4
030568c2  3a 11  lrw r1,0x30569a8
030568c4  08 32  movi r2,0x8
030568c6  7e e2 39 a5  bsr 0x0002b338
030568ca  00 33  movi r3,0x0
030568cc  68 a4  st.b r3,(r4,0x8)
030568ce  02 5e  addi r0,r6,0x1
030568d0  ca d0 24 00  ldr.b r4,(r10,r6<<0)
030568d4  10 75  zextb r4,r4
030568d6  16 66  cmpne r5,r8
030568d8  0e 08  bt 0x030568f4
030568da  04 19  addi r1,sp,0x10
030568dc  01 32  movi r2,0x1
030568de  fe e3 c9 11  bsr 0x03018c70
030568e2  73 11  lrw r3,0x30569ac
030568e4  60 b8  st.w r3,(sp,0x0)
030568e6  0c 30  movi r0,0xc
030568e8  2e 5c  addi r1,r4,0x4
030568ea  11 32  movi r2,0x11
030568ec  cb 6c  mov r3,r2
030568ee  ff e3 8f 13  bsr 0x0303900c
030568f2  0d 04  br 0x0305690c
030568f4  04 19  addi r1,sp,0x10
030568f6  00 32  movi r2,0x0
030568f8  fe e3 bc 11  bsr 0x03018c70
030568fc  4d 11  lrw r2,0x30569b0
030568fe  40 b8  st.w r2,(sp,0x0)
03056900  0c 30  movi r0,0xc
03056902  2e 5c  addi r1,r4,0x4
03056904  11 32  movi r2,0x11
03056906  cb 6c  mov r3,r2
03056908  ff e3 82 13  bsr 0x0303900c
0305690c  00 25  addi r5,0x1
0305690e  54 75  zextb r5,r5
03056910  d4 65  cmphs r5,r7
03056912  03 08  bt 0x03056918
03056914  47 3e  cmpnei r6,0x7
03056916  24 08  bt 0x0305695e
03056918  7f 10  lrw r3,0x3056994
0305691a  63 d8 30 00  ld.b r3,(r3,0x30)
0305691e  63 e4 40 20  andi r3,r3,0x40
03056922  cc 74  zextb r3,r3
03056924  23 e9 0a 00  bnez r3,0x03056938
03056928  04 18  addi r0,sp,0x10
0305692a  23 11  lrw r1,0x30569b4
0305692c  48 e4 00 00  addi r2,r8,0x1
03056930  62 98  ld.w r3,(sp,0x8)
03056932  00 e0 c9 cd  bsr 0x030704c4
03056936  08 04  br 0x03056946
03056938  04 18  addi r0,sp,0x10
0305693a  20 11  lrw r1,0x30569b8
0305693c  48 e4 00 00  addi r2,r8,0x1
03056940  62 98  ld.w r3,(sp,0x8)
03056942  00 e0 c1 cd  bsr 0x030704c4
03056946  00 30  movi r0,0x0
03056948  43 6c  mov r1,r0
0305694a  fe e3 bb 18  bsr 0x03019ac0
0305694e  01 30  movi r0,0x1
03056950  01 ea ff ff  movi r1,0xffff
03056954  00 32  movi r2,0x0
03056956  04 1b  addi r3,sp,0x10
03056958  fe e3 ce 10  bsr 0x03018af4
0305695c  05 04  br 0x03056966
0305695e  00 26  addi r6,0x1
03056960  d8 74  zextb r3,r6
03056962  cc 65  cmphs r3,r7
03056964  6e 0f  bf 0x03056840
03056966  09 14  addi sp,sp,0x24
03056968  98 14  pop r4,r5,r6,r7,r8,r9,r10,r11,lr

; 0307050c FUN_0307050c
0307050c  c3 14  push r4,r5,r6
0307050e  03 6d  mov r4,r0
03070510  7f 6d  mov r5,lr
03070512  02 11  lrw r0,0x3070598
03070514  00 e0 98 04  bsr 0x03070e44
03070518  13 6c  mov r0,r4
0307051a  d7 6f  mov lr,r5
0307051c  20 11  lrw r1,0x307059c
0307051e  80 91  ld.w r4,(r1,0x0)
03070520  40 3c  cmpnei r4,0x0
03070522  0a 08  bt 0x03070536
03070524  5f 10  lrw r2,0x30705a0
03070526  41 b1  st.w r2,(r1,0x4)
03070528  80 b2  st.w r4,(r2,0x0)
0307052a  7f 10  lrw r3,0x30705a4
0307052c  ca 60  subu r3,r2
0307052e  07 2b  subi r3,0x8
03070530  61 b2  st.w r3,(r2,0x4)
03070532  01 34  movi r4,0x1
03070534  80 b1  st.w r4,(r1,0x0)
03070536  9a 58  addi r4,r0,0x7
03070538  07 30  movi r0,0x7
0307053a  01 69  andn r4,r0
0307053c  00 30  movi r0,0x0
0307053e  ae 59  addi r5,r1,0x4
03070540  21 91  ld.w r1,(r1,0x4)
03070542  0d 04  br 0x0307055c
03070544  41 91  ld.w r2,(r1,0x4)
03070546  08 65  cmphs r2,r4
03070548  08 0c  bf 0x03070558
0307054a  40 38  cmpnei r0,0x0
0307054c  03 0c  bf 0x03070552
0307054e  c8 64  cmphs r2,r3
03070550  04 08  bt 0x03070558
03070552  cb 6c  mov r3,r2
03070554  97 6d  mov r6,r5
03070556  07 6c  mov r0,r1
03070558  47 6d  mov r5,r1
0307055a  20 91  ld.w r1,(r1,0x0)
0307055c  40 39  cmpnei r1,0x0
0307055e  f3 0b  bt 0x03070544
03070560  40 38  cmpnei r0,0x0
03070562  12 0c  bf 0x03070586
03070564  21 90  ld.w r1,(r0,0x4)
03070566  31 59  subu r1,r1,r4
03070568  2e 39  cmplti r1,0xf
0307056a  20 90  ld.w r1,(r0,0x0)
0307056c  0b 08  bt 0x03070582
0307056e  5e 5c  addi r2,r4,0x8
03070570  48 58  addu r2,r0,r2
03070572  20 b2  st.w r1,(r2,0x0)
03070574  21 90  ld.w r1,(r0,0x4)
03070576  07 29  subi r1,0x8
03070578  52 60  subu r1,r4
0307057a  21 b2  st.w r1,(r2,0x4)
0307057c  40 b6  st.w r2,(r6,0x0)
0307057e  81 b0  st.w r4,(r0,0x4)
03070580  02 04  br 0x03070584
03070582  20 b6  st.w r1,(r6,0x0)
03070584  07 20  addi r0,0x8
03070586  03 6d  mov r4,r0
03070588  7f 6d  mov r5,lr
0307058a  04 10  lrw r0,0x3070598
0307058c  00 e0 5e 04  bsr 0x03070e48
03070590  13 6c  mov r0,r4
03070592  d7 6f  mov lr,r5
03070594  83 14  pop r4,r5,r6

; 030705a8 FUN_030705a8
030705a8  c2 14  push r4,r5
030705aa  03 6d  mov r4,r0
030705ac  7f 6d  mov r5,lr
030705ae  1b 10  lrw r0,0x3070618
030705b0  00 e0 4a 04  bsr 0x03070e44
030705b4  13 6c  mov r0,r4
030705b6  d7 6f  mov lr,r5
030705b8  40 38  cmpnei r0,0x0
030705ba  29 0c  bf 0x0307060c
030705bc  5f 58  subi r2,r0,0x8
030705be  61 92  ld.w r3,(r2,0x4)
030705c0  0c 60  addu r0,r3
030705c2  97 10  lrw r4,0x307061c
030705c4  60 94  ld.w r3,(r4,0x0)
030705c6  c2 64  cmpne r0,r3
030705c8  07 08  bt 0x030705d6
030705ca  61 90  ld.w r3,(r0,0x4)
030705cc  21 92  ld.w r1,(r2,0x4)
030705ce  4c 60  addu r1,r3
030705d0  07 21  addi r1,0x8
030705d2  21 b2  st.w r1,(r2,0x4)
030705d4  60 90  ld.w r3,(r0,0x0)
030705d6  40 3b  cmpnei r3,0x0
030705d8  05 0c  bf 0x030705e2
030705da  21 93  ld.w r1,(r3,0x4)
030705dc  07 21  addi r1,0x8
030705de  4c 60  addu r1,r3
030705e0  02 04  br 0x030705e4
030705e2  4f 6c  mov r1,r3
030705e4  86 64  cmpne r1,r2
030705e6  0b 08  bt 0x030705fc
030705e8  01 93  ld.w r0,(r3,0x4)
030705ea  41 91  ld.w r2,(r1,0x4)
030705ec  08 60  addu r0,r2
030705ee  07 20  addi r0,0x8
030705f0  01 b3  st.w r0,(r3,0x4)
030705f2  00 32  movi r2,0x0
030705f4  41 b1  st.w r2,(r1,0x4)
030705f6  60 b1  st.w r3,(r1,0x0)
030705f8  60 b4  st.w r3,(r4,0x0)
030705fa  09 04  br 0x0307060c
030705fc  84 64  cmphs r1,r2
030705fe  04 08  bt 0x03070606
03070600  40 b4  st.w r2,(r4,0x0)
03070602  60 b2  st.w r3,(r2,0x0)
03070604  04 04  br 0x0307060c
03070606  0f 6d  mov r4,r3
03070608  60 93  ld.w r3,(r3,0x0)
0307060a  de 07  br 0x030705c6
0307060c  03 10  lrw r0,0x3070618
0307060e  7f 6d  mov r5,lr
03070610  00 e0 1c 04  bsr 0x03070e48
03070614  d7 6f  mov lr,r5
03070616  82 14  pop r4,r5

; 0002e174 FUN_0002e174
0002e174  d2 14  push r4,r5,lr
0002e176  2a 14  subi sp,sp,0x28
0002e178  ff e3 12 ed  bsr 0x0002bb9c
0002e17c  ff e3 1e f4  bsr 0x0002c9b8
0002e180  81 e1 78 fa  bsr 0x0306d670
0002e184  09 1c  addi r4,sp,0x24
0002e186  13 6c  mov r0,r4
0002e188  ff e3 ea 15  bsr 0x00010d5c
0002e18c  b0 10  lrw r5,0x2e1cc
0002e18e  17 6c  mov r0,r5
0002e190  00 31  movi r1,0x0
0002e192  b4 32  movi r2,0xb4
0002e194  44 42  lsli r2,r2 ,0x4
0002e196  ff e3 dd e8  bsr 0x0002b350
0002e19a  1e 32  movi r2,0x1e
0002e19c  40 b8  st.w r2,(sp,0x0)
0002e19e  a1 b8  st.w r5,(sp,0x4)
0002e1a0  00 33  movi r3,0x0
0002e1a2  62 b8  st.w r3,(sp,0x8)
0002e1a4  b4 32  movi r2,0xb4
0002e1a6  42 42  lsli r2,r2 ,0x2
0002e1a8  43 b8  st.w r2,(sp,0xc)
0002e1aa  64 b8  st.w r3,(sp,0x10)
0002e1ac  65 b8  st.w r3,(sp,0x14)
0002e1ae  66 b8  st.w r3,(sp,0x18)
0002e1b0  03 32  movi r2,0x3
0002e1b2  47 b8  st.w r2,(sp,0x1c)
0002e1b4  88 b8  st.w r4,(sp,0x20)
0002e1b6  07 10  lrw r0,0x2e1d0
0002e1b8  27 10  lrw r1,0x2e1d4
0002e1ba  48 10  lrw r2,0x2e1d8
0002e1bc  ff e3 0e 26  bsr 0x00012dd8
0002e1c0  13 6c  mov r0,r4
0002e1c2  ff e3 21 14  bsr 0x00010a04
0002e1c6  0a 14  addi sp,sp,0x28
0002e1c8  92 14  pop r4,r5,lr

; 0001064a FUN_0001064a
0001064a  03 6c  mov r0,r0
0001064c  31 14  subi sp,sp,0x44
0001064e  0e d4 2d 1c  stm r0,count=0xd,(sp)
00010652  ee dd 0e 20  st.w lr,(sp,0x38)
00010656  02 c0 20 60  mfcr r0,cr<epsr,0x0>
0001065a  0f b8  st.w r0,(sp,0x3c)
0001065c  04 c0 20 60  mfcr r0,cr<epc,0x0>
00010660  10 b8  st.w r0,(sp,0x40)
00010662  15 10  lrw r0,0x106b4
00010664  c0 dd 00 20  st.w sp,(r0,0x0)
00010668  8e ea 16 00  lrw sp,0x106c0
0001066c  00 e0 14 01  bsr 0x00010894
00010670  15 10  lrw r0,0x106c4
00010672  04 31  movi r1,0x4
00010674  20 b0  st.w r1,(r0,0x0)
00010676  35 10  lrw r1,0x106c8
00010678  00 c0 20 60  mfcr r0,cr<psr,0x0>
0001067c  10 48  lsri r0,r0,0x10
0001067e  02 74  sextb r0,r0
00010680  1f 28  subi r0,0x20
00010682  02 40  lsli r0,r0 ,0x2
00010684  40 60  addu r1,r0
00010686  20 91  ld.w r1,(r1,0x0)
00010688  02 48  lsri r0,r0,0x2
0001068a  c5 7b  jsr r1
0001068c  00 e0 12 01  bsr 0x000108b0
00010690  09 10  lrw r0,0x106b4
00010692  c0 d9 00 20  ld.w sp,(r0,0x0)
00010696  00 32  movi r2,0x0
00010698  40 b0  st.w r2,(r0,0x0)
0001069a  10 98  ld.w r0,(sp,0x40)
0001069c  00 c0 24 64  mtcr r0,cr<epc,0x0>
000106a0  0f 98  ld.w r0,(sp,0x3c)
000106a2  00 c0 22 64  mtcr r0,cr<epsr,0x0>
000106a6  0e d0 2d 1c  ldm r0,count=0xd,(sp)
000106aa  ee d9 0e 20  ld.w lr,(sp,0x38)
000106ae  11 14  addi sp,sp,0x44
000106b0  00 c0 20 40  rte

; 0303b6ac FUN_0303b6ac
0303b6ac  d2 14  push r4,r5,lr
0303b6ae  29 14  subi sp,sp,0x24
0303b6b0  71 10  lrw r3,0x303b6f4
0303b6b2  42 83  ld.b r2,(r3,0x2)
0303b6b4  41 3a  cmpnei r2,0x1
0303b6b6  0c 08  bt 0x0303b6ce
0303b6b8  70 10  lrw r3,0x303b6f8
0303b6ba  60 83  ld.b r3,(r3,0x0)
0303b6bc  63 e4 02 20  andi r3,r3,0x2
0303b6c0  cc 74  zextb r3,r3
0303b6c2  23 e9 06 00  bnez r3,0x0303b6ce
0303b6c6  ff e3 57 fe  bsr 0x0303b374
0303b6ca  00 e8 ae 08  br 0x0303c826
0303b6ce  6c 10  lrw r3,0x303b6fc
0303b6d0  20 83  ld.b r1,(r3,0x0)
0303b6d2  08 33  movi r3,0x8
0303b6d4  4c 64  cmphs r3,r1
0303b6d6  04 08  bt 0x0303b6de
0303b6d8  08 31  movi r1,0x8
0303b6da  69 10  lrw r3,0x303b6fc
0303b6dc  20 a3  st.b r1,(r3,0x0)
0303b6de  69 10  lrw r3,0x303b700
0303b6e0  20 83  ld.b r1,(r3,0x0)
0303b6e2  01 eb 34 00  cmphsi r1,0x35
0303b6e6  60 e8 4c 08  bt 0x0303c77e
0303b6ea  67 10  lrw r3,0x303b704
0303b6ec  23 d0 83 08  ldr.w r3,(r3,r1<<2)
0303b6f0  0c 78  jmp r3
0303b708  ff e3 fc e6  bsr 0x03038500
0303b70c  61 13  lrw r3,0x303b890
0303b70e  60 8b  ld.h r3,(r3,0x0)
0303b710  08 32  movi r2,0x8
0303b712  c8 64  cmphs r2,r3
0303b714  05 08  bt 0x0303b71e
0303b716  08 31  movi r1,0x8
0303b718  5f 12  lrw r2,0x303b894
0303b71a  20 a2  st.b r1,(r2,0x0)
0303b71c  03 04  br 0x0303b722
0303b71e  5e 12  lrw r2,0x303b894
0303b720  60 a2  st.b r3,(r2,0x0)
0303b722  23 e9 0d 00  bnez r3,0x0303b73c
0303b726  ff e3 45 da  bsr 0x03036bb0
0303b72a  7c 12  lrw r3,0x303b898
0303b72c  40 83  ld.b r2,(r3,0x0)
0303b72e  79 12  lrw r3,0x303b890
0303b730  40 ab  st.h r2,(r3,0x0)
0303b732  00 32  movi r2,0x0
0303b734  7a 12  lrw r3,0x303b89c
0303b736  44 a3  st.b r2,(r3,0x4)
0303b738  00 e8 77 08  br 0x0303c826
0303b73c  79 12  lrw r3,0x303b8a0
0303b73e  60 93  ld.w r3,(r3,0x0)
0303b740  23 e9 07 00  bnez r3,0x0303b74e
0303b744  00 30  movi r0,0x0
0303b746  fe e3 d3 e3  bsr 0x03017eec
0303b74a  00 e8 6e 08  br 0x0303c826
0303b74e  76 12  lrw r3,0x303b8a4
0303b750  60 83  ld.b r3,(r3,0x0)
0303b752  42 3b  cmpnei r3,0x2
0303b754  07 08  bt 0x0303b762
0303b756  00 30  movi r0,0x0
0303b758  fe e3 ca e3  bsr 0x03017eec
0303b75c  00 e0 40 2f  bsr 0x030415dc
0303b760  08 04  br 0x0303b770
0303b762  53 3b  cmpnei r3,0x13
0303b764  41 08  bt 0x0303b7e6
0303b766  00 30  movi r0,0x0
0303b768  fe e3 c2 e3  bsr 0x03017eec
0303b76c  fe e3 50 b4  bsr 0x0301200c
0303b770  6d 12  lrw r3,0x303b8a4
0303b772  60 83  ld.b r3,(r3,0x0)
0303b774  53 3b  cmpnei r3,0x13
0303b776  38 08  bt 0x0303b7e6
0303b778  00 30  movi r0,0x0
0303b77a  00 b8  st.w r0,(sp,0x0)
0303b77c  91 31  movi r1,0x91
0303b77e  21 41  lsli r1,r1 ,0x1
0303b780  f0 32  movi r2,0xf0
0303b782  a0 33  movi r3,0xa0
0303b784  61 43  lsli r3,r3 ,0x1
0303b786  fe e3 31 e2  bsr 0x03017be8
0303b78a  7f e2 a5 93  bsr 0x0002ded4
0303b78e  41 38  cmpnei r0,0x1
0303b790  05 0c  bf 0x0303b79a
0303b792  7f e2 a1 93  bsr 0x0002ded4
0303b796  43 38  cmpnei r0,0x3
0303b798  13 08  bt 0x0303b7be
0303b79a  64 12  lrw r3,0x303b8a8
0303b79c  43 d8 30 00  ld.b r2,(r3,0x30)
0303b7a0  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303b7a4  62 12  lrw r3,0x303b8ac
0303b7a6  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303b7aa  00 31  movi r1,0x0
0303b7ac  20 b8  st.w r1,(sp,0x0)
0303b7ae  91 30  movi r0,0x91
0303b7b0  01 40  lsli r0,r0 ,0x1
0303b7b2  0c 31  movi r1,0xc
0303b7b4  40 93  ld.w r2,(r3,0x0)
0303b7b6  03 ea ff ff  movi r3,0xffff
0303b7ba  fe e3 bb e8  bsr 0x03018930
0303b7be  7b 11  lrw r3,0x303b8a8
0303b7c0  43 d8 30 00  ld.b r2,(r3,0x30)
0303b7c4  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303b7c8  7a 11  lrw r3,0x303b8b0
0303b7ca  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303b7ce  00 34  movi r4,0x0
0303b7d0  80 b8  st.w r4,(sp,0x0)
0303b7d2  91 30  movi r0,0x91
0303b7d4  01 40  lsli r0,r0 ,0x1
0303b7d6  b4 31  movi r1,0xb4
0303b7d8  40 93  ld.w r2,(r3,0x0)
0303b7da  03 ea ff ff  movi r3,0xffff
0303b7de  fe e3 a9 e8  bsr 0x03018930
0303b7e2  00 e8 cf 07  br 0x0303c780
0303b7e6  fe e3 f7 f1  bsr 0x03019bd4
0303b7ea  00 34  movi r4,0x0
0303b7ec  00 e8 ca 07  br 0x0303c780
0303b7f0  71 11  lrw r3,0x303b8b4
0303b7f2  60 83  ld.b r3,(r3,0x0)
0303b7f4  8d 74  zexth r2,r3
0303b7f6  27 11  lrw r1,0x303b890
0303b7f8  60 a9  st.h r3,(r1,0x0)
0303b7fa  22 e9 0d 00  bnez r2,0x0303b814
0303b7fe  ff e3 d9 d9  bsr 0x03036bb0
0303b802  66 11  lrw r3,0x303b898
0303b804  40 83  ld.b r2,(r3,0x0)
0303b806  63 11  lrw r3,0x303b890
0303b808  40 ab  st.h r2,(r3,0x0)
0303b80a  00 32  movi r2,0x0
0303b80c  64 11  lrw r3,0x303b89c
0303b80e  44 a3  st.b r2,(r3,0x4)
0303b810  00 e8 0b 08  br 0x0303c826
0303b814  fe e3 c4 f1  bsr 0x03019b9c
0303b818  68 11  lrw r3,0x303b8b8
0303b81a  00 83  ld.b r0,(r3,0x0)
0303b81c  00 e0 5c ba  bsr 0x03052cd4
0303b820  fe e3 da f1  bsr 0x03019bd4
0303b824  00 34  movi r4,0x0
0303b826  00 e8 ad 07  br 0x0303c780
0303b82a  63 11  lrw r3,0x303b8b4
0303b82c  60 83  ld.b r3,(r3,0x0)
0303b82e  59 10  lrw r2,0x303b890
0303b830  60 aa  st.h r3,(r2,0x0)
0303b832  08 32  movi r2,0x8
0303b834  c8 64  cmphs r2,r3
0303b836  05 08  bt 0x0303b840
0303b838  08 31  movi r1,0x8
0303b83a  57 10  lrw r2,0x303b894
0303b83c  20 a2  st.b r1,(r2,0x0)
0303b83e  03 04  br 0x0303b844
0303b840  55 10  lrw r2,0x303b894
0303b842  60 a2  st.b r3,(r2,0x0)
0303b844  03 e9 05 00  bez r3,0x0303b84e
0303b848  00 30  movi r0,0x0
0303b84a  fe e3 51 e3  bsr 0x03017eec
0303b84e  7b 10  lrw r3,0x303b8b8
0303b850  00 83  ld.b r0,(r3,0x0)
0303b852  00 e0 d9 b9  bsr 0x03052c04
0303b856  fe e3 bf f1  bsr 0x03019bd4
0303b85a  00 34  movi r4,0x0
0303b85c  00 e8 92 07  br 0x0303c780
0303b860  fc 32  movi r2,0xfc
0303b862  43 42  lsli r2,r2 ,0x3
0303b864  40 b8  st.w r2,(sp,0x0)
0303b866  14 30  movi r0,0x14
0303b868  5a 31  movi r1,0x5a
0303b86a  dc 32  movi r2,0xdc
0303b86c  aa 33  movi r3,0xaa
0303b86e  fe e3 bd e1  bsr 0x03017be8
0303b872  00 e0 6f 6b  bsr 0x03048f50
0303b876  72 10  lrw r3,0x303b8bc
0303b878  40 83  ld.b r2,(r3,0x0)
0303b87a  00 2a  subi r2,0x1
0303b87c  88 74  zextb r2,r2
0303b87e  01 33  movi r3,0x1
0303b880  8c 64  cmphs r3,r2
0303b882  00 c4 04 05  mvc r4
0303b886  fe e3 a7 f1  bsr 0x03019bd4
0303b88a  00 e8 7b 07  br 0x0303c780
0303b8c0  68 13  lrw r3,0x303ba60
0303b8c2  60 83  ld.b r3,(r3,0x0)
0303b8c4  48 13  lrw r2,0x303ba64
0303b8c6  60 aa  st.h r3,(r2,0x0)
0303b8c8  03 e9 04 00  bez r3,0x0303b8d0
0303b8cc  00 e0 1e 5c  bsr 0x03047108
0303b8d0  00 34  movi r4,0x0
0303b8d2  80 b8  st.w r4,(sp,0x0)
0303b8d4  13 6c  mov r0,r4
0303b8d6  91 31  movi r1,0x91
0303b8d8  21 41  lsli r1,r1 ,0x1
0303b8da  f0 32  movi r2,0xf0
0303b8dc  a0 33  movi r3,0xa0
0303b8de  61 43  lsli r3,r3 ,0x1
0303b8e0  fe e3 84 e1  bsr 0x03017be8
0303b8e4  13 6c  mov r0,r4
0303b8e6  fe e3 bd f1  bsr 0x03019c60
0303b8ea  00 e8 4b 07  br 0x0303c780
0303b8ee  7f 12  lrw r3,0x303ba68
0303b8f0  60 93  ld.w r3,(r3,0x0)
0303b8f2  0c ea c0 00  movi r12,0xc0
0303b8f6  2c c5 2c 48  lsli r12,r12,0x9
0303b8fa  f0 68  and r3,r12
0303b8fc  43 eb 00 80  cmpnei r3,0x8000
0303b900  21 08  bt 0x0303b942
0303b902  7b 12  lrw r3,0x303ba6c
0303b904  63 d8 2d 00  ld.b r3,(r3,0x2d)
0303b908  63 e4 7f 30  andni r3,r3,0x7f
0303b90c  cc 74  zextb r3,r3
0303b90e  40 3b  cmpnei r3,0x0
0303b910  3b 31  movi r1,0x3b
0303b912  b1 32  movi r2,0xb1
0303b914  61 c4 40 0c  movt r3,r1
0303b918  62 c4 20 0c  movf r3,r2
0303b91c  54 12  lrw r2,0x303ba6c
0303b91e  42 d8 6c 00  ld.b r2,(r2,0x6c)
0303b922  40 3a  cmpnei r2,0x0
0303b924  0c ea 59 00  movi r12,0x59
0303b928  6c c4 20 0c  movf r3,r12
0303b92c  2c 23  addi r3,0x2d
0303b92e  cc 74  zextb r3,r3
0303b930  00 34  movi r4,0x0
0303b932  80 b8  st.w r4,(sp,0x0)
0303b934  0a 30  movi r0,0xa
0303b936  4f 6c  mov r1,r3
0303b938  e3 32  movi r2,0xe3
0303b93a  1a 23  addi r3,0x1b
0303b93c  fe e3 56 e1  bsr 0x03017be8
0303b940  2f 04  br 0x0303b99e
0303b942  6c 12  lrw r3,0x303ba70
0303b944  66 83  ld.b r3,(r3,0x6)
0303b946  63 e4 0c 20  andi r3,r3,0xc
0303b94a  03 e9 27 00  bez r3,0x0303b998
0303b94e  68 12  lrw r3,0x303ba6c
0303b950  63 d8 2d 00  ld.b r3,(r3,0x2d)
0303b954  63 e4 7f 30  andni r3,r3,0x7f
0303b958  cc 74  zextb r3,r3
0303b95a  40 3b  cmpnei r3,0x0
0303b95c  b1 31  movi r1,0xb1
0303b95e  3b 32  movi r2,0x3b
0303b960  61 c4 40 0c  movt r3,r1
0303b964  62 c4 20 0c  movf r3,r2
0303b968  41 12  lrw r2,0x303ba6c
0303b96a  42 d8 6c 00  ld.b r2,(r2,0x6c)
0303b96e  22 e9 0b 00  bnez r2,0x0303b984
0303b972  00 34  movi r4,0x0
0303b974  80 b8  st.w r4,(sp,0x0)
0303b976  08 30  movi r0,0x8
0303b978  59 31  movi r1,0x59
0303b97a  eb 32  movi r2,0xeb
0303b97c  74 33  movi r3,0x74
0303b97e  fe e3 35 e1  bsr 0x03017be8
0303b982  0e 04  br 0x0303b99e
0303b984  33 5b  subi r1,r3,0x5
0303b986  00 34  movi r4,0x0
0303b988  80 b8  st.w r4,(sp,0x0)
0303b98a  08 30  movi r0,0x8
0303b98c  45 74  zexth r1,r1
0303b98e  eb 32  movi r2,0xeb
0303b990  22 23  addi r3,0x23
0303b992  fe e3 2b e1  bsr 0x03017be8
0303b996  04 04  br 0x0303b99e
0303b998  fe e3 02 f1  bsr 0x03019b9c
0303b99c  01 34  movi r4,0x1
0303b99e  00 e0 cf ed  bsr 0x0305953c
0303b9a2  74 11  lrw r3,0x303ba70
0303b9a4  64 83  ld.b r3,(r3,0x4)
0303b9a6  43 e4 10 20  andi r2,r3,0x10
0303b9aa  88 74  zextb r2,r2
0303b9ac  02 e9 13 00  bez r2,0x0303b9d2
0303b9b0  6f 11  lrw r3,0x303ba6c
0303b9b2  43 d8 30 00  ld.b r2,(r3,0x30)
0303b9b6  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303b9ba  6f 11  lrw r3,0x303ba74
0303b9bc  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303b9c0  01 30  movi r0,0x1
0303b9c2  01 ea ff ff  movi r1,0xffff
0303b9c6  00 32  movi r2,0x0
0303b9c8  66 93  ld.w r3,(r3,0x18)
0303b9ca  fe e3 95 e8  bsr 0x03018af4
0303b9ce  01 35  movi r5,0x1
0303b9d0  02 05  br 0x0303bbd4
0303b9d2  43 e4 60 20  andi r2,r3,0x60
0303b9d6  02 e9 2f 00  bez r2,0x0303ba34
0303b9da  66 11  lrw r3,0x303ba70
0303b9dc  83 d9 04 00  ld.b r12,(r3,0x4)
0303b9e0  ac c4 cc 54  zext r12,r12,0x6,0x5
0303b9e4  2c eb 02 00  cmplti r12,0x3
0303b9e8  15 0c  bf 0x0303ba12
0303b9ea  61 11  lrw r3,0x303ba6c
0303b9ec  43 d8 30 00  ld.b r2,(r3,0x30)
0303b9f0  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303b9f4  8c e5 00 10  subi r12,r12,0x1
0303b9f8  60 11  lrw r3,0x303ba78
0303b9fa  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303b9fe  01 30  movi r0,0x1
0303ba00  01 ea ff ff  movi r1,0xffff
0303ba04  00 32  movi r2,0x0
0303ba06  83 d1 83 08  ldr.w r3,(r3,r12<<2)
0303ba0a  fe e3 75 e8  bsr 0x03018af4
0303ba0e  01 35  movi r5,0x1
0303ba10  e2 04  br 0x0303bbd4
0303ba12  77 10  lrw r3,0x303ba6c
0303ba14  43 d8 30 00  ld.b r2,(r3,0x30)
0303ba18  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303ba1c  76 10  lrw r3,0x303ba74
0303ba1e  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303ba22  01 30  movi r0,0x1
0303ba24  01 ea ff ff  movi r1,0xffff
0303ba28  00 32  movi r2,0x0
0303ba2a  74 93  ld.w r3,(r3,0x50)
0303ba2c  fe e3 64 e8  bsr 0x03018af4
0303ba30  01 35  movi r5,0x1
0303ba32  d1 04  br 0x0303bbd4
0303ba34  63 e4 7f 30  andni r3,r3,0x7f
0303ba38  03 e9 22 00  bez r3,0x0303ba7c
0303ba3c  6c 10  lrw r3,0x303ba6c
0303ba3e  43 d8 30 00  ld.b r2,(r3,0x30)
0303ba42  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303ba46  6c 10  lrw r3,0x303ba74
0303ba48  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303ba4c  01 30  movi r0,0x1
0303ba4e  01 ea ff ff  movi r1,0xffff
0303ba52  00 32  movi r2,0x0
0303ba54  67 93  ld.w r3,(r3,0x1c)
0303ba56  fe e3 4f e8  bsr 0x03018af4
0303ba5a  01 35  movi r5,0x1
0303ba5c  bc 04  br 0x0303bbd4
0303ba7c  7f 12  lrw r3,0x303bbf8
0303ba7e  65 83  ld.b r3,(r3,0x5)
0303ba80  43 e4 04 20  andi r2,r3,0x4
0303ba84  88 74  zextb r2,r2
0303ba86  02 e9 19 00  bez r2,0x0303bab8
0303ba8a  7d 12  lrw r3,0x303bbfc
0303ba8c  43 d8 30 00  ld.b r2,(r3,0x30)
0303ba90  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303ba94  79 12  lrw r3,0x303bbf8
0303ba96  83 d9 03 00  ld.b r12,(r3,0x3)
0303ba9a  4c c4 4c 54  zext r12,r12,0x2,0x2
0303ba9e  79 12  lrw r3,0x303bc00
0303baa0  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303baa4  01 30  movi r0,0x1
0303baa6  01 ea ff ff  movi r1,0xffff
0303baaa  00 32  movi r2,0x0
0303baac  83 d1 83 08  ldr.w r3,(r3,r12<<2)
0303bab0  fe e3 22 e8  bsr 0x03018af4
0303bab4  01 35  movi r5,0x1
0303bab6  8f 04  br 0x0303bbd4
0303bab8  43 e4 10 20  andi r2,r3,0x10
0303babc  88 74  zextb r2,r2
0303babe  02 e9 13 00  bez r2,0x0303bae4
0303bac2  6f 12  lrw r3,0x303bbfc
0303bac4  43 d8 30 00  ld.b r2,(r3,0x30)
0303bac8  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303bacc  6e 12  lrw r3,0x303bc04
0303bace  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303bad2  01 30  movi r0,0x1
0303bad4  01 ea ff ff  movi r1,0xffff
0303bad8  00 32  movi r2,0x0
0303bada  62 93  ld.w r3,(r3,0x8)
0303badc  fe e3 0c e8  bsr 0x03018af4
0303bae0  01 35  movi r5,0x1
0303bae2  79 04  br 0x0303bbd4
0303bae4  45 12  lrw r2,0x303bbf8
0303bae6  46 82  ld.b r2,(r2,0x6)
0303bae8  22 e4 04 20  andi r1,r2,0x4
0303baec  44 74  zextb r1,r1
0303baee  21 e9 99 06  bnez r1,0x0303c820
0303baf2  22 e4 08 20  andi r1,r2,0x8
0303baf6  44 74  zextb r1,r1
0303baf8  21 e9 93 06  bnez r1,0x0303c81e
0303bafc  42 e4 40 20  andi r2,r2,0x40
0303bb00  88 74  zextb r2,r2
0303bb02  02 e9 12 00  bez r2,0x0303bb26
0303bb06  7e 11  lrw r3,0x303bbfc
0303bb08  83 d9 30 00  ld.b r12,(r3,0x30)
0303bb0c  cc c4 cc 54  zext r12,r12,0x6,0x6
0303bb10  01 30  movi r0,0x1
0303bb12  01 ea ff ff  movi r1,0xffff
0303bb16  00 32  movi r2,0x0
0303bb18  7c 11  lrw r3,0x303bc08
0303bb1a  83 d1 83 08  ldr.w r3,(r3,r12<<2)
0303bb1e  fe e3 eb e7  bsr 0x03018af4
0303bb22  01 35  movi r5,0x1
0303bb24  58 04  br 0x0303bbd4
0303bb26  43 e4 7f 30  andni r2,r3,0x7f
0303bb2a  02 e9 16 00  bez r2,0x0303bb56
0303bb2e  74 11  lrw r3,0x303bbfc
0303bb30  43 d8 30 00  ld.b r2,(r3,0x30)
0303bb34  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303bb38  75 11  lrw r3,0x303bc0c
0303bb3a  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303bb3e  01 30  movi r0,0x1
0303bb40  01 ea ff ff  movi r1,0xffff
0303bb44  00 32  movi r2,0x0
0303bb46  61 93  ld.w r3,(r3,0x4)
0303bb48  fe e3 d6 e7  bsr 0x03018af4
0303bb4c  01 30  movi r0,0x1
0303bb4e  00 e0 a1 f0  bsr 0x03059c90
0303bb52  01 35  movi r5,0x1
0303bb54  40 04  br 0x0303bbd4
0303bb56  63 e4 40 20  andi r3,r3,0x40
0303bb5a  cc 74  zextb r3,r3
0303bb5c  03 e9 62 06  bez r3,0x0303c820
0303bb60  6c 11  lrw r3,0x303bc10
0303bb62  41 83  ld.b r2,(r3,0x1)
0303bb64  6c 11  lrw r3,0x303bc14
0303bb66  6c 5a  addu r3,r2,r3
0303bb68  62 83  ld.b r3,(r3,0x2)
0303bb6a  23 e9 1a 00  bnez r3,0x0303bb9e
0303bb6e  00 35  movi r5,0x0
0303bb70  a0 b8  st.w r5,(sp,0x0)
0303bb72  17 6c  mov r0,r5
0303bb74  91 31  movi r1,0x91
0303bb76  21 41  lsli r1,r1 ,0x1
0303bb78  f0 32  movi r2,0xf0
0303bb7a  a0 33  movi r3,0xa0
0303bb7c  61 43  lsli r3,r3 ,0x1
0303bb7e  fe e3 35 e0  bsr 0x03017be8
0303bb82  17 6c  mov r0,r5
0303bb84  fe e3 8a f0  bsr 0x03019c98
0303bb88  7c 10  lrw r3,0x303bbf8
0303bb8a  63 83  ld.b r3,(r3,0x3)
0303bb8c  63 e4 04 20  andi r3,r3,0x4
0303bb90  cc 74  zextb r3,r3
0303bb92  23 e9 08 00  bnez r3,0x0303bba2
0303bb96  17 6c  mov r0,r5
0303bb98  fe e3 96 f0  bsr 0x03019cc4
0303bb9c  04 04  br 0x0303bba4
0303bb9e  01 35  movi r5,0x1
0303bba0  02 04  br 0x0303bba4
0303bba2  00 35  movi r5,0x0
0303bba4  76 10  lrw r3,0x303bbfc
0303bba6  43 d8 30 00  ld.b r2,(r3,0x30)
0303bbaa  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303bbae  73 10  lrw r3,0x303bbf8
0303bbb0  83 d9 03 00  ld.b r12,(r3,0x3)
0303bbb4  4c c4 4c 54  zext r12,r12,0x2,0x2
0303bbb8  72 10  lrw r3,0x303bc00
0303bbba  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303bbbe  01 30  movi r0,0x1
0303bbc0  01 ea ff ff  movi r1,0xffff
0303bbc4  00 32  movi r2,0x0
0303bbc6  83 d1 83 08  ldr.w r3,(r3,r12<<2)
0303bbca  fe e3 95 e7  bsr 0x03018af4
0303bbce  01 30  movi r0,0x1
0303bbd0  00 e0 60 f0  bsr 0x03059c90
0303bbd4  69 10  lrw r3,0x303bbf8
0303bbd6  65 83  ld.b r3,(r3,0x5)
0303bbd8  63 e4 10 20  andi r3,r3,0x10
0303bbdc  cc 74  zextb r3,r3
0303bbde  03 e9 1d 00  bez r3,0x0303bc18
0303bbe2  00 30  movi r0,0x0
0303bbe4  00 b8  st.w r0,(sp,0x0)
0303bbe6  91 31  movi r1,0x91
0303bbe8  21 41  lsli r1,r1 ,0x1
0303bbea  f0 32  movi r2,0xf0
0303bbec  a0 33  movi r3,0xa0
0303bbee  61 43  lsli r3,r3 ,0x1
0303bbf0  fe e3 fc df  bsr 0x03017be8
0303bbf4  00 e8 c6 05  br 0x0303c780
0303bc18  68 13  lrw r3,0x303bdb8
0303bc1a  66 83  ld.b r3,(r3,0x6)
0303bc1c  63 e4 0c 20  andi r3,r3,0xc
0303bc20  23 e9 b0 05  bnez r3,0x0303c780
0303bc24  66 13  lrw r3,0x303bdbc
0303bc26  60 93  ld.w r3,(r3,0x0)
0303bc28  0c ea c0 00  movi r12,0xc0
0303bc2c  2c c5 2c 48  lsli r12,r12,0x9
0303bc30  f0 68  and r3,r12
0303bc32  43 eb 00 80  cmpnei r3,0x8000
0303bc36  40 e8 a5 05  bf 0x0303c780
0303bc3a  05 e9 a3 05  bez r5,0x0303c780
0303bc3e  fe e3 cb ef  bsr 0x03019bd4
0303bc42  00 e8 9f 05  br 0x0303c780
0303bc46  1f 12  lrw r0,0x303bdc0
0303bc48  00 31  movi r1,0x0
0303bc4a  87 6c  mov r2,r1
0303bc4c  08 1b  addi r3,sp,0x20
0303bc4e  01 e0 0f 80  bsr 0x0306bc6c
0303bc52  fe e3 a5 ef  bsr 0x03019b9c
0303bc56  7c 12  lrw r3,0x303bdc4
0303bc58  43 d8 30 00  ld.b r2,(r3,0x30)
0303bc5c  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303bc60  7a 12  lrw r3,0x303bdc8
0303bc62  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303bc66  01 30  movi r0,0x1
0303bc68  01 ea ff ff  movi r1,0xffff
0303bc6c  00 32  movi r2,0x0
0303bc6e  60 93  ld.w r3,(r3,0x0)
0303bc70  fe e3 42 e7  bsr 0x03018af4
0303bc74  01 30  movi r0,0x1
0303bc76  00 e0 0d f0  bsr 0x03059c90
0303bc7a  00 34  movi r4,0x0
0303bc7c  80 b8  st.w r4,(sp,0x0)
0303bc7e  13 6c  mov r0,r4
0303bc80  91 31  movi r1,0x91
0303bc82  21 41  lsli r1,r1 ,0x1
0303bc84  f0 32  movi r2,0xf0
0303bc86  a0 33  movi r3,0xa0
0303bc88  61 43  lsli r3,r3 ,0x1
0303bc8a  fe e3 af df  bsr 0x03017be8
0303bc8e  00 e0 3b ee  bsr 0x03059904
0303bc92  00 e8 77 05  br 0x0303c780
0303bc96  ff e3 95 c9  bsr 0x03034fc0
0303bc9a  43 6d  mov r5,r0
0303bc9c  00 34  movi r4,0x0
0303bc9e  80 b8  st.w r4,(sp,0x0)
0303bca0  13 6c  mov r0,r4
0303bca2  53 6c  mov r1,r4
0303bca4  f0 32  movi r2,0xf0
0303bca6  1b 33  movi r3,0x1b
0303bca8  fe e3 a0 df  bsr 0x03017be8
0303bcac  13 6c  mov r0,r4
0303bcae  fe e3 1f e1  bsr 0x03017eec
0303bcb2  17 6c  mov r0,r5
0303bcb4  ff e3 80 c8  bsr 0x03034db4
0303bcb8  c3 6c  mov r3,r0
0303bcba  17 6c  mov r0,r5
0303bcbc  44 12  lrw r2,0x303bdcc
0303bcbe  20 8a  ld.h r1,(r2,0x0)
0303bcc0  44 12  lrw r2,0x303bdd0
0303bcc2  40 8a  ld.h r2,(r2,0x0)
0303bcc4  ff e3 d2 c2  bsr 0x03034268
0303bcc8  fe e3 86 ef  bsr 0x03019bd4
0303bccc  00 e8 5a 05  br 0x0303c780
0303bcd0  ff e3 78 c9  bsr 0x03034fc0
0303bcd4  43 6d  mov r5,r0
0303bcd6  00 34  movi r4,0x0
0303bcd8  80 b8  st.w r4,(sp,0x0)
0303bcda  13 6c  mov r0,r4
0303bcdc  53 6c  mov r1,r4
0303bcde  f0 32  movi r2,0xf0
0303bce0  1b 33  movi r3,0x1b
0303bce2  fe e3 83 df  bsr 0x03017be8
0303bce6  13 6c  mov r0,r4
0303bce8  fe e3 02 e1  bsr 0x03017eec
0303bcec  17 6c  mov r0,r5
0303bcee  ff e3 63 c8  bsr 0x03034db4
0303bcf2  62 58  addi r3,r0,0x1
0303bcf4  17 6c  mov r0,r5
0303bcf6  56 11  lrw r2,0x303bdcc
0303bcf8  20 8a  ld.h r1,(r2,0x0)
0303bcfa  56 11  lrw r2,0x303bdd0
0303bcfc  40 8a  ld.h r2,(r2,0x0)
0303bcfe  cd 74  zexth r3,r3
0303bd00  ff e3 7e c1  bsr 0x03033ffc
0303bd04  fe e3 68 ef  bsr 0x03019bd4
0303bd08  00 e8 3c 05  br 0x0303c780
0303bd0c  72 11  lrw r3,0x303bdd4
0303bd0e  60 8b  ld.h r3,(r3,0x0)
0303bd10  23 e9 12 00  bnez r3,0x0303bd34
0303bd14  71 11  lrw r3,0x303bdd8
0303bd16  20 83  ld.b r1,(r3,0x0)
0303bd18  6f 11  lrw r3,0x303bdd4
0303bd1a  20 ab  st.h r1,(r3,0x0)
0303bd1c  70 11  lrw r3,0x303bddc
0303bd1e  62 d0 20 00  ldr.b r0,(r2,r3<<0)
0303bd22  00 74  zextb r0,r0
0303bd24  00 31  movi r1,0x0
0303bd26  ff e3 a1 d0  bsr 0x03035e68
0303bd2a  02 32  movi r2,0x2
0303bd2c  6d 11  lrw r3,0x303bde0
0303bd2e  40 a3  st.b r2,(r3,0x0)
0303bd30  00 e8 7b 05  br 0x0303c826
0303bd34  00 30  movi r0,0x0
0303bd36  fe e3 db e0  bsr 0x03017eec
0303bd3a  6b 11  lrw r3,0x303bde4
0303bd3c  00 93  ld.w r0,(r3,0x0)
0303bd3e  6b 11  lrw r3,0x303bde8
0303bd40  20 93  ld.w r1,(r3,0x0)
0303bd42  6b 11  lrw r3,0x303bdec
0303bd44  40 93  ld.w r2,(r3,0x0)
0303bd46  ff e3 f5 bc  bsr 0x03033730
0303bd4a  fe e3 45 ef  bsr 0x03019bd4
0303bd4e  00 34  movi r4,0x0
0303bd50  00 e8 18 05  br 0x0303c780
0303bd54  00 34  movi r4,0x0
0303bd56  80 b8  st.w r4,(sp,0x0)
0303bd58  13 6c  mov r0,r4
0303bd5a  53 6c  mov r1,r4
0303bd5c  f0 32  movi r2,0xf0
0303bd5e  1b 33  movi r3,0x1b
0303bd60  fe e3 44 df  bsr 0x03017be8
0303bd64  78 10  lrw r3,0x303bdc4
0303bd66  43 d8 30 00  ld.b r2,(r3,0x30)
0303bd6a  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303bd6e  61 11  lrw r3,0x303bdf0
0303bd70  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303bd74  01 30  movi r0,0x1
0303bd76  01 ea ff ff  movi r1,0xffff
0303bd7a  93 6c  mov r2,r4
0303bd7c  62 93  ld.w r3,(r3,0x8)
0303bd7e  fe e3 bb e6  bsr 0x03018af4
0303bd82  13 6c  mov r0,r4
0303bd84  fe e3 b4 e0  bsr 0x03017eec
0303bd88  7b 10  lrw r3,0x303bdf4
0303bd8a  41 83  ld.b r2,(r3,0x1)
0303bd8c  7b 10  lrw r3,0x303bdf8
0303bd8e  6c 5a  addu r3,r2,r3
0303bd90  62 83  ld.b r3,(r3,0x2)
0303bd92  41 3b  cmpnei r3,0x1
0303bd94  38 08  bt 0x0303be04
0303bd96  7a 10  lrw r3,0x303bdfc
0303bd98  00 83  ld.b r0,(r3,0x0)
0303bd9a  68 10  lrw r3,0x303bdb8
0303bd9c  29 8b  ld.h r1,(r3,0x12)
0303bd9e  ff e3 39 95  bsr 0x0302e810
0303bda2  83 6c  mov r2,r0
0303bda4  77 10  lrw r3,0x303be00
0303bda6  00 ab  st.h r0,(r3,0x0)
0303bda8  69 10  lrw r3,0x303bdcc
0303bdaa  00 8b  ld.h r0,(r3,0x0)
0303bdac  69 10  lrw r3,0x303bdd0
0303bdae  20 8b  ld.h r1,(r3,0x0)
0303bdb0  00 e0 92 d8  bsr 0x03056ed4
0303bdb4  3a 04  br 0x0303be28
0303be04  42 3b  cmpnei r3,0x2
0303be06  11 08  bt 0x0303be28
0303be08  66 13  lrw r3,0x303bfa0
0303be0a  60 83  ld.b r3,(r3,0x0)
0303be0c  46 13  lrw r2,0x303bfa4
0303be0e  49 8a  ld.h r2,(r2,0x12)
0303be10  4d 5a  subu r2,r2,r3
0303be12  89 74  zexth r2,r2
0303be14  65 13  lrw r3,0x303bfa8
0303be16  40 ab  st.h r2,(r3,0x0)
0303be18  65 13  lrw r3,0x303bfac
0303be1a  40 ab  st.h r2,(r3,0x0)
0303be1c  65 13  lrw r3,0x303bfb0
0303be1e  00 8b  ld.h r0,(r3,0x0)
0303be20  65 13  lrw r3,0x303bfb4
0303be22  20 8b  ld.h r1,(r3,0x0)
0303be24  00 e0 c4 d6  bsr 0x03056bac
0303be28  fe e3 d6 ee  bsr 0x03019bd4
0303be2c  00 34  movi r4,0x0
0303be2e  00 e8 a9 04  br 0x0303c780
0303be32  00 34  movi r4,0x0
0303be34  80 b8  st.w r4,(sp,0x0)
0303be36  13 6c  mov r0,r4
0303be38  53 6c  mov r1,r4
0303be3a  f0 32  movi r2,0xf0
0303be3c  1b 33  movi r3,0x1b
0303be3e  fe e3 d5 de  bsr 0x03017be8
0303be42  7e 12  lrw r3,0x303bfb8
0303be44  43 d8 30 00  ld.b r2,(r3,0x30)
0303be48  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303be4c  7c 12  lrw r3,0x303bfbc
0303be4e  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303be52  01 30  movi r0,0x1
0303be54  01 ea ff ff  movi r1,0xffff
0303be58  93 6c  mov r2,r4
0303be5a  62 93  ld.w r3,(r3,0x8)
0303be5c  fe e3 4c e6  bsr 0x03018af4
0303be60  13 6c  mov r0,r4
0303be62  fe e3 45 e0  bsr 0x03017eec
0303be66  77 12  lrw r3,0x303bfc0
0303be68  46 83  ld.b r2,(r3,0x6)
0303be6a  77 12  lrw r3,0x303bfc4
0303be6c  60 83  ld.b r3,(r3,0x0)
0303be6e  4d 5a  subu r2,r2,r3
0303be70  88 74  zextb r2,r2
0303be72  76 12  lrw r3,0x303bfc8
0303be74  40 a3  st.b r2,(r3,0x0)
0303be76  76 12  lrw r3,0x303bfcc
0303be78  40 ab  st.h r2,(r3,0x0)
0303be7a  76 12  lrw r3,0x303bfd0
0303be7c  00 83  ld.b r0,(r3,0x0)
0303be7e  76 12  lrw r3,0x303bfd4
0303be80  20 83  ld.b r1,(r3,0x0)
0303be82  01 e0 59 57  bsr 0x03066d34
0303be86  00 e8 7d 04  br 0x0303c780
0303be8a  74 12  lrw r3,0x303bfd8
0303be8c  60 83  ld.b r3,(r3,0x0)
0303be8e  50 12  lrw r2,0x303bfcc
0303be90  60 aa  st.h r3,(r2,0x0)
0303be92  08 32  movi r2,0x8
0303be94  c8 64  cmphs r2,r3
0303be96  04 08  bt 0x0303be9e
0303be98  71 12  lrw r3,0x303bfdc
0303be9a  40 a3  st.b r2,(r3,0x0)
0303be9c  03 04  br 0x0303bea2
0303be9e  50 12  lrw r2,0x303bfdc
0303bea0  60 a2  st.b r3,(r2,0x0)
0303bea2  00 30  movi r0,0x0
0303bea4  fe e3 24 e0  bsr 0x03017eec
0303bea8  6e 12  lrw r3,0x303bfe0
0303beaa  02 83  ld.b r0,(r3,0x2)
0303beac  00 20  addi r0,0x1
0303beae  00 74  zextb r0,r0
0303beb0  00 e0 08 e8  bsr 0x03058ec0
0303beb4  fe e3 90 ee  bsr 0x03019bd4
0303beb8  00 34  movi r4,0x0
0303beba  00 e8 63 04  br 0x0303c780
0303bebe  12 32  movi r2,0x12
0303bec0  69 12  lrw r3,0x303bfe4
0303bec2  40 a3  st.b r2,(r3,0x0)
0303bec4  00 e8 b1 04  br 0x0303c826
0303bec8  64 12  lrw r3,0x303bfd8
0303beca  60 83  ld.b r3,(r3,0x0)
0303becc  8d 74  zexth r2,r3
0303bece  20 12  lrw r1,0x303bfcc
0303bed0  60 a9  st.h r3,(r1,0x0)
0303bed2  66 12  lrw r3,0x303bfe8
0303bed4  20 93  ld.w r1,(r3,0x0)
0303bed6  60 91  ld.w r3,(r1,0x0)
0303bed8  03 e9 2f 00  bez r3,0x0303bf36
0303bedc  41 3a  cmpnei r2,0x1
0303bede  09 08  bt 0x0303bef0
0303bee0  23 12  lrw r1,0x303bfec
0303bee2  20 b8  st.w r1,(sp,0x0)
0303bee4  30 30  movi r0,0x30
0303bee6  43 6c  mov r1,r0
0303bee8  42 12  lrw r2,0x303bff0
0303beea  fe e3 2b f6  bsr 0x0301ab40
0303beee  24 04  br 0x0303bf36
0303bef0  42 3a  cmpnei r2,0x2
0303bef2  09 08  bt 0x0303bf04
0303bef4  21 91  ld.w r1,(r1,0x4)
0303bef6  20 b8  st.w r1,(sp,0x0)
0303bef8  30 30  movi r0,0x30
0303befa  43 6c  mov r1,r0
0303befc  5d 11  lrw r2,0x303bff0
0303befe  fe e3 21 f6  bsr 0x0301ab40
0303bf02  1a 04  br 0x0303bf36
0303bf04  43 3a  cmpnei r2,0x3
0303bf06  18 08  bt 0x0303bf36
0303bf08  72 30  movi r0,0x72
0303bf0a  00 31  movi r1,0x0
0303bf0c  02 ea 18 c6  movi r2,0xc618
0303bf10  fe e3 f2 e5  bsr 0x03018af4
0303bf14  95 11  lrw r4,0x303bfe8
0303bf16  60 94  ld.w r3,(r4,0x0)
0303bf18  90 30  movi r0,0x90
0303bf1a  00 31  movi r1,0x0
0303bf1c  02 ea 18 c6  movi r2,0xc618
0303bf20  61 93  ld.w r3,(r3,0x4)
0303bf22  fe e3 e9 e5  bsr 0x03018af4
0303bf26  60 94  ld.w r3,(r4,0x0)
0303bf28  ae 30  movi r0,0xae
0303bf2a  00 31  movi r1,0x0
0303bf2c  02 ea 18 c6  movi r2,0xc618
0303bf30  62 93  ld.w r3,(r3,0x8)
0303bf32  fe e3 e1 e5  bsr 0x03018af4
0303bf36  fe e3 4f ee  bsr 0x03019bd4
0303bf3a  00 34  movi r4,0x0
0303bf3c  00 e8 22 04  br 0x0303c780
0303bf40  fe e3 2e ee  bsr 0x03019b9c
0303bf44  78 10  lrw r3,0x303bfa4
0303bf46  65 83  ld.b r3,(r3,0x5)
0303bf48  43 e4 08 20  andi r2,r3,0x8
0303bf4c  88 74  zextb r2,r2
0303bf4e  02 e9 12 00  bez r2,0x0303bf72
0303bf52  7a 10  lrw r3,0x303bfb8
0303bf54  43 d8 30 00  ld.b r2,(r3,0x30)
0303bf58  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303bf5c  66 11  lrw r3,0x303bff4
0303bf5e  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303bf62  01 30  movi r0,0x1
0303bf64  01 ea ff ff  movi r1,0xffff
0303bf68  00 32  movi r2,0x0
0303bf6a  60 93  ld.w r3,(r3,0x0)
0303bf6c  fe e3 c4 e5  bsr 0x03018af4
0303bf70  93 04  br 0x0303c096
0303bf72  4d 10  lrw r2,0x303bfa4
0303bf74  46 82  ld.b r2,(r2,0x6)
0303bf76  22 e4 10 20  andi r1,r2,0x10
0303bf7a  44 74  zextb r1,r1
0303bf7c  01 e9 40 00  bez r1,0x0303bffc
0303bf80  6e 10  lrw r3,0x303bfb8
0303bf82  43 d8 30 00  ld.b r2,(r3,0x30)
0303bf86  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303bf8a  7c 10  lrw r3,0x303bff8
0303bf8c  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303bf90  01 30  movi r0,0x1
0303bf92  01 ea ff ff  movi r1,0xffff
0303bf96  00 32  movi r2,0x0
0303bf98  60 93  ld.w r3,(r3,0x0)
0303bf9a  fe e3 ad e5  bsr 0x03018af4
0303bf9e  7c 04  br 0x0303c096
0303bffc  23 e4 01 20  andi r1,r3,0x1
0303c000  01 e9 12 00  bez r1,0x0303c024
0303c004  6e 13  lrw r3,0x303c1bc
0303c006  43 d8 30 00  ld.b r2,(r3,0x30)
0303c00a  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c00e  6d 13  lrw r3,0x303c1c0
0303c010  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c014  01 30  movi r0,0x1
0303c016  01 ea ff ff  movi r1,0xffff
0303c01a  00 32  movi r2,0x0
0303c01c  68 93  ld.w r3,(r3,0x20)
0303c01e  fe e3 6b e5  bsr 0x03018af4
0303c022  3a 04  br 0x0303c096
0303c024  42 e4 20 20  andi r2,r2,0x20
0303c028  88 74  zextb r2,r2
0303c02a  02 e9 12 00  bez r2,0x0303c04e
0303c02e  64 13  lrw r3,0x303c1bc
0303c030  43 d8 30 00  ld.b r2,(r3,0x30)
0303c034  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c038  62 13  lrw r3,0x303c1c0
0303c03a  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c03e  01 30  movi r0,0x1
0303c040  01 ea ff ff  movi r1,0xffff
0303c044  00 32  movi r2,0x0
0303c046  6b 93  ld.w r3,(r3,0x2c)
0303c048  fe e3 56 e5  bsr 0x03018af4
0303c04c  25 04  br 0x0303c096
0303c04e  63 e4 20 20  andi r3,r3,0x20
0303c052  cc 74  zextb r3,r3
0303c054  03 e9 12 00  bez r3,0x0303c078
0303c058  79 12  lrw r3,0x303c1bc
0303c05a  43 d8 30 00  ld.b r2,(r3,0x30)
0303c05e  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c062  79 12  lrw r3,0x303c1c4
0303c064  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303c068  01 30  movi r0,0x1
0303c06a  01 ea ff ff  movi r1,0xffff
0303c06e  00 32  movi r2,0x0
0303c070  60 93  ld.w r3,(r3,0x0)
0303c072  fe e3 41 e5  bsr 0x03018af4
0303c076  10 04  br 0x0303c096
0303c078  71 12  lrw r3,0x303c1bc
0303c07a  43 d8 30 00  ld.b r2,(r3,0x30)
0303c07e  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c082  72 12  lrw r3,0x303c1c8
0303c084  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303c088  01 30  movi r0,0x1
0303c08a  01 ea ff ff  movi r1,0xffff
0303c08e  00 32  movi r2,0x0
0303c090  60 93  ld.w r3,(r3,0x0)
0303c092  fe e3 31 e5  bsr 0x03018af4
0303c096  6e 12  lrw r3,0x303c1cc
0303c098  00 83  ld.b r0,(r3,0x0)
0303c09a  00 e0 fb ed  bsr 0x03059c90
0303c09e  00 e0 35 ef  bsr 0x03059f08
0303c0a2  01 34  movi r4,0x1
0303c0a4  00 e8 6e 03  br 0x0303c780
0303c0a8  00 e0 a2 d3  bsr 0x030567ec
0303c0ac  43 6d  mov r5,r0
0303c0ae  00 30  movi r0,0x0
0303c0b0  fe e3 1e df  bsr 0x03017eec
0303c0b4  00 34  movi r4,0x0
0303c0b6  80 b8  st.w r4,(sp,0x0)
0303c0b8  13 6c  mov r0,r4
0303c0ba  53 6c  mov r1,r4
0303c0bc  f0 32  movi r2,0xf0
0303c0be  1b 33  movi r3,0x1b
0303c0c0  fe e3 94 dd  bsr 0x03017be8
0303c0c4  7e 11  lrw r3,0x303c1bc
0303c0c6  43 d8 30 00  ld.b r2,(r3,0x30)
0303c0ca  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c0ce  61 12  lrw r3,0x303c1d0
0303c0d0  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c0d4  01 30  movi r0,0x1
0303c0d6  01 ea ff ff  movi r1,0xffff
0303c0da  93 6c  mov r2,r4
0303c0dc  62 93  ld.w r3,(r3,0x8)
0303c0de  fe e3 0b e5  bsr 0x03018af4
0303c0e2  7d 11  lrw r3,0x303c1d4
0303c0e4  60 8b  ld.h r3,(r3,0x0)
0303c0e6  08 32  movi r2,0x8
0303c0e8  c8 64  cmphs r2,r3
0303c0ea  04 08  bt 0x0303c0f2
0303c0ec  7b 11  lrw r3,0x303c1d8
0303c0ee  40 a3  st.b r2,(r3,0x0)
0303c0f0  03 04  br 0x0303c0f6
0303c0f2  5a 11  lrw r2,0x303c1d8
0303c0f4  60 a2  st.b r3,(r2,0x0)
0303c0f6  42 5d  addi r2,r5,0x1
0303c0f8  79 11  lrw r3,0x303c1dc
0303c0fa  00 83  ld.b r0,(r3,0x0)
0303c0fc  79 11  lrw r3,0x303c1e0
0303c0fe  20 83  ld.b r1,(r3,0x0)
0303c100  88 74  zextb r2,r2
0303c102  00 e0 85 d3  bsr 0x0305680c
0303c106  fe e3 67 ed  bsr 0x03019bd4
0303c10a  00 34  movi r4,0x0
0303c10c  00 e8 3a 03  br 0x0303c780
0303c110  01 e0 78 52  bsr 0x03066600
0303c114  43 6d  mov r5,r0
0303c116  00 30  movi r0,0x0
0303c118  fe e3 ea de  bsr 0x03017eec
0303c11c  00 34  movi r4,0x0
0303c11e  80 b8  st.w r4,(sp,0x0)
0303c120  13 6c  mov r0,r4
0303c122  53 6c  mov r1,r4
0303c124  f0 32  movi r2,0xf0
0303c126  1b 33  movi r3,0x1b
0303c128  fe e3 60 dd  bsr 0x03017be8
0303c12c  64 11  lrw r3,0x303c1bc
0303c12e  43 d8 30 00  ld.b r2,(r3,0x30)
0303c132  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c136  6c 11  lrw r3,0x303c1e4
0303c138  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c13c  01 30  movi r0,0x1
0303c13e  01 ea ff ff  movi r1,0xffff
0303c142  93 6c  mov r2,r4
0303c144  61 93  ld.w r3,(r3,0x4)
0303c146  fe e3 d7 e4  bsr 0x03018af4
0303c14a  42 5d  addi r2,r5,0x1
0303c14c  64 11  lrw r3,0x303c1dc
0303c14e  00 83  ld.b r0,(r3,0x0)
0303c150  64 11  lrw r3,0x303c1e0
0303c152  20 83  ld.b r1,(r3,0x0)
0303c154  88 74  zextb r2,r2
0303c156  01 e0 b9 53  bsr 0x030668c8
0303c15a  fe e3 3d ed  bsr 0x03019bd4
0303c15e  00 e8 11 03  br 0x0303c780
0303c162  00 30  movi r0,0x0
0303c164  fe e3 c4 de  bsr 0x03017eec
0303c168  60 11  lrw r3,0x303c1e8
0303c16a  43 83  ld.b r2,(r3,0x3)
0303c16c  60 11  lrw r3,0x303c1ec
0303c16e  6c 5a  addu r3,r2,r3
0303c170  62 83  ld.b r3,(r3,0x2)
0303c172  44 3b  cmpnei r3,0x4
0303c174  07 08  bt 0x0303c182
0303c176  7f 10  lrw r3,0x303c1f0
0303c178  53 83  ld.b r2,(r3,0x13)
0303c17a  14 83  ld.b r0,(r3,0x14)
0303c17c  08 40  lsli r0,r0 ,0x8
0303c17e  08 6c  or r0,r2
0303c180  06 04  br 0x0303c18c
0303c182  7c 10  lrw r3,0x303c1f0
0303c184  51 83  ld.b r2,(r3,0x11)
0303c186  12 83  ld.b r0,(r3,0x12)
0303c188  08 40  lsli r0,r0 ,0x8
0303c18a  08 6c  or r0,r2
0303c18c  ff e3 da a7  bsr 0x03031140
0303c190  41 38  cmpnei r0,0x1
0303c192  08 32  movi r2,0x8
0303c194  71 10  lrw r3,0x303c1d8
0303c196  40 a3  st.b r2,(r3,0x0)
0303c198  71 10  lrw r3,0x303c1dc
0303c19a  00 83  ld.b r0,(r3,0x0)
0303c19c  71 10  lrw r3,0x303c1e0
0303c19e  20 83  ld.b r1,(r3,0x0)
0303c1a0  69 33  movi r3,0x69
0303c1a2  0c ea 32 00  movi r12,0x32
0303c1a6  43 c4 40 0c  movt r2,r3
0303c1aa  4c c4 20 0c  movf r2,r12
0303c1ae  ff e3 0d a8  bsr 0x030311c8
0303c1b2  fe e3 11 ed  bsr 0x03019bd4
0303c1b6  00 34  movi r4,0x0
0303c1b8  00 e8 e4 02  br 0x0303c780
0303c1f4  00 30  movi r0,0x0
0303c1f6  fe e3 7b de  bsr 0x03017eec
0303c1fa  69 13  lrw r3,0x303c39c
0303c1fc  43 d8 30 00  ld.b r2,(r3,0x30)
0303c200  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c204  67 13  lrw r3,0x303c3a0
0303c206  22 83  ld.b r1,(r3,0x2)
0303c208  67 13  lrw r3,0x303c3a4
0303c20a  6c 59  addu r3,r1,r3
0303c20c  83 d9 02 00  ld.b r12,(r3,0x2)
0303c210  66 13  lrw r3,0x303c3a8
0303c212  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c216  28 30  movi r0,0x28
0303c218  01 ea ff ff  movi r1,0xffff
0303c21c  00 32  movi r2,0x0
0303c21e  83 d1 83 08  ldr.w r3,(r3,r12<<2)
0303c222  fe e3 69 e4  bsr 0x03018af4
0303c226  22 13  lrw r1,0x303c3ac
0303c228  20 b8  st.w r1,(sp,0x0)
0303c22a  02 ea ff ff  movi r2,0xffff
0303c22e  41 b8  st.w r2,(sp,0x4)
0303c230  68 30  movi r0,0x68
0303c232  50 31  movi r1,0x50
0303c234  20 32  movi r2,0x20
0303c236  88 33  movi r3,0x88
0303c238  fe e3 a0 e5  bsr 0x03018d78
0303c23c  7d 12  lrw r3,0x303c3b0
0303c23e  64 83  ld.b r3,(r3,0x4)
0303c240  63 e4 02 20  andi r3,r3,0x2
0303c244  cc 74  zextb r3,r3
0303c246  03 e9 06 00  bez r3,0x0303c252
0303c24a  1b 12  lrw r0,0x303c3b4
0303c24c  ff e3 72 9f  bsr 0x03030130
0303c250  04 04  br 0x0303c258
0303c252  19 12  lrw r0,0x303c3b4
0303c254  ff e3 3e 9f  bsr 0x030300d0
0303c258  78 12  lrw r3,0x303c3b8
0303c25a  51 83  ld.b r2,(r3,0x11)
0303c25c  12 83  ld.b r0,(r3,0x12)
0303c25e  08 40  lsli r0,r0 ,0x8
0303c260  08 6c  or r0,r2
0303c262  fe e3 a9 90  bsr 0x0300e3b4
0303c266  76 12  lrw r3,0x303c3bc
0303c268  43 d8 35 00  ld.b r2,(r3,0x35)
0303c26c  40 c4 22 5c  ins r2,r0,0x1,0x2
0303c270  43 dc 35 00  st.b r2,(r3,0x35)
0303c274  fe e3 d2 8f  bsr 0x0300e218
0303c278  00 34  movi r4,0x0
0303c27a  00 e8 83 02  br 0x0303c780
0303c27e  00 30  movi r0,0x0
0303c280  fe e3 36 de  bsr 0x03017eec
0303c284  00 34  movi r4,0x0
0303c286  80 b8  st.w r4,(sp,0x0)
0303c288  13 6c  mov r0,r4
0303c28a  53 6c  mov r1,r4
0303c28c  f0 32  movi r2,0xf0
0303c28e  1b 33  movi r3,0x1b
0303c290  fe e3 ac dc  bsr 0x03017be8
0303c294  62 12  lrw r3,0x303c39c
0303c296  43 d8 30 00  ld.b r2,(r3,0x30)
0303c29a  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c29e  63 12  lrw r3,0x303c3a8
0303c2a0  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c2a4  01 30  movi r0,0x1
0303c2a6  01 ea ff ff  movi r1,0xffff
0303c2aa  93 6c  mov r2,r4
0303c2ac  61 93  ld.w r3,(r3,0x4)
0303c2ae  fe e3 23 e4  bsr 0x03018af4
0303c2b2  64 12  lrw r3,0x303c3c0
0303c2b4  60 8b  ld.h r3,(r3,0x0)
0303c2b6  08 32  movi r2,0x8
0303c2b8  c8 64  cmphs r2,r3
0303c2ba  04 08  bt 0x0303c2c2
0303c2bc  62 12  lrw r3,0x303c3c4
0303c2be  40 a3  st.b r2,(r3,0x0)
0303c2c0  03 04  br 0x0303c2c6
0303c2c2  41 12  lrw r2,0x303c3c4
0303c2c4  60 a2  st.b r3,(r2,0x0)
0303c2c6  61 12  lrw r3,0x303c3c8
0303c2c8  40 83  ld.b r2,(r3,0x0)
0303c2ca  00 22  addi r2,0x1
0303c2cc  60 12  lrw r3,0x303c3cc
0303c2ce  00 83  ld.b r0,(r3,0x0)
0303c2d0  60 12  lrw r3,0x303c3d0
0303c2d2  20 83  ld.b r1,(r3,0x0)
0303c2d4  88 74  zextb r2,r2
0303c2d6  ff e3 a5 92  bsr 0x0302e820
0303c2da  fe e3 7d ec  bsr 0x03019bd4
0303c2de  00 34  movi r4,0x0
0303c2e0  00 e8 50 02  br 0x0303c780
0303c2e4  00 30  movi r0,0x0
0303c2e6  fe e3 03 de  bsr 0x03017eec
0303c2ea  78 11  lrw r3,0x303c3c8
0303c2ec  41 83  ld.b r2,(r3,0x1)
0303c2ee  00 22  addi r2,0x1
0303c2f0  77 11  lrw r3,0x303c3cc
0303c2f2  00 83  ld.b r0,(r3,0x0)
0303c2f4  77 11  lrw r3,0x303c3d0
0303c2f6  20 83  ld.b r1,(r3,0x0)
0303c2f8  88 74  zextb r2,r2
0303c2fa  ff e3 65 93  bsr 0x0302e9c4
0303c2fe  fe e3 6b ec  bsr 0x03019bd4
0303c302  00 34  movi r4,0x0
0303c304  00 e8 3e 02  br 0x0303c780
0303c308  00 30  movi r0,0x0
0303c30a  fe e3 f1 dd  bsr 0x03017eec
0303c30e  00 34  movi r4,0x0
0303c310  80 b8  st.w r4,(sp,0x0)
0303c312  13 6c  mov r0,r4
0303c314  53 6c  mov r1,r4
0303c316  f0 32  movi r2,0xf0
0303c318  1b 33  movi r3,0x1b
0303c31a  fe e3 67 dc  bsr 0x03017be8
0303c31e  6e 11  lrw r3,0x303c3d4
0303c320  40 83  ld.b r2,(r3,0x0)
0303c322  6b 11  lrw r3,0x303c3cc
0303c324  00 83  ld.b r0,(r3,0x0)
0303c326  6b 11  lrw r3,0x303c3d0
0303c328  20 83  ld.b r1,(r3,0x0)
0303c32a  00 22  addi r2,0x1
0303c32c  00 e0 ee e1  bsr 0x03058708
0303c330  fe e3 52 ec  bsr 0x03019bd4
0303c334  00 e8 26 02  br 0x0303c780
0303c338  00 30  movi r0,0x0
0303c33a  fe e3 d9 dd  bsr 0x03017eec
0303c33e  00 34  movi r4,0x0
0303c340  80 b8  st.w r4,(sp,0x0)
0303c342  13 6c  mov r0,r4
0303c344  53 6c  mov r1,r4
0303c346  f0 32  movi r2,0xf0
0303c348  1b 33  movi r3,0x1b
0303c34a  fe e3 4f dc  bsr 0x03017be8
0303c34e  74 10  lrw r3,0x303c39c
0303c350  43 d8 30 00  ld.b r2,(r3,0x30)
0303c354  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c358  60 11  lrw r3,0x303c3d8
0303c35a  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c35e  01 30  movi r0,0x1
0303c360  01 ea ff ff  movi r1,0xffff
0303c364  93 6c  mov r2,r4
0303c366  6c 93  ld.w r3,(r3,0x30)
0303c368  fe e3 c6 e3  bsr 0x03018af4
0303c36c  75 10  lrw r3,0x303c3c0
0303c36e  60 8b  ld.h r3,(r3,0x0)
0303c370  08 32  movi r2,0x8
0303c372  c8 64  cmphs r2,r3
0303c374  04 08  bt 0x0303c37c
0303c376  74 10  lrw r3,0x303c3c4
0303c378  40 a3  st.b r2,(r3,0x0)
0303c37a  03 04  br 0x0303c380
0303c37c  52 10  lrw r2,0x303c3c4
0303c37e  60 a2  st.b r3,(r2,0x0)
0303c380  77 10  lrw r3,0x303c3dc
0303c382  40 83  ld.b r2,(r3,0x0)
0303c384  01 22  addi r2,0x2
0303c386  72 10  lrw r3,0x303c3cc
0303c388  00 83  ld.b r0,(r3,0x0)
0303c38a  72 10  lrw r3,0x303c3d0
0303c38c  20 83  ld.b r1,(r3,0x0)
0303c38e  89 74  zexth r2,r2
0303c390  00 e0 5e cd  bsr 0x03055e4c
0303c394  fe e3 20 ec  bsr 0x03019bd4
0303c398  00 34  movi r4,0x0
0303c39a  f3 05  br 0x0303c780
0303c3e0  00 30  movi r0,0x0
0303c3e2  fe e3 85 dd  bsr 0x03017eec
0303c3e6  00 34  movi r4,0x0
0303c3e8  80 b8  st.w r4,(sp,0x0)
0303c3ea  13 6c  mov r0,r4
0303c3ec  53 6c  mov r1,r4
0303c3ee  f0 32  movi r2,0xf0
0303c3f0  1b 33  movi r3,0x1b
0303c3f2  fe e3 fb db  bsr 0x03017be8
0303c3f6  70 13  lrw r3,0x303c5b4
0303c3f8  83 d9 30 00  ld.b r12,(r3,0x30)
0303c3fc  cc c4 cc 54  zext r12,r12,0x6,0x6
0303c400  01 30  movi r0,0x1
0303c402  01 ea ff ff  movi r1,0xffff
0303c406  93 6c  mov r2,r4
0303c408  6c 13  lrw r3,0x303c5b8
0303c40a  83 d1 83 08  ldr.w r3,(r3,r12<<2)
0303c40e  fe e3 73 e3  bsr 0x03018af4
0303c412  6b 13  lrw r3,0x303c5bc
0303c414  40 83  ld.b r2,(r3,0x0)
0303c416  00 22  addi r2,0x1
0303c418  6a 13  lrw r3,0x303c5c0
0303c41a  00 83  ld.b r0,(r3,0x0)
0303c41c  6a 13  lrw r3,0x303c5c4
0303c41e  20 83  ld.b r1,(r3,0x0)
0303c420  89 74  zexth r2,r2
0303c422  6a 13  lrw r3,0x303c5c8
0303c424  60 83  ld.b r3,(r3,0x0)
0303c426  00 e0 53 ce  bsr 0x030560cc
0303c42a  fe e3 d5 eb  bsr 0x03019bd4
0303c42e  a9 05  br 0x0303c780
0303c430  00 30  movi r0,0x0
0303c432  fe e3 5d dd  bsr 0x03017eec
0303c436  00 34  movi r4,0x0
0303c438  80 b8  st.w r4,(sp,0x0)
0303c43a  13 6c  mov r0,r4
0303c43c  53 6c  mov r1,r4
0303c43e  f0 32  movi r2,0xf0
0303c440  1b 33  movi r3,0x1b
0303c442  fe e3 d3 db  bsr 0x03017be8
0303c446  7c 12  lrw r3,0x303c5b4
0303c448  43 d8 30 00  ld.b r2,(r3,0x30)
0303c44c  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c450  7f 12  lrw r3,0x303c5cc
0303c452  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c456  01 30  movi r0,0x1
0303c458  01 ea ff ff  movi r1,0xffff
0303c45c  93 6c  mov r2,r4
0303c45e  61 93  ld.w r3,(r3,0x4)
0303c460  fe e3 4a e3  bsr 0x03018af4
0303c464  77 12  lrw r3,0x303c5c0
0303c466  00 83  ld.b r0,(r3,0x0)
0303c468  77 12  lrw r3,0x303c5c4
0303c46a  20 83  ld.b r1,(r3,0x0)
0303c46c  79 12  lrw r3,0x303c5d0
0303c46e  40 83  ld.b r2,(r3,0x0)
0303c470  00 e0 ba d2  bsr 0x030569e4
0303c474  fe e3 b0 eb  bsr 0x03019bd4
0303c478  84 05  br 0x0303c780
0303c47a  00 30  movi r0,0x0
0303c47c  fe e3 38 dd  bsr 0x03017eec
0303c480  00 34  movi r4,0x0
0303c482  80 b8  st.w r4,(sp,0x0)
0303c484  13 6c  mov r0,r4
0303c486  53 6c  mov r1,r4
0303c488  f0 32  movi r2,0xf0
0303c48a  1b 33  movi r3,0x1b
0303c48c  fe e3 ae db  bsr 0x03017be8
0303c490  69 12  lrw r3,0x303c5b4
0303c492  43 d8 30 00  ld.b r2,(r3,0x30)
0303c496  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c49a  6d 12  lrw r3,0x303c5cc
0303c49c  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c4a0  01 30  movi r0,0x1
0303c4a2  01 ea ff ff  movi r1,0xffff
0303c4a6  93 6c  mov r2,r4
0303c4a8  61 93  ld.w r3,(r3,0x4)
0303c4aa  fe e3 25 e3  bsr 0x03018af4
0303c4ae  65 12  lrw r3,0x303c5c0
0303c4b0  00 83  ld.b r0,(r3,0x0)
0303c4b2  65 12  lrw r3,0x303c5c4
0303c4b4  20 83  ld.b r1,(r3,0x0)
0303c4b6  68 12  lrw r3,0x303c5d4
0303c4b8  40 83  ld.b r2,(r3,0x0)
0303c4ba  01 e0 6b 53  bsr 0x03066b90
0303c4be  fe e3 8b eb  bsr 0x03019bd4
0303c4c2  5f 05  br 0x0303c780
0303c4c4  00 30  movi r0,0x0
0303c4c6  fe e3 13 dd  bsr 0x03017eec
0303c4ca  64 12  lrw r3,0x303c5d8
0303c4cc  a0 93  ld.w r5,(r3,0x0)
0303c4ce  64 12  lrw r3,0x303c5dc
0303c4d0  80 93  ld.w r4,(r3,0x0)
0303c4d2  fe e3 13 a4  bsr 0x03010cf8
0303c4d6  83 6c  mov r2,r0
0303c4d8  17 6c  mov r0,r5
0303c4da  53 6c  mov r1,r4
0303c4dc  01 e0 42 2b  bsr 0x03061b60
0303c4e0  fe e3 7a eb  bsr 0x03019bd4
0303c4e4  00 34  movi r4,0x0
0303c4e6  4d 05  br 0x0303c780
0303c4e8  00 30  movi r0,0x0
0303c4ea  fe e3 01 dd  bsr 0x03017eec
0303c4ee  00 34  movi r4,0x0
0303c4f0  80 b8  st.w r4,(sp,0x0)
0303c4f2  13 6c  mov r0,r4
0303c4f4  53 6c  mov r1,r4
0303c4f6  f0 32  movi r2,0xf0
0303c4f8  1b 33  movi r3,0x1b
0303c4fa  fe e3 77 db  bsr 0x03017be8
0303c4fe  6e 11  lrw r3,0x303c5b4
0303c500  43 d8 30 00  ld.b r2,(r3,0x30)
0303c504  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c508  76 11  lrw r3,0x303c5e0
0303c50a  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c50e  01 30  movi r0,0x1
0303c510  01 ea ff ff  movi r1,0xffff
0303c514  93 6c  mov r2,r4
0303c516  61 93  ld.w r3,(r3,0x4)
0303c518  fe e3 ee e2  bsr 0x03018af4
0303c51c  72 11  lrw r3,0x303c5e4
0303c51e  60 8b  ld.h r3,(r3,0x0)
0303c520  08 32  movi r2,0x8
0303c522  c8 64  cmphs r2,r3
0303c524  04 08  bt 0x0303c52c
0303c526  71 11  lrw r3,0x303c5e8
0303c528  40 a3  st.b r2,(r3,0x0)
0303c52a  03 04  br 0x0303c530
0303c52c  4f 11  lrw r2,0x303c5e8
0303c52e  60 a2  st.b r3,(r2,0x0)
0303c530  6f 11  lrw r3,0x303c5ec
0303c532  40 83  ld.b r2,(r3,0x0)
0303c534  63 11  lrw r3,0x303c5c0
0303c536  00 83  ld.b r0,(r3,0x0)
0303c538  63 11  lrw r3,0x303c5c4
0303c53a  20 83  ld.b r1,(r3,0x0)
0303c53c  00 22  addi r2,0x1
0303c53e  01 e0 c1 04  bsr 0x0305cec0
0303c542  fe e3 49 eb  bsr 0x03019bd4
0303c546  00 34  movi r4,0x0
0303c548  1c 05  br 0x0303c780
0303c54a  00 30  movi r0,0x0
0303c54c  fe e3 d0 dc  bsr 0x03017eec
0303c550  68 11  lrw r3,0x303c5f0
0303c552  a0 8b  ld.h r5,(r3,0x0)
0303c554  68 11  lrw r3,0x303c5f4
0303c556  80 8b  ld.h r4,(r3,0x0)
0303c558  01 e0 64 34  bsr 0x03062e20
0303c55c  83 6c  mov r2,r0
0303c55e  17 6c  mov r0,r5
0303c560  53 6c  mov r1,r4
0303c562  01 e0 3b 37  bsr 0x030633d8
0303c566  fe e3 37 eb  bsr 0x03019bd4
0303c56a  00 34  movi r4,0x0
0303c56c  0a 05  br 0x0303c780
0303c56e  00 30  movi r0,0x0
0303c570  fe e3 be dc  bsr 0x03017eec
0303c574  00 34  movi r4,0x0
0303c576  80 b8  st.w r4,(sp,0x0)
0303c578  13 6c  mov r0,r4
0303c57a  53 6c  mov r1,r4
0303c57c  f0 32  movi r2,0xf0
0303c57e  1b 33  movi r3,0x1b
0303c580  fe e3 34 db  bsr 0x03017be8
0303c584  6c 10  lrw r3,0x303c5b4
0303c586  43 d8 30 00  ld.b r2,(r3,0x30)
0303c58a  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c58e  7b 10  lrw r3,0x303c5f8
0303c590  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c594  01 30  movi r0,0x1
0303c596  01 ea ff ff  movi r1,0xffff
0303c59a  93 6c  mov r2,r4
0303c59c  63 93  ld.w r3,(r3,0xc)
0303c59e  fe e3 ab e2  bsr 0x03018af4
0303c5a2  68 10  lrw r3,0x303c5c0
0303c5a4  00 83  ld.b r0,(r3,0x0)
0303c5a6  68 10  lrw r3,0x303c5c4
0303c5a8  20 83  ld.b r1,(r3,0x0)
0303c5aa  01 e0 79 38  bsr 0x0306369c
0303c5ae  fe e3 13 eb  bsr 0x03019bd4
0303c5b2  e7 04  br 0x0303c780
0303c5fc  75 13  lrw r3,0x303c7d0
0303c5fe  60 83  ld.b r3,(r3,0x0)
0303c600  23 e9 05 00  bnez r3,0x0303c60a
0303c604  01 e0 d8 2c  bsr 0x03061fb4
0303c608  35 04  br 0x0303c672
0303c60a  41 3b  cmpnei r3,0x1
0303c60c  08 08  bt 0x0303c61c
0303c60e  fe e3 c7 ea  bsr 0x03019b9c
0303c612  71 13  lrw r3,0x303c7d4
0303c614  00 8b  ld.h r0,(r3,0x0)
0303c616  01 e0 41 34  bsr 0x03062e98
0303c61a  2c 04  br 0x0303c672
0303c61c  42 3b  cmpnei r3,0x2
0303c61e  2a 08  bt 0x0303c672
0303c620  00 34  movi r4,0x0
0303c622  80 b8  st.w r4,(sp,0x0)
0303c624  13 6c  mov r0,r4
0303c626  53 6c  mov r1,r4
0303c628  f0 32  movi r2,0xf0
0303c62a  1b 33  movi r3,0x1b
0303c62c  fe e3 de da  bsr 0x03017be8
0303c630  6a 13  lrw r3,0x303c7d8
0303c632  43 d8 30 00  ld.b r2,(r3,0x30)
0303c636  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c63a  a9 13  lrw r5,0x303c7dc
0303c63c  69 13  lrw r3,0x303c7e0
0303c63e  63 83  ld.b r3,(r3,0x3)
0303c640  6c 5d  addu r3,r5,r3
0303c642  83 d9 8f 00  ld.b r12,(r3,0x8f)
0303c646  68 13  lrw r3,0x303c7e4
0303c648  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303c64c  01 30  movi r0,0x1
0303c64e  01 ea ff ff  movi r1,0xffff
0303c652  93 6c  mov r2,r4
0303c654  83 d1 83 08  ldr.w r3,(r3,r12<<2)
0303c658  fe e3 4e e2  bsr 0x03018af4
0303c65c  60 8d  ld.h r3,(r5,0x0)
0303c65e  08 32  movi r2,0x8
0303c660  c8 64  cmphs r2,r3
0303c662  04 08  bt 0x0303c66a
0303c664  61 13  lrw r3,0x303c7e8
0303c666  40 a3  st.b r2,(r3,0x0)
0303c668  03 04  br 0x0303c66e
0303c66a  40 13  lrw r2,0x303c7e8
0303c66c  60 a2  st.b r3,(r2,0x0)
0303c66e  00 e0 15 28  bsr 0x03041698
0303c672  00 34  movi r4,0x0
0303c674  80 b8  st.w r4,(sp,0x0)
0303c676  13 6c  mov r0,r4
0303c678  91 31  movi r1,0x91
0303c67a  21 41  lsli r1,r1 ,0x1
0303c67c  f0 32  movi r2,0xf0
0303c67e  a0 33  movi r3,0xa0
0303c680  61 43  lsli r3,r3 ,0x1
0303c682  fe e3 b3 da  bsr 0x03017be8
0303c686  13 6c  mov r0,r4
0303c688  fe e3 ec ea  bsr 0x03019c60
0303c68c  7a 04  br 0x0303c780
0303c68e  fe e3 79 ea  bsr 0x03019b80
0303c692  77 12  lrw r3,0x303c7ec
0303c694  41 83  ld.b r2,(r3,0x1)
0303c696  02 83  ld.b r0,(r3,0x2)
0303c698  08 40  lsli r0,r0 ,0x8
0303c69a  08 6c  or r0,r2
0303c69c  02 19  addi r1,sp,0x8
0303c69e  ff e3 21 b6  bsr 0x030332e0
0303c6a2  90 30  movi r0,0x90
0303c6a4  00 31  movi r1,0x0
0303c6a6  02 ea 18 c6  movi r2,0xc618
0303c6aa  6e e4 09 00  addi r3,sp,0xa
0303c6ae  fe e3 23 e2  bsr 0x03018af4
0303c6b2  6a 12  lrw r3,0x303c7d8
0303c6b4  43 d8 30 00  ld.b r2,(r3,0x30)
0303c6b8  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303c6bc  6d 12  lrw r3,0x303c7f0
0303c6be  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303c6c2  ae 30  movi r0,0xae
0303c6c4  00 31  movi r1,0x0
0303c6c6  02 ea 18 c6  movi r2,0xc618
0303c6ca  60 93  ld.w r3,(r3,0x0)
0303c6cc  fe e3 14 e2  bsr 0x03018af4
0303c6d0  00 34  movi r4,0x0
0303c6d2  80 b8  st.w r4,(sp,0x0)
0303c6d4  13 6c  mov r0,r4
0303c6d6  91 31  movi r1,0x91
0303c6d8  21 41  lsli r1,r1 ,0x1
0303c6da  f0 32  movi r2,0xf0
0303c6dc  a0 33  movi r3,0xa0
0303c6de  61 43  lsli r3,r3 ,0x1
0303c6e0  fe e3 84 da  bsr 0x03017be8
0303c6e4  13 6c  mov r0,r4
0303c6e6  fe e3 bd ea  bsr 0x03019c60
0303c6ea  4b 04  br 0x0303c780
0303c6ec  fe e3 4a ea  bsr 0x03019b80
0303c6f0  81 12  lrw r4,0x303c7f4
0303c6f2  ba 11  lrw r5,0x303c7d8
0303c6f4  65 d8 30 00  ld.b r3,(r5,0x30)
0303c6f8  c3 c4 c3 54  zext r3,r3,0x6,0x6
0303c6fc  64 d0 83 08  ldr.w r3,(r4,r3<<2)
0303c700  90 30  movi r0,0x90
0303c702  00 31  movi r1,0x0
0303c704  02 ea 18 c6  movi r2,0xc618
0303c708  60 93  ld.w r3,(r3,0x0)
0303c70a  fe e3 f5 e1  bsr 0x03018af4
0303c70e  65 d8 30 00  ld.b r3,(r5,0x30)
0303c712  c3 c4 c3 54  zext r3,r3,0x6,0x6
0303c716  64 d0 83 08  ldr.w r3,(r4,r3<<2)
0303c71a  ae 30  movi r0,0xae
0303c71c  00 31  movi r1,0x0
0303c71e  02 ea 18 c6  movi r2,0xc618
0303c722  61 93  ld.w r3,(r3,0x4)
0303c724  fe e3 e8 e1  bsr 0x03018af4
0303c728  00 34  movi r4,0x0
0303c72a  2b 04  br 0x0303c780
0303c72c  6c 11  lrw r3,0x303c7dc
0303c72e  60 8b  ld.h r3,(r3,0x0)
0303c730  08 32  movi r2,0x8
0303c732  c8 64  cmphs r2,r3
0303c734  05 08  bt 0x0303c73e
0303c736  08 31  movi r1,0x8
0303c738  4c 11  lrw r2,0x303c7e8
0303c73a  20 a2  st.b r1,(r2,0x0)
0303c73c  03 04  br 0x0303c742
0303c73e  4b 11  lrw r2,0x303c7e8
0303c740  60 a2  st.b r3,(r2,0x0)
0303c742  23 e9 0c 00  bnez r3,0x0303c75a
0303c746  ff e3 35 d2  bsr 0x03036bb0
0303c74a  6c 11  lrw r3,0x303c7f8
0303c74c  40 83  ld.b r2,(r3,0x0)
0303c74e  64 11  lrw r3,0x303c7dc
0303c750  40 ab  st.h r2,(r3,0x0)
0303c752  00 32  movi r2,0x0
0303c754  6a 11  lrw r3,0x303c7fc
0303c756  44 a3  st.b r2,(r3,0x4)
0303c758  67 04  br 0x0303c826
0303c75a  6a 11  lrw r3,0x303c800
0303c75c  60 93  ld.w r3,(r3,0x0)
0303c75e  23 e9 06 00  bnez r3,0x0303c76a
0303c762  00 30  movi r0,0x0
0303c764  fe e3 c4 db  bsr 0x03017eec
0303c768  5f 04  br 0x0303c826
0303c76a  00 30  movi r0,0x0
0303c76c  fe e3 c0 db  bsr 0x03017eec
0303c770  65 11  lrw r3,0x303c804
0303c772  00 93  ld.w r0,(r3,0x0)
0303c774  00 20  addi r0,0x1
0303c776  ff e3 19 bc  bsr 0x03033fa8
0303c77a  00 34  movi r4,0x0
0303c77c  02 04  br 0x0303c780
0303c77e  00 34  movi r4,0x0
0303c780  62 11  lrw r3,0x303c808
0303c782  60 83  ld.b r3,(r3,0x0)
0303c784  48 3b  cmpnei r3,0x8
0303c786  1d 0c  bf 0x0303c7c0
0303c788  45 3b  cmpnei r3,0x5
0303c78a  1b 0c  bf 0x0303c7c0
0303c78c  46 3b  cmpnei r3,0x6
0303c78e  19 0c  bf 0x0303c7c0
0303c790  44 3b  cmpnei r3,0x4
0303c792  17 0c  bf 0x0303c7c0
0303c794  58 3b  cmpnei r3,0x18
0303c796  15 0c  bf 0x0303c7c0
0303c798  43 3b  cmpnei r3,0x3
0303c79a  13 0c  bf 0x0303c7c0
0303c79c  4a 3b  cmpnei r3,0xa
0303c79e  11 0c  bf 0x0303c7c0
0303c7a0  57 3b  cmpnei r3,0x17
0303c7a2  0f 0c  bf 0x0303c7c0
0303c7a4  43 eb 25 00  cmpnei r3,0x25
0303c7a8  0c 0c  bf 0x0303c7c0
0303c7aa  43 eb 2f 00  cmpnei r3,0x2f
0303c7ae  09 0c  bf 0x0303c7c0
0303c7b0  56 3b  cmpnei r3,0x16
0303c7b2  05 08  bt 0x0303c7bc
0303c7b4  67 10  lrw r3,0x303c7d0
0303c7b6  60 83  ld.b r3,(r3,0x0)
0303c7b8  41 3b  cmpnei r3,0x1
0303c7ba  03 0c  bf 0x0303c7c0
0303c7bc  ff e3 d6 e5  bsr 0x03039368
0303c7c0  04 e9 28 00  bez r4,0x0303c810
0303c7c4  12 10  lrw r0,0x303c80c
0303c7c6  08 19  addi r1,sp,0x20
0303c7c8  01 e0 d6 7a  bsr 0x0306bd74
0303c7cc  2d 04  br 0x0303c826
0303c810  1f 12  lrw r0,0x303c98c
0303c812  00 31  movi r1,0x0
0303c814  87 6c  mov r2,r1
0303c816  08 1b  addi r3,sp,0x20
0303c818  01 e0 2a 7a  bsr 0x0306bc6c
0303c81c  05 04  br 0x0303c826
0303c81e  00 34  movi r4,0x0
0303c820  01 35  movi r5,0x1
0303c822  00 e8 fb f9  br 0x0303bc18
0303c826  09 14  addi sp,sp,0x24
0303c828  92 14  pop r4,r5,lr

; 03038500 FUN_03038500
03038500  d1 14  push r4,lr
03038502  26 14  subi sp,sp,0x18
03038504  01 1b  addi r3,sp,0x4
03038506  00 32  movi r2,0x0
03038508  40 b3  st.w r2,(r3,0x0)
0303850a  41 b3  st.w r2,(r3,0x4)
0303850c  42 b3  st.w r2,(r3,0x8)
0303850e  43 b3  st.w r2,(r3,0xc)
03038510  50 a3  st.b r2,(r3,0x10)
03038512  73 10  lrw r3,0x303855c
03038514  60 83  ld.b r3,(r3,0x0)
03038516  63 e4 02 20  andi r3,r3,0x2
0303851a  cc 74  zextb r3,r3
0303851c  23 e9 cb 04  bnez r3,0x03038eb2
03038520  4b 6c  mov r1,r2
03038522  40 b8  st.w r2,(sp,0x0)
03038524  0b 6c  mov r0,r2
03038526  f0 32  movi r2,0xf0
03038528  1b 33  movi r3,0x1b
0303852a  fe e3 5f fb  bsr 0x03017be8
0303852e  69 10  lrw r3,0x3038550
03038530  63 83  ld.b r3,(r3,0x3)
03038532  cc 74  zextb r3,r3
03038534  06 2b  subi r3,0x7
03038536  8c 74  zextb r2,r3
03038538  02 eb 31 00  cmphsi r2,0x32
0303853c  60 e8 5e 04  bt 0x03038df8
03038540  cb 6c  mov r3,r2
03038542  48 10  lrw r2,0x3038560
03038544  62 d0 83 08  ldr.w r3,(r2,r3<<2)
03038548  0c 78  jmp r3
03038564  74 10  lrw r3,0x30385b4
03038566  43 d8 30 00  ld.b r2,(r3,0x30)
0303856a  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303856e  73 10  lrw r3,0x30385b8
03038570  43 d0 03 09  ldr.w r3,(r3,r2<<3)
03038574  60 93  ld.w r3,(r3,0x0)
03038576  00 e8 98 04  br 0x03038ea6
0303857a  6f 10  lrw r3,0x30385b4
0303857c  23 d8 30 00  ld.b r1,(r3,0x30)
03038580  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038584  6e 10  lrw r3,0x30385bc
03038586  41 83  ld.b r2,(r3,0x1)
03038588  6e 10  lrw r3,0x30385c0
0303858a  6c 5a  addu r3,r2,r3
0303858c  42 83  ld.b r2,(r3,0x2)
0303858e  6e 10  lrw r3,0x30385c4
03038590  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038594  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038598  00 e8 87 04  br 0x03038ea6
0303859c  68 10  lrw r3,0x30385bc
0303859e  41 83  ld.b r2,(r3,0x1)
030385a0  68 10  lrw r3,0x30385c0
030385a2  6c 5a  addu r3,r2,r3
030385a4  42 83  ld.b r2,(r3,0x2)
030385a6  09 3a  cmphsi r2,0xa
030385a8  12 08  bt 0x030385cc
030385aa  68 10  lrw r3,0x30385c8
030385ac  43 d0 83 08  ldr.w r3,(r3,r2<<2)
030385b0  0c 78  jmp r3
030385cc  64 13  lrw r3,0x303875c
030385ce  00 e8 6c 04  br 0x03038ea6
030385d2  64 13  lrw r3,0x3038760
030385d4  23 d8 30 00  ld.b r1,(r3,0x30)
030385d8  c1 c4 c1 54  zext r1,r1,0x6,0x6
030385dc  62 13  lrw r3,0x3038764
030385de  42 83  ld.b r2,(r3,0x2)
030385e0  62 13  lrw r3,0x3038768
030385e2  6c 5a  addu r3,r2,r3
030385e4  42 83  ld.b r2,(r3,0x2)
030385e6  62 13  lrw r3,0x303876c
030385e8  23 d0 03 09  ldr.w r3,(r3,r1<<3)
030385ec  43 d0 83 08  ldr.w r3,(r3,r2<<2)
030385f0  00 e8 5b 04  br 0x03038ea6
030385f4  7b 12  lrw r3,0x3038760
030385f6  23 d8 30 00  ld.b r1,(r3,0x30)
030385fa  c1 c4 c1 54  zext r1,r1,0x6,0x6
030385fe  7a 12  lrw r3,0x3038764
03038600  42 83  ld.b r2,(r3,0x2)
03038602  7a 12  lrw r3,0x3038768
03038604  6c 5a  addu r3,r2,r3
03038606  42 83  ld.b r2,(r3,0x2)
03038608  7a 12  lrw r3,0x3038770
0303860a  23 d0 03 09  ldr.w r3,(r3,r1<<3)
0303860e  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038612  00 e8 4a 04  br 0x03038ea6
03038616  73 12  lrw r3,0x3038760
03038618  23 d8 30 00  ld.b r1,(r3,0x30)
0303861c  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038620  71 12  lrw r3,0x3038764
03038622  42 83  ld.b r2,(r3,0x2)
03038624  71 12  lrw r3,0x3038768
03038626  6c 5a  addu r3,r2,r3
03038628  42 83  ld.b r2,(r3,0x2)
0303862a  73 12  lrw r3,0x3038774
0303862c  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038630  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038634  00 e8 39 04  br 0x03038ea6
03038638  6a 12  lrw r3,0x3038760
0303863a  23 d8 30 00  ld.b r1,(r3,0x30)
0303863e  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038642  69 12  lrw r3,0x3038764
03038644  42 83  ld.b r2,(r3,0x2)
03038646  69 12  lrw r3,0x3038768
03038648  6c 5a  addu r3,r2,r3
0303864a  42 83  ld.b r2,(r3,0x2)
0303864c  6b 12  lrw r3,0x3038778
0303864e  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038652  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038656  00 e8 28 04  br 0x03038ea6
0303865a  62 12  lrw r3,0x3038760
0303865c  23 d8 30 00  ld.b r1,(r3,0x30)
03038660  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038664  60 12  lrw r3,0x3038764
03038666  42 83  ld.b r2,(r3,0x2)
03038668  60 12  lrw r3,0x3038768
0303866a  6c 5a  addu r3,r2,r3
0303866c  42 83  ld.b r2,(r3,0x2)
0303866e  64 12  lrw r3,0x303877c
03038670  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038674  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038678  00 e8 17 04  br 0x03038ea6
0303867c  79 11  lrw r3,0x3038760
0303867e  23 d8 30 00  ld.b r1,(r3,0x30)
03038682  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038686  78 11  lrw r3,0x3038764
03038688  42 83  ld.b r2,(r3,0x2)
0303868a  78 11  lrw r3,0x3038768
0303868c  6c 5a  addu r3,r2,r3
0303868e  42 83  ld.b r2,(r3,0x2)
03038690  7c 11  lrw r3,0x3038780
03038692  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038696  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303869a  00 e8 06 04  br 0x03038ea6
0303869e  71 11  lrw r3,0x3038760
030386a0  23 d8 30 00  ld.b r1,(r3,0x30)
030386a4  c1 c4 c1 54  zext r1,r1,0x6,0x6
030386a8  6f 11  lrw r3,0x3038764
030386aa  42 83  ld.b r2,(r3,0x2)
030386ac  6f 11  lrw r3,0x3038768
030386ae  6c 5a  addu r3,r2,r3
030386b0  42 83  ld.b r2,(r3,0x2)
030386b2  75 11  lrw r3,0x3038784
030386b4  23 d0 03 09  ldr.w r3,(r3,r1<<3)
030386b8  43 d0 83 08  ldr.w r3,(r3,r2<<2)
030386bc  00 e8 f5 03  br 0x03038ea6
030386c0  68 11  lrw r3,0x3038760
030386c2  23 d8 30 00  ld.b r1,(r3,0x30)
030386c6  c1 c4 c1 54  zext r1,r1,0x6,0x6
030386ca  67 11  lrw r3,0x3038764
030386cc  42 83  ld.b r2,(r3,0x2)
030386ce  67 11  lrw r3,0x3038768
030386d0  6c 5a  addu r3,r2,r3
030386d2  42 83  ld.b r2,(r3,0x2)
030386d4  6d 11  lrw r3,0x3038788
030386d6  23 d0 03 09  ldr.w r3,(r3,r1<<3)
030386da  43 d0 83 08  ldr.w r3,(r3,r2<<2)
030386de  00 e8 e4 03  br 0x03038ea6
030386e2  60 11  lrw r3,0x3038760
030386e4  43 d8 30 00  ld.b r2,(r3,0x30)
030386e8  c2 c4 c2 54  zext r2,r2,0x6,0x6
030386ec  68 11  lrw r3,0x303878c
030386ee  43 d0 03 09  ldr.w r3,(r3,r2<<3)
030386f2  69 93  ld.w r3,(r3,0x24)
030386f4  00 e8 d9 03  br 0x03038ea6
030386f8  7b 10  lrw r3,0x3038764
030386fa  41 83  ld.b r2,(r3,0x1)
030386fc  65 11  lrw r3,0x3038790
030386fe  6c 5a  addu r3,r2,r3
03038700  62 83  ld.b r3,(r3,0x2)
03038702  45 3b  cmpnei r3,0x5
03038704  9b 08  bt 0x0303883a
03038706  78 10  lrw r3,0x3038764
03038708  42 83  ld.b r2,(r3,0x2)
0303870a  78 10  lrw r3,0x3038768
0303870c  6c 5a  addu r3,r2,r3
0303870e  62 83  ld.b r3,(r3,0x2)
03038710  23 e9 13 00  bnez r3,0x03038736
03038714  73 10  lrw r3,0x3038760
03038716  23 d8 30 00  ld.b r1,(r3,0x30)
0303871a  c1 c4 c1 54  zext r1,r1,0x6,0x6
0303871e  72 10  lrw r3,0x3038764
03038720  43 83  ld.b r2,(r3,0x3)
03038722  7d 10  lrw r3,0x3038794
03038724  6c 5a  addu r3,r2,r3
03038726  42 83  ld.b r2,(r3,0x2)
03038728  7c 10  lrw r3,0x3038798
0303872a  23 d0 03 09  ldr.w r3,(r3,r1<<3)
0303872e  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038732  00 e8 ba 03  br 0x03038ea6
03038736  41 3b  cmpnei r3,0x1
03038738  34 08  bt 0x030387a0
0303873a  6a 10  lrw r3,0x3038760
0303873c  23 d8 30 00  ld.b r1,(r3,0x30)
03038740  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038744  68 10  lrw r3,0x3038764
03038746  43 83  ld.b r2,(r3,0x3)
03038748  73 10  lrw r3,0x3038794
0303874a  6c 5a  addu r3,r2,r3
0303874c  42 83  ld.b r2,(r3,0x2)
0303874e  74 10  lrw r3,0x303879c
03038750  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038754  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038758  00 e8 a7 03  br 0x03038ea6
030387a0  43 3b  cmpnei r3,0x3
030387a2  12 08  bt 0x030387c6
030387a4  63 13  lrw r3,0x3038930
030387a6  23 d8 30 00  ld.b r1,(r3,0x30)
030387aa  c1 c4 c1 54  zext r1,r1,0x6,0x6
030387ae  62 13  lrw r3,0x3038934
030387b0  43 83  ld.b r2,(r3,0x3)
030387b2  62 13  lrw r3,0x3038938
030387b4  6c 5a  addu r3,r2,r3
030387b6  42 83  ld.b r2,(r3,0x2)
030387b8  61 13  lrw r3,0x303893c
030387ba  23 d0 03 09  ldr.w r3,(r3,r1<<3)
030387be  43 d0 83 08  ldr.w r3,(r3,r2<<2)
030387c2  00 e8 72 03  br 0x03038ea6
030387c6  44 3b  cmpnei r3,0x4
030387c8  12 08  bt 0x030387ec
030387ca  7a 12  lrw r3,0x3038930
030387cc  23 d8 30 00  ld.b r1,(r3,0x30)
030387d0  c1 c4 c1 54  zext r1,r1,0x6,0x6
030387d4  78 12  lrw r3,0x3038934
030387d6  43 83  ld.b r2,(r3,0x3)
030387d8  78 12  lrw r3,0x3038938
030387da  6c 5a  addu r3,r2,r3
030387dc  42 83  ld.b r2,(r3,0x2)
030387de  79 12  lrw r3,0x3038940
030387e0  23 d0 03 09  ldr.w r3,(r3,r1<<3)
030387e4  43 d0 83 08  ldr.w r3,(r3,r2<<2)
030387e8  00 e8 5f 03  br 0x03038ea6
030387ec  45 3b  cmpnei r3,0x5
030387ee  12 08  bt 0x03038812
030387f0  70 12  lrw r3,0x3038930
030387f2  23 d8 30 00  ld.b r1,(r3,0x30)
030387f6  c1 c4 c1 54  zext r1,r1,0x6,0x6
030387fa  6f 12  lrw r3,0x3038934
030387fc  43 83  ld.b r2,(r3,0x3)
030387fe  6f 12  lrw r3,0x3038938
03038800  6c 5a  addu r3,r2,r3
03038802  42 83  ld.b r2,(r3,0x2)
03038804  70 12  lrw r3,0x3038944
03038806  23 d0 03 09  ldr.w r3,(r3,r1<<3)
0303880a  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303880e  00 e8 4c 03  br 0x03038ea6
03038812  46 3b  cmpnei r3,0x6
03038814  60 e8 f6 02  bt 0x03038e00
03038818  66 12  lrw r3,0x3038930
0303881a  23 d8 30 00  ld.b r1,(r3,0x30)
0303881e  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038822  65 12  lrw r3,0x3038934
03038824  43 83  ld.b r2,(r3,0x3)
03038826  65 12  lrw r3,0x3038938
03038828  6c 5a  addu r3,r2,r3
0303882a  42 83  ld.b r2,(r3,0x2)
0303882c  67 12  lrw r3,0x3038948
0303882e  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038832  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038836  00 e8 38 03  br 0x03038ea6
0303883a  23 e9 20 00  bnez r3,0x0303887a
0303883e  7e 11  lrw r3,0x3038934
03038840  42 83  ld.b r2,(r3,0x2)
03038842  63 12  lrw r3,0x303894c
03038844  6c 5a  addu r3,r2,r3
03038846  62 83  ld.b r3,(r3,0x2)
03038848  03 e9 de 02  bez r3,0x03038e04
0303884c  42 3b  cmpnei r3,0x2
0303884e  40 e8 dd 02  bf 0x03038e08
03038852  44 3b  cmpnei r3,0x4
03038854  60 e8 dc 02  bt 0x03038e0c
03038858  76 11  lrw r3,0x3038930
0303885a  23 d8 30 00  ld.b r1,(r3,0x30)
0303885e  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038862  75 11  lrw r3,0x3038934
03038864  43 83  ld.b r2,(r3,0x3)
03038866  75 11  lrw r3,0x3038938
03038868  6c 5a  addu r3,r2,r3
0303886a  42 83  ld.b r2,(r3,0x2)
0303886c  79 11  lrw r3,0x3038950
0303886e  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038872  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038876  00 e8 18 03  br 0x03038ea6
0303887a  41 3b  cmpnei r3,0x1
0303887c  0f 08  bt 0x0303889a
0303887e  6e 11  lrw r3,0x3038934
03038880  42 83  ld.b r2,(r3,0x2)
03038882  73 11  lrw r3,0x303894c
03038884  6c 5a  addu r3,r2,r3
03038886  62 83  ld.b r3,(r3,0x2)
03038888  41 3b  cmpnei r3,0x1
0303888a  33 11  lrw r1,0x3038954
0303888c  53 11  lrw r2,0x3038958
0303888e  62 c4 40 0c  movt r3,r2
03038892  61 c4 20 0c  movf r3,r1
03038896  00 e8 08 03  br 0x03038ea6
0303889a  43 3b  cmpnei r3,0x3
0303889c  0c 08  bt 0x030388b4
0303889e  65 11  lrw r3,0x3038930
030388a0  43 d8 30 00  ld.b r2,(r3,0x30)
030388a4  c2 c4 c2 54  zext r2,r2,0x6,0x6
030388a8  6d 11  lrw r3,0x303895c
030388aa  43 d0 83 08  ldr.w r3,(r3,r2<<2)
030388ae  60 93  ld.w r3,(r3,0x0)
030388b0  00 e8 fb 02  br 0x03038ea6
030388b4  44 3b  cmpnei r3,0x4
030388b6  40 e8 ad 02  bf 0x03038e10
030388ba  46 3b  cmpnei r3,0x6
030388bc  0c 08  bt 0x030388d4
030388be  7d 10  lrw r3,0x3038930
030388c0  43 d8 30 00  ld.b r2,(r3,0x30)
030388c4  c2 c4 c2 54  zext r2,r2,0x6,0x6
030388c8  66 11  lrw r3,0x3038960
030388ca  43 d0 03 09  ldr.w r3,(r3,r2<<3)
030388ce  66 93  ld.w r3,(r3,0x18)
030388d0  00 e8 eb 02  br 0x03038ea6
030388d4  47 3b  cmpnei r3,0x7
030388d6  17 08  bt 0x03038904
030388d8  77 10  lrw r3,0x3038934
030388da  42 83  ld.b r2,(r3,0x2)
030388dc  7c 10  lrw r3,0x303894c
030388de  6c 5a  addu r3,r2,r3
030388e0  62 83  ld.b r3,(r3,0x2)
030388e2  41 3b  cmpnei r3,0x1
030388e4  40 e8 98 02  bf 0x03038e14
030388e8  42 3b  cmpnei r3,0x2
030388ea  60 e8 97 02  bt 0x03038e18
030388ee  71 10  lrw r3,0x3038930
030388f0  43 d8 30 00  ld.b r2,(r3,0x30)
030388f4  c2 c4 c2 54  zext r2,r2,0x6,0x6
030388f8  7b 10  lrw r3,0x3038964
030388fa  43 d0 03 09  ldr.w r3,(r3,r2<<3)
030388fe  62 93  ld.w r3,(r3,0x8)
03038900  00 e8 d3 02  br 0x03038ea6
03038904  48 3b  cmpnei r3,0x8
03038906  60 e8 8b 02  bt 0x03038e1c
0303890a  6b 10  lrw r3,0x3038934
0303890c  42 83  ld.b r2,(r3,0x2)
0303890e  70 10  lrw r3,0x303894c
03038910  6c 5a  addu r3,r2,r3
03038912  62 83  ld.b r3,(r3,0x2)
03038914  41 3b  cmpnei r3,0x1
03038916  60 e8 85 02  bt 0x03038e20
0303891a  66 10  lrw r3,0x3038930
0303891c  43 d8 30 00  ld.b r2,(r3,0x30)
03038920  c2 c4 c2 54  zext r2,r2,0x6,0x6
03038924  71 10  lrw r3,0x3038968
03038926  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303892a  60 93  ld.w r3,(r3,0x0)
0303892c  00 e8 bd 02  br 0x03038ea6
0303896c  7f 12  lrw r3,0x3038ae8
0303896e  41 83  ld.b r2,(r3,0x1)
03038970  7f 12  lrw r3,0x3038aec
03038972  6c 5a  addu r3,r2,r3
03038974  62 83  ld.b r3,(r3,0x2)
03038976  43 3b  cmpnei r3,0x3
03038978  12 08  bt 0x0303899c
0303897a  7e 12  lrw r3,0x3038af0
0303897c  23 d8 30 00  ld.b r1,(r3,0x30)
03038980  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038984  79 12  lrw r3,0x3038ae8
03038986  42 83  ld.b r2,(r3,0x2)
03038988  7b 12  lrw r3,0x3038af4
0303898a  6c 5a  addu r3,r2,r3
0303898c  42 83  ld.b r2,(r3,0x2)
0303898e  7b 12  lrw r3,0x3038af8
03038990  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038994  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038998  00 e8 87 02  br 0x03038ea6
0303899c  45 3b  cmpnei r3,0x5
0303899e  8b 08  bt 0x03038ab4
030389a0  72 12  lrw r3,0x3038ae8
030389a2  42 83  ld.b r2,(r3,0x2)
030389a4  74 12  lrw r3,0x3038af4
030389a6  6c 5a  addu r3,r2,r3
030389a8  62 83  ld.b r3,(r3,0x2)
030389aa  23 e9 54 00  bnez r3,0x03038a52
030389ae  6f 12  lrw r3,0x3038ae8
030389b0  43 83  ld.b r2,(r3,0x3)
030389b2  73 12  lrw r3,0x3038afc
030389b4  6c 5a  addu r3,r2,r3
030389b6  62 83  ld.b r3,(r3,0x2)
030389b8  23 e9 13 00  bnez r3,0x030389de
030389bc  6d 12  lrw r3,0x3038af0
030389be  23 d8 30 00  ld.b r1,(r3,0x30)
030389c2  c1 c4 c1 54  zext r1,r1,0x6,0x6
030389c6  69 12  lrw r3,0x3038ae8
030389c8  44 83  ld.b r2,(r3,0x4)
030389ca  6e 12  lrw r3,0x3038b00
030389cc  6c 5a  addu r3,r2,r3
030389ce  42 83  ld.b r2,(r3,0x2)
030389d0  6d 12  lrw r3,0x3038b04
030389d2  23 d0 03 09  ldr.w r3,(r3,r1<<3)
030389d6  43 d0 83 08  ldr.w r3,(r3,r2<<2)
030389da  00 e8 66 02  br 0x03038ea6
030389de  41 3b  cmpnei r3,0x1
030389e0  12 08  bt 0x03038a04
030389e2  64 12  lrw r3,0x3038af0
030389e4  23 d8 30 00  ld.b r1,(r3,0x30)
030389e8  c1 c4 c1 54  zext r1,r1,0x6,0x6
030389ec  7f 11  lrw r3,0x3038ae8
030389ee  44 83  ld.b r2,(r3,0x4)
030389f0  64 12  lrw r3,0x3038b00
030389f2  6c 5a  addu r3,r2,r3
030389f4  42 83  ld.b r2,(r3,0x2)
030389f6  65 12  lrw r3,0x3038b08
030389f8  23 d0 03 09  ldr.w r3,(r3,r1<<3)
030389fc  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038a00  00 e8 53 02  br 0x03038ea6
03038a04  42 3b  cmpnei r3,0x2
03038a06  12 08  bt 0x03038a2a
03038a08  7a 11  lrw r3,0x3038af0
03038a0a  23 d8 30 00  ld.b r1,(r3,0x30)
03038a0e  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038a12  76 11  lrw r3,0x3038ae8
03038a14  44 83  ld.b r2,(r3,0x4)
03038a16  7b 11  lrw r3,0x3038b00
03038a18  6c 5a  addu r3,r2,r3
03038a1a  42 83  ld.b r2,(r3,0x2)
03038a1c  7c 11  lrw r3,0x3038b0c
03038a1e  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038a22  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038a26  00 e8 40 02  br 0x03038ea6
03038a2a  43 3b  cmpnei r3,0x3
03038a2c  60 e8 1c 02  bt 0x03038e64
03038a30  70 11  lrw r3,0x3038af0
03038a32  23 d8 30 00  ld.b r1,(r3,0x30)
03038a36  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038a3a  6c 11  lrw r3,0x3038ae8
03038a3c  44 83  ld.b r2,(r3,0x4)
03038a3e  71 11  lrw r3,0x3038b00
03038a40  6c 5a  addu r3,r2,r3
03038a42  42 83  ld.b r2,(r3,0x2)
03038a44  73 11  lrw r3,0x3038b10
03038a46  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038a4a  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038a4e  00 e8 2c 02  br 0x03038ea6
03038a52  41 3b  cmpnei r3,0x1
03038a54  60 e8 0a 02  bt 0x03038e68
03038a58  64 11  lrw r3,0x3038ae8
03038a5a  43 83  ld.b r2,(r3,0x3)
03038a5c  68 11  lrw r3,0x3038afc
03038a5e  6c 5a  addu r3,r2,r3
03038a60  62 83  ld.b r3,(r3,0x2)
03038a62  43 3b  cmpnei r3,0x3
03038a64  12 08  bt 0x03038a88
03038a66  63 11  lrw r3,0x3038af0
03038a68  23 d8 30 00  ld.b r1,(r3,0x30)
03038a6c  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038a70  7e 10  lrw r3,0x3038ae8
03038a72  44 83  ld.b r2,(r3,0x4)
03038a74  63 11  lrw r3,0x3038b00
03038a76  6c 5a  addu r3,r2,r3
03038a78  42 83  ld.b r2,(r3,0x2)
03038a7a  67 11  lrw r3,0x3038b14
03038a7c  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038a80  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038a84  00 e8 11 02  br 0x03038ea6
03038a88  47 3b  cmpnei r3,0x7
03038a8a  f1 0d  bf 0x03038e6c
03038a8c  4c 3b  cmpnei r3,0xc
03038a8e  f1 0d  bf 0x03038e70
03038a90  4f 3b  cmpnei r3,0xf
03038a92  f1 09  bt 0x03038e74
03038a94  77 10  lrw r3,0x3038af0
03038a96  23 d8 30 00  ld.b r1,(r3,0x30)
03038a9a  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038a9e  73 10  lrw r3,0x3038ae8
03038aa0  44 83  ld.b r2,(r3,0x4)
03038aa2  78 10  lrw r3,0x3038b00
03038aa4  6c 5a  addu r3,r2,r3
03038aa6  42 83  ld.b r2,(r3,0x2)
03038aa8  7c 10  lrw r3,0x3038b18
03038aaa  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038aae  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038ab2  fa 05  br 0x03038ea6
03038ab4  23 e9 59 00  bnez r3,0x03038b66
03038ab8  6c 10  lrw r3,0x3038ae8
03038aba  42 83  ld.b r2,(r3,0x2)
03038abc  6e 10  lrw r3,0x3038af4
03038abe  6c 5a  addu r3,r2,r3
03038ac0  62 83  ld.b r3,(r3,0x2)
03038ac2  23 e9 2f 00  bnez r3,0x03038b20
03038ac6  6b 10  lrw r3,0x3038af0
03038ac8  23 d8 30 00  ld.b r1,(r3,0x30)
03038acc  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038ad0  66 10  lrw r3,0x3038ae8
03038ad2  44 83  ld.b r2,(r3,0x4)
03038ad4  6b 10  lrw r3,0x3038b00
03038ad6  6c 5a  addu r3,r2,r3
03038ad8  42 83  ld.b r2,(r3,0x2)
03038ada  71 10  lrw r3,0x3038b1c
03038adc  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038ae0  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038ae4  e1 05  br 0x03038ea6
03038b20  43 3b  cmpnei r3,0x3
03038b22  09 08  bt 0x03038b34
03038b24  01 1c  addi r4,sp,0x4
03038b26  13 6c  mov r0,r4
03038b28  3a 12  lrw r1,0x3038c90
03038b2a  10 32  movi r2,0x10
03038b2c  7f e2 06 94  bsr 0x0002b338
03038b30  d3 6c  mov r3,r4
03038b32  ba 05  br 0x03038ea6
03038b34  44 3b  cmpnei r3,0x4
03038b36  a1 09  bt 0x03038e78
03038b38  77 12  lrw r3,0x3038c94
03038b3a  43 83  ld.b r2,(r3,0x3)
03038b3c  77 12  lrw r3,0x3038c98
03038b3e  6c 5a  addu r3,r2,r3
03038b40  62 83  ld.b r3,(r3,0x2)
03038b42  23 e9 9d 01  bnez r3,0x03038e7c
03038b46  76 12  lrw r3,0x3038c9c
03038b48  23 d8 30 00  ld.b r1,(r3,0x30)
03038b4c  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038b50  71 12  lrw r3,0x3038c94
03038b52  44 83  ld.b r2,(r3,0x4)
03038b54  73 12  lrw r3,0x3038ca0
03038b56  6c 5a  addu r3,r2,r3
03038b58  42 83  ld.b r2,(r3,0x2)
03038b5a  73 12  lrw r3,0x3038ca4
03038b5c  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038b60  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038b64  a1 05  br 0x03038ea6
03038b66  42 3b  cmpnei r3,0x2
03038b68  30 12  lrw r1,0x3038ca8
03038b6a  51 12  lrw r2,0x3038cac
03038b6c  62 c4 40 0c  movt r3,r2
03038b70  61 c4 20 0c  movf r3,r1
03038b74  99 05  br 0x03038ea6
03038b76  68 12  lrw r3,0x3038c94
03038b78  41 83  ld.b r2,(r3,0x1)
03038b7a  6e 12  lrw r3,0x3038cb0
03038b7c  6c 5a  addu r3,r2,r3
03038b7e  62 83  ld.b r3,(r3,0x2)
03038b80  43 3b  cmpnei r3,0x3
03038b82  11 08  bt 0x03038ba4
03038b84  66 12  lrw r3,0x3038c9c
03038b86  23 d8 30 00  ld.b r1,(r3,0x30)
03038b8a  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038b8e  62 12  lrw r3,0x3038c94
03038b90  42 83  ld.b r2,(r3,0x2)
03038b92  69 12  lrw r3,0x3038cb4
03038b94  6c 5a  addu r3,r2,r3
03038b96  42 83  ld.b r2,(r3,0x2)
03038b98  68 12  lrw r3,0x3038cb8
03038b9a  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038b9e  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038ba2  82 05  br 0x03038ea6
03038ba4  45 3b  cmpnei r3,0x5
03038ba6  44 08  bt 0x03038c2e
03038ba8  7b 11  lrw r3,0x3038c94
03038baa  43 83  ld.b r2,(r3,0x3)
03038bac  7b 11  lrw r3,0x3038c98
03038bae  6c 5a  addu r3,r2,r3
03038bb0  62 83  ld.b r3,(r3,0x2)
03038bb2  41 3b  cmpnei r3,0x1
03038bb4  0b 08  bt 0x03038bca
03038bb6  7a 11  lrw r3,0x3038c9c
03038bb8  43 d8 30 00  ld.b r2,(r3,0x30)
03038bbc  c2 c4 c2 54  zext r2,r2,0x6,0x6
03038bc0  7f 11  lrw r3,0x3038cbc
03038bc2  43 d0 03 09  ldr.w r3,(r3,r2<<3)
03038bc6  60 93  ld.w r3,(r3,0x0)
03038bc8  6f 05  br 0x03038ea6
03038bca  42 3b  cmpnei r3,0x2
03038bcc  18 08  bt 0x03038bfc
03038bce  72 11  lrw r3,0x3038c94
03038bd0  44 83  ld.b r2,(r3,0x4)
03038bd2  74 11  lrw r3,0x3038ca0
03038bd4  6c 5a  addu r3,r2,r3
03038bd6  62 83  ld.b r3,(r3,0x2)
03038bd8  51 3b  cmpnei r3,0x11
03038bda  53 09  bt 0x03038e80
03038bdc  70 11  lrw r3,0x3038c9c
03038bde  23 d8 30 00  ld.b r1,(r3,0x30)
03038be2  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038be6  6c 11  lrw r3,0x3038c94
03038be8  45 83  ld.b r2,(r3,0x5)
03038bea  76 11  lrw r3,0x3038cc0
03038bec  6c 5a  addu r3,r2,r3
03038bee  42 83  ld.b r2,(r3,0x2)
03038bf0  75 11  lrw r3,0x3038cc4
03038bf2  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038bf6  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038bfa  56 05  br 0x03038ea6
03038bfc  43 3b  cmpnei r3,0x3
03038bfe  43 09  bt 0x03038e84
03038c00  65 11  lrw r3,0x3038c94
03038c02  44 83  ld.b r2,(r3,0x4)
03038c04  67 11  lrw r3,0x3038ca0
03038c06  6c 5a  addu r3,r2,r3
03038c08  62 83  ld.b r3,(r3,0x2)
03038c0a  43 3b  cmpnei r3,0x3
03038c0c  3e 09  bt 0x03038e88
03038c0e  64 11  lrw r3,0x3038c9c
03038c10  23 d8 30 00  ld.b r1,(r3,0x30)
03038c14  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038c18  7f 10  lrw r3,0x3038c94
03038c1a  45 83  ld.b r2,(r3,0x5)
03038c1c  69 11  lrw r3,0x3038cc0
03038c1e  6c 5a  addu r3,r2,r3
03038c20  42 83  ld.b r2,(r3,0x2)
03038c22  6a 11  lrw r3,0x3038cc8
03038c24  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038c28  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038c2c  3d 05  br 0x03038ea6
03038c2e  23 e9 1d 00  bnez r3,0x03038c68
03038c32  79 10  lrw r3,0x3038c94
03038c34  42 83  ld.b r2,(r3,0x2)
03038c36  60 11  lrw r3,0x3038cb4
03038c38  6c 5a  addu r3,r2,r3
03038c3a  62 83  ld.b r3,(r3,0x2)
03038c3c  23 e9 0c 00  bnez r3,0x03038c54
03038c40  77 10  lrw r3,0x3038c9c
03038c42  43 d8 30 00  ld.b r2,(r3,0x30)
03038c46  c2 c4 c2 54  zext r2,r2,0x6,0x6
03038c4a  61 11  lrw r3,0x3038ccc
03038c4c  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038c50  60 93  ld.w r3,(r3,0x0)
03038c52  2a 05  br 0x03038ea6
03038c54  43 3b  cmpnei r3,0x3
03038c56  1b 09  bt 0x03038e8c
03038c58  01 1c  addi r4,sp,0x4
03038c5a  13 6c  mov r0,r4
03038c5c  2d 10  lrw r1,0x3038c90
03038c5e  10 32  movi r2,0x10
03038c60  7f e2 6c 93  bsr 0x0002b338
03038c64  d3 6c  mov r3,r4
03038c66  20 05  br 0x03038ea6
03038c68  41 3b  cmpnei r3,0x1
03038c6a  35 08  bt 0x03038cd4
03038c6c  6a 10  lrw r3,0x3038c94
03038c6e  42 83  ld.b r2,(r3,0x2)
03038c70  71 10  lrw r3,0x3038cb4
03038c72  6c 5a  addu r3,r2,r3
03038c74  62 83  ld.b r3,(r3,0x2)
03038c76  41 3b  cmpnei r3,0x1
03038c78  0c 09  bt 0x03038e90
03038c7a  69 10  lrw r3,0x3038c9c
03038c7c  43 d8 30 00  ld.b r2,(r3,0x30)
03038c80  c2 c4 c2 54  zext r2,r2,0x6,0x6
03038c84  73 10  lrw r3,0x3038cd0
03038c86  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038c8a  60 93  ld.w r3,(r3,0x0)
03038c8c  0d 05  br 0x03038ea6
03038cd4  44 3b  cmpnei r3,0x4
03038cd6  0b 08  bt 0x03038cec
03038cd8  73 12  lrw r3,0x3038e24
03038cda  43 d8 30 00  ld.b r2,(r3,0x30)
03038cde  c2 c4 c2 54  zext r2,r2,0x6,0x6
03038ce2  72 12  lrw r3,0x3038e28
03038ce4  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038ce8  60 93  ld.w r3,(r3,0x0)
03038cea  de 04  br 0x03038ea6
03038cec  47 3b  cmpnei r3,0x7
03038cee  30 12  lrw r1,0x3038e2c
03038cf0  50 12  lrw r2,0x3038e30
03038cf2  62 c4 40 0c  movt r3,r2
03038cf6  61 c4 20 0c  movf r3,r1
03038cfa  d6 04  br 0x03038ea6
03038cfc  6e 12  lrw r3,0x3038e34
03038cfe  41 83  ld.b r2,(r3,0x1)
03038d00  6e 12  lrw r3,0x3038e38
03038d02  6c 5a  addu r3,r2,r3
03038d04  62 83  ld.b r3,(r3,0x2)
03038d06  43 3b  cmpnei r3,0x3
03038d08  29 08  bt 0x03038d5a
03038d0a  6d 12  lrw r3,0x3038e3c
03038d0c  66 83  ld.b r3,(r3,0x6)
03038d0e  63 e4 10 20  andi r3,r3,0x10
03038d12  cc 74  zextb r3,r3
03038d14  03 e9 13 00  bez r3,0x03038d3a
03038d18  63 12  lrw r3,0x3038e24
03038d1a  43 d8 30 00  ld.b r2,(r3,0x30)
03038d1e  c2 c4 c2 54  zext r2,r2,0x6,0x6
03038d22  62 12  lrw r3,0x3038e28
03038d24  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038d28  01 30  movi r0,0x1
03038d2a  01 ea ff ff  movi r1,0xffff
03038d2e  00 32  movi r2,0x0
03038d30  60 93  ld.w r3,(r3,0x0)
03038d32  fe e3 e1 fe  bsr 0x03018af4
03038d36  7f 11  lrw r3,0x3038e30
03038d38  b7 04  br 0x03038ea6
03038d3a  7b 11  lrw r3,0x3038e24
03038d3c  23 d8 30 00  ld.b r1,(r3,0x30)
03038d40  c1 c4 c1 54  zext r1,r1,0x6,0x6
03038d44  7c 11  lrw r3,0x3038e34
03038d46  42 83  ld.b r2,(r3,0x2)
03038d48  7e 11  lrw r3,0x3038e40
03038d4a  6c 5a  addu r3,r2,r3
03038d4c  42 83  ld.b r2,(r3,0x2)
03038d4e  7e 11  lrw r3,0x3038e44
03038d50  23 d0 03 09  ldr.w r3,(r3,r1<<3)
03038d54  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038d58  a7 04  br 0x03038ea6
03038d5a  41 3b  cmpnei r3,0x1
03038d5c  0b 08  bt 0x03038d72
03038d5e  72 11  lrw r3,0x3038e24
03038d60  43 d8 30 00  ld.b r2,(r3,0x30)
03038d64  c2 c4 c2 54  zext r2,r2,0x6,0x6
03038d68  78 11  lrw r3,0x3038e48
03038d6a  43 d0 03 09  ldr.w r3,(r3,r2<<3)
03038d6e  60 93  ld.w r3,(r3,0x0)
03038d70  9b 04  br 0x03038ea6
03038d72  45 3b  cmpnei r3,0x5
03038d74  12 08  bt 0x03038d98
03038d76  70 11  lrw r3,0x3038e34
03038d78  43 83  ld.b r2,(r3,0x3)
03038d7a  75 11  lrw r3,0x3038e4c
03038d7c  6c 5a  addu r3,r2,r3
03038d7e  62 83  ld.b r3,(r3,0x2)
03038d80  4c 3b  cmpnei r3,0xc
03038d82  89 08  bt 0x03038e94
03038d84  68 11  lrw r3,0x3038e24
03038d86  43 d8 30 00  ld.b r2,(r3,0x30)
03038d8a  c2 c4 c2 54  zext r2,r2,0x6,0x6
03038d8e  71 11  lrw r3,0x3038e50
03038d90  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038d94  60 93  ld.w r3,(r3,0x0)
03038d96  88 04  br 0x03038ea6
03038d98  23 e9 80 00  bnez r3,0x03038e98
03038d9c  66 11  lrw r3,0x3038e34
03038d9e  42 83  ld.b r2,(r3,0x2)
03038da0  68 11  lrw r3,0x3038e40
03038da2  6c 5a  addu r3,r2,r3
03038da4  62 83  ld.b r3,(r3,0x2)
03038da6  43 3b  cmpnei r3,0x3
03038da8  7a 08  bt 0x03038e9c
03038daa  01 1c  addi r4,sp,0x4
03038dac  13 6c  mov r0,r4
03038dae  2a 11  lrw r1,0x3038e54
03038db0  10 32  movi r2,0x10
03038db2  7f e2 c3 92  bsr 0x0002b338
03038db6  d3 6c  mov r3,r4
03038db8  77 04  br 0x03038ea6
03038dba  7f 10  lrw r3,0x3038e34
03038dbc  41 83  ld.b r2,(r3,0x1)
03038dbe  7f 10  lrw r3,0x3038e38
03038dc0  6c 5a  addu r3,r2,r3
03038dc2  62 83  ld.b r3,(r3,0x2)
03038dc4  43 3b  cmpnei r3,0x3
03038dc6  6d 08  bt 0x03038ea0
03038dc8  7d 10  lrw r3,0x3038e3c
03038dca  66 83  ld.b r3,(r3,0x6)
03038dcc  63 e4 10 20  andi r3,r3,0x10
03038dd0  cc 74  zextb r3,r3
03038dd2  03 e9 69 00  bez r3,0x03038ea4
03038dd6  74 10  lrw r3,0x3038e24
03038dd8  43 d8 30 00  ld.b r2,(r3,0x30)
03038ddc  c2 c4 c2 54  zext r2,r2,0x6,0x6
03038de0  72 10  lrw r3,0x3038e28
03038de2  43 d0 83 08  ldr.w r3,(r3,r2<<2)
03038de6  01 30  movi r0,0x1
03038de8  01 ea ff ff  movi r1,0xffff
03038dec  00 32  movi r2,0x0
03038dee  60 93  ld.w r3,(r3,0x0)
03038df0  fe e3 82 fe  bsr 0x03018af4
03038df4  6f 10  lrw r3,0x3038e30
03038df6  58 04  br 0x03038ea6
03038df8  6e 10  lrw r3,0x3038e30
03038dfa  56 04  br 0x03038ea6
03038dfc  77 10  lrw r3,0x3038e58
03038dfe  54 04  br 0x03038ea6
03038e00  6c 10  lrw r3,0x3038e30
03038e02  52 04  br 0x03038ea6
03038e04  75 10  lrw r3,0x3038e58
03038e06  50 04  br 0x03038ea6
03038e08  75 10  lrw r3,0x3038e5c
03038e0a  4e 04  br 0x03038ea6
03038e0c  69 10  lrw r3,0x3038e30
03038e0e  4c 04  br 0x03038ea6
03038e10  74 10  lrw r3,0x3038e60
03038e12  4a 04  br 0x03038ea6
03038e14  71 10  lrw r3,0x3038e58
03038e16  48 04  br 0x03038ea6
03038e18  66 10  lrw r3,0x3038e30
03038e1a  46 04  br 0x03038ea6
03038e1c  65 10  lrw r3,0x3038e30
03038e1e  44 04  br 0x03038ea6
03038e20  64 10  lrw r3,0x3038e30
03038e22  42 04  br 0x03038ea6
03038e64  63 13  lrw r3,0x3038ff0
03038e66  20 04  br 0x03038ea6
03038e68  62 13  lrw r3,0x3038ff0
03038e6a  1e 04  br 0x03038ea6
03038e6c  62 13  lrw r3,0x3038ff4
03038e6e  1c 04  br 0x03038ea6
03038e70  62 13  lrw r3,0x3038ff8
03038e72  1a 04  br 0x03038ea6
03038e74  7f 12  lrw r3,0x3038ff0
03038e76  18 04  br 0x03038ea6
03038e78  7e 12  lrw r3,0x3038ff0
03038e7a  16 04  br 0x03038ea6
03038e7c  7d 12  lrw r3,0x3038ff0
03038e7e  14 04  br 0x03038ea6
03038e80  7c 12  lrw r3,0x3038ff0
03038e82  12 04  br 0x03038ea6
03038e84  7b 12  lrw r3,0x3038ff0
03038e86  10 04  br 0x03038ea6
03038e88  7a 12  lrw r3,0x3038ff0
03038e8a  0e 04  br 0x03038ea6
03038e8c  79 12  lrw r3,0x3038ff0
03038e8e  0c 04  br 0x03038ea6
03038e90  78 12  lrw r3,0x3038ff0
03038e92  0a 04  br 0x03038ea6
03038e94  77 12  lrw r3,0x3038ff0
03038e96  08 04  br 0x03038ea6
03038e98  76 12  lrw r3,0x3038ff0
03038e9a  06 04  br 0x03038ea6
03038e9c  75 12  lrw r3,0x3038ff0
03038e9e  04 04  br 0x03038ea6
03038ea0  74 12  lrw r3,0x3038ff0
03038ea2  02 04  br 0x03038ea6
03038ea4  73 12  lrw r3,0x3038ff0
03038ea6  01 30  movi r0,0x1
03038ea8  01 ea ff ff  movi r1,0xffff
03038eac  00 32  movi r2,0x0
03038eae  fe e3 23 fe  bsr 0x03018af4
03038eb2  06 14  addi sp,sp,0x18
03038eb4  91 14  pop r4,lr

; 0303a748 FUN_0303a748
0303a748  d1 14  push r4,lr
0303a74a  21 14  subi sp,sp,0x4
0303a74c  78 11  lrw r3,0x303a82c
0303a74e  60 83  ld.b r3,(r3,0x0)
0303a750  63 e4 02 20  andi r3,r3,0x2
0303a754  cc 74  zextb r3,r3
0303a756  03 e9 12 00  bez r3,0x0303a77a
0303a75a  76 11  lrw r3,0x303a830
0303a75c  41 83  ld.b r2,(r3,0x1)
0303a75e  76 11  lrw r3,0x303a834
0303a760  6c 5a  addu r3,r2,r3
0303a762  62 83  ld.b r3,(r3,0x2)
0303a764  03 e9 05 00  bez r3,0x0303a76e
0303a768  41 3b  cmpnei r3,0x1
0303a76a  e1 09  bt 0x0303ab2c
0303a76c  04 04  br 0x0303a774
0303a76e  00 e0 71 94  bsr 0x0304d050
0303a772  dd 05  br 0x0303ab2c
0303a774  00 e0 84 94  bsr 0x0304d07c
0303a778  da 05  br 0x0303ab2c
0303a77a  6e 11  lrw r3,0x303a830
0303a77c  41 83  ld.b r2,(r3,0x1)
0303a77e  6e 11  lrw r3,0x303a834
0303a780  6c 5a  addu r3,r2,r3
0303a782  62 83  ld.b r3,(r3,0x2)
0303a784  44 3b  cmpnei r3,0x4
0303a786  18 08  bt 0x0303a7b6
0303a788  6c 11  lrw r3,0x303a838
0303a78a  68 83  ld.b r3,(r3,0x8)
0303a78c  63 e4 0f 30  andni r3,r3,0xf
0303a790  cc 74  zextb r3,r3
0303a792  23 e9 0f 00  bnez r3,0x0303a7b0
0303a796  00 30  movi r0,0x0
0303a798  fe e3 3a c6  bsr 0x0301340c
0303a79c  61 11  lrw r3,0x303a820
0303a79e  42 83  ld.b r2,(r3,0x2)
0303a7a0  61 11  lrw r3,0x303a824
0303a7a2  62 d0 20 00  ldr.b r0,(r2,r3<<0)
0303a7a6  00 74  zextb r0,r0
0303a7a8  00 31  movi r1,0x0
0303a7aa  ff e3 5f db  bsr 0x03035e68
0303a7ae  bf 05  br 0x0303ab2c
0303a7b0  00 e0 5e 97  bsr 0x0304d66c
0303a7b4  bc 05  br 0x0303ab2c
0303a7b6  23 e9 9b 00  bnez r3,0x0303a8ec
0303a7ba  7e 10  lrw r3,0x303a830
0303a7bc  42 83  ld.b r2,(r3,0x2)
0303a7be  60 11  lrw r3,0x303a83c
0303a7c0  6c 5a  addu r3,r2,r3
0303a7c2  62 83  ld.b r3,(r3,0x2)
0303a7c4  41 3b  cmpnei r3,0x1
0303a7c6  56 08  bt 0x0303a872
0303a7c8  00 e0 ca fa  bsr 0x03059d5c
0303a7cc  41 38  cmpnei r0,0x1
0303a7ce  48 08  bt 0x0303a85e
0303a7d0  7c 10  lrw r3,0x303a840
0303a7d2  00 93  ld.w r0,(r3,0x0)
0303a7d4  ff e3 24 d8  bsr 0x0303581c
0303a7d8  00 e9 3a 00  bez r0,0x0303a84c
0303a7dc  6b 10  lrw r3,0x303a808
0303a7de  43 d8 30 00  ld.b r2,(r3,0x30)
0303a7e2  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303a7e6  78 10  lrw r3,0x303a844
0303a7e8  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303a7ec  2d 30  movi r0,0x2d
0303a7ee  0a 31  movi r1,0xa
0303a7f0  40 93  ld.w r2,(r3,0x0)
0303a7f2  00 e0 b1 6e  bsr 0x03048554
0303a7f6  75 10  lrw r3,0x303a848
0303a7f8  45 83  ld.b r2,(r3,0x5)
0303a7fa  00 31  movi r1,0x0
0303a7fc  41 c4 03 5c  ins r2,r1,0x0,0x3
0303a800  41 c4 02 5c  ins r2,r1,0x0,0x2
0303a804  45 a3  st.b r2,(r3,0x5)
0303a806  93 05  br 0x0303ab2c
0303a84c  07 13  lrw r0,0x303a9e8
0303a84e  28 13  lrw r1,0x303a9ec
0303a850  01 e0 44 b2  bsr 0x03070cd8
0303a854  1c 30  movi r0,0x1c
0303a856  01 31  movi r1,0x1
0303a858  ff e3 08 db  bsr 0x03035e68
0303a85c  68 05  br 0x0303ab2c
0303a85e  65 13  lrw r3,0x303a9f0
0303a860  42 83  ld.b r2,(r3,0x2)
0303a862  65 13  lrw r3,0x303a9f4
0303a864  62 d0 20 00  ldr.b r0,(r2,r3<<0)
0303a868  00 74  zextb r0,r0
0303a86a  00 31  movi r1,0x0
0303a86c  ff e3 fe da  bsr 0x03035e68
0303a870  5e 05  br 0x0303ab2c
0303a872  42 3b  cmpnei r3,0x2
0303a874  37 08  bt 0x0303a8e2
0303a876  00 32  movi r2,0x0
0303a878  60 13  lrw r3,0x303a9f8
0303a87a  40 a3  st.b r2,(r3,0x0)
0303a87c  00 e0 70 fa  bsr 0x03059d5c
0303a880  20 e9 0c 00  bnez r0,0x0303a898
0303a884  7b 12  lrw r3,0x303a9f0
0303a886  42 83  ld.b r2,(r3,0x2)
0303a888  7b 12  lrw r3,0x303a9f4
0303a88a  62 d0 20 00  ldr.b r0,(r2,r3<<0)
0303a88e  00 74  zextb r0,r0
0303a890  00 31  movi r1,0x0
0303a892  ff e3 eb da  bsr 0x03035e68
0303a896  4b 05  br 0x0303ab2c
0303a898  79 12  lrw r3,0x303a9fc
0303a89a  63 83  ld.b r3,(r3,0x3)
0303a89c  63 e4 04 20  andi r3,r3,0x4
0303a8a0  cc 74  zextb r3,r3
0303a8a2  03 e9 15 00  bez r3,0x0303a8cc
0303a8a6  00 30  movi r0,0x0
0303a8a8  fe e3 b2 c5  bsr 0x0301340c
0303a8ac  74 12  lrw r3,0x303a9fc
0303a8ae  45 83  ld.b r2,(r3,0x5)
0303a8b0  01 31  movi r1,0x1
0303a8b2  41 c4 06 5c  ins r2,r1,0x0,0x6
0303a8b6  45 a3  st.b r2,(r3,0x5)
0303a8b8  6e 12  lrw r3,0x303a9f0
0303a8ba  42 83  ld.b r2,(r3,0x2)
0303a8bc  6e 12  lrw r3,0x303a9f4
0303a8be  62 d0 20 00  ldr.b r0,(r2,r3<<0)
0303a8c2  00 74  zextb r0,r0
0303a8c4  00 31  movi r1,0x0
0303a8c6  ff e3 d1 da  bsr 0x03035e68
0303a8ca  31 05  br 0x0303ab2c
0303a8cc  6c 12  lrw r3,0x303a9fc
0303a8ce  45 83  ld.b r2,(r3,0x5)
0303a8d0  00 31  movi r1,0x0
0303a8d2  41 c4 06 5c  ins r2,r1,0x0,0x6
0303a8d6  45 a3  st.b r2,(r3,0x5)
0303a8d8  1c 30  movi r0,0x1c
0303a8da  01 31  movi r1,0x1
0303a8dc  ff e3 c6 da  bsr 0x03035e68
0303a8e0  26 05  br 0x0303ab2c
0303a8e2  1c 30  movi r0,0x1c
0303a8e4  01 31  movi r1,0x1
0303a8e6  ff e3 c1 da  bsr 0x03035e68
0303a8ea  21 05  br 0x0303ab2c
0303a8ec  41 3b  cmpnei r3,0x1
0303a8ee  04 08  bt 0x0303a8f6
0303a8f0  00 e0 c6 93  bsr 0x0304d07c
0303a8f4  1c 05  br 0x0303ab2c
0303a8f6  42 3b  cmpnei r3,0x2
0303a8f8  04 08  bt 0x0303a900
0303a8fa  00 e0 b9 95  bsr 0x0304d46c
0303a8fe  17 05  br 0x0303ab2c
0303a900  43 3b  cmpnei r3,0x3
0303a902  2f 08  bt 0x0303a960
0303a904  7f 11  lrw r3,0x303aa00
0303a906  60 83  ld.b r3,(r3,0x0)
0303a908  4a 3b  cmpnei r3,0xa
0303a90a  22 08  bt 0x0303a94e
0303a90c  7e 11  lrw r3,0x303aa04
0303a90e  60 83  ld.b r3,(r3,0x0)
0303a910  43 3b  cmpnei r3,0x3
0303a912  12 08  bt 0x0303a936
0303a914  7d 11  lrw r3,0x303aa08
0303a916  40 8b  ld.h r2,(r3,0x0)
0303a918  7d 11  lrw r3,0x303aa0c
0303a91a  40 ab  st.h r2,(r3,0x0)
0303a91c  7d 11  lrw r3,0x303aa10
0303a91e  40 8b  ld.h r2,(r3,0x0)
0303a920  7d 11  lrw r3,0x303aa14
0303a922  40 ab  st.h r2,(r3,0x0)
0303a924  00 33  movi r3,0x0
0303a926  0f 2b  subi r3,0x10
0303a928  5c 11  lrw r2,0x303aa18
0303a92a  60 a2  st.b r3,(r2,0x0)
0303a92c  1c 30  movi r0,0x1c
0303a92e  01 31  movi r1,0x1
0303a930  ff e3 9c da  bsr 0x03035e68
0303a934  fc 04  br 0x0303ab2c
0303a936  01 e0 79 02  bsr 0x0305ae28
0303a93a  6e 11  lrw r3,0x303a9f0
0303a93c  42 83  ld.b r2,(r3,0x2)
0303a93e  6e 11  lrw r3,0x303a9f4
0303a940  62 d0 20 00  ldr.b r0,(r2,r3<<0)
0303a944  00 74  zextb r0,r0
0303a946  00 31  movi r1,0x0
0303a948  ff e3 90 da  bsr 0x03035e68
0303a94c  f0 04  br 0x0303ab2c
0303a94e  74 11  lrw r3,0x303aa1c
0303a950  60 83  ld.b r3,(r3,0x0)
0303a952  03 e9 ed 00  bez r3,0x0303ab2c
0303a956  1c 30  movi r0,0x1c
0303a958  01 31  movi r1,0x1
0303a95a  ff e3 87 da  bsr 0x03035e68
0303a95e  e7 04  br 0x0303ab2c
0303a960  46 3b  cmpnei r3,0x6
0303a962  94 08  bt 0x0303aa8a
0303a964  6f 11  lrw r3,0x303aa20
0303a966  42 83  ld.b r2,(r3,0x2)
0303a968  6f 11  lrw r3,0x303aa24
0303a96a  6c 5a  addu r3,r2,r3
0303a96c  62 83  ld.b r3,(r3,0x2)
0303a96e  43 3b  cmpnei r3,0x3
0303a970  21 08  bt 0x0303a9b2
0303a972  8e 11  lrw r4,0x303aa28
0303a974  44 d8 30 00  ld.b r2,(r4,0x30)
0303a978  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303a97c  6c 11  lrw r3,0x303aa2c
0303a97e  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303a982  4c 11  lrw r2,0x303aa30
0303a984  40 b8  st.w r2,(sp,0x0)
0303a986  30 30  movi r0,0x30
0303a988  43 6c  mov r1,r0
0303a98a  4b 11  lrw r2,0x303aa34
0303a98c  60 93  ld.w r3,(r3,0x0)
0303a98e  ff e3 d9 00  bsr 0x0301ab40
0303a992  fe e3 d7 b0  bsr 0x03010b40
0303a996  44 d8 30 00  ld.b r2,(r4,0x30)
0303a99a  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303a99e  67 11  lrw r3,0x303aa38
0303a9a0  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0303a9a4  01 30  movi r0,0x1
0303a9a6  20 93  ld.w r1,(r3,0x0)
0303a9a8  ff e3 a6 fd  bsr 0x0303a4f4
0303a9ac  ff e3 02 e1  bsr 0x03036bb0
0303a9b0  be 04  br 0x0303ab2c
0303a9b2  23 e9 5c 00  bnez r3,0x0303aa6a
0303a9b6  62 11  lrw r3,0x303aa3c
0303a9b8  60 83  ld.b r3,(r3,0x0)
0303a9ba  23 e9 49 00  bnez r3,0x0303aa4c
0303a9be  70 10  lrw r3,0x303a9fc
0303a9c0  71 83  ld.b r3,(r3,0x11)
0303a9c2  63 e4 10 20  andi r3,r3,0x10
0303a9c6  cc 74  zextb r3,r3
0303a9c8  03 e9 3e 00  bez r3,0x0303aa44
0303a9cc  21 30  movi r0,0x21
0303a9ce  ff e3 27 39  bsr 0x03021c1c
0303a9d2  76 10  lrw r3,0x303aa28
0303a9d4  43 d8 30 00  ld.b r2,(r3,0x30)
0303a9d8  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303a9dc  79 10  lrw r3,0x303aa40
0303a9de  43 d0 80 08  ldr.w r0,(r3,r2<<2)
0303a9e2  00 e0 bd 64  bsr 0x0304735c
0303a9e6  36 04  br 0x0303aa52
0303aa44  01 30  movi r0,0x1
0303aa46  01 e0 03 3c  bsr 0x0306224c
0303aa4a  04 04  br 0x0303aa52
0303aa4c  00 30  movi r0,0x0
0303aa4e  01 e0 ff 3b  bsr 0x0306224c
0303aa52  78 12  lrw r3,0x303abb0
0303aa54  71 83  ld.b r3,(r3,0x11)
0303aa56  63 e4 10 20  andi r3,r3,0x10
0303aa5a  cc 74  zextb r3,r3
0303aa5c  23 e9 68 00  bnez r3,0x0303ab2c
0303aa60  00 e0 68 35  bsr 0x03041530
0303aa64  ff e3 24 fd  bsr 0x0303a4ac
0303aa68  62 04  br 0x0303ab2c
0303aa6a  41 3b  cmpnei r3,0x1
0303aa6c  0a 08  bt 0x0303aa80
0303aa6e  72 12  lrw r3,0x303abb4
0303aa70  00 83  ld.b r0,(r3,0x0)
0303aa72  01 e0 c9 3b  bsr 0x03062204
0303aa76  00 e0 5d 35  bsr 0x03041530
0303aa7a  ff e3 19 fd  bsr 0x0303a4ac
0303aa7e  57 04  br 0x0303ab2c
0303aa80  1c 30  movi r0,0x1c
0303aa82  01 31  movi r1,0x1
0303aa84  ff e3 f2 d9  bsr 0x03035e68
0303aa88  52 04  br 0x0303ab2c
0303aa8a  47 3b  cmpnei r3,0x7
0303aa8c  11 08  bt 0x0303aaae
0303aa8e  6b 12  lrw r3,0x303abb8
0303aa90  42 83  ld.b r2,(r3,0x2)
0303aa92  6b 12  lrw r3,0x303abbc
0303aa94  6c 5a  addu r3,r2,r3
0303aa96  62 83  ld.b r3,(r3,0x2)
0303aa98  41 3b  cmpnei r3,0x1
0303aa9a  05 08  bt 0x0303aaa4
0303aa9c  66 12  lrw r3,0x303abb4
0303aa9e  40 83  ld.b r2,(r3,0x0)
0303aaa0  68 12  lrw r3,0x303abc0
0303aaa2  40 a3  st.b r2,(r3,0x0)
0303aaa4  1c 30  movi r0,0x1c
0303aaa6  01 31  movi r1,0x1
0303aaa8  ff e3 e0 d9  bsr 0x03035e68
0303aaac  40 04  br 0x0303ab2c
0303aaae  48 3b  cmpnei r3,0x8
0303aab0  04 08  bt 0x0303aab8
0303aab2  00 e0 ff 95  bsr 0x0304d6b0
0303aab6  3b 04  br 0x0303ab2c
0303aab8  49 3b  cmpnei r3,0x9
0303aaba  04 08  bt 0x0303aac2
0303aabc  00 e0 92 96  bsr 0x0304d7e0
0303aac0  36 04  br 0x0303ab2c
0303aac2  4a 3b  cmpnei r3,0xa
0303aac4  04 08  bt 0x0303aacc
0303aac6  00 e0 53 97  bsr 0x0304d96c
0303aaca  31 04  br 0x0303ab2c
0303aacc  45 3b  cmpnei r3,0x5
0303aace  2b 08  bt 0x0303ab24
0303aad0  79 11  lrw r3,0x303abb4
0303aad2  60 83  ld.b r3,(r3,0x0)
0303aad4  5c 11  lrw r2,0x303abc4
0303aad6  6c 5a  addu r3,r2,r3
0303aad8  62 83  ld.b r3,(r3,0x2)
0303aada  4d 3b  cmpnei r3,0xd
0303aadc  1f 08  bt 0x0303ab1a
0303aade  77 11  lrw r3,0x303abb8
0303aae0  42 83  ld.b r2,(r3,0x2)
0303aae2  77 11  lrw r3,0x303abbc
0303aae4  6c 5a  addu r3,r2,r3
0303aae6  62 83  ld.b r3,(r3,0x2)
0303aae8  41 3b  cmpnei r3,0x1
0303aaea  18 08  bt 0x0303ab1a
0303aaec  71 11  lrw r3,0x303abb0
0303aaee  49 8b  ld.h r2,(r3,0x12)
0303aaf0  03 ea 9f 0f  movi r3,0xf9f
0303aaf4  8c 64  cmphs r3,r2
0303aaf6  0d 08  bt 0x0303ab10
0303aaf8  74 11  lrw r3,0x303abc8
0303aafa  43 d8 30 00  ld.b r2,(r3,0x30)
0303aafe  c2 c4 c2 54  zext r2,r2,0x6,0x6
0303ab02  00 30  movi r0,0x0
0303ab04  72 11  lrw r3,0x303abcc
0303ab06  43 d0 81 08  ldr.w r1,(r3,r2<<2)
0303ab0a  ff e3 f5 fc  bsr 0x0303a4f4
0303ab0e  0f 04  br 0x0303ab2c
0303ab10  1c 30  movi r0,0x1c
0303ab12  01 31  movi r1,0x1
0303ab14  ff e3 aa d9  bsr 0x03035e68
0303ab18  0a 04  br 0x0303ab2c
0303ab1a  1c 30  movi r0,0x1c
0303ab1c  01 31  movi r1,0x1
0303ab1e  ff e3 a5 d9  bsr 0x03035e68
0303ab22  05 04  br 0x0303ab2c
0303ab24  1c 30  movi r0,0x1c
0303ab26  01 31  movi r1,0x1
0303ab28  ff e3 a0 d9  bsr 0x03035e68
0303ab2c  01 14  addi sp,sp,0x4
0303ab2e  91 14  pop r4,lr

; 0303cda8 FUN_0303cda8
0303cda8  d3 14  push r4,r5,r6,lr
0303cdaa  21 14  subi sp,sp,0x4
0303cdac  ff e3 26 ce  bsr 0x030369f8
0303cdb0  7c 11  lrw r3,0x303cea0
0303cdb2  60 83  ld.b r3,(r3,0x0)
0303cdb4  63 e4 02 20  andi r3,r3,0x2
0303cdb8  cc 74  zextb r3,r3
0303cdba  03 e9 62 00  bez r3,0x0303ce7e
0303cdbe  7a 11  lrw r3,0x303cea4
0303cdc0  41 83  ld.b r2,(r3,0x1)
0303cdc2  7a 11  lrw r3,0x303cea8
0303cdc4  6c 5a  addu r3,r2,r3
0303cdc6  62 83  ld.b r3,(r3,0x2)
0303cdc8  03 e9 06 00  bez r3,0x0303cdd4
0303cdcc  41 3b  cmpnei r3,0x1
0303cdce  60 e8 2e 05  bt 0x0303d82a
0303cdd2  52 04  br 0x0303ce76
0303cdd4  00 34  movi r4,0x0
0303cdd6  80 b8  st.w r4,(sp,0x0)
0303cdd8  13 6c  mov r0,r4
0303cdda  53 6c  mov r1,r4
0303cddc  f0 32  movi r2,0xf0
0303cdde  1b 33  movi r3,0x1b
0303cde0  fe e3 04 d7  bsr 0x03017be8
0303cde4  d2 11  lrw r6,0x303ceac
0303cde6  b0 11  lrw r5,0x303cea4
0303cde8  62 85  ld.b r3,(r5,0x2)
0303cdea  6c 5e  addu r3,r6,r3
0303cdec  83 d9 6c 00  ld.b r12,(r3,0x6c)
0303cdf0  70 11  lrw r3,0x303ceb0
0303cdf2  60 93  ld.w r3,(r3,0x0)
0303cdf4  02 30  movi r0,0x2
0303cdf6  01 ea ff ff  movi r1,0xffff
0303cdfa  93 6c  mov r2,r4
0303cdfc  83 d1 83 08  ldr.w r3,(r3,r12<<2)
0303ce00  fe e3 7a de  bsr 0x03018af4
0303ce04  62 85  ld.b r3,(r5,0x2)
0303ce06  cc 5e  addu r6,r6,r3
0303ce08  66 d8 6c 00  ld.b r3,(r6,0x6c)
0303ce0c  23 e9 0b 00  bnez r3,0x0303ce22
0303ce10  69 11  lrw r3,0x303ceb4
0303ce12  43 83  ld.b r2,(r3,0x3)
0303ce14  01 31  movi r1,0x1
0303ce16  41 c4 03 5c  ins r2,r1,0x0,0x3
0303ce1a  41 c4 04 5c  ins r2,r1,0x0,0x4
0303ce1e  43 a3  st.b r2,(r3,0x3)
0303ce20  0b 04  br 0x0303ce36
0303ce22  41 3b  cmpnei r3,0x1
0303ce24  09 08  bt 0x0303ce36
0303ce26  64 11  lrw r3,0x303ceb4
0303ce28  43 83  ld.b r2,(r3,0x3)
0303ce2a  00 31  movi r1,0x0
0303ce2c  41 c4 03 5c  ins r2,r1,0x0,0x3
0303ce30  41 c4 04 5c  ins r2,r1,0x0,0x4
0303ce34  43 a3  st.b r2,(r3,0x3)
0303ce36  61 11  lrw r3,0x303ceb8
0303ce38  64 83  ld.b r3,(r3,0x4)
0303ce3a  41 3b  cmpnei r3,0x1
0303ce3c  07 08  bt 0x0303ce4a
0303ce3e  5c 10  lrw r2,0x303ceac
0303ce40  25 30  movi r0,0x25
0303ce42  4b 6c  mov r1,r2
0303ce44  01 22  addi r2,0x2
0303ce46  00 e0 29 63  bsr 0x03049498
0303ce4a  79 10  lrw r3,0x303ceac
0303ce4c  60 8b  ld.h r3,(r3,0x0)
0303ce4e  03 e9 10 00  bez r3,0x0303ce6e
0303ce52  7b 10  lrw r3,0x303cebc
0303ce54  24 83  ld.b r1,(r3,0x4)
0303ce56  5b 10  lrw r2,0x303cec0
0303ce58  20 a2  st.b r1,(r2,0x0)
0303ce5a  40 93  ld.w r2,(r3,0x0)
0303ce5c  3a 10  lrw r1,0x303cec4
0303ce5e  40 b1  st.w r2,(r1,0x0)
0303ce60  3a 10  lrw r1,0x303cec8
0303ce62  40 b1  st.w r2,(r1,0x0)
0303ce64  45 83  ld.b r2,(r3,0x5)
0303ce66  7a 10  lrw r3,0x303cecc
0303ce68  40 a3  st.b r2,(r3,0x0)
0303ce6a  00 e8 e0 04  br 0x0303d82a
0303ce6e  ff e3 a1 ce  bsr 0x03036bb0
0303ce72  00 e8 dc 04  br 0x0303d82a
0303ce76  00 e0 6d 27  bsr 0x03041d50
0303ce7a  00 e8 d8 04  br 0x0303d82a
0303ce7e  01 32  movi r2,0x1
0303ce80  6e 10  lrw r3,0x303ceb8
0303ce82  43 dc 0a 0a  st.b r2,(r3,0xa0a)
0303ce86  68 10  lrw r3,0x303cea4
0303ce88  41 83  ld.b r2,(r3,0x1)
0303ce8a  68 10  lrw r3,0x303cea8
0303ce8c  6c 5a  addu r3,r2,r3
0303ce8e  42 83  ld.b r2,(r3,0x2)
0303ce90  09 3a  cmphsi r2,0xa
0303ce92  60 e8 cc 04  bt 0x0303d82a
0303ce96  6f 10  lrw r3,0x303ced0
0303ce98  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303ce9c  0c 78  jmp r3
0303d82a  ff e3 41 ef  bsr 0x0303b6ac
0303d82e  01 14  addi sp,sp,0x4
0303d830  93 14  pop r4,r5,r6,lr

; 0304d46c FUN_0304d46c
0304d46c  d4 14  push r4,r5,r6,r7,lr
0304d46e  28 14  subi sp,sp,0x20
0304d470  00 e0 be 49  bsr 0x030567ec
0304d474  6e e4 1e 00  addi r3,sp,0x1f
0304d478  00 a3  st.b r0,(r3,0x0)
0304d47a  64 12  lrw r3,0x304d588
0304d47c  60 83  ld.b r3,(r3,0x0)
0304d47e  0c 64  cmphs r3,r0
0304d480  a0 0c  bf 0x0304d5c0
0304d482  79 11  lrw r3,0x304d564
0304d484  60 83  ld.b r3,(r3,0x0)
0304d486  4a 3b  cmpnei r3,0xa
0304d488  ef 08  bt 0x0304d666
0304d48a  61 12  lrw r3,0x304d58c
0304d48c  60 83  ld.b r3,(r3,0x0)
0304d48e  43 3b  cmpnei r3,0x3
0304d490  8c 08  bt 0x0304d5a8
0304d492  00 12  lrw r0,0x304d590
0304d494  00 31  movi r1,0x0
0304d496  87 6c  mov r2,r1
0304d498  fb 6c  mov r3,sp
0304d49a  00 e0 e9 f3  bsr 0x0306bc6c
0304d49e  00 33  movi r3,0x0
0304d4a0  0f 2b  subi r3,0x10
0304d4a2  5d 11  lrw r2,0x304d594
0304d4a4  60 a2  st.b r3,(r2,0x0)
0304d4a6  7d 11  lrw r3,0x304d598
0304d4a8  60 83  ld.b r3,(r3,0x0)
0304d4aa  23 e9 0f 00  bnez r3,0x0304d4c8
0304d4ae  6b 11  lrw r3,0x304d558
0304d4b0  43 d8 30 00  ld.b r2,(r3,0x30)
0304d4b4  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304d4b8  79 11  lrw r3,0x304d59c
0304d4ba  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0304d4be  00 30  movi r0,0x0
0304d4c0  20 93  ld.w r1,(r3,0x0)
0304d4c2  ff e3 19 68  bsr 0x0303a4f4
0304d4c6  d0 04  br 0x0304d666
0304d4c8  14 11  lrw r0,0x304d598
0304d4ca  00 e0 59 4c  bsr 0x03056d7c
0304d4ce  00 e9 0e 00  bez r0,0x0304d4ea
0304d4d2  62 11  lrw r3,0x304d558
0304d4d4  43 d8 30 00  ld.b r2,(r3,0x30)
0304d4d8  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304d4dc  00 30  movi r0,0x0
0304d4de  71 11  lrw r3,0x304d5a0
0304d4e0  43 d0 81 08  ldr.w r1,(r3,r2<<2)
0304d4e4  ff e3 08 68  bsr 0x0303a4f4
0304d4e8  bf 04  br 0x0304d666
0304d4ea  ae e4 1e 00  addi r5,sp,0x1f
0304d4ee  00 85  ld.b r0,(r5,0x0)
0304d4f0  00 20  addi r0,0x1
0304d4f2  07 1e  addi r6,sp,0x1c
0304d4f4  ee e4 19 00  addi r7,sp,0x1a
0304d4f8  00 74  zextb r0,r0
0304d4fa  5b 6c  mov r1,r6
0304d4fc  9f 6c  mov r2,r7
0304d4fe  00 e0 c9 43  bsr 0x03055c90
0304d502  01 1c  addi r4,sp,0x4
0304d504  13 6c  mov r0,r4
0304d506  25 11  lrw r1,0x304d598
0304d508  10 32  movi r2,0x10
0304d50a  7e e2 17 ef  bsr 0x0002b338
0304d50e  01 33  movi r3,0x1
0304d510  70 a4  st.b r3,(r4,0x10)
0304d512  71 a4  st.b r3,(r4,0x11)
0304d514  00 33  movi r3,0x0
0304d516  72 a4  st.b r3,(r4,0x12)
0304d518  00 86  ld.b r0,(r6,0x0)
0304d51a  20 8f  ld.h r1,(r7,0x0)
0304d51c  93 6c  mov r2,r4
0304d51e  13 33  movi r3,0x13
0304d520  fe e3 ac 11  bsr 0x0300f878
0304d524  60 85  ld.b r3,(r5,0x0)
0304d526  00 23  addi r3,0x1
0304d528  60 a5  st.b r3,(r5,0x0)
0304d52a  5c 30  movi r0,0x5c
0304d52c  00 31  movi r1,0x0
0304d52e  97 6c  mov r2,r5
0304d530  01 33  movi r3,0x1
0304d532  fe e3 a3 11  bsr 0x0300f878
0304d536  69 10  lrw r3,0x304d558
0304d538  43 d8 30 00  ld.b r2,(r3,0x30)
0304d53c  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304d540  79 10  lrw r3,0x304d5a4
0304d542  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0304d546  01 30  movi r0,0x1
0304d548  20 93  ld.w r1,(r3,0x0)
0304d54a  ff e3 d5 67  bsr 0x0303a4f4
0304d54e  8c 04  br 0x0304d666
0304d5a8  00 e0 40 6c  bsr 0x0305ae28
0304d5ac  60 13  lrw r3,0x304d72c
0304d5ae  40 83  ld.b r2,(r3,0x0)
0304d5b0  60 13  lrw r3,0x304d730
0304d5b2  62 d0 20 00  ldr.b r0,(r2,r3<<0)
0304d5b6  00 74  zextb r0,r0
0304d5b8  00 31  movi r1,0x0
0304d5ba  ff e3 57 44  bsr 0x03035e68
0304d5be  54 04  br 0x0304d666
0304d5c0  7d 12  lrw r3,0x304d734
0304d5c2  60 83  ld.b r3,(r3,0x0)
0304d5c4  23 e9 12 00  bnez r3,0x0304d5e8
0304d5c8  00 30  movi r0,0x0
0304d5ca  ff e3 6b 0b  bsr 0x0302eca0
0304d5ce  7b 12  lrw r3,0x304d738
0304d5d0  20 83  ld.b r1,(r3,0x0)
0304d5d2  00 21  addi r1,0x1
0304d5d4  06 30  movi r0,0x6
0304d5d6  44 74  zextb r1,r1
0304d5d8  ff e3 c0 ed  bsr 0x0304b158
0304d5dc  09 30  movi r0,0x9
0304d5de  ff e3 c1 17  bsr 0x03030560
0304d5e2  ff e3 e7 4a  bsr 0x03036bb0
0304d5e6  40 04  br 0x0304d666
0304d5e8  41 3b  cmpnei r3,0x1
0304d5ea  06 08  bt 0x0304d5f6
0304d5ec  1c 30  movi r0,0x1c
0304d5ee  01 31  movi r1,0x1
0304d5f0  ff e3 3c 44  bsr 0x03035e68
0304d5f4  39 04  br 0x0304d666
0304d5f6  42 3b  cmpnei r3,0x2
0304d5f8  33 08  bt 0x0304d65e
0304d5fa  71 12  lrw r3,0x304d73c
0304d5fc  60 83  ld.b r3,(r3,0x0)
0304d5fe  51 12  lrw r2,0x304d740
0304d600  49 8a  ld.h r2,(r2,0x12)
0304d602  4d 5a  subu r2,r2,r3
0304d604  89 74  zexth r2,r2
0304d606  30 12  lrw r1,0x304d744
0304d608  40 a9  st.h r2,(r1,0x0)
0304d60a  3f 31  movi r1,0x3f
0304d60c  c4 64  cmphs r1,r3
0304d60e  11 08  bt 0x0304d630
0304d610  1b 30  movi r0,0x1b
0304d612  fe e3 05 a3  bsr 0x03021c1c
0304d616  6d 12  lrw r3,0x304d748
0304d618  43 d8 30 00  ld.b r2,(r3,0x30)
0304d61c  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304d620  6b 12  lrw r3,0x304d74c
0304d622  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0304d626  00 30  movi r0,0x0
0304d628  20 93  ld.w r1,(r3,0x0)
0304d62a  ff e3 65 67  bsr 0x0303a4f4
0304d62e  1c 04  br 0x0304d666
0304d630  22 e9 12 00  bnez r2,0x0304d654
0304d634  1b 30  movi r0,0x1b
0304d636  fe e3 f3 a2  bsr 0x03021c1c
0304d63a  64 12  lrw r3,0x304d748
0304d63c  43 d8 30 00  ld.b r2,(r3,0x30)
0304d640  c2 c4 c2 54  zext r2,r2,0x6,0x6
0304d644  63 12  lrw r3,0x304d750
0304d646  43 d0 03 09  ldr.w r3,(r3,r2<<3)
0304d64a  00 30  movi r0,0x0
0304d64c  20 93  ld.w r1,(r3,0x0)
0304d64e  ff e3 53 67  bsr 0x0303a4f4
0304d652  0a 04  br 0x0304d666
0304d654  1c 30  movi r0,0x1c
0304d656  01 31  movi r1,0x1
0304d658  ff e3 08 44  bsr 0x03035e68
0304d65c  05 04  br 0x0304d666
0304d65e  1c 30  movi r0,0x1c
0304d660  01 31  movi r1,0x1
0304d662  ff e3 03 44  bsr 0x03035e68
0304d666  08 14  addi sp,sp,0x20
0304d668  94 14  pop r4,r5,r6,r7,lr

; 0305696c FUN_0305696c
0305696c  d3 14  push r4,r5,r6,lr
0305696e  43 6d  mov r5,r0
03056970  87 6d  mov r6,r1
03056972  ff e3 3d ff  bsr 0x030567ec
03056976  00 20  addi r0,0x1
03056978  00 75  zextb r4,r0
0305697a  41 3c  cmpnei r4,0x1
0305697c  0b 0c  bf 0x03056992
0305697e  17 6c  mov r0,r5
03056980  5b 6c  mov r1,r6
03056982  93 6c  mov r2,r4
03056984  ff e3 4e 15  bsr 0x03039420
03056988  00 85  ld.b r0,(r5,0x0)
0305698a  20 86  ld.b r1,(r6,0x0)
0305698c  93 6c  mov r2,r4
0305698e  ff e3 3f ff  bsr 0x0305680c
03056992  93 14  pop r4,r5,r6,lr

; 030569bc FUN_030569bc
030569bc  d3 14  push r4,r5,r6,lr
030569be  43 6d  mov r5,r0
030569c0  87 6d  mov r6,r1
030569c2  ff e3 15 ff  bsr 0x030567ec
030569c6  00 20  addi r0,0x1
030569c8  00 75  zextb r4,r0
030569ca  41 3c  cmpnei r4,0x1
030569cc  0b 0c  bf 0x030569e2
030569ce  17 6c  mov r0,r5
030569d0  5b 6c  mov r1,r6
030569d2  93 6c  mov r2,r4
030569d4  ff e3 f2 14  bsr 0x030393b8
030569d8  00 85  ld.b r0,(r5,0x0)
030569da  20 86  ld.b r1,(r6,0x0)
030569dc  93 6c  mov r2,r4
030569de  ff e3 17 ff  bsr 0x0305680c
030569e2  93 14  pop r4,r5,r6,lr

; 030567ec FUN_030567ec
030567ec  d1 14  push r4,lr
030567ee  21 14  subi sp,sp,0x4
030567f0  8e e4 02 00  addi r4,sp,0x3
030567f4  00 33  movi r3,0x0
030567f6  60 a4  st.b r3,(r4,0x0)
030567f8  5c 30  movi r0,0x5c
030567fa  00 31  movi r1,0x0
030567fc  93 6c  mov r2,r4
030567fe  01 33  movi r3,0x1
03056800  fd e3 c0 c7  bsr 0x0300f780
03056804  00 84  ld.b r0,(r4,0x0)
03056806  01 14  addi sp,sp,0x4
03056808  91 14  pop r4,lr

; 0303ec8c FUN_0303ec8c
0303ec8c  d3 14  push r4,r5,r6,lr
0303ec8e  00 75  zextb r4,r0
0303ec90  7e e2 7e 8a  bsr 0x0001018c
0303ec94  43 6d  mov r5,r0
0303ec96  7e e2 d3 8a  bsr 0x0001023c
0303ec9a  57 11  lrw r2,0x303ed74
0303ec9c  60 82  ld.b r3,(r2,0x0)
0303ec9e  00 23  addi r3,0x1
0303eca0  cc 74  zextb r3,r3
0303eca2  60 a2  st.b r3,(r2,0x0)
0303eca4  41 3b  cmpnei r3,0x1
0303eca6  03 08  bt 0x0303ecac
0303eca8  7e e2 6a 92  bsr 0x0001117c
0303ecac  7e e2 da 8a  bsr 0x00010260
0303ecb0  17 6c  mov r0,r5
0303ecb2  7e e2 75 8a  bsr 0x0001019c
0303ecb6  00 33  movi r3,0x0
0303ecb8  51 11  lrw r2,0x303ed7c
0303ecba  60 a2  st.b r3,(r2,0x0)
0303ecbc  51 11  lrw r2,0x303ed80
0303ecbe  60 a2  st.b r3,(r2,0x0)
0303ecc0  51 11  lrw r2,0x303ed84
0303ecc2  60 a2  st.b r3,(r2,0x0)
0303ecc4  07 33  movi r3,0x7
0303ecc6  61 a2  st.b r3,(r2,0x1)
0303ecc8  b0 11  lrw r5,0x303ed88
0303ecca  c5 e4 23 10  subi r6,r5,0x24
0303ecce  17 6c  mov r0,r5
0303ecd0  5b 6c  mov r1,r6
0303ecd2  23 32  movi r2,0x23
0303ecd4  7f e2 32 63  bsr 0x0002b338
0303ecd8  25 2d  subi r5,0x26
0303ecda  60 8d  ld.h r3,(r5,0x0)
0303ecdc  65 dc e3 02  st.b r3,(r5,0x2e3)
0303ece0  17 30  movi r0,0x17
0303ece2  57 6c  mov r1,r5
0303ece4  9b 6c  mov r2,r6
0303ece6  00 e0 d9 53  bsr 0x03049498
0303ecea  20 8d  ld.h r1,(r5,0x0)
0303ecec  01 e9 11 00  bez r1,0x0303ed0e
0303ecf0  7e 10  lrw r3,0x303ed68
0303ecf2  62 83  ld.b r3,(r3,0x2)
0303ecf4  44 3b  cmpnei r3,0x4
0303ecf6  1f 0d  bf 0x0303ef34
0303ecf8  00 33  movi r3,0x0
0303ecfa  1c 10  lrw r0,0x303ed68
0303ecfc  05 04  br 0x0303ed06
0303ecfe  4c 58  addu r2,r0,r3
0303ed00  42 82  ld.b r2,(r2,0x2)
0303ed02  44 3a  cmpnei r2,0x4
0303ed04  44 0c  bf 0x0303ed8c
0303ed06  00 23  addi r3,0x1
0303ed08  cc 74  zextb r3,r3
0303ed0a  4c 64  cmphs r3,r1
0303ed0c  f9 0f  bf 0x0303ecfe
0303ed0e  7e e2 3f 8a  bsr 0x0001018c
0303ed12  03 6d  mov r4,r0
0303ed14  7e e2 94 8a  bsr 0x0001023c
0303ed18  57 10  lrw r2,0x303ed74
0303ed1a  60 82  ld.b r3,(r2,0x0)
0303ed1c  00 2b  subi r3,0x1
0303ed1e  cc 74  zextb r3,r3
0303ed20  60 a2  st.b r3,(r2,0x0)
0303ed22  23 e9 16 00  bnez r3,0x0303ed4e
0303ed26  7e e2 63 92  bsr 0x000111ec
0303ed2a  74 10  lrw r3,0x303ed78
0303ed2c  60 8b  ld.h r3,(r3,0x0)
0303ed2e  03 e9 0a 00  bez r3,0x0303ed42
0303ed32  7e e2 97 8a  bsr 0x00010260
0303ed36  13 6c  mov r0,r4
0303ed38  7e e2 32 8a  bsr 0x0001019c
0303ed3c  7e e2 06 92  bsr 0x00011148
0303ed40  0c 04  br 0x0303ed58
0303ed42  7e e2 8f 8a  bsr 0x00010260
0303ed46  13 6c  mov r0,r4
0303ed48  7e e2 2a 8a  bsr 0x0001019c
0303ed4c  06 04  br 0x0303ed58
0303ed4e  7e e2 89 8a  bsr 0x00010260
0303ed52  13 6c  mov r0,r4
0303ed54  7e e2 24 8a  bsr 0x0001019c
0303ed58  00 30  movi r0,0x0
0303ed5a  fe e3 59 a3  bsr 0x0301340c
0303ed5e  00 30  movi r0,0x0
0303ed60  ca 04  br 0x0303eef4
0303ed8c  5b 12  lrw r2,0x303eef8
0303ed8e  02 d8 30 00  ld.b r0,(r2,0x30)
0303ed92  c0 c4 c0 54  zext r0,r0,0x6,0x6
0303ed96  3a 12  lrw r1,0x303eefc
0303ed98  43 40  lsli r2,r0 ,0x3
0303ed9a  48 59  addu r2,r1,r2
0303ed9c  03 22  addi r2,0x4
0303ed9e  a2 d9 00 00  ld.b r13,(r2,0x0)
0303eda2  8c ea 58 00  lrw r12,0x303ef00
0303eda6  ac dd 00 00  st.b r13,(r12,0x0)
0303edaa  8c ea 57 00  lrw r12,0x303ef04
0303edae  01 d0 01 09  ldr.w r1,(r1,r0<<3)
0303edb2  2c dc 00 20  st.w r1,(r12,0x0)
0303edb6  21 82  ld.b r1,(r2,0x1)
0303edb8  54 12  lrw r2,0x303ef08
0303edba  20 a2  st.b r1,(r2,0x0)
0303edbc  54 12  lrw r2,0x303ef0c
0303edbe  61 a2  st.b r3,(r2,0x1)
0303edc0  00 23  addi r3,0x1
0303edc2  cc 74  zextb r3,r3
0303edc4  53 12  lrw r2,0x303ef10
0303edc6  61 a2  st.b r3,(r2,0x1)
0303edc8  08 32  movi r2,0x8
0303edca  c8 64  cmphs r2,r3
0303edcc  03 08  bt 0x0303edd2
0303edce  71 12  lrw r3,0x303ef10
0303edd0  41 a3  st.b r2,(r3,0x1)
0303edd2  b1 12  lrw r5,0x303ef14
0303edd4  c5 e4 46 10  subi r6,r5,0x47
0303edd8  17 6c  mov r0,r5
0303edda  5b 6c  mov r1,r6
0303eddc  23 32  movi r2,0x23
0303edde  7f e2 ad 62  bsr 0x0002b338
0303ede2  48 2d  subi r5,0x49
0303ede4  60 8d  ld.h r3,(r5,0x0)
0303ede6  65 dc e4 02  st.b r3,(r5,0x2e4)
0303edea  0e 32  movi r2,0xe
0303edec  6b 12  lrw r3,0x303ef18
0303edee  42 a3  st.b r2,(r3,0x2)
0303edf0  05 30  movi r0,0x5
0303edf2  57 6c  mov r1,r5
0303edf4  9b 6c  mov r2,r6
0303edf6  00 e0 51 53  bsr 0x03049498
0303edfa  20 8d  ld.h r1,(r5,0x0)
0303edfc  01 e9 11 00  bez r1,0x0303ee1e
0303ee00  67 12  lrw r3,0x303ef1c
0303ee02  62 83  ld.b r3,(r3,0x2)
0303ee04  0e 65  cmpne r3,r4
0303ee06  b3 0c  bf 0x0303ef6c
0303ee08  00 33  movi r3,0x0
0303ee0a  05 12  lrw r0,0x303ef1c
0303ee0c  05 04  br 0x0303ee16
0303ee0e  4c 58  addu r2,r0,r3
0303ee10  42 82  ld.b r2,(r2,0x2)
0303ee12  0a 65  cmpne r2,r4
0303ee14  2f 0c  bf 0x0303ee72
0303ee16  00 23  addi r3,0x1
0303ee18  cc 74  zextb r3,r3
0303ee1a  4c 64  cmphs r3,r1
0303ee1c  f9 0f  bf 0x0303ee0e
0303ee1e  7e e2 b7 89  bsr 0x0001018c
0303ee22  03 6d  mov r4,r0
0303ee24  7e e2 0c 8a  bsr 0x0001023c
0303ee28  5e 11  lrw r2,0x303ef20
0303ee2a  60 82  ld.b r3,(r2,0x0)
0303ee2c  00 2b  subi r3,0x1
0303ee2e  cc 74  zextb r3,r3
0303ee30  60 a2  st.b r3,(r2,0x0)
0303ee32  23 e9 16 00  bnez r3,0x0303ee5e
0303ee36  7e e2 db 91  bsr 0x000111ec
0303ee3a  7b 11  lrw r3,0x303ef24
0303ee3c  60 8b  ld.h r3,(r3,0x0)
0303ee3e  03 e9 0a 00  bez r3,0x0303ee52
0303ee42  7e e2 0f 8a  bsr 0x00010260
0303ee46  13 6c  mov r0,r4
0303ee48  7e e2 aa 89  bsr 0x0001019c
0303ee4c  7e e2 7e 91  bsr 0x00011148
0303ee50  0c 04  br 0x0303ee68
0303ee52  7e e2 07 8a  bsr 0x00010260
0303ee56  13 6c  mov r0,r4
0303ee58  7e e2 a2 89  bsr 0x0001019c
0303ee5c  06 04  br 0x0303ee68
0303ee5e  7e e2 01 8a  bsr 0x00010260
0303ee62  13 6c  mov r0,r4
0303ee64  7e e2 9c 89  bsr 0x0001019c
0303ee68  00 30  movi r0,0x0
0303ee6a  fe e3 d1 a2  bsr 0x0301340c
0303ee6e  00 30  movi r0,0x0
0303ee70  42 04  br 0x0303eef4
0303ee72  2e 11  lrw r1,0x303ef28
0303ee74  02 32  movi r2,0x2
0303ee76  41 a1  st.b r2,(r1,0x1)
0303ee78  40 a1  st.b r2,(r1,0x0)
0303ee7a  29 11  lrw r1,0x303ef1c
0303ee7c  41 dc e2 02  st.b r2,(r1,0x2e2)
0303ee80  41 dc f7 02  st.b r2,(r1,0x2f7)
0303ee84  4a 11  lrw r2,0x303ef2c
0303ee86  60 a2  st.b r3,(r2,0x0)
0303ee88  00 23  addi r3,0x1
0303ee8a  cc 74  zextb r3,r3
0303ee8c  49 11  lrw r2,0x303ef30
0303ee8e  60 a2  st.b r3,(r2,0x0)
0303ee90  08 32  movi r2,0x8
0303ee92  c8 64  cmphs r2,r3
0303ee94  03 08  bt 0x0303ee9a
0303ee96  67 11  lrw r3,0x303ef30
0303ee98  40 a3  st.b r2,(r3,0x0)
0303ee9a  64 11  lrw r3,0x303ef28
0303ee9c  03 32  movi r2,0x3
0303ee9e  42 a3  st.b r2,(r3,0x2)
0303eea0  0e 32  movi r2,0xe
0303eea2  43 a3  st.b r2,(r3,0x3)
0303eea4  7e e2 74 89  bsr 0x0001018c
0303eea8  03 6d  mov r4,r0
0303eeaa  7e e2 c9 89  bsr 0x0001023c
0303eeae  5d 10  lrw r2,0x303ef20
0303eeb0  60 82  ld.b r3,(r2,0x0)
0303eeb2  00 2b  subi r3,0x1
0303eeb4  cc 74  zextb r3,r3
0303eeb6  60 a2  st.b r3,(r2,0x0)
0303eeb8  23 e9 18 00  bnez r3,0x0303eee8
0303eebc  7e e2 98 91  bsr 0x000111ec
0303eec0  79 10  lrw r3,0x303ef24
0303eec2  60 8b  ld.h r3,(r3,0x0)
0303eec4  03 e9 0b 00  bez r3,0x0303eeda
0303eec8  7e e2 cc 89  bsr 0x00010260
0303eecc  13 6c  mov r0,r4
0303eece  7e e2 67 89  bsr 0x0001019c
0303eed2  7e e2 3b 91  bsr 0x00011148
0303eed6  01 30  movi r0,0x1
0303eed8  0e 04  br 0x0303eef4
0303eeda  7e e2 c3 89  bsr 0x00010260
0303eede  13 6c  mov r0,r4
0303eee0  7e e2 5e 89  bsr 0x0001019c
0303eee4  01 30  movi r0,0x1
0303eee6  07 04  br 0x0303eef4
0303eee8  7e e2 bc 89  bsr 0x00010260
0303eeec  13 6c  mov r0,r4
0303eeee  7e e2 57 89  bsr 0x0001019c
0303eef2  01 30  movi r0,0x1
0303eef4  93 14  pop r4,r5,r6,lr
0303ef34  6b 13  lrw r3,0x303f0e0
0303ef36  23 d8 30 00  ld.b r1,(r3,0x30)
0303ef3a  c1 c4 c1 54  zext r1,r1,0x6,0x6
0303ef3e  4a 13  lrw r2,0x303f0e4
0303ef40  63 41  lsli r3,r1 ,0x3
0303ef42  6c 5a  addu r3,r2,r3
0303ef44  03 23  addi r3,0x4
0303ef46  83 d9 00 00  ld.b r12,(r3,0x0)
0303ef4a  08 13  lrw r0,0x303f0e8
0303ef4c  80 dd 00 00  st.b r12,(r0,0x0)
0303ef50  07 13  lrw r0,0x303f0ec
0303ef52  22 d0 02 09  ldr.w r2,(r2,r1<<3)
0303ef56  40 b0  st.w r2,(r0,0x0)
0303ef58  41 83  ld.b r2,(r3,0x1)
0303ef5a  66 13  lrw r3,0x303f0f0
0303ef5c  40 a3  st.b r2,(r3,0x0)
0303ef5e  00 32  movi r2,0x0
0303ef60  65 13  lrw r3,0x303f0f4
0303ef62  41 a3  st.b r2,(r3,0x1)
0303ef64  01 32  movi r2,0x1
0303ef66  65 13  lrw r3,0x303f0f8
0303ef68  41 a3  st.b r2,(r3,0x1)
0303ef6a  34 07  br 0x0303edd2
0303ef6c  44 13  lrw r2,0x303f0fc
0303ef6e  02 33  movi r3,0x2
0303ef70  61 a2  st.b r3,(r2,0x1)
0303ef72  60 a2  st.b r3,(r2,0x0)
0303ef74  43 13  lrw r2,0x303f100
0303ef76  62 dc e2 02  st.b r3,(r2,0x2e2)
0303ef7a  62 dc f7 02  st.b r3,(r2,0x2f7)
0303ef7e  00 32  movi r2,0x0
0303ef80  61 13  lrw r3,0x303f104
0303ef82  40 a3  st.b r2,(r3,0x0)
0303ef84  01 32  movi r2,0x1
0303ef86  61 13  lrw r3,0x303f108
0303ef88  40 a3  st.b r2,(r3,0x0)
0303ef8a  88 07  br 0x0303ee9a

; 03013078 FUN_03013078
03013078  d1 14  push r4,lr
0301307a  25 14  subi sp,sp,0x14
0301307c  83 13  lrw r4,0x3013208
0301307e  01 33  movi r3,0x1
03013080  64 dc 04 04  st.b r3,(r4,0x404)
03013084  02 1b  addi r3,sp,0x8
03013086  60 b8  st.w r3,(sp,0x0)
03013088  04 1b  addi r3,sp,0x10
0301308a  61 b8  st.w r3,(sp,0x4)
0301308c  00 13  lrw r0,0x301320c
0301308e  00 31  movi r1,0x0
03013090  87 6c  mov r2,r1
03013092  6e e4 0d 00  addi r3,sp,0xe
03013096  02 e0 77 bc  bsr 0x0306a984
0301309a  00 33  movi r3,0x0
0301309c  64 dc 04 04  st.b r3,(r4,0x404)
030130a0  00 80  ld.b r0,(r0,0x0)
030130a2  7c 12  lrw r3,0x3013210
030130a4  00 a3  st.b r0,(r3,0x0)
030130a6  05 14  addi sp,sp,0x14
030130a8  91 14  pop r4,lr

; 03037674 FUN_03037674
03037674  d1 14  push r4,lr
03037676  73 12  lrw r3,0x30377c0
03037678  60 83  ld.b r3,(r3,0x0)
0303767a  48 3b  cmpnei r3,0x8
0303767c  03 0c  bf 0x03037682
0303767e  4a 3b  cmpnei r3,0xa
03037680  04 08  bt 0x03037688
03037682  ff e3 cf fe  bsr 0x03037420
03037686  27 04  br 0x030376d4
03037688  43 eb 2f 00  cmpnei r3,0x2f
0303768c  1f 08  bt 0x030376ca
0303768e  70 12  lrw r3,0x30377cc
03037690  63 83  ld.b r3,(r3,0x3)
03037692  63 e4 7f 30  andni r3,r3,0x7f
03037696  cc 74  zextb r3,r3
03037698  03 e9 08 00  bez r3,0x030376a8
0303769c  6c 12  lrw r3,0x30377cc
0303769e  43 83  ld.b r2,(r3,0x3)
030376a0  00 31  movi r1,0x0
030376a2  41 c4 07 5c  ins r2,r1,0x0,0x7
030376a6  43 a3  st.b r2,(r3,0x3)
030376a8  00 32  movi r2,0x0
030376aa  6a 12  lrw r3,0x30377d0
030376ac  40 a3  st.b r2,(r3,0x0)
030376ae  68 12  lrw r3,0x30377cc
030376b0  44 83  ld.b r2,(r3,0x4)
030376b2  00 34  movi r4,0x0
030376b4  44 c4 00 5c  ins r2,r4,0x0,0x0
030376b8  44 a3  st.b r2,(r3,0x4)
030376ba  08 30  movi r0,0x8
030376bc  ff e3 52 c7  bsr 0x03030560
030376c0  13 6c  mov r0,r4
030376c2  01 31  movi r1,0x1
030376c4  ff e3 d2 f3  bsr 0x03035e68
030376c8  06 04  br 0x030376d4
030376ca  00 32  movi r2,0x0
030376cc  62 12  lrw r3,0x30377d4
030376ce  40 a3  st.b r2,(r3,0x0)
030376d0  ff e3 70 fa  bsr 0x03036bb0
030376d4  91 14  pop r4,lr

; 03037658 FUN_03037658
03037658  d0 14  push lr
0303765a  7a 12  lrw r3,0x30377c0
0303765c  60 83  ld.b r3,(r3,0x0)
0303765e  48 3b  cmpnei r3,0x8
03037660  03 0c  bf 0x03037666
03037662  4a 3b  cmpnei r3,0xa
03037664  04 08  bt 0x0303766c
03037666  ff e3 dd fe  bsr 0x03037420
0303766a  03 04  br 0x03037670
0303766c  ff e3 a2 fa  bsr 0x03036bb0
03037670  90 14  pop lr

; 03036498 FUN_03036498
03036498  d0 14  push lr
0303649a  6c 13  lrw r3,0x3036648
0303649c  42 83  ld.b r2,(r3,0x2)
0303649e  6c 13  lrw r3,0x303664c
030364a0  62 d0 20 00  ldr.b r0,(r2,r3<<0)
030364a4  00 74  zextb r0,r0
030364a6  00 31  movi r1,0x0
030364a8  ff e3 e0 fc  bsr 0x03035e68
030364ac  90 14  pop lr

; 03036480 FUN_03036480
03036480  d0 14  push lr
03036482  72 13  lrw r3,0x3036648
03036484  42 83  ld.b r2,(r3,0x2)
03036486  72 13  lrw r3,0x303664c
03036488  62 d0 20 00  ldr.b r0,(r2,r3<<0)
0303648c  00 74  zextb r0,r0
0303648e  00 31  movi r1,0x0
03036490  ff e3 ec fc  bsr 0x03035e68
03036494  90 14  pop lr

; 03036468 FUN_03036468
03036468  d0 14  push lr
0303646a  78 13  lrw r3,0x3036648
0303646c  42 83  ld.b r2,(r3,0x2)
0303646e  78 13  lrw r3,0x303664c
03036470  62 d0 20 00  ldr.b r0,(r2,r3<<0)
03036474  00 74  zextb r0,r0
03036476  00 31  movi r1,0x0
03036478  ff e3 f8 fc  bsr 0x03035e68
0303647c  90 14  pop lr

; 03036440 FUN_03036440
03036440  d0 14  push lr
03036442  68 10  lrw r3,0x3036460
03036444  42 83  ld.b r2,(r3,0x2)
03036446  68 10  lrw r3,0x3036464
03036448  62 d0 20 00  ldr.b r0,(r2,r3<<0)
0303644c  00 74  zextb r0,r0
0303644e  00 31  movi r1,0x0
03036450  ff e3 0c fd  bsr 0x03035e68
03036454  90 14  pop lr

; 030363c4 FUN_030363c4
030363c4  d0 14  push lr
030363c6  65 11  lrw r3,0x3036458
030363c8  41 83  ld.b r2,(r3,0x1)
030363ca  65 11  lrw r3,0x303645c
030363cc  6c 5a  addu r3,r2,r3
030363ce  62 83  ld.b r3,(r3,0x2)
030363d0  23 e9 05 00  bnez r3,0x030363da
030363d4  00 e0 e2 c6  bsr 0x0304f198
030363d8  32 04  br 0x0303643c
030363da  41 3b  cmpnei r3,0x1
030363dc  04 08  bt 0x030363e4
030363de  00 e0 49 c4  bsr 0x0304ec70
030363e2  2d 04  br 0x0303643c
030363e4  42 3b  cmpnei r3,0x2
030363e6  04 08  bt 0x030363ee
030363e8  00 e0 0a c5  bsr 0x0304edfc
030363ec  28 04  br 0x0303643c
030363ee  43 3b  cmpnei r3,0x3
030363f0  04 08  bt 0x030363f8
030363f2  00 e0 0f ca  bsr 0x0304f810
030363f6  23 04  br 0x0303643c
030363f8  44 3b  cmpnei r3,0x4
030363fa  04 08  bt 0x03036402
030363fc  00 e0 a6 ca  bsr 0x0304f948
03036400  1e 04  br 0x0303643c
03036402  45 3b  cmpnei r3,0x5
03036404  04 08  bt 0x0303640c
03036406  00 e0 c5 d0  bsr 0x03050590
0303640a  19 04  br 0x0303643c
0303640c  46 3b  cmpnei r3,0x6
0303640e  04 08  bt 0x03036416
03036410  00 e0 d2 d0  bsr 0x030505b4
03036414  14 04  br 0x0303643c
03036416  47 3b  cmpnei r3,0x7
03036418  04 08  bt 0x03036420
0303641a  00 e0 d9 d0  bsr 0x030505cc
0303641e  0f 04  br 0x0303643c
03036420  48 3b  cmpnei r3,0x8
03036422  04 08  bt 0x0303642a
03036424  00 e0 7e d1  bsr 0x03050720
03036428  0a 04  br 0x0303643c
0303642a  4a 3b  cmpnei r3,0xa
0303642c  04 08  bt 0x03036434
0303642e  00 e0 bf d1  bsr 0x030507ac
03036432  05 04  br 0x0303643c
03036434  2a 30  movi r0,0x2a
03036436  01 31  movi r1,0x1
03036438  ff e3 18 fd  bsr 0x03035e68
0303643c  90 14  pop lr

; 030369f8 FUN_030369f8
030369f8  d0 14  push lr
030369fa  60 13  lrw r3,0x3036b78
030369fc  64 83  ld.b r3,(r3,0x4)
030369fe  41 3b  cmpnei r3,0x1
03036a00  0f 08  bt 0x03036a1e
03036a02  ff e3 a5 ff  bsr 0x0303694c
03036a06  00 32  movi r2,0x0
03036a08  7d 12  lrw r3,0x3036b7c
03036a0a  40 a3  st.b r2,(r3,0x0)
03036a0c  01 32  movi r2,0x1
03036a0e  7d 12  lrw r3,0x3036b80
03036a10  40 a3  st.b r2,(r3,0x0)
03036a12  7d 12  lrw r3,0x3036b84
03036a14  20 8b  ld.h r1,(r3,0x0)
03036a16  5d 12  lrw r2,0x3036b88
03036a18  20 a2  st.b r1,(r2,0x0)
03036a1a  00 32  movi r2,0x0
03036a1c  40 ab  st.h r2,(r3,0x0)
03036a1e  90 14  pop lr

; 0303cb04 FUN_0303cb04
0303cb04  d0 14  push lr
0303cb06  ff e3 79 cf  bsr 0x030369f8
0303cb0a  01 32  movi r2,0x1
0303cb0c  67 10  lrw r3,0x303cb28
0303cb0e  43 dc 0a 0a  st.b r2,(r3,0xa0a)
0303cb12  67 10  lrw r3,0x303cb2c
0303cb14  41 83  ld.b r2,(r3,0x1)
0303cb16  67 10  lrw r3,0x303cb30
0303cb18  6c 5a  addu r3,r2,r3
0303cb1a  42 83  ld.b r2,(r3,0x2)
0303cb1c  0a 3a  cmphsi r2,0xb
0303cb1e  2a 08  bt 0x0303cb72
0303cb20  65 10  lrw r3,0x303cb34
0303cb22  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303cb26  0c 78  jmp r3
0303cb72  ff e3 9d f5  bsr 0x0303b6ac
0303cb76  90 14  pop lr

; 0303cb78 FUN_0303cb78
0303cb78  d2 14  push r4,r5,lr
0303cb7a  21 14  subi sp,sp,0x4
0303cb7c  ff e3 3e cf  bsr 0x030369f8
0303cb80  7c 12  lrw r3,0x303ccf0
0303cb82  60 83  ld.b r3,(r3,0x0)
0303cb84  63 e4 02 20  andi r3,r3,0x2
0303cb88  cc 74  zextb r3,r3
0303cb8a  03 e9 d3 00  bez r3,0x0303cd30
0303cb8e  00 31  movi r1,0x0
0303cb90  20 b8  st.w r1,(sp,0x0)
0303cb92  07 6c  mov r0,r1
0303cb94  f0 32  movi r2,0xf0
0303cb96  1b 33  movi r3,0x1b
0303cb98  fe e3 28 d8  bsr 0x03017be8
0303cb9c  76 12  lrw r3,0x303ccf4
0303cb9e  42 83  ld.b r2,(r3,0x2)
0303cba0  76 12  lrw r3,0x303ccf8
0303cba2  6c 5a  addu r3,r2,r3
0303cba4  62 83  ld.b r3,(r3,0x2)
0303cba6  41 3b  cmpnei r3,0x1
0303cba8  48 08  bt 0x0303cc38
0303cbaa  95 12  lrw r4,0x303ccfc
0303cbac  b2 12  lrw r5,0x303ccf4
0303cbae  63 85  ld.b r3,(r5,0x3)
0303cbb0  6c 5c  addu r3,r4,r3
0303cbb2  83 d9 8f 00  ld.b r12,(r3,0x8f)
0303cbb6  73 12  lrw r3,0x303cd00
0303cbb8  60 93  ld.w r3,(r3,0x0)
0303cbba  02 30  movi r0,0x2
0303cbbc  01 ea ff ff  movi r1,0xffff
0303cbc0  00 32  movi r2,0x0
0303cbc2  83 d1 83 08  ldr.w r3,(r3,r12<<2)
0303cbc6  fe e3 97 df  bsr 0x03018af4
0303cbca  63 85  ld.b r3,(r5,0x3)
0303cbcc  8c 5c  addu r4,r4,r3
0303cbce  64 d8 8f 00  ld.b r3,(r4,0x8f)
0303cbd2  23 e9 0b 00  bnez r3,0x0303cbe8
0303cbd6  6c 12  lrw r3,0x303cd04
0303cbd8  43 83  ld.b r2,(r3,0x3)
0303cbda  01 31  movi r1,0x1
0303cbdc  41 c4 03 5c  ins r2,r1,0x0,0x3
0303cbe0  41 c4 04 5c  ins r2,r1,0x0,0x4
0303cbe4  43 a3  st.b r2,(r3,0x3)
0303cbe6  0b 04  br 0x0303cbfc
0303cbe8  41 3b  cmpnei r3,0x1
0303cbea  09 08  bt 0x0303cbfc
0303cbec  66 12  lrw r3,0x303cd04
0303cbee  43 83  ld.b r2,(r3,0x3)
0303cbf0  00 31  movi r1,0x0
0303cbf2  41 c4 03 5c  ins r2,r1,0x0,0x3
0303cbf6  41 c4 04 5c  ins r2,r1,0x0,0x4
0303cbfa  43 a3  st.b r2,(r3,0x3)
0303cbfc  63 12  lrw r3,0x303cd08
0303cbfe  64 83  ld.b r3,(r3,0x4)
0303cc00  41 3b  cmpnei r3,0x1
0303cc02  07 08  bt 0x0303cc10
0303cc04  5e 11  lrw r2,0x303ccfc
0303cc06  2b 30  movi r0,0x2b
0303cc08  4b 6c  mov r1,r2
0303cc0a  01 22  addi r2,0x2
0303cc0c  00 e0 46 64  bsr 0x03049498
0303cc10  7b 11  lrw r3,0x303ccfc
0303cc12  60 8b  ld.h r3,(r3,0x0)
0303cc14  03 e9 0f 00  bez r3,0x0303cc32
0303cc18  7d 11  lrw r3,0x303cd0c
0303cc1a  24 83  ld.b r1,(r3,0x4)
0303cc1c  5d 11  lrw r2,0x303cd10
0303cc1e  20 a2  st.b r1,(r2,0x0)
0303cc20  40 93  ld.w r2,(r3,0x0)
0303cc22  3d 11  lrw r1,0x303cd14
0303cc24  40 b1  st.w r2,(r1,0x0)
0303cc26  3d 11  lrw r1,0x303cd18
0303cc28  40 b1  st.w r2,(r1,0x0)
0303cc2a  45 83  ld.b r2,(r3,0x5)
0303cc2c  7c 11  lrw r3,0x303cd1c
0303cc2e  40 a3  st.b r2,(r3,0x0)
0303cc30  b8 04  br 0x0303cda0
0303cc32  ff e3 bf cf  bsr 0x03036bb0
0303cc36  b5 04  br 0x0303cda0
0303cc38  42 3b  cmpnei r3,0x2
0303cc3a  48 08  bt 0x0303ccca
0303cc3c  90 11  lrw r4,0x303ccfc
0303cc3e  ae 11  lrw r5,0x303ccf4
0303cc40  63 85  ld.b r3,(r5,0x3)
0303cc42  6c 5c  addu r3,r4,r3
0303cc44  83 d9 8f 00  ld.b r12,(r3,0x8f)
0303cc48  76 11  lrw r3,0x303cd20
0303cc4a  60 93  ld.w r3,(r3,0x0)
0303cc4c  00 30  movi r0,0x0
0303cc4e  01 ea ff ff  movi r1,0xffff
0303cc52  83 6c  mov r2,r0
0303cc54  83 d1 83 08  ldr.w r3,(r3,r12<<2)
0303cc58  fe e3 4e df  bsr 0x03018af4
0303cc5c  63 85  ld.b r3,(r5,0x3)
0303cc5e  8c 5c  addu r4,r4,r3
0303cc60  64 d8 8f 00  ld.b r3,(r4,0x8f)
0303cc64  23 e9 0b 00  bnez r3,0x0303cc7a
0303cc68  67 11  lrw r3,0x303cd04
0303cc6a  43 83  ld.b r2,(r3,0x3)
0303cc6c  01 31  movi r1,0x1
0303cc6e  41 c4 03 5c  ins r2,r1,0x0,0x3
0303cc72  41 c4 04 5c  ins r2,r1,0x0,0x4
0303cc76  43 a3  st.b r2,(r3,0x3)
0303cc78  0b 04  br 0x0303cc8e
0303cc7a  41 3b  cmpnei r3,0x1
0303cc7c  09 08  bt 0x0303cc8e
0303cc7e  62 11  lrw r3,0x303cd04
0303cc80  43 83  ld.b r2,(r3,0x3)
0303cc82  00 31  movi r1,0x0
0303cc84  41 c4 03 5c  ins r2,r1,0x0,0x3
0303cc88  41 c4 04 5c  ins r2,r1,0x0,0x4
0303cc8c  43 a3  st.b r2,(r3,0x3)
0303cc8e  7f 10  lrw r3,0x303cd08
0303cc90  64 83  ld.b r3,(r3,0x4)
0303cc92  41 3b  cmpnei r3,0x1
0303cc94  07 08  bt 0x0303cca2
0303cc96  5a 10  lrw r2,0x303ccfc
0303cc98  2d 30  movi r0,0x2d
0303cc9a  4b 6c  mov r1,r2
0303cc9c  01 22  addi r2,0x2
0303cc9e  00 e0 fd 63  bsr 0x03049498
0303cca2  77 10  lrw r3,0x303ccfc
0303cca4  60 8b  ld.h r3,(r3,0x0)
0303cca6  03 e9 0f 00  bez r3,0x0303ccc4
0303ccaa  7f 10  lrw r3,0x303cd24
0303ccac  24 83  ld.b r1,(r3,0x4)
0303ccae  59 10  lrw r2,0x303cd10
0303ccb0  20 a2  st.b r1,(r2,0x0)
0303ccb2  40 93  ld.w r2,(r3,0x0)
0303ccb4  38 10  lrw r1,0x303cd14
0303ccb6  40 b1  st.w r2,(r1,0x0)
0303ccb8  38 10  lrw r1,0x303cd18
0303ccba  40 b1  st.w r2,(r1,0x0)
0303ccbc  45 83  ld.b r2,(r3,0x5)
0303ccbe  78 10  lrw r3,0x303cd1c
0303ccc0  40 a3  st.b r2,(r3,0x0)
0303ccc2  6f 04  br 0x0303cda0
0303ccc4  ff e3 76 cf  bsr 0x03036bb0
0303ccc8  6c 04  br 0x0303cda0
0303ccca  44 3b  cmpnei r3,0x4
0303cccc  6a 08  bt 0x0303cda0
0303ccce  6a 10  lrw r3,0x303ccf4
0303ccd0  43 83  ld.b r2,(r3,0x3)
0303ccd2  76 10  lrw r3,0x303cd28
0303ccd4  6c 5a  addu r3,r2,r3
0303ccd6  83 d9 02 00  ld.b r12,(r3,0x2)
0303ccda  75 10  lrw r3,0x303cd2c
0303ccdc  60 93  ld.w r3,(r3,0x0)
0303ccde  00 30  movi r0,0x0
0303cce0  01 ea ff ff  movi r1,0xffff
0303cce4  83 6c  mov r2,r0
0303cce6  83 d1 83 08  ldr.w r3,(r3,r12<<2)
0303ccea  fe e3 05 df  bsr 0x03018af4
0303ccee  59 04  br 0x0303cda0
0303cd30  01 32  movi r2,0x1
0303cd32  68 10  lrw r3,0x303cd50
0303cd34  43 dc 0a 0a  st.b r2,(r3,0xa0a)
0303cd38  67 10  lrw r3,0x303cd54
0303cd3a  41 83  ld.b r2,(r3,0x1)
0303cd3c  67 10  lrw r3,0x303cd58
0303cd3e  6c 5a  addu r3,r2,r3
0303cd40  42 83  ld.b r2,(r3,0x2)
0303cd42  0a 3a  cmphsi r2,0xb
0303cd44  2e 08  bt 0x0303cda0
0303cd46  66 10  lrw r3,0x303cd5c
0303cd48  43 d0 83 08  ldr.w r3,(r3,r2<<2)
0303cd4c  0c 78  jmp r3
0303cda0  ff e3 86 f4  bsr 0x0303b6ac
0303cda4  01 14  addi sp,sp,0x4
0303cda6  92 14  pop r4,r5,lr
