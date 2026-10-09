
/* Address: 0303b6ac; FUN_0303b6ac */

/* WARNING: Removing unreachable block (ram,0x0303c7c4) */

void FUN_0303b6ac(void)

{
  char cVar1;
  undefined1 auStack_10 [4];
  
  if ((PTR_DAT_0303b6f4[2] == '\x01') && ((*PTR_DAT_0303b6f8 & 2) == 0)) {
    FUN_0303b374();
  }
  else {
    if (8 < (byte)*PTR_DAT_0303b6fc) {
      *PTR_DAT_0303b6fc = 8;
    }
    if ((byte)*PTR_DAT_0303b700 < 0x35) {
                    /* WARNING: Could not recover jumptable at 0x0303b6f0. Too many branches */
                    /* WARNING: Treating indirect jump as call */
      (*(code *)(*(uint *)(PTR_switchdataD_030b0d7c_0303b704 + (uint)(byte)*PTR_DAT_0303b700 * 4) &
                0xfffffffe))();
      return;
    }
    cVar1 = *PTR_DAT_0303c808;
    if (((((((cVar1 != '\b') && (cVar1 != '\x05')) && (cVar1 != '\x06')) &&
          ((cVar1 != '\x04' && (cVar1 != '\x18')))) &&
         ((cVar1 != '\x03' && ((cVar1 != '\n' && (cVar1 != '\x17')))))) && (cVar1 != '%')) &&
       ((cVar1 != '/' && ((cVar1 != '\x16' || (*PTR_DAT_0303c7d0 != '\x01')))))) {
      FUN_03039368();
    }
    FUN_0306bc6c(PTR_DAT_0303c98c,0,0,auStack_10);
  }
  return;
}



/* Address: 03048f50; FUN_03048f50 */

void FUN_03048f50(void)

{
  if ((byte)*PTR_DAT_03048f6c < 0x6d) {
                    /* WARNING: Could not recover jumptable at 0x03048f66. Too many branches */
                    /* WARNING: Treating indirect jump as call */
    (*(code *)(*(uint *)(PTR_switchdataD_030b1e38_03048f7c + (uint)(byte)*PTR_DAT_03048f6c * 4) &
              0xfffffffe))();
    return;
  }
  return;
}



/* Address: 03038500; FUN_03038500 */

void FUN_03038500(void)

{
  uint uVar1;
  
  if ((*PTR_DAT_0303855c & 2) == 0) {
    FUN_03017be8(0,0,0xf0,0x1b,0,0,0,0,0,0);
    uVar1 = (byte)PTR_DAT_03038550[3] - 7 & 0xff;
    if (uVar1 < 0x32) {
                    /* WARNING: Could not recover jumptable at 0x03038548. Too many branches */
                    /* WARNING: Treating indirect jump as call */
      (*(code *)(*(uint *)(PTR_switchdataD_030b0c8c_03038560 + uVar1 * 4) & 0xfffffffe))();
      return;
    }
    FUN_03018af4(1,0xffff,0,PTR_DAT_03038e30);
  }
  return;
}



/* Address: 03043164; FUN_03043164 */

void FUN_03043164(void)

{
  char cVar1;
  undefined1 uVar2;
  undefined *puVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *puVar6;
  uint uVar7;
  
  puVar6 = PTR_PTR_030432c0;
  puVar5 = PTR_PTR_030432bc;
  puVar4 = PTR_PTR_030432b8;
  puVar3 = PTR_PTR_030432a0;
  cVar1 = PTR_DAT_03043298[(byte)PTR_DAT_03043294[3] + 2];
  if (cVar1 == '\x01') {
    uVar7 = (byte)PTR_DAT_0304329c[0x30] >> 6 & 1;
    *PTR_DAT_030432a4 = PTR_PTR_030432b8[uVar7 * 8 + 4];
    *(undefined4 *)PTR_DAT_030432a8 = *(undefined4 *)(puVar4 + uVar7 * 8);
    *PTR_DAT_030432ac = puVar4[uVar7 * 8 + 5];
    if (*PTR_DAT_030432b0 == '\x01') {
      FUN_03049498(0x16,PTR_DAT_030432b4,PTR_DAT_030432b4 + 2);
    }
  }
  else if (cVar1 == '\0') {
    uVar7 = (byte)PTR_DAT_0304329c[0x30] >> 6 & 1;
    uVar2 = PTR_PTR_030432a0[uVar7 * 8 + 4];
    *PTR_DAT_030432a4 = uVar2;
    *(undefined4 *)PTR_DAT_030432a8 = *(undefined4 *)(puVar3 + uVar7 * 8);
    *PTR_DAT_030432ac = puVar3[uVar7 * 8 + 5];
    if (*PTR_DAT_030432b0 == '\x01') {
      FUN_0304a1e8(uVar2,PTR_DAT_030432b4,PTR_DAT_030432b4 + 2);
    }
  }
  else if (cVar1 == '\x02') {
    uVar7 = (byte)PTR_DAT_0304329c[0x30] >> 6 & 1;
    *PTR_DAT_030432a4 = PTR_PTR_030432bc[uVar7 * 8 + 4];
    *(undefined4 *)PTR_DAT_030432a8 = *(undefined4 *)(puVar5 + uVar7 * 8);
    *PTR_DAT_030432ac = puVar5[uVar7 * 8 + 5];
    if (*PTR_DAT_030432b0 == '\x01') {
      FUN_03049498(0x13,PTR_DAT_030432b4,PTR_DAT_030432b4 + 2);
    }
  }
  else if (cVar1 == '\x03') {
    uVar7 = (byte)PTR_DAT_0304329c[0x30] >> 6 & 1;
    *PTR_DAT_030432a4 = PTR_PTR_030432c0[uVar7 * 8 + 4];
    *(undefined4 *)PTR_DAT_030432a8 = *(undefined4 *)(puVar6 + uVar7 * 8);
    *PTR_DAT_030432ac = puVar6[uVar7 * 8 + 5];
    if (*PTR_DAT_030432b0 == '\x01') {
      FUN_03049498(0x15,PTR_DAT_030432b4,PTR_DAT_030432b4 + 2);
    }
  }
  return;
}


