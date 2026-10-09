
/* Address: 0301ec40; FUN_0301ec40 */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void FUN_0301ec40(byte param_1)

{
  PTR_DAT_0301ecb4[0x18] = PTR_DAT_0301ecb4[0x18] & 0xf7 | (param_1 & 1) << 3;
  _DAT_11000384 = _DAT_11000384 & 0xfffffcff;
  if ((param_1 & 1) == 0) {
    PTR_DAT_0301ecbc[7] = 0;
  }
  else {
    PTR_DAT_0301ecbc[7] = 8;
    _DAT_11000384 = _DAT_11000384 | 0x100;
  }
  return;
}



/* Address: 0305ccf0; FUN_0305ccf0 */

void FUN_0305ccf0(char param_1)

{
  if (param_1 == '\0') {
    FUN_0301ec40(0);
    PTR_DAT_0305cdb8[0xd] = PTR_DAT_0305cdb8[0xd] & 0xfd;
  }
  else {
    FUN_0301ec40(1);
    PTR_DAT_0305cdb8[0xd] = PTR_DAT_0305cdb8[0xd] & 0xfd | 2;
  }
  return;
}



/* Address: 03028644; FUN_03028644 */

void FUN_03028644(void)

{
  char cVar1;
  byte bVar2;
  char *pcVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *puVar6;
  uint uVar7;
  uint uVar8;
  int iVar9;
  uint uVar10;
  uint uVar11;
  undefined1 uVar12;
  uint uVar13;
  uint uVar14;
  uint uVar15;
  uint in_r13;
  
  puVar5 = PTR_DAT_03028844;
  puVar4 = PTR_DAT_030286ec;
  uVar10 = *(uint *)PTR_DAT_030286f0;
  uVar8 = uVar10 & 3;
  uVar7 = (uVar10 & 0xfff) >> 8;
  uVar11 = (uVar10 & 0x7fff) >> 0xc;
  uVar13 = (uVar10 & 0xff) >> 4;
  uVar14 = uVar10 >> 0x13 & 1;
  uVar15 = (uVar10 & 0xf) >> 2;
  if ((PTR_DAT_030286f4[7] & 8) != 0) {
    *(undefined2 *)(PTR_DAT_030286ec + 0x10) = 0;
    return;
  }
  if ((PTR_DAT_030286f8[0x19] & 0x11) != 0) {
    return;
  }
  cVar1 = PTR_DAT_030286fc[1];
  if (cVar1 == '\0') {
    if (uVar15 == 0) {
      if (PTR_DAT_030286e8[(*PTR_DAT_030286ec == '\0') + 0xc] == '\x01') {
        return;
      }
      cVar1 = PTR_DAT_030286e8[(*PTR_DAT_030286ec == '\0') + 0xe];
joined_r0x030287e8:
      if (cVar1 == '\x01') {
        return;
      }
    }
    else if (uVar15 == 1) {
      if (PTR_DAT_030286ec[7] == '\0') {
        if (((uVar8 - 1 & 0xff) < 2) && (in_r13 = uVar10 >> 0x18, in_r13 == 0)) {
          *(undefined2 *)(PTR_DAT_030286ec + 0x10) = 0;
          puVar4[7] = 1;
          return;
        }
      }
      else {
        if (PTR_DAT_03028844[9] == '\0') {
          return;
        }
        if (*PTR_DAT_03028844 != PTR_DAT_03028848[4]) {
          return;
        }
      }
    }
  }
  else if (cVar1 == '\x04') {
    if ((uVar8 - 1 & 0xff) < 2) {
      if (uVar15 == 2) {
        *PTR_DAT_03028844 = 0;
      }
      else if (uVar15 == 3) {
        *PTR_DAT_03028844 = 1;
      }
      puVar4 = PTR_DAT_03028844;
      *(undefined2 *)(PTR_DAT_03028844 + 0x10) = 0;
      puVar4[0xc] = 1;
    }
    if ((*PTR_DAT_03028844 != PTR_DAT_03028844[2]) && (uVar8 == 2)) {
      if (uVar7 != 3) {
        return;
      }
      if (uVar13 != 0xf) {
        return;
      }
    }
  }
  else if (cVar1 == '\x01') {
    if (uVar15 == 1) {
      if (PTR_DAT_03028844[7] == '\0') {
        if (uVar8 == 2) {
          if (uVar7 == 9) {
            *(undefined2 *)(PTR_DAT_03028844 + 0x10) = 0;
            puVar5[7] = 1;
            FUN_0300c724(0x10000000);
            return;
          }
        }
        else if (1 < (uVar8 - 1 & 0xff)) goto LAB_03028880;
        in_r13 = uVar10 >> 0x18;
        if (in_r13 == 0) {
          *(undefined2 *)(PTR_DAT_03028844 + 0x10) = 0;
          puVar5[7] = 1;
          return;
        }
      }
      else {
        if (PTR_DAT_03028844[9] == '\0') {
          return;
        }
        if (*PTR_DAT_03028844 != PTR_DAT_03028848[4]) {
          return;
        }
      }
    }
    else if (uVar15 == 0) {
      if (PTR_DAT_0302884c[(*PTR_DAT_03028844 == '\0') + 0xc] == '\x01') {
        return;
      }
      cVar1 = PTR_DAT_0302884c[(*PTR_DAT_03028844 == '\0') + 0xe];
      goto joined_r0x030287e8;
    }
  }
  else if (cVar1 == '\x02') {
    if (PTR_DAT_03028844[7] == '\0') {
      if (uVar8 != 2) {
        return;
      }
      if (uVar7 == 3) {
        *(undefined4 *)(PTR_DAT_03028850 + 0x78) = 0;
        FUN_030280c0();
        return;
      }
      in_r13 = uVar10 >> 0x18;
      if ((uVar15 == 1) && (in_r13 == 0)) {
        *(undefined4 *)(PTR_DAT_03028850 + 0x78) = 0;
        PTR_DAT_03028844[7] = 1;
        return;
      }
    }
    else {
      if (PTR_DAT_03028844[9] == '\0') {
        if (uVar8 != 2) {
          return;
        }
        if (uVar7 != 3) {
          return;
        }
        *(undefined4 *)(PTR_DAT_03028850 + 0x78) = 0;
        FUN_030280c0();
        return;
      }
      if (PTR_DAT_03028a10[0x72] != '\x01') {
        if (uVar8 != 2) {
          return;
        }
        if (uVar7 != 3) {
          return;
        }
        *(undefined4 *)(PTR_DAT_03028a10 + 0x78) = 0;
        FUN_030280c0();
        return;
      }
      if (PTR_DAT_03028a14[4] != *PTR_DAT_03028a18) {
        return;
      }
    }
  }
LAB_03028880:
  if (uVar11 != 0) {
    *PTR_DAT_03028a1c = (char)uVar11 + -1;
  }
  puVar5 = PTR_DAT_03028b8c;
  puVar4 = PTR_DAT_03028b80;
  uVar12 = (undefined1)uVar13;
  if (uVar8 != 0) {
    if (uVar8 == 1) {
      *(undefined2 *)(PTR_DAT_03028b80 + 0x10) = 0;
      *(undefined4 *)(PTR_DAT_03028b88 + 0x78) = 0;
      puVar5 = PTR_DAT_03028b8c;
      bVar2 = *puVar4;
      PTR_DAT_03028b8c[bVar2 + 0x12] = 0;
      puVar4[3] = 1;
      puVar5[2] = (char)uVar15;
      if (puVar5[bVar2 + 0xc] == '\0') {
        return;
      }
      if (PTR_DAT_03028b90[1] == '\x04') {
        if (uVar14 == 0) {
          FUN_0300d41c(0x36,PTR_DAT_03028b8c + (uint)(byte)PTR_DAT_03028b8c[0xbe] * 0x1b + 0x88,0x1b
                      );
        }
        else {
          FUN_0300d41c(0x66,puVar5 + (uint)(byte)puVar5[0xbe] * 0x1b + 0x88,0x1b);
        }
      }
      else if (uVar14 == 0) {
        FUN_0300d41c(0x39,PTR_DAT_03028b8c + (uint)(byte)PTR_DAT_03028b8c[0xbe] * 0x1b + 0x88,0x1b);
      }
      else {
        FUN_0300d41c(0x69,PTR_DAT_03028b8c + (uint)(byte)PTR_DAT_03028b8c[0xbe] * 0x1b + 0x88,0x1b);
      }
      puVar6 = PTR_DAT_03028ba0;
      puVar5 = PTR_DAT_03028b9c;
      puVar4 = PTR_DAT_03028b98;
      if (PTR_DAT_03028b94[2] != '\0') {
        FUN_0002b300(PTR_DAT_03028b9c,PTR_DAT_03028b98 + (uint)(byte)PTR_DAT_03028b98[0x36] * 0x1b,
                     *PTR_DAT_03028ba0);
        FUN_0002b30c(puVar5 + -0x80,puVar4 + (uint)(byte)puVar4[0x36] * 0x1b,*puVar6);
      }
      puVar4 = PTR_DAT_03028b8c;
      pcVar3 = PTR_DAT_03028b8c + 0xbe;
      PTR_DAT_03028b8c[0xbf] = *pcVar3;
      puVar4[0xbe] = *pcVar3 == '\0';
      return;
    }
    if (uVar8 == 2) {
      PTR_DAT_03028b8c[2] = (char)uVar15;
      puVar5[6] = uVar12;
      if (((byte)PTR_DAT_03028b90[5] != uVar13) && ((PTR_DAT_03028ba4[0x18] & 8) == 0)) {
        return;
      }
      *(undefined4 *)(PTR_DAT_03028b88 + 0x78) = 0;
      if (10 < uVar7) {
        return;
      }
                    /* WARNING: Could not recover jumptable at 0x03028b7c. Too many branches */
                    /* WARNING: Treating indirect jump as call */
      (*(code *)(*(uint *)(PTR_switchdataD_030b0548_03028ba8 + uVar7 * 4) & 0xfffffffe))();
      return;
    }
    if (uVar8 != 3) {
      return;
    }
    if (in_r13 != 0) {
      return;
    }
    PTR_DAT_03028d48[6] = uVar12;
    return;
  }
  if ((uVar11 == 4) && ((byte)(PTR_DAT_03028a14[1] - 1) < 2)) {
    iVar9 = (uint)(byte)*PTR_DAT_03028a18 * 0xc;
    if (PTR_DAT_03028a20[iVar9] != '\0') {
      if (((PTR_DAT_03028a24[(byte)*PTR_DAT_03028a18 + 2] & 0x30) == 0x30) &&
         (iVar9 = FUN_03029c78(PTR_DAT_03028a20 + iVar9), iVar9 == 0)) {
        PTR_DAT_03028a20[(uint)(byte)*PTR_DAT_03028a18 * 0xc] = 0;
      }
      goto LAB_030288e8;
    }
  }
  if (uVar11 == 5) {
    PTR_DAT_03028a28[5] = (byte)(uVar10 >> 0x11) & 1;
  }
LAB_030288e8:
  if (PTR_DAT_03028a2c[(byte)*PTR_DAT_03028a18] != '\0') {
    *(undefined2 *)(PTR_DAT_03028a18 + 0x10) = 0;
    PTR_DAT_03028a28[6] = uVar12;
    if (PTR_DAT_03028a14[1] == '\x04') {
      if (uVar14 == 0) {
        FUN_0300d41c(0x36,PTR_DAT_03028a28 + (uint)(byte)PTR_DAT_03028a28[0xbe] * 0x1b + 0x88,0x1b);
      }
      else {
        FUN_0300d41c(0x66,PTR_DAT_03028a28 + (uint)(byte)PTR_DAT_03028a28[0xbe] * 0x1b + 0x88,0x1b);
      }
    }
    else if (uVar14 == 0) {
      FUN_0300d41c(0x39,PTR_DAT_03028a28 + (uint)(byte)PTR_DAT_03028a28[0xbe] * 0x1b + 0x88,0x1b);
    }
    else {
      FUN_0300d41c(0x69,PTR_DAT_03028a28 + (uint)(byte)PTR_DAT_03028a28[0xbe] * 0x1b + 0x88,0x1b);
    }
    puVar6 = PTR_DAT_03028a38;
    puVar5 = PTR_DAT_03028a34;
    puVar4 = PTR_DAT_03028a1c;
    if (PTR_DAT_03028a30[2] != '\0') {
      FUN_0002b300(PTR_DAT_03028a38,PTR_DAT_03028a34 + (uint)(byte)PTR_DAT_03028a34[0x36] * 0x1b,
                   *PTR_DAT_03028a1c);
      FUN_0002b30c(puVar6 + -0x80,puVar5 + (uint)(byte)puVar5[0x36] * 0x1b,*puVar4);
    }
    puVar4 = PTR_DAT_03028a28;
    pcVar3 = PTR_DAT_03028a28 + 0xbe;
    PTR_DAT_03028a28[0xbf] = *pcVar3;
    puVar4[0xbe] = *pcVar3 == '\0';
    if (uVar11 == 6) {
      FUN_03027628();
    }
    if ((byte)PTR_DAT_03028a14[5] == uVar13) {
      PTR_DAT_03028b84[(byte)*PTR_DAT_03028b80 + 2] = 0;
    }
    else {
      uVar7 = (uint)(byte)*PTR_DAT_03028a18;
      cVar1 = PTR_DAT_03028a3c[uVar7 + 2];
      PTR_DAT_03028a3c[uVar7 + 2] = cVar1 + 1U;
      if (6 < (byte)(cVar1 + 1U)) {
        PTR_DAT_03028a2c[uVar7] = 0;
        FUN_0300c724(4);
      }
    }
  }
  return;
}



/* Address: 03028be4; FUN_03028be4 */

void FUN_03028be4(void)

{
  char cVar1;
  byte bVar2;
  undefined1 uVar3;
  undefined *puVar4;
  undefined *puVar5;
  undefined *puVar6;
  int iVar7;
  undefined1 *puVar8;
  byte bVar9;
  byte bVar10;
  uint uVar11;
  uint uVar12;
  uint uVar13;
  undefined4 local_20;
  undefined1 auStack_1c [4];
  
  if ((PTR_DAT_03028d4c[0x19] & 0x11) != 0) {
    return;
  }
  uVar12 = *(uint *)PTR_DAT_03028d50;
  uVar13 = (uVar12 & 0xf) >> 2;
  cVar1 = PTR_DAT_03028d54[1];
  if (cVar1 == '\0') {
    if (uVar13 == 0) {
      cVar1 = PTR_DAT_03028d48[(*PTR_DAT_03028d58 == '\0') + 0xc];
joined_r0x03028c98:
      if (cVar1 == '\x01') {
        return;
      }
    }
    else if (uVar13 == 1) {
      if (PTR_DAT_03028d58[7] == '\0') {
        return;
      }
      if (PTR_DAT_03028d58[9] == '\0') {
        return;
      }
      if (*PTR_DAT_03028d58 != PTR_DAT_03028d54[4]) {
        return;
      }
    }
  }
  else if (cVar1 == '\x04') {
    if (PTR_DAT_03028d58[0xc] == '\0') {
      return;
    }
    if (*PTR_DAT_03028d58 != PTR_DAT_03028d58[2]) {
      return;
    }
  }
  else if (cVar1 == '\x01') {
    if (uVar13 == 1) {
      if (PTR_DAT_03028d58[7] == '\0') {
        return;
      }
      if (PTR_DAT_03028d58[9] == '\0') {
        return;
      }
      if (*PTR_DAT_03028d58 != PTR_DAT_03028d54[4]) {
        return;
      }
    }
    else if (uVar13 == 0) {
      cVar1 = PTR_DAT_03028d48[(*PTR_DAT_03028d58 == '\0') + 0xc];
      goto joined_r0x03028c98;
    }
  }
  else if (cVar1 == '\x02') {
    if (PTR_DAT_03028d5c[0x72] == '\0') {
      return;
    }
    if (PTR_DAT_03028d58[7] == '\0') {
      return;
    }
    if (PTR_DAT_03028d58[9] == '\0') {
      return;
    }
    if (*PTR_DAT_03028d58 != PTR_DAT_03028d54[4]) {
      return;
    }
  }
  PTR_DAT_03028d58[3] = 1;
  uVar11 = (uVar12 & 0xff) >> 4;
  PTR_DAT_03028d48[6] = (char)uVar11;
  if ((uVar12 >> 0x19 & 1) != 0) {
    return;
  }
  if (((byte)PTR_DAT_03028d54[5] != uVar11) && ((PTR_DAT_03028d4c[0x18] & 8) == 0)) {
    return;
  }
  uVar12 = uVar12 >> 0x11 & 1;
  PTR_DAT_03028d48[5] = (char)uVar12;
  puVar4 = PTR_DAT_03028ef8;
  if (uVar12 == 1) {
    bVar2 = *PTR_DAT_03028d58;
    if (PTR_DAT_03028d60[bVar2] == '\0') {
      return;
    }
    *(undefined2 *)(PTR_DAT_03028d58 + 0x10) = 0;
    if ((PTR_DAT_03028d64[0x10] & 2) != 0) {
      return;
    }
    FUN_0300d41c(0,PTR_DAT_03028d68 + (uint)bVar2 * 0xc,9);
    FUN_0300c724(0x4000);
    return;
  }
  PTR_DAT_03028ef8[5] = 0;
  puVar5 = PTR_DAT_03028efc;
  FUN_0300d41c(0,puVar4 + (uint)(byte)*PTR_DAT_03028efc * 0xc + 0x28,9);
  cVar1 = puVar4[(uint)(byte)*puVar5 * 0xc + 0x29];
  bVar2 = puVar4[(uint)(byte)*puVar5 * 0xc + 0x28];
  uVar12 = bVar2 & 0x3f;
  if ((bVar2 & 4) != 0) {
    uVar11 = bVar2 & 7;
    if (uVar11 == 4) {
      if ((PTR_DAT_03028f00[3] & 1) == 0) {
        PTR_DAT_03028f00[3] = PTR_DAT_03028f00[3] & 0xfe | 1;
      }
      else {
        PTR_DAT_03028f00[3] = PTR_DAT_03028f00[3] & 0xfc | 2;
        FUN_0300c724(0x40000000);
      }
    }
    puVar6 = PTR_DAT_03028f00;
    puVar5 = PTR_DAT_03028ef8;
    if ((PTR_DAT_03028f00[3] & 1) != 0) {
      if (uVar11 == 4) {
        bVar10 = *PTR_DAT_03028efc;
        bVar9 = PTR_DAT_03028ef8[(uint)bVar10 * 0xc + 0x2a];
        PTR_DAT_03028f00[3] = PTR_DAT_03028f00[3] & 0x87 | (bVar9 >> 6) << 3;
        puVar6[4] = (char)((bVar9 & 0x3f) >> 1);
        FUN_0002b338(puVar6 + 5,puVar5 + (uint)bVar10 * 0xc + 0x2a,7);
      }
      else {
        FUN_0002b338(PTR_DAT_03028f04 + uVar11 * 7,
                     PTR_DAT_03028f08 + (uint)(byte)*PTR_DAT_03028efc * 0xc,7);
        if (uVar11 == 7) {
          FUN_0300c724(0x40000000);
        }
      }
    }
  }
  if ((cVar1 != '\0') || ((PTR_DAT_03028f00[3] & 3) != 0)) {
    if (cVar1 != '\x10') {
      return;
    }
    if ((PTR_DAT_03029098[3] & 1) != 0) {
      return;
    }
    *(undefined2 *)(PTR_DAT_03029094 + 0x10) = 0;
    if (PTR_DAT_0302909c[1] == '\x02') {
      *(undefined4 *)(PTR_DAT_030290a0 + 0x78) = 0;
      iVar7 = FUN_0302768c(1,puVar4 + (uint)(byte)*PTR_DAT_03029094 * 0xc + 0x28,auStack_1c,
                           &local_20);
      if (iVar7 == 0) {
        bVar10 = *PTR_DAT_03029094;
        bVar9 = PTR_DAT_03029090[(uint)bVar10 * 0xc + 0x2a];
        PTR_DAT_03029090[0xb] = bVar9;
        bVar9 = bVar9 & 0x30;
        if ((bVar9 == 0x20) || (bVar9 == 0x30)) {
          PTR_DAT_03029090[9] = 1;
          *(undefined4 *)(PTR_DAT_030290a4 + (uint)bVar10 * 0xc) = local_20;
        }
        else {
          PTR_DAT_03029090[9] = 0;
        }
        puVar4 = PTR_DAT_03029090;
        uVar13 = (uint)(byte)*PTR_DAT_03029094;
        puVar8 = PTR_DAT_03029090 + uVar13 + 0x10;
        PTR_DAT_03029090[uVar13 + 0x12] = 0;
        *puVar8 = 0;
        iVar7 = (uint)(byte)puVar4[uVar13 * 0xc + 0x2f] * 0x100 +
                (uint)(byte)puVar4[uVar13 * 0xc + 0x2e] * 0x10000 +
                (uint)(byte)puVar4[uVar13 * 0xc + 0x30];
        if ((puVar4[uVar13 + 0xc] != '\x01') ||
           (*(int *)(PTR_DAT_03029090 + (uVar13 + 8) * 4) != iVar7)) {
          PTR_DAT_030290a8[uVar13] = 1;
          if ((bVar2 & 0x3f) == 0) {
            PTR_DAT_03029090[8] = 1;
          }
          else if (uVar12 == 3) {
            PTR_DAT_03029090[8] = 0;
          }
          puVar4 = PTR_DAT_03029090;
          uVar12 = (uint)(byte)*PTR_DAT_03029094;
          *(uint *)(PTR_DAT_03029090 + (uVar12 + 6) * 4) =
               (uint)(byte)PTR_DAT_03029090[uVar12 * 0xc + 0x2d] +
               (uint)(byte)PTR_DAT_03029090[uVar12 * 0xc + 0x2c] * 0x100 +
               (uint)(byte)PTR_DAT_03029090[uVar12 * 0xc + 0x2b] * 0x10000;
          *(int *)(puVar4 + (uVar12 + 8) * 4) = iVar7;
          FUN_0300c724(2);
        }
      }
      else {
        if (PTR_DAT_03029220[0x15] == '\0') {
          PTR_DAT_03029224[0x74] = 1;
        }
        if (PTR_DAT_03029224[0x75] != '\0') {
          bVar2 = *PTR_DAT_03029228;
          bVar10 = PTR_DAT_0302922c[(uint)bVar2 * 0xc + 0x2a];
          PTR_DAT_0302922c[0xb] = bVar10;
          bVar10 = bVar10 & 0x30;
          if ((bVar10 == 0x20) || (bVar10 == 0x30)) {
            PTR_DAT_0302922c[9] = 1;
            *(undefined4 *)(PTR_DAT_03029230 + (uint)bVar2 * 0xc) = local_20;
          }
          else {
            PTR_DAT_0302922c[9] = 0;
          }
        }
      }
      puVar4 = PTR_DAT_0302922c;
      uVar12 = (uint)(byte)*PTR_DAT_03029228;
      uVar3 = PTR_DAT_0302922c[uVar12 * 0xc + 0x2a];
      PTR_DAT_0302922c[uVar12 + 0x14] = uVar3;
      puVar4[uVar12 + 0x16] = uVar3;
      return;
    }
    iVar7 = FUN_0302768c(1,puVar4 + (uint)(byte)*PTR_DAT_03029228 * 0xc + 0x28,auStack_1c,&local_20)
    ;
    puVar4 = PTR_DAT_0302922c;
    if (iVar7 == 0) {
      PTR_DAT_0302922c[10] = 0;
      bVar10 = *PTR_DAT_03029228;
      bVar9 = puVar4[(uint)bVar10 * 0xc + 0x2a];
      puVar4[0xb] = bVar9;
      bVar9 = bVar9 & 0x30;
      if ((bVar9 == 0x20) || (bVar9 == 0x30)) {
        PTR_DAT_0302922c[9] = 1;
        *(undefined4 *)(PTR_DAT_03029230 + (uint)bVar10 * 0xc) = local_20;
      }
      else {
        PTR_DAT_0302922c[9] = 0;
      }
      puVar4 = PTR_DAT_03029228;
      if (uVar13 == 0) {
        uVar3 = *PTR_DAT_03029228;
        PTR_DAT_03029228[2] = uVar3;
        puVar4[4] = uVar3;
      }
      puVar4 = PTR_DAT_0302922c;
      uVar13 = (uint)(byte)*PTR_DAT_03029228;
      puVar8 = PTR_DAT_0302922c + uVar13 + 0x10;
      PTR_DAT_0302922c[uVar13 + 0x12] = 0;
      *puVar8 = 0;
      iVar7 = (uint)(byte)puVar4[uVar13 * 0xc + 0x2f] * 0x100 +
              (uint)(byte)puVar4[uVar13 * 0xc + 0x2e] * 0x10000 +
              (uint)(byte)puVar4[uVar13 * 0xc + 0x30];
      if ((puVar4[uVar13 + 0xc] != '\x01') ||
         (*(int *)(PTR_DAT_0302922c + (uVar13 + 8) * 4) != iVar7)) {
        PTR_DAT_03029234[uVar13] = 1;
        if ((bVar2 & 0x3f) == 0) {
          PTR_DAT_0302922c[8] = 1;
        }
        else if (uVar12 == 3) {
          PTR_DAT_0302922c[8] = 0;
        }
        puVar4 = PTR_DAT_0302922c;
        uVar12 = (uint)(byte)*PTR_DAT_03029228;
        *(uint *)(PTR_DAT_0302922c + (uVar12 + 6) * 4) =
             (uint)(byte)PTR_DAT_0302922c[uVar12 * 0xc + 0x2d] +
             (uint)(byte)PTR_DAT_0302922c[uVar12 * 0xc + 0x2c] * 0x100 +
             (uint)(byte)PTR_DAT_0302922c[uVar12 * 0xc + 0x2b] * 0x10000;
        *(int *)(puVar4 + (uVar12 + 8) * 4) = iVar7;
        FUN_0300c724(2);
      }
    }
    else {
      bVar2 = *PTR_DAT_03029368;
      bVar10 = PTR_DAT_0302936c[(uint)bVar2 * 0xc + 0x2a];
      PTR_DAT_0302936c[0xb] = bVar10;
      bVar10 = bVar10 & 0x30;
      if ((bVar10 == 0x20) || (bVar10 == 0x30)) {
        PTR_DAT_0302936c[9] = 1;
        *(undefined4 *)(PTR_DAT_03029370 + (uint)bVar2 * 0xc) = local_20;
        puVar4 = PTR_DAT_03029368;
        if (uVar13 == 0) {
          PTR_DAT_03029368[2] = bVar2;
          puVar4[4] = bVar2;
        }
      }
      else {
        PTR_DAT_0302936c[9] = 0;
      }
    }
    puVar4 = PTR_DAT_0302936c;
    uVar12 = (uint)(byte)*PTR_DAT_03029368;
    if (PTR_DAT_03029374[uVar12 * 0xc] != '\0') {
      bVar2 = PTR_DAT_0302936c[uVar12 * 0xc + 0x2a];
      PTR_DAT_0302936c[uVar12 + 0x14] = bVar2;
      if ((bVar2 & 0x30) == 0x20) {
        if ((((PTR_DAT_03029378[1] == '\0') || (PTR_DAT_03029378[1] == '\x04')) &&
            ((PTR_DAT_0302937c[uVar12 + 2] & 0x30) == 0x30)) &&
           (iVar7 = FUN_03029c78(PTR_DAT_03029374 + uVar12 * 0xc), iVar7 == 0)) {
          PTR_DAT_03029374[(uint)(byte)*PTR_DAT_03029368 * 0xc] = 0;
        }
        (PTR_DAT_0302937c + (byte)*PTR_DAT_03029368)[2] = PTR_DAT_0302937c[(byte)*PTR_DAT_03029368];
        return;
      }
      PTR_DAT_0302937c[uVar12 + 2] = bVar2;
      return;
    }
    uVar3 = PTR_DAT_0302936c[uVar12 * 0xc + 0x2a];
    PTR_DAT_0302936c[uVar12 + 0x14] = uVar3;
    puVar4[uVar12 + 0x16] = uVar3;
    return;
  }
  if (*PTR_DAT_03028f0c != '\0') {
    return;
  }
  iVar7 = FUN_0302768c(1,puVar4 + (uint)(byte)*PTR_DAT_03028efc * 0xc + 0x28,auStack_1c,&local_20);
  puVar4 = PTR_DAT_03028efc;
  if (iVar7 != 0) {
    return;
  }
  *(undefined2 *)(PTR_DAT_03028efc + 0x10) = 0;
  bVar10 = *puVar4;
  uVar11 = (uint)bVar10;
  PTR_DAT_03028ef8[0xb] = PTR_DAT_03028ef8[uVar11 * 0xc + 0x2a];
  if (uVar13 == 0) {
    PTR_DAT_03028efc[2] = bVar10;
  }
  puVar4 = PTR_DAT_03028ef8;
  PTR_DAT_03028ef8[9] = 0;
  puVar4[uVar11 + 0x12] = 0;
  puVar4[uVar11 + 0x10] = 0;
  iVar7 = (uint)(byte)puVar4[uVar11 * 0xc + 0x2f] * 0x100 +
          (uint)(byte)puVar4[uVar11 * 0xc + 0x2e] * 0x10000 +
          (uint)(byte)puVar4[uVar11 * 0xc + 0x30];
  if ((puVar4[uVar11 + 0xc] == '\x01') && (*(int *)(PTR_DAT_03028ef8 + (uVar11 + 8) * 4) == iVar7))
  {
    return;
  }
  PTR_DAT_03028f10[uVar11] = 1;
  if ((bVar2 & 0x3f) == 0) {
    PTR_DAT_03028ef8[8] = 1;
  }
  else {
    if (uVar12 == 3) {
      PTR_DAT_03029090[8] = 0;
    }
    else if (PTR_DAT_03029090[8] != '\0') goto LAB_03028f40;
    if ((((byte)PTR_DAT_03029090[0xb] & 0x3f) >> 4 & 2) != 0) {
      PTR_DAT_03029090[10] = 1;
      goto LAB_03028f46;
    }
  }
LAB_03028f40:
  PTR_DAT_03029090[10] = 0;
LAB_03028f46:
  puVar4 = PTR_DAT_03029090;
  uVar12 = (uint)(byte)*PTR_DAT_03029094;
  *(uint *)(PTR_DAT_03029090 + (uVar12 + 6) * 4) =
       (uint)(byte)PTR_DAT_03029090[uVar12 * 0xc + 0x2d] +
       (uint)(byte)PTR_DAT_03029090[uVar12 * 0xc + 0x2c] * 0x100 +
       (uint)(byte)PTR_DAT_03029090[uVar12 * 0xc + 0x2b] * 0x10000;
  *(int *)(puVar4 + (uVar12 + 8) * 4) = iVar7;
  FUN_0300c724(2);
  return;
}



/* Address: 0302e1a4; FUN_0302e1a4 */

void FUN_0302e1a4(ushort param_1)

{
  short sVar1;
  short sVar2;
  short sVar3;
  byte bVar4;
  short sVar5;
  char cVar6;
  undefined *puVar7;
  undefined *puVar8;
  undefined *puVar9;
  undefined *puVar10;
  undefined2 uVar11;
  undefined4 uVar12;
  short *psVar13;
  uint uVar14;
  short *psVar15;
  uint uVar16;
  uint uVar17;
  short local_68;
  undefined1 local_66 [2];
  short local_64 [16];
  short local_44 [16];
  byte local_23;
  ushort local_22;
  
  puVar7 = PTR_DAT_0302e368;
  PTR_DAT_0302e368[0x5c] = 0;
  if ((param_1 & 0xff) == 0) {
    puVar7[1] = 0;
  }
  else {
    uVar12 = FUN_0300f594(0x11);
    puVar7 = PTR_DAT_0302e374;
    sVar1 = ((param_1 & 0xff) - 1) * 0x39;
    FUN_0300f71c(uVar12,sVar1 + 0xc,PTR_DAT_0302e374,4);
    puVar8 = PTR_DAT_0302e378;
    if ((byte)(*puVar7 - 2) < 0xf) {
      FUN_0300f71c(uVar12,sVar1 + 0x10,PTR_DAT_0302e378,7);
      FUN_0300f71c(uVar12,sVar1 + 0x19,puVar8 + 0x10,(uint)(byte)puVar8[-5] << 1);
      *(undefined2 *)(puVar8 + 0x10) = *(undefined2 *)(puVar8 + 0x4e);
      if (2 < (byte)puVar8[-4] >> 4) {
        PTR_DAT_0302e368[2] = PTR_DAT_0302e368[2] & 0xf;
      }
      puVar7 = PTR_DAT_0302e37c;
      FUN_0300f71c(uVar12,sVar1 + 1,PTR_DAT_0302e37c,0xb);
      puVar7[0xb] = 0;
      puVar7[0xc] = 0;
      if ((4000 < *(ushort *)(puVar7 + -0x2e)) && ((PTR_DAT_0302e368[4] & 0xf) == 2)) {
        PTR_DAT_0302e368[4] = 0;
      }
      local_44[0] = 0;
      if ((PTR_DAT_0302e368[4] & 0xf) == 1) {
        local_44[0] = *(short *)(PTR_DAT_0302e368 + 0x16);
      }
      else if ((PTR_DAT_0302e368[4] & 0xf) == 2) {
        local_44[0] = *(short *)(PTR_DAT_0302e368 + 8);
      }
      if ((PTR_DAT_0302e368[4] & 0xf) != 0) {
        PTR_DAT_0302e368[0x5c] = PTR_DAT_0302e368[0x5c] + '\x01';
      }
      puVar7 = PTR_DAT_0302e368;
      *(short *)(PTR_DAT_0302e368 + 8) = local_44[0];
      if ((puVar7[4] & 0xf0) == 0x10) {
        local_44[0] = *(short *)(PTR_DAT_0302e368 + 0x16);
      }
      else if ((puVar7[4] & 0xf0) == 0x20) {
        local_44[0] = *(short *)(PTR_DAT_0302e368 + 10);
      }
      if ((byte)PTR_DAT_0302e368[4] >> 4 != 0) {
        PTR_DAT_0302e368[0x5c] = PTR_DAT_0302e368[0x5c] + '\x01';
      }
      puVar7 = PTR_DAT_0302e368;
      *(short *)(PTR_DAT_0302e368 + 10) = local_44[0];
      puVar10 = PTR_DAT_0302e514;
      puVar9 = PTR_DAT_0302e510;
      puVar8 = PTR_DAT_0302e368;
      if ((puVar7[2] & 0xf0) == 0x20) {
        FUN_03055d3c(*(undefined2 *)(PTR_DAT_0302e368 + 6),local_66,&local_68);
        FUN_0300f780(local_66[0],local_68,puVar8 + 0x42,0xb);
        FUN_03055ccc(*(undefined2 *)(puVar8 + 6),local_66,&local_68);
        FUN_0300f780(local_66[0],local_68 + 8,&local_23,1);
        puVar8[0x10] = puVar8[0x10] & 0xe1 | local_23 & 6 | (local_23 >> 6) << 3;
        *(undefined2 *)(puVar8 + 0x58) = *(undefined2 *)(puVar8 + 6);
      }
      else {
        FUN_0002b338(PTR_DAT_0302e510,PTR_DAT_0302e514,0x11);
        puVar9[-0x32] =
             puVar9[-0x32] & 0xe1 | puVar10[-0x18] & 6 | ((byte)puVar10[-0x18] >> 4 & 3) << 3;
        uVar11 = FUN_0305660c(PTR_DAT_0302e518[0x29],PTR_DAT_0302e518[0x26]);
        *(undefined2 *)(puVar9 + 0x16) = uVar11;
      }
      PTR_DAT_0302e51c[0x4c] = 0;
      FUN_0300f71c(uVar12,sVar1 + 0x17,&local_22,2);
      if ((PTR_DAT_0302e520[8] & 0xf0) == 0) {
        local_22 = local_22 & 0xfffe;
      }
      else {
        local_22 = local_22 | 1;
      }
      bVar4 = PTR_DAT_0302e51c[1];
      if (bVar4 == 0) {
        uVar17 = 0;
        uVar16 = 0;
      }
      else {
        sVar1 = *(short *)(PTR_DAT_0302e51c + 0x16);
        sVar2 = *(short *)(PTR_DAT_0302e51c + 8);
        sVar5 = *(short *)(PTR_DAT_0302e51c + 10);
        uVar14 = 0;
        uVar17 = 0;
        uVar16 = 0;
        do {
          if (((int)(uint)local_22 >> (uVar14 & 0x3f) & 1U) == 0) {
            sVar3 = *(short *)(PTR_DAT_0302e51c + (uVar14 + 10) * 2 + 2);
            if (sVar1 == sVar3) {
              if (uVar14 == 0) goto LAB_0302e498;
            }
            else if (uVar14 == 0) {
LAB_0302e498:
              if ((sVar2 != sVar3) && (sVar5 != sVar3)) {
                local_64[uVar17] = sVar1;
                uVar17 = uVar17 + 1 & 0xff;
              }
            }
            else if ((sVar2 != sVar3) && (sVar5 != sVar3)) {
              local_64[uVar17] = sVar3;
              uVar17 = uVar17 + 1 & 0xff;
            }
          }
          else {
            sVar3 = *(short *)(PTR_DAT_0302e51c + (uVar14 + 10) * 2 + 2);
            if (sVar3 == sVar1) {
              if (uVar14 == 0) goto LAB_0302e45c;
            }
            else if (uVar14 == 0) {
LAB_0302e45c:
              if ((sVar3 != sVar2) && (sVar3 != sVar5)) {
                local_44[uVar16] = sVar1;
                uVar16 = uVar16 + 1 & 0xff;
              }
            }
            else if ((sVar3 != sVar2) && (sVar3 != sVar5)) {
              local_44[uVar16] = sVar3;
              uVar16 = uVar16 + 1 & 0xff;
            }
          }
          uVar14 = uVar14 + 1 & 0xff;
        } while (uVar14 < bVar4);
        local_23 = 0;
        if (uVar17 != 0) {
          psVar15 = local_64;
          psVar13 = (short *)PTR_DAT_0302e524;
          do {
            *psVar13 = *psVar15;
            psVar15 = psVar15 + 1;
            psVar13 = psVar13 + 1;
          } while (psVar15 != local_64 + (uVar17 - 1 & 0xff) + 1);
        }
        local_23 = 0;
        if (uVar16 != 0) {
          psVar15 = local_44;
          psVar13 = (short *)(PTR_DAT_0302e528 + (uVar17 + 10) * 2);
          do {
            *psVar13 = *psVar15;
            psVar15 = psVar15 + 1;
            psVar13 = psVar13 + 1;
          } while (psVar15 != local_44 + (uVar16 - 1 & 0xff) + 1);
        }
      }
      puVar7 = PTR_DAT_0302e6c4;
      cVar6 = (char)uVar17 + (char)uVar16;
      PTR_DAT_0302e6c4[1] = cVar6;
      puVar7[0x5c] = cVar6 + puVar7[0x5c];
    }
  }
  return;
}



/* Address: 0302f418; FUN_0302f418 */

bool FUN_0302f418(int param_1)

{
  bool bVar1;
  undefined *puVar2;
  int iVar3;
  undefined1 auStack_44 [52];
  
  if (((param_1 == 0) && (iVar3 = FUN_0302ece0(), iVar3 == 2)) &&
     ((PTR_DAT_0302f550[9] & 0x3f) != 0)) {
    return false;
  }
  FUN_0302eca0(0);
  if (((PTR_DAT_0302f558[0x2d] & 4) == 0) || ((PTR_DAT_0302f55c[0x15] & 4) != 0)) {
    FUN_0302e144();
  }
  else {
    if (0x1f < ((PTR_DAT_0302f550[9] & 0x3f) + 0x3f & 0x3f)) {
      bVar1 = true;
      goto LAB_0302f576;
    }
    FUN_0302e1a4();
  }
  iVar3 = FUN_0302f3d0();
  if (((iVar3 == 0) && ((PTR_DAT_0302f558[0x2d] & 4) != 0)) && ((PTR_DAT_0302f55c[0x15] & 4) == 0))
  {
    bVar1 = true;
  }
  else {
    if (param_1 == 0) {
      if ((PTR_DAT_0302f554[0x10] & 0x80) == 0) {
        bVar1 = false;
        goto LAB_0302f576;
      }
    }
    else {
      PTR_DAT_0302f554[0x10] = PTR_DAT_0302f554[0x10] & 0x7f | 0x80;
    }
    if (((*PTR_DAT_0302f72c & 8) == 0) || ((PTR_DAT_0302f558[0x2d] & 0x80) != 0)) {
      if (((*PTR_DAT_0302f72c & 0x10) != 0) && ((PTR_DAT_0302f558[0x2d] & 0x80) != 0)) {
        *PTR_DAT_0302f560 = *PTR_DAT_0302f560 & 0xef;
        puVar2 = PTR_DAT_0302f568;
        FUN_03031658(auStack_44,1);
        FUN_03070b88(puVar2,auStack_44,0x33);
        FUN_03070b88(PTR_DAT_0302f550,puVar2,0x33);
      }
    }
    else {
      *PTR_DAT_0302f560 = *PTR_DAT_0302f560 & 0xf7;
      puVar2 = PTR_DAT_0302f564;
      FUN_03031658(auStack_44);
      FUN_03070b88(puVar2,auStack_44,0x33);
      FUN_03070b88(PTR_DAT_0302f550,puVar2,0x33);
    }
    FUN_0302eca0(1);
    PTR_DAT_0302f56c[0xf] = 0;
    bVar1 = false;
  }
LAB_0302f576:
  return !bVar1;
}



/* Address: 03055c90; FUN_03055c90 */

void FUN_03055c90(uint param_1,short *param_2,short *param_3)

{
  ushort uVar1;
  int iVar2;
  short sVar3;
  uint uVar4;
  
  iVar2 = (param_1 & 0xff) - 1;
  uVar4 = iVar2 / 0x1c;
  uVar1 = (ushort)(iVar2 % 0x1c) & 0xff;
  if ((uVar4 & 0xffff) == 0) {
    sVar3 = uVar1 * 0x91 + 0x10;
  }
  else {
    sVar3 = uVar1 * 0x91;
  }
  *param_2 = (short)uVar4 + 0x5c;
  *param_3 = sVar3;
  return;
}



/* Address: 0305660c; FUN_0305660c */

ushort FUN_0305660c(undefined1 param_1,ushort param_2)

{
  short local_18;
  byte local_15;
  undefined1 local_14 [2];
  ushort local_12;
  
  FUN_03055c90(param_1,local_14,&local_18);
  FUN_0300f780(local_14[0],local_18 + 0x10,&local_15,1);
  if ((ushort)local_15 < (param_2 & 0xff)) {
    local_12 = 1;
  }
  else {
    FUN_0300f780(local_14[0],local_18 + 0x11 + ((param_2 & 0xff) - 1) * 2,&local_12,2);
    if (4000 < local_12) {
      local_12 = 1;
    }
  }
  return local_12;
}



/* Address: 0304d9c4; FUN_0304d9c4 */

void FUN_0304d9c4(void)

{
  undefined1 uVar1;
  undefined4 uVar2;
  int iVar3;
  undefined1 auStack_14 [4];
  undefined2 local_10;
  undefined1 local_e [2];
  
  if (PTR_DAT_0304dac8[(byte)PTR_DAT_0304dab8[3] + 2] == '\x02') {
    uVar1 = *PTR_DAT_0304dacc;
    uVar2 = FUN_03056af8(uVar1,*(short *)PTR_DAT_0304dad0 + 1);
    FUN_03056c28(uVar1,uVar2);
    FUN_0303a4f4(1,**(undefined4 **)(PTR_PTR_0304dad4 + ((byte)PTR_DAT_0304daac[0x30] >> 6 & 1) * 8)
                );
  }
  else if (PTR_DAT_0304dac8[(byte)PTR_DAT_0304dab8[3] + 2] == '\x03') {
    if (*PTR_DAT_0304dad8 == '\n') {
      if (*PTR_DAT_0304dadc == '\x03') {
        PTR_DAT_0304dae0[5] = PTR_DAT_0304dae0[5] & 0xdf;
        FUN_0306bc6c(PTR_DAT_0304dae4,0,0,auStack_14);
        *PTR_DAT_0304dae8 = 0xf0;
        if (*PTR_DAT_0304daec == '\0') {
          FUN_0303a4f4(0,**(undefined4 **)
                           (PTR_PTR_0304daf0 + ((byte)PTR_DAT_0304daac[0x30] >> 6 & 1) * 8));
        }
        else {
          iVar3 = FUN_03056d7c(PTR_DAT_0304daec);
          if (iVar3 == 0) {
            FUN_0002b338(PTR_DAT_0304daf8,PTR_DAT_0304daec,0x10);
            if ((PTR_DAT_0304daac[0x2d] & 0x80) == 0) {
              FUN_0002b338(PTR_DAT_0304dafc,PTR_DAT_0304daec,0x10);
            }
            else {
              FUN_0002b338(PTR_DAT_0304dc98,PTR_DAT_0304dc9c,0x10);
            }
            FUN_03055c90(*PTR_DAT_0304dca0 + '\x01',local_e,&local_10);
            FUN_0300f878(local_e[0],local_10,PTR_DAT_0304dc9c,0x10);
            FUN_0303a4ac();
          }
          else {
            FUN_0303a4f4(0,*(undefined4 *)
                            (PTR_PTR_0304daf4 + ((byte)PTR_DAT_0304daac[0x30] >> 6 & 1) * 4));
          }
        }
      }
      else {
        FUN_0305ae28();
        FUN_03035e68(*(undefined1 *)((uint)(byte)*PTR_DAT_0304dca4 + DAT_0304dca8),0);
      }
    }
  }
  else {
    FUN_03035e68(0x23,1);
  }
  return;
}



/* Address: 0304a200; FUN_0304a200 */

void FUN_0304a200(int param_1)

{
  undefined *puVar1;
  undefined4 uVar2;
  short local_18;
  undefined1 local_16 [2];
  
  puVar1 = PTR_DAT_0304a38c;
  FUN_03055c90(*PTR_DAT_0304a38c,local_16,&local_18);
  uVar2 = FUN_0300f594(local_16[0]);
  FUN_0300f71c(uVar2,local_18 + 0x10,puVar1 + 0x12,1);
  if (0x40 < (byte)puVar1[0x12]) {
    puVar1[0x12] = 1;
  }
  puVar1 = PTR_DAT_0304a390;
  FUN_0300f71c(uVar2,local_18,PTR_DAT_0304a390,0x10);
  puVar1[0x10] = 0;
  FUN_03055c90(puVar1[0x12],local_16,&local_18);
  uVar2 = FUN_0300f594(local_16[0]);
  FUN_0300f71c(uVar2,local_18 + 0x10,puVar1 + 0x24,1);
  if (0x40 < (byte)puVar1[0x24]) {
    PTR_DAT_0304a38c[0x25] = 1;
  }
  puVar1 = PTR_DAT_0304a394;
  FUN_0300f71c(uVar2,local_18,PTR_DAT_0304a394,0x10);
  puVar1[0x10] = 0;
  puVar1 = PTR_DAT_0304a38c;
  if (param_1 == 0) {
    PTR_DAT_0304a38c[0x29] = *PTR_DAT_0304a38c;
    puVar1[0x2c] = puVar1[0x12];
  }
  else {
    PTR_DAT_0304a38c[0x29] = PTR_DAT_0304a38c[0x13];
    puVar1[0x2c] = puVar1[0x25];
  }
  return;
}



/* Address: 0304d07c; FUN_0304d07c */

void FUN_0304d07c(void)

{
  bool bVar1;
  undefined2 *puVar2;
  char cVar3;
  byte bVar4;
  undefined *puVar5;
  undefined *puVar6;
  undefined *puVar7;
  int iVar8;
  
  puVar7 = PTR_DAT_0304d3a0;
  puVar6 = PTR_DAT_0304d398;
  puVar5 = PTR_DAT_0304d1d4;
  if ((*PTR_DAT_0304d1b0 & 2) == 0) {
    cVar3 = PTR_DAT_0304d1c8[(byte)PTR_DAT_0304d1c4[2] + 2];
    if (cVar3 == '\0') {
      if (*PTR_DAT_0304d1b4 == '\0') {
        iVar8 = FUN_0302f418(1);
        if (iVar8 == 0) {
          FUN_03021c1c(0x1b);
          FUN_0303a4f4(0,**(undefined4 **)
                           (PTR_PTR_0304d1d0 + ((byte)PTR_DAT_0304d1cc[0x30] >> 6 & 1) * 8));
        }
        else {
          FUN_03035e68(0,1);
        }
      }
      else {
        *PTR_DAT_0304d1d4 = *PTR_DAT_0304d1d4 & 0xfb | 4;
        FUN_0302f388();
        *puVar5 = *puVar5 & 0xfb;
        FUN_03021c1c(0x19);
        PTR_DAT_0304d1d8[0x10] = PTR_DAT_0304d1d8[0x10] & 0x7f;
        FUN_03035e68(0,1);
      }
    }
    else if (cVar3 == '\x01') {
      if (*PTR_DAT_0304d1b4 == '\0') {
        FUN_03018d78(8,0x28,0x18,0x48,PTR_DAT_0304d1dc,0xffff);
        FUN_03018d78(8,0x28,0x18,0x48,PTR_DAT_0304d1e0,0xffff);
        FUN_0303a4ac();
        FUN_0304b158(0x32,0);
        FUN_0302e1a4(PTR_DAT_0304d1e4[9] & 0x3f);
        if (((byte)PTR_DAT_0304d1d8[1] < 2) && (iVar8 = FUN_0302ece0(), iVar8 != 0)) {
          FUN_0302eca0(0);
        }
      }
      else {
        *PTR_DAT_0304d1e8 = *PTR_DAT_0304d1b4;
        FUN_03035e68(0x1c,1);
      }
    }
    else if ((byte)(cVar3 - 2U) < 2) {
      bVar1 = cVar3 == '\x02';
      iVar8 = FUN_0302f6a4(bVar1,PTR_DAT_0304d1ec);
      if (iVar8 == 0) {
        if (bVar1) {
          FUN_0302f6a4(1,PTR_DAT_0304d38c);
        }
        else {
          FUN_0302f6a4(0,PTR_DAT_0304d37c);
        }
        FUN_0303a4f4(0,*(undefined4 *)
                        (PTR_PTR_0304d390 + ((byte)PTR_DAT_0304d384[0x30] >> 6 & 1) * 4));
      }
      else {
        if (bVar1) {
          FUN_0002b338(PTR_DAT_0304d1f0,PTR_DAT_0304d1ec,4);
          FUN_0304b158(0x52,0);
        }
        else {
          FUN_0002b338(PTR_DAT_0304d37c,PTR_DAT_0304d380,4);
          FUN_0304b158(0x53,0);
        }
        FUN_0303a4f4(1,**(undefined4 **)
                         (PTR_PTR_0304d388 + ((byte)PTR_DAT_0304d384[0x30] >> 6 & 1) * 8));
      }
    }
    else if (cVar3 == '\x04') {
      FUN_0304b158(0x57,*PTR_DAT_0304d394);
      FUN_03041530();
      FUN_0303a4f4(1,**(undefined4 **)
                       (PTR_PTR_0304d388 + ((byte)PTR_DAT_0304d384[0x30] >> 6 & 1) * 8));
    }
    else if ((byte)(cVar3 - 5U) < 2) {
      if ((PTR_DAT_0304d398[3] & 0x80) == 0) {
        if ((PTR_DAT_0304d384[0x2d] & 4) == 0) {
          cVar3 = PTR_DAT_0304d39c[0x5e];
          if ((cVar3 == '\0') || (cVar3 == '\x02')) {
            puVar2 = (undefined2 *)(PTR_DAT_0304d3a0 + 0x11);
            PTR_DAT_0304d3a0[0x13] = (char)*puVar2;
            puVar7[0x14] = (char)((ushort)*puVar2 >> 8);
            FUN_03031364(1);
            if (PTR_DAT_0304d39c[0x5e] == '\x02') {
              FUN_03031364(0,*(undefined2 *)(PTR_DAT_0304d3a0 + 0x11));
            }
          }
          else if (cVar3 == '\x01') {
            FUN_03031364(0,*(undefined2 *)(PTR_DAT_0304d3a0 + 0x11));
          }
        }
        else {
          cVar3 = PTR_DAT_0304d39c[0x5e];
          if ((cVar3 == '\0') || (cVar3 == '\x02')) {
            puVar2 = (undefined2 *)(PTR_DAT_0304d3a0 + 0x11);
            PTR_DAT_0304d3a0[0x13] = (char)*puVar2;
            puVar7[0x14] = (char)((ushort)*puVar2 >> 8);
            FUN_030312a0(1);
            if (PTR_DAT_0304d39c[0x5e] == '\x02') {
              FUN_030312a0(0,*(undefined2 *)(PTR_DAT_0304d3a0 + 0x11));
            }
          }
          else if (cVar3 == '\x01') {
            FUN_030312a0(0,*(undefined2 *)(PTR_DAT_0304d3a0 + 0x11));
          }
        }
        FUN_0303a4ac();
        FUN_03030560(8);
        FUN_03035e68(0,1);
      }
      else {
        PTR_DAT_0304d398[3] = PTR_DAT_0304d398[3] & 0x7f;
        puVar6[4] = puVar6[4] & 0xfe;
        FUN_03035e68(0,1);
      }
    }
    else if (cVar3 == '\a') {
      PTR_DAT_0304d554[0x5e] = *PTR_DAT_0304d550;
      FUN_0300fa28(0x11,0xe10);
      FUN_03041530();
      FUN_0303a4f4(1,**(undefined4 **)
                       (PTR_PTR_0304d55c + ((byte)PTR_DAT_0304d558[0x30] >> 6 & 1) * 8));
    }
    else if ((*PTR_DAT_0304d560 == '\0') || (*PTR_DAT_0304d564 == '\x05')) {
      FUN_03035e68(*(undefined1 *)((uint)(byte)*PTR_DAT_0304d568 + DAT_0304d56c),0);
    }
    else {
      FUN_03035e68(0x1c,1);
    }
  }
  else if (PTR_DAT_0304d574[(byte)PTR_DAT_0304d570[2] + 2] == '\x04') {
    *PTR_DAT_0304d578 = 5;
    *PTR_DAT_0304d57c = 5;
    bVar4 = *PTR_DAT_0304d550;
    if (bVar4 < 3) {
      PTR_DAT_0304d580[3] = PTR_DAT_0304d580[3] & 0xe7;
      *PTR_DAT_0304d584 = bVar4 + 0x1b;
    }
    else {
      PTR_DAT_0304d580[3] = PTR_DAT_0304d580[3] & 0xe7 | 0x18;
      *PTR_DAT_0304d584 = bVar4 + 0x1b;
    }
    FUN_03035e68(0x62,1);
  }
  else {
    FUN_03035e68(0x1c,1);
  }
  return;
}



/* Address: 0304d970; FUN_0304d970 */

void FUN_0304d970(void)

{
  int iVar1;
  
  if (PTR_DAT_0304dabc[(byte)PTR_DAT_0304dab8[2] + 2] == '\x01') {
    if (*PTR_DAT_0304daa8 == '\0') {
      FUN_0303a4ac();
      FUN_0304b158(0x32,PTR_DAT_0304dab8[3]);
      FUN_0302e1a4(PTR_DAT_0304dac0[9] & 0x3f);
      if (((byte)PTR_DAT_0304dac4[1] < 2) && (iVar1 = FUN_0302ece0(), iVar1 != 0)) {
        FUN_0302eca0(0);
      }
    }
    else {
      FUN_03035e68(0x23,1);
    }
  }
  return;
}



/* Address: 030174e0; FUN_030174e0 */

void FUN_030174e0(char param_1)

{
  int iVar1;
  
  if (((PTR_DAT_03017750[10] & 0x30) == 0x10) || (param_1 != '\x01' && param_1 != '\x03')) {
    FUN_03021c1c(0x21);
  }
  else {
    iVar1 = FUN_030140e4(0x19);
    if (iVar1 != 0) {
      if ((PTR_DAT_03017754[0xd] & 2) == 0) {
        FUN_0305ccf0(1);
        FUN_03021c1c(0x18);
      }
      else {
        FUN_0305ccf0(0);
        FUN_03021c1c(0x19);
      }
      if ((*PTR_DAT_03017758 == '\0') || (*PTR_DAT_03017758 == '[')) {
        FUN_030193cc();
      }
    }
  }
  return;
}



/* Address: 0305e134; FUN_0305e134 */

void FUN_0305e134(byte param_1)

{
  bool bVar1;
  undefined2 uVar2;
  int iVar3;
  uint uVar4;
  undefined1 auStack_5c [8];
  byte bStack_54;
  undefined1 auStack_28 [22];
  char cStack_12;
  
  iVar3 = FUN_0302ece0();
  if (iVar3 == 0) {
    FUN_03064c9c();
    uVar4 = FUN_0002ded4();
  }
  else {
    uVar4 = ((byte)PTR_DAT_0305e268[0x10] & 0x7f) >> 5;
  }
  if ((PTR_DAT_0305e26c[3] & 0x40) != 0) {
    return;
  }
  if ((PTR_DAT_0305e270[7] == '\x04') && ((PTR_DAT_0305e264[1] & 3) == 1)) {
    return;
  }
  iVar3 = FUN_030140e4(7);
  if (iVar3 == 0) {
    return;
  }
  if (param_1 == 2) {
    PTR_DAT_0305e264[0x2f] = PTR_DAT_0305e264[0x2f] & 0x8f | 0x20;
    FUN_0305ccf0(0);
    FUN_0305dd38();
    return;
  }
  if (PTR_DAT_0305e264[0x32] == '\0') {
    bVar1 = false;
  }
  else {
    bVar1 = uVar4 != 0 && uVar4 != 2;
    if (PTR_DAT_0305e264[0x32] == '\x01') goto LAB_0305e1d2;
  }
  if (*(ushort *)(PTR_DAT_0305e26c + 0x12) < *(ushort *)(PTR_DAT_0305e264 + 0x34)) {
    bVar1 = false;
  }
LAB_0305e1d2:
  FUN_03057510(*(undefined2 *)(PTR_DAT_0305e264 + 0x34),auStack_5c);
  if (((bStack_54 & 8) != 0) && (PTR_DAT_0305e264[0x32] != '\x01')) {
    bVar1 = false;
  }
  if (*(short *)(PTR_DAT_0305e264 + 0x34) == 0) {
    if ((PTR_DAT_0305e274[0x2d] & 4) == 0) {
      uVar2 = FUN_03056600((byte)PTR_DAT_0305e274[0x2d] >> 7);
      *(undefined2 *)(PTR_DAT_0305e264 + 0x36) = uVar2;
    }
    else {
      uVar2 = FUN_030565f4(*(undefined2 *)(PTR_DAT_0305e268 + 0x54));
      *(undefined2 *)(PTR_DAT_0305e264 + 0x36) = uVar2;
    }
  }
  else {
    uVar2 = FUN_030565f4();
    *(undefined2 *)(PTR_DAT_0305e264 + 0x36) = uVar2;
  }
  FUN_030332e0(*(undefined2 *)(PTR_DAT_0305e264 + 0x36),auStack_28);
  if (((cStack_12 == '\x04') || (PTR_DAT_0305e264[0x32] == '\x01')) && (bVar1)) {
    if ((PTR_DAT_0305e3cc[1] != '\0') && ((*PTR_DAT_0305e3cc & 1) == 0)) {
      *PTR_DAT_0305e3cc = *PTR_DAT_0305e3cc & 0xfe | 1;
    }
    iVar3 = FUN_0302ece0();
    if (iVar3 != 0) {
      FUN_0302f388();
    }
    PTR_DAT_0305e3d0[0x2f] = PTR_DAT_0305e3d0[0x2f] & 0x8f | (param_1 & 7) << 4;
    FUN_0305ccf0(0);
    FUN_0305dd38();
  }
  else {
    FUN_03021c1c(0x1b);
  }
  return;
}



/* Address: 03031fd4; FUN_03031fd4 */

void FUN_03031fd4(void)

{
  char cVar1;
  byte bVar2;
  bool bVar3;
  undefined *puVar4;
  uint uVar5;
  int iVar6;
  
  FUN_03060468();
  FUN_03030520();
  if (((PTR_DAT_030320c0[8] & 0xf0) == 0) && ((*PTR_DAT_030320c4 & 8) != 0)) {
    FUN_030601cc(1);
  }
  if ((*PTR_DAT_030320c4 & 1) != 0) {
    *PTR_DAT_030320c4 = *PTR_DAT_030320c4 & 0xfe;
    puVar4 = PTR_DAT_030320c8;
    PTR_DAT_030320c8[0x5f] = PTR_DAT_030320c8[0x5f] & 0xfe;
    FUN_0002b350(puVar4 + 0x3f,0,0x20);
    FUN_0002b350(PTR_DAT_030320cc,0,0x20);
  }
  if (PTR_DAT_030320d0[0x328] == '\x01') {
    PTR_DAT_030320d4[10] = PTR_DAT_030320d4[10] & 0xfe | 1;
    FUN_0305d338();
    PTR_DAT_030320d0[0x328] = 0;
  }
  FUN_0300d838();
  FUN_0300d828();
  if ((PTR_DAT_030320d8[1] & 4) != 0) {
    FUN_0305dd28();
  }
  cVar1 = PTR_DAT_030320dc[1];
  if ((cVar1 == '\x01') || (cVar1 == '\t')) {
    if ((PTR_DAT_030320dc[0xd] & 2) != 0) {
      PTR_DAT_030320dc[0xd] = PTR_DAT_030320dc[0xd] & 0xfd;
      FUN_0301ec40();
    }
    if ((PTR_DAT_030320dc[0x15] & 4) == 0) {
      uVar5 = FUN_0305660c(PTR_DAT_03032248[0x29],PTR_DAT_03032248[0x26]);
    }
    else {
      uVar5 = (uint)(byte)PTR_DAT_030320b8[0x26];
    }
    PTR_DAT_0303224c[2] = (char)uVar5;
  }
  else if (cVar1 == '\x12') {
    if ((PTR_DAT_03032250[1] & 1) == 0) {
      uVar5 = FUN_0305660c(*PTR_DAT_03032248,PTR_DAT_03032248[0x26]);
    }
    else {
      uVar5 = FUN_0305660c(PTR_DAT_03032248[0x13],PTR_DAT_03032248[0x26]);
    }
  }
  else if (cVar1 == '\x02') {
    uVar5 = (uint)*(ushort *)(PTR_DAT_03032254 + 0x14);
  }
  else if (cVar1 == '\x1a') {
    uVar5 = (uint)*(ushort *)(PTR_DAT_03032254 + 0x14);
  }
  else if (cVar1 == '\x04') {
    uVar5 = (uint)*(ushort *)(PTR_DAT_03032258 + 0x34);
  }
  else if (cVar1 == '\x14') {
    uVar5 = (uint)*(ushort *)(PTR_DAT_0303225c + 2);
  }
  else if (cVar1 == '\x16') {
    uVar5 = (uint)*(ushort *)(PTR_DAT_03032260 + 2);
  }
  else if (cVar1 == '\f') {
    uVar5 = (uint)*(ushort *)PTR_DAT_0303224c;
  }
  else if (cVar1 == '\r') {
    if ((PTR_DAT_03032250[1] & 1) == 0) {
      uVar5 = FUN_0305660c(*PTR_DAT_03032248,PTR_DAT_03032248[0x26]);
    }
    else {
      uVar5 = FUN_0305660c(PTR_DAT_03032248[0x13],PTR_DAT_03032248[0x26]);
    }
  }
  else {
    iVar6 = FUN_0305df8c();
    if (iVar6 == 0) {
      uVar5 = (uint)*(ushort *)(PTR_DAT_03032254 + 0x54);
    }
    else {
      uVar5 = FUN_0305660c(PTR_DAT_03032248[0x29],PTR_DAT_03032248[0x26]);
    }
  }
  puVar4 = PTR_DAT_03032264;
  FUN_030584e4(uVar5,PTR_DAT_03032264[1]);
  bVar2 = puVar4[3];
  if (((*PTR_DAT_03032268 & 2) == 0) &&
     (((cVar1 = puVar4[1], cVar1 == '\x01' || (cVar1 == '\t')) || (cVar1 == '\n')))) {
    FUN_0302f418(0);
    puVar4 = PTR_DAT_03032264;
    PTR_DAT_03032264[0x10] = PTR_DAT_03032264[0x10] & 0x3f;
    PTR_DAT_0303226c[1] = 0;
    puVar4[0x16] = puVar4[0x16] & 0xe7;
  }
  FUN_0300c494(PTR_DAT_03032270,4);
  if ((*PTR_DAT_03032268 & 2) == 0) {
    cVar1 = PTR_DAT_03032264[1];
    if (((cVar1 == '\x01') || (cVar1 == '\t')) || ((cVar1 == '\x10' || (cVar1 == '\x11')))) {
      FUN_0305e2c0();
      if ((*PTR_DAT_03032274 == '\0') && ((PTR_DAT_03032264[3] & 0x40) == 0)) {
        bVar3 = false;
      }
      else {
        FUN_030130ac(1,100);
        bVar3 = true;
      }
      if ((*PTR_DAT_030323b4 & 2) == 0) {
        if (PTR_DAT_030323b8[1] != '\x01') goto LAB_030322b6;
        if ((PTR_DAT_030323b8[3] & 0x40) != 0) {
          cVar1 = '\x01';
          if ((PTR_DAT_030323bc[0x5d] & 1) == 0) goto LAB_030322e4;
          FUN_03021c1c(0x20);
        }
      }
    }
    else {
      bVar3 = false;
LAB_030322b6:
      if (((PTR_DAT_030323b8[3] & 0x40) != 0) && ((PTR_DAT_030323bc[0x5d] & 1) != 0)) {
        FUN_03021c1c(0x20);
      }
    }
  }
  else {
    bVar3 = false;
  }
  cVar1 = PTR_DAT_030323b8[1];
  if (cVar1 == '\b') {
    return;
  }
LAB_030322e4:
  if (!bVar3) {
    if ((cVar1 == '\x03') || ((bVar2 >> 6 & 1) != 0)) {
      if ((*PTR_DAT_030323c0 & 4) == 0) {
        FUN_030193cc();
        FUN_030317bc();
      }
    }
    else if (cVar1 == '\x04') {
      if (*PTR_DAT_030323c4 != '\0') {
        FUN_030130ac(1,100);
      }
    }
    else if (cVar1 == '\n') {
      if ((PTR_DAT_030323b8[0xd] & 2) != 0) {
        PTR_DAT_030323b8[0xd] = PTR_DAT_030323b8[0xd] & 0xfd;
        FUN_0301ec40();
      }
      FUN_030193cc();
      if (PTR_DAT_030323bc[0x6c] == '\0') {
        FUN_030317bc();
      }
      else {
        FUN_0301aaec((byte)PTR_DAT_030323bc[0x2d] >> 7);
      }
    }
    else if ((((1 < (byte)(cVar1 - 0x12U)) && (cVar1 != '\r')) && (3 < (byte)(cVar1 - 0x14U))) &&
            ((1 < (byte)(cVar1 - 0x18U) && (*PTR_DAT_030323c4 == '\0')))) {
      if (cVar1 == '\x1a') {
        FUN_03019af8((byte)PTR_DAT_030323bc[0x2d] >> 7,0);
      }
      FUN_03031b7c();
    }
  }
  return;
}



/* Address: 030239d4; FUN_030239d4 */

void FUN_030239d4(void)

{
  uint uVar1;
  
  uVar1 = *(uint *)PTR_DAT_03023a44;
  if ((PTR_DAT_03023a48[1] != '\x02') && (PTR_DAT_03023a48[1] != '\x04')) {
    if ((uVar1 & 0x40) != 0) {
      FUN_03023880();
    }
    if ((uVar1 & 0x10) != 0) {
      FUN_03027388();
    }
    if ((uVar1 & 8) != 0) {
      FUN_0300c0e8();
      FUN_0300c0e4(*PTR_DAT_03023a4c);
      FUN_03028644();
    }
    if ((uVar1 & 4) != 0) {
      FUN_03028be4();
    }
    if ((uVar1 & 2) != 0) {
      FUN_0002d6c0();
    }
    if ((uVar1 & 0x800) != 0) {
      FUN_030239c4();
      FUN_0300c0e4(*PTR_DAT_03023a4c);
    }
  }
  return;
}



/* Address: 03023eb8; FUN_03023eb8 */

void FUN_03023eb8(int param_1)

{
  undefined *puVar1;
  undefined *puVar2;
  int iVar3;
  byte bVar4;
  uint uVar5;
  int iVar6;
  byte local_11;
  
  puVar1 = PTR_DAT_03024048;
  *(undefined4 *)(PTR_DAT_03024048 + 0x78) = 0;
  puVar2 = PTR_DAT_03024048;
  if (puVar1[0x72] == '\0') {
    PTR_DAT_03024048[0x72] = 1;
    uVar5 = *(byte *)(param_1 + 2) & 0x1f;
    puVar2[0x73] = (char)uVar5;
    puVar1 = PTR_DAT_0302404c;
    iVar6 = uVar5 + 1;
    bVar4 = (byte)iVar6 & 1;
    PTR_DAT_0302404c[3] = bVar4;
    puVar1[4] = bVar4;
    iVar3 = FUN_03023c04();
    puVar1 = PTR_DAT_03024050;
    iVar6 = iVar6 >> 1;
    if (iVar3 == iVar6) {
      *PTR_DAT_03024050 = *(byte *)(param_1 + 2) >> 5 & 1;
      puVar1[9] = 1;
      puVar1[7] = 1;
      puVar1[2] = bVar4;
      puVar1[4] = bVar4;
      FUN_0300c724(0x8000000);
    }
    else {
      FUN_03023c10(iVar6);
    }
    PTR_DAT_03024050[3] = 0;
  }
  else if (PTR_DAT_03024050[9] == '\0') {
    if (PTR_DAT_0302404c[0x15] == '\0') {
      iVar3 = FUN_03023d24(param_1,PTR_DAT_03024048[0x73],&local_11);
      puVar1 = PTR_DAT_03024050;
      if (iVar3 == 0) {
        if ((uint)(byte)PTR_DAT_03024048[0x73] == (uint)local_11) {
          *PTR_DAT_03024050 = *(byte *)(param_1 + 2) >> 5 & 1;
          puVar1[9] = 1;
          puVar1[7] = 1;
          puVar2 = PTR_DAT_0302404c;
          puVar1[2] = PTR_DAT_0302404c[4];
          puVar1[4] = puVar2[3];
          FUN_0300c724(0x8000000);
        }
        else {
          PTR_DAT_03024048[0x73] = local_11;
          puVar1 = PTR_DAT_0302404c;
          iVar6 = local_11 + 1;
          bVar4 = (byte)iVar6 & 1;
          PTR_DAT_0302404c[3] = bVar4;
          puVar1[4] = bVar4;
          puVar1 = PTR_DAT_03024050;
          PTR_DAT_03024050[2] = bVar4;
          puVar1[4] = bVar4;
          iVar3 = FUN_03023c04();
          iVar6 = iVar6 >> 1;
          if (iVar3 != iVar6) {
            FUN_03023c10(iVar6);
          }
        }
      }
      else {
        uVar5 = *(byte *)(param_1 + 2) & 0x1f;
        PTR_DAT_03024048[0x73] = (char)uVar5;
        puVar1 = PTR_DAT_0302404c;
        iVar6 = uVar5 + 1;
        bVar4 = (byte)iVar6 & 1;
        PTR_DAT_0302404c[3] = bVar4;
        puVar1[4] = bVar4;
        iVar3 = FUN_03023c04();
        puVar1 = PTR_DAT_03024050;
        iVar6 = iVar6 >> 1;
        if (iVar3 == iVar6) {
          *PTR_DAT_03024050 = *(byte *)(param_1 + 2) >> 5 & 1;
          puVar1[9] = 1;
          puVar1[7] = 1;
          puVar1[2] = bVar4;
          puVar1[4] = bVar4;
          FUN_0300c724(0x8000000);
        }
        else {
          FUN_03023c10(iVar6);
        }
        PTR_DAT_03024050[3] = 0;
      }
    }
  }
  else if (PTR_DAT_0302404c[0x15] == '\0') {
    iVar3 = FUN_03023d24(param_1,PTR_DAT_03024048[0x73],&local_11);
    if (iVar3 == 0) {
      if ((uint)(byte)PTR_DAT_03024048[0x73] != (uint)local_11) {
        PTR_DAT_03024048[0x73] = local_11;
        puVar1 = PTR_DAT_0302404c;
        iVar6 = local_11 + 1;
        bVar4 = (byte)iVar6 & 1;
        PTR_DAT_0302404c[3] = bVar4;
        puVar1[4] = bVar4;
        puVar1 = PTR_DAT_03024050;
        PTR_DAT_03024050[2] = bVar4;
        puVar1[4] = bVar4;
        iVar3 = FUN_03023c04();
        iVar6 = iVar6 >> 1;
        if (iVar3 != iVar6) {
          FUN_03023c10(iVar6);
        }
      }
    }
    else {
      uVar5 = *(byte *)(param_1 + 2) & 0x1f;
      if ((byte)PTR_DAT_03024098[0x73] != uVar5) {
        PTR_DAT_03024098[0x73] = (char)uVar5;
        puVar1 = PTR_DAT_0302409c;
        bVar4 = (byte)(uVar5 + 1) & 1;
        PTR_DAT_0302409c[3] = bVar4;
        puVar1[4] = bVar4;
        puVar1 = PTR_DAT_030240a0;
        PTR_DAT_030240a0[2] = bVar4;
        puVar1[4] = bVar4;
        iVar3 = FUN_03023c04();
        iVar6 = (int)(uVar5 + 1) >> 1;
        if (iVar3 != iVar6) {
          FUN_03023c10(iVar6);
        }
      }
      PTR_DAT_030240a0[3] = 0;
    }
  }
  return;
}



/* Address: 03024120; FUN_03024120 */

void FUN_03024120(void)

{
  undefined *puVar1;
  undefined *puVar2;
  uint uVar3;
  
  puVar1 = PTR_DAT_03024298;
  PTR_DAT_03024298[9] = PTR_DAT_03024298[9] & 7;
  *(ushort *)(puVar1 + 8) = *(ushort *)(puVar1 + 8) & 0xf800;
  *puVar1 = 3;
  puVar1[1] = 0;
  puVar1[2] = 0x12;
  puVar1[3] = 0;
  puVar1[4] = 0;
  puVar1[5] = 0;
  *(undefined4 *)(puVar1 + 0xc) = 0;
  puVar1[7] = 0;
  *(ushort *)(puVar1 + 0x12) = *(ushort *)(puVar1 + 0x12) & 0xf;
  uVar3 = FUN_03070670();
  *(uint *)(puVar1 + 0x10) = *(uint *)(puVar1 + 0x10) & 0xfff00000 | uVar3 & 0xfffff;
  puVar2 = PTR_DAT_030242a0;
  puVar1 = PTR_DAT_0302429c;
  PTR_DAT_0302429c[2] = PTR_DAT_030242a0[4];
  puVar1[4] = puVar2[3];
  puVar1[0xf] = 0;
  FUN_0300c690(&DAT_00041eb0);
  FUN_030293ac();
  return;
}



/* Address: 030237b8; FUN_030237b8 */

void FUN_030237b8(char param_1)

{
  byte bVar1;
  int iVar2;
  
  if (PTR_DAT_03023860[1] == '\0') {
    if (param_1 == '\0') {
      PTR_DAT_03023864[4] = PTR_DAT_03023864[2];
    }
    else {
      bVar1 = PTR_DAT_03023864[2];
      if (PTR_DAT_03023868[bVar1] == '\0') {
        PTR_DAT_03023864[4] = bVar1;
      }
      else {
        PTR_DAT_03023864[4] = bVar1 == 0;
      }
    }
  }
  else if (PTR_DAT_03023860[1] == '\x01') {
    if (param_1 == '\0') {
      iVar2 = FUN_030237ac();
      if (iVar2 == 0) {
        PTR_DAT_03023864[4] = PTR_DAT_03023864[2];
      }
      else {
        PTR_DAT_03023864[4] = PTR_DAT_03023860[3];
      }
    }
    else {
      PTR_DAT_03023864[4] = PTR_DAT_03023864[2] == '\0';
    }
  }
  return;
}



/* Address: 0305da8c; FUN_0305da8c */

void FUN_0305da8c(undefined4 param_1,undefined4 param_2,uint param_3)

{
  undefined *puVar1;
  uint uVar2;
  undefined1 auStack_30 [10];
  undefined1 uStack_26;
  char cStack_25;
  undefined2 uStack_24;
  undefined1 uStack_22;
  undefined1 uStack_21;
  byte bStack_20;
  byte bStack_1f;
  char cStack_1e;
  byte bStack_1d;
  
  uVar2 = param_3 >> 0x18 & 0x1f;
  if ((param_3 & 0x80000000) == 0) {
    PTR_DAT_0305dc74[0x2f] = PTR_DAT_0305dc74[0x2f] & 0xfd;
  }
  else {
    PTR_DAT_0305dc74[0x2f] = PTR_DAT_0305dc74[0x2f] & 0xfd | 2;
  }
  if ((param_3 & 0x40000000) == 0) {
    PTR_DAT_0305dc74[0x2f] = PTR_DAT_0305dc74[0x2f] & 0xfb;
  }
  else {
    PTR_DAT_0305dc74[0x2f] = PTR_DAT_0305dc74[0x2f] & 0xfb | 4;
  }
  if ((param_3 & 0x80000000) == 0) {
    PTR_DAT_0305dc74[0x2f] = PTR_DAT_0305dc74[0x2f] & 0xf7;
  }
  else {
    PTR_DAT_0305dc74[0x2f] = PTR_DAT_0305dc74[0x2f] & 0xf7 | 8;
  }
  puVar1 = PTR_DAT_0305dc74;
  if (((param_3 & 0x1f000000) == 0) || (0xf < uVar2)) {
    PTR_DAT_0305dc74[0x2f] = PTR_DAT_0305dc74[0x2f] & 0xfe;
    puVar1[0x32] = 0;
    puVar1[0x3f] = 0;
    puVar1[0x33] = 0;
    *(undefined2 *)(puVar1 + 0x34) = 0;
    puVar1[0x38] = 0;
    puVar1[0x39] = 0;
    puVar1[0x3a] = 0;
  }
  else {
    PTR_DAT_0305dc74[0x2f] = PTR_DAT_0305dc74[0x2f] & 0xfe | 1;
    FUN_0300f780(0x10,(uVar2 - 1) * 0x14 & 0xfffc,auStack_30);
    puVar1[0x32] = uStack_26;
    puVar1[0x3f] = uStack_26;
    puVar1[0x33] = cStack_25;
    *(undefined2 *)(puVar1 + 0x34) = uStack_24;
    puVar1[0x38] = uStack_22;
    puVar1[0x39] = uStack_21;
    puVar1[0x3a] = bStack_20;
    if (cStack_25 == '\x01') {
      puVar1[0x3e] = puVar1[0x3e] & 0xfe;
    }
    else {
      PTR_DAT_0305dc74[0x3e] = PTR_DAT_0305dc74[0x3e] & 0xfe | bStack_1f & 1;
    }
    if (0xb < bStack_20) {
      PTR_DAT_0305dc74[0x3a] = 0;
    }
    puVar1 = PTR_DAT_0305dc74;
    PTR_DAT_0305dc74[0x3a] = (PTR_DAT_0305dc74[0x3a] + '\x01') * '\n';
    puVar1[0x3b] = bStack_1d;
    if (0xb < bStack_1d) {
      PTR_DAT_0305dc74[0x3b] = 0;
    }
    puVar1 = PTR_DAT_0305dc74;
    PTR_DAT_0305dc74[0x3b] = (PTR_DAT_0305dc74[0x3b] + '\x01') * '\n';
    puVar1[0x3c] = cStack_1e;
    if (cStack_1e == '\0') {
      puVar1[0x3c] = 1;
    }
  }
  puVar1 = PTR_DAT_0305dc74;
  FUN_0301ec88((byte)PTR_DAT_0305dc74[0x2f] >> 1 & 1);
  FUN_0301ec94((byte)puVar1[0x2f] >> 2 & 1);
  if (puVar1[0x3f] == '\x03') {
    FUN_0301eca0(1);
  }
  else {
    FUN_0301eca0(0);
  }
  FUN_0301ecac(PTR_DAT_0305de18[0x38]);
  return;
}


