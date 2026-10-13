
/* Address: 0300c000 */

void startup_entry(void)

{
  undefined4 *puVar1;
  undefined4 *puVar2;
  undefined4 *puVar3;
  uint *puVar4;
  undefined4 *puVar5;
  undefined4 *puVar6;
  uint uVar7;
  undefined4 *puVar8;
  
  puVar4 = DAT_0300c0bc;
  DAT_0300c0bc[1] = 1;
  *puVar4 = 4;
  puVar4[2] = DAT_0300c0c0;
  *puVar4 = *puVar4 | 1;
  puVar5 = DAT_0300c0c8;
  puVar6 = (undefined4 *)PTR_DAT_0300c0cc;
  puVar1 = (undefined4 *)PTR_DAT_0300c0d4;
  for (puVar8 = (undefined4 *)PTR_DAT_0300c0c4; PTR_DAT_0300c0d4 = (undefined *)puVar1,
      puVar2 = (undefined4 *)PTR_PTR_0300c0d8, puVar3 = (undefined4 *)PTR_PTR_0300c0d0,
      puVar8 < puVar5; puVar8 = puVar8 + 1) {
    *puVar8 = *puVar6;
    puVar6 = puVar6 + 1;
    puVar1 = (undefined4 *)PTR_DAT_0300c0d4;
  }
  for (; puVar3 < puVar1; puVar3 = puVar3 + 1) {
    *puVar3 = *puVar2;
    puVar2 = puVar2 + 1;
  }
  puVar8 = (undefined4 *)PTR_DAT_0300c0dc;
  for (uVar7 = (uint)((int)PTR_DAT_0300c0e0 - (int)PTR_DAT_0300c0dc) >> 2; uVar7 != 0;
      uVar7 = uVar7 - 1) {
    *puVar8 = 0;
    puVar8 = puVar8 + 1;
  }
  FUN_0002e174();
  stub();
  stub();
  return;
}



/* Address: 0302e144 */

void FUN_0302e144(void)

{
  undefined *puVar1;
  undefined2 uVar2;
  
  puVar1 = PTR_DAT_0302e368;
  PTR_DAT_0302e368[0x10] =
       PTR_DAT_0302e368[0x10] & 0xe1 | PTR_DAT_0302e36c[8] & 6 |
       ((byte)PTR_DAT_0302e36c[8] >> 4 & 3) << 3;
  uVar2 = FUN_0305660c(PTR_DAT_0302e370[0x29],PTR_DAT_0302e370[0x26]);
  *(undefined2 *)(puVar1 + 0x58) = uVar2;
  return;
}



/* Address: 0302e1a4 */

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



/* Address: 0302edc8 */

void FUN_0302edc8(void)

{
  char cVar1;
  short sVar2;
  undefined *puVar3;
  undefined *puVar4;
  byte bVar5;
  undefined2 uVar6;
  int iVar7;
  int iVar8;
  
  iVar7 = FUN_0302ece0();
  if ((*PTR_DAT_0302ef1c & 0x40) != 0) {
    return;
  }
  if (iVar7 == 0) {
    return;
  }
  iVar8 = FUN_0305df8c();
  if (iVar8 == 0) {
    FUN_0302eca0();
    return;
  }
  if (iVar7 == 1) {
    if ((((byte)PTR_DAT_0302ef20[0x5c] < 2) && ((PTR_DAT_0302ef24[0x2d] & 4) != 0)) &&
       ((PTR_DAT_0302ef28[0x15] & 4) == 0)) {
      FUN_0302eca0(0);
      return;
    }
    if ((PTR_DAT_0302ef2c[1] & 3) != 0) {
      return;
    }
    cVar1 = PTR_DAT_0302ef30[0x12];
    PTR_DAT_0302ef30[0x12] = cVar1 + 1U;
    if ((byte)(cVar1 + 1U) < 0x32) {
      return;
    }
    bVar5 = FUN_0002ded4();
    PTR_DAT_0302ef20[0x10] = PTR_DAT_0302ef20[0x10] & 0x9f | (bVar5 & 3) << 5;
    if ((PTR_DAT_0302ef28[0x15] & 4) == 0) {
      uVar6 = FUN_0305660c(PTR_DAT_0302ef24[0x29],PTR_DAT_0302ef24[0x26]);
      *(undefined2 *)(PTR_DAT_0302ef20 + 0x56) = uVar6;
    }
    else {
      *(ushort *)(PTR_DAT_0302ef20 + 0x56) = (ushort)(byte)PTR_DAT_0302ef24[0x26];
    }
    puVar3 = PTR_DAT_0302ef20;
    *(undefined2 *)(PTR_DAT_0302ef20 + 0x5a) = *(undefined2 *)(PTR_DAT_0302ef20 + 0x56);
    PTR_DAT_0302ef28[2] = PTR_DAT_0302ef28[2] & 0xf3 | (PTR_DAT_0302ef28[2] & 3) << 2;
    PTR_DAT_0302ef30[0x12] = 0;
    *(undefined4 *)PTR_DAT_0302ef34 = 0;
    puVar3[0x5d] = puVar3[0x5d] & 0xfe | 1;
    if ((puVar3[1] == '\0') && ((PTR_DAT_0302ef28[0x15] & 4) == 0)) {
      PTR_DAT_0302ef20[0xf] = PTR_DAT_0302ef20[0xf] & 0xdf | 0x20;
    }
    FUN_0302eca0(3);
    FUN_0301a768();
    FUN_03021c1c(0x18);
    return;
  }
  if (iVar7 != 3) {
    if (iVar7 == 4) {
      cVar1 = PTR_DAT_0302f238[0x12];
      PTR_DAT_0302f238[0x12] = cVar1 + 1U;
      if ((PTR_DAT_0302f23c[8] & 0xf0) == 0x10) {
        bVar5 = 100;
      }
      else {
        bVar5 = 0x1e;
      }
      if ((byte)(cVar1 + 1U) <= bVar5) {
        iVar7 = FUN_0302ed04();
        if (iVar7 == 0) {
          return;
        }
        PTR_DAT_0302f238[0x12] = 0;
        FUN_0302eca0(6);
        return;
      }
      PTR_DAT_0302f238[0x12] = 0;
      PTR_DAT_0302f240[3] = PTR_DAT_0302f240[3] & 0xbf;
      PTR_DAT_0302f234[0x10] = PTR_DAT_0302f234[0x10] & 0xfe | 1;
      FUN_0302eca0(3);
      return;
    }
    if (iVar7 != 6) {
      if (iVar7 != 2) {
        return;
      }
      if (*PTR_DAT_0302f3cc != 'M') {
        return;
      }
      FUN_0302eca0(6);
      return;
    }
    if ((PTR_DAT_0302f234[0xf] & 0x40) != 0) {
      if ((PTR_DAT_0302f234[2] & 0xf0) == 0x10) {
        FUN_0002b338(PTR_DAT_0302f244,PTR_DAT_0302f248,0x11);
      }
      puVar3 = PTR_DAT_0302f234;
      *(undefined2 *)(PTR_DAT_0302f234 + 0x56) = *(undefined2 *)(PTR_DAT_0302f234 + 0x54);
      FUN_0301a768();
      puVar3[0xf] = puVar3[0xf] & 0xbf;
    }
    iVar7 = FUN_0302ed04();
    if (iVar7 == 0) {
      sVar2 = *(short *)(PTR_DAT_0302f3b8 + 0x10);
      *(ushort *)(PTR_DAT_0302f3b8 + 0x10) = sVar2 + 1U;
      if ((ushort)(sVar2 + 1U) < (ushort)((ushort)(byte)PTR_DAT_0302f3bc[3] * 0x32)) {
        return;
      }
      *(undefined2 *)(PTR_DAT_0302f3b8 + 0x10) = 0;
      PTR_DAT_0302f3c8[3] = PTR_DAT_0302f3c8[3] & 0xbf;
      FUN_0302eca0(3);
      PTR_DAT_0302f3bc[0x10] = PTR_DAT_0302f3bc[0x10] & 0xfe | 1;
      if (*PTR_DAT_0302f3cc != '\0') {
        return;
      }
      FUN_0301a768();
      return;
    }
    if (((PTR_DAT_0302f230[0x2d] & 4) != 0) || ((PTR_DAT_0302f24c[0x15] & 4) != 0)) {
      *(undefined2 *)(PTR_DAT_0302f238 + 0x10) = 0;
      return;
    }
    if (*PTR_DAT_0302f250 != '\0') {
      if (*PTR_DAT_0302f250 == '\x01') {
        *(undefined2 *)(PTR_DAT_0302f3b8 + 0x10) = 0;
        return;
      }
      FUN_0302eca0(0);
      PTR_DAT_0302f3bc[0xe] = 0;
      FUN_0301a36c();
      FUN_030308f8(*(undefined4 *)PTR_DAT_0302f3c0,(byte)PTR_DAT_0302f3c4[0x2d] >> 7);
      return;
    }
    sVar2 = *(short *)(PTR_DAT_0302f238 + 0x10);
    *(ushort *)(PTR_DAT_0302f238 + 0x10) = sVar2 + 1U;
    if ((ushort)(sVar2 + 1U) < (ushort)((ushort)(byte)PTR_DAT_0302f234[3] * 0x32)) {
      return;
    }
    *(undefined2 *)(PTR_DAT_0302f238 + 0x10) = 0;
    FUN_0302eca0(3);
    PTR_DAT_0302f234[0x10] = PTR_DAT_0302f234[0x10] & 0xfe | 1;
    FUN_0301a768();
    return;
  }
  cVar1 = PTR_DAT_0302ef30[0x12];
  PTR_DAT_0302ef30[0x12] = cVar1 + 1U;
  if (((*PTR_DAT_0302ef1c & 0x20) != 0) && ((PTR_DAT_0302ef20[0x10] & 1) == 0)) {
    PTR_DAT_0302ef30[0x12] = 0;
    FUN_0302eca0(4);
    return;
  }
  if ((byte)(cVar1 + 1U) < 6) {
    return;
  }
  PTR_DAT_0302f09c[0x12] = 0;
  if (PTR_DAT_0302f0a0[0xc] != '\0') {
    FUN_0302eca0(6);
    return;
  }
  PTR_DAT_0302f0a4[3] = PTR_DAT_0302f0a4[3] & 0xbf;
  puVar4 = PTR_DAT_0302f234;
  puVar3 = PTR_DAT_0302f0ac;
  if (((PTR_DAT_0302f0a8[0x2d] & 4) == 0) && ((PTR_DAT_0302f0a0[0x15] & 4) == 0)) {
    PTR_DAT_0302f234[0xf] = PTR_DAT_0302f234[0xf] & 0xdf;
    FUN_0302ecf8(puVar4[0x5d] & 1);
    puVar4[0x10] = puVar4[0x10] & 0xfe;
    return;
  }
  if (((byte)PTR_DAT_0302f0ac[0x5c] < 2) && ((PTR_DAT_0302f0a0[0x15] & 4) == 0)) {
    return;
  }
  if ((PTR_DAT_0302f0a0[7] & 8) != 0) {
    return;
  }
  PTR_DAT_0302f0ac[0x10] = PTR_DAT_0302f0ac[0x10] & 0xfe | 1;
  bVar5 = puVar3[4];
  if ((bVar5 == 0) || ((PTR_DAT_0302f0a0[0x15] & 4) != 0)) {
    uVar6 = 0;
    PTR_DAT_0302f0ac[0xf] = PTR_DAT_0302f0ac[0xf] & 0xdf;
LAB_0302f02c:
    if ((PTR_DAT_0302f0ac[0xf] & 0x20) != 0) {
LAB_0302f03a:
      FUN_0302ece8(uVar6);
      if (PTR_DAT_0302f0ac[1] != '\0') {
        PTR_DAT_0302f0ac[0xf] = PTR_DAT_0302f0ac[0xf] & 0xdf;
      }
      goto LAB_0302f0ec;
    }
    if ((PTR_DAT_0302f0a0[0x15] & 4) != 0) {
      cVar1 = PTR_DAT_0302f0ac[0xe];
      PTR_DAT_0302f0ac[0xe] = cVar1 + 1U;
      if (10 < (byte)(cVar1 + 1U)) {
        PTR_DAT_0302f0ac[0xe] = 1;
      }
      bVar5 = PTR_DAT_0302f0ac[0xe];
      *(ushort *)(PTR_DAT_0302f0ac + 0x14) = (ushort)bVar5;
      puVar3 = PTR_DAT_0302f0a8;
      PTR_DAT_0302f0a8[0x26] = bVar5;
      if ((puVar3[0x2d] & 0x80) == 0) {
        PTR_DAT_0302f0a8[0x2a] = bVar5;
      }
      else {
        PTR_DAT_0302f230[0x2b] = bVar5;
      }
      FUN_03030560(2);
      goto LAB_0302f0ec;
    }
  }
  else if ((PTR_DAT_0302f0ac[0xf] & 0x20) != 0) {
    if ((bVar5 & 0xf0) == 0) {
      if ((bVar5 & 0xf) != 0) {
        uVar6 = *(undefined2 *)(PTR_DAT_0302f0ac + 8);
        goto LAB_0302f03a;
      }
    }
    else if ((bVar5 & 0xf) != 0) {
      if ((PTR_DAT_0302f0ac[0xf] & 0x10) == 0) {
        uVar6 = *(undefined2 *)(PTR_DAT_0302f0ac + 8);
        PTR_DAT_0302f0ac[0xf] = PTR_DAT_0302f0ac[0xf] & 0xef | 0x10;
      }
      else {
        uVar6 = *(undefined2 *)(PTR_DAT_0302f0ac + 10);
        PTR_DAT_0302f0ac[0xf] = PTR_DAT_0302f0ac[0xf] & 0xef;
      }
      goto LAB_0302f02c;
    }
    uVar6 = *(undefined2 *)(PTR_DAT_0302f0ac + 10);
    goto LAB_0302f03a;
  }
  puVar3 = PTR_DAT_0302f234;
  FUN_0302ece8(*(undefined2 *)(PTR_DAT_0302f234 + ((byte)PTR_DAT_0302f234[0xe] + 10) * 2 + 2));
  cVar1 = puVar3[0xe];
  puVar3[0xe] = cVar1 + 1U;
  if ((byte)puVar3[1] <= (byte)(cVar1 + 1U)) {
    puVar3[0xe] = 0;
  }
  PTR_DAT_0302f234[0xf] = PTR_DAT_0302f234[0xf] & 0xdf | 0x20;
LAB_0302f0ec:
  PTR_DAT_0302f234[0x10] = PTR_DAT_0302f234[0x10] & 0xfe;
  return;
}



/* Address: 0302f2f8 */

undefined4 FUN_0302f2f8(void)

{
  byte bVar1;
  undefined *puVar2;
  undefined4 uVar3;
  uint uVar4;
  
  puVar2 = PTR_DAT_0302f3bc;
  if (*(short *)(PTR_DAT_0302f3bc + 8) == *(short *)(PTR_DAT_0302f3bc + 0x54)) {
    uVar3 = 0;
  }
  else if (*(short *)(PTR_DAT_0302f3bc + 10) == *(short *)(PTR_DAT_0302f3bc + 0x54)) {
    uVar3 = 0;
  }
  else {
    bVar1 = PTR_DAT_0302f3bc[1];
    if (bVar1 < 3) {
      uVar3 = 0;
    }
    else {
      uVar4 = (uint)(byte)PTR_DAT_0302f3bc[0xe];
      if (uVar4 != 0) {
        for (; uVar4 < bVar1; uVar4 = uVar4 + 1 & 0xff) {
          *(undefined2 *)(puVar2 + (uVar4 + 9) * 2 + 2) =
               *(undefined2 *)(puVar2 + (uVar4 + 10) * 2 + 2);
        }
      }
      puVar2 = PTR_DAT_0302f3bc;
      PTR_DAT_0302f3bc[1] = bVar1 - 1;
      FUN_0302eca0(3);
      FUN_0301a768();
      uVar3 = 1;
      puVar2[0x10] = puVar2[0x10] & 0xfe | 1;
    }
  }
  return uVar3;
}



/* Address: 0302f370 */

void FUN_0302f370(void)

{
  FUN_0302eca0(2);
  FUN_03030560(3);
  PTR_DAT_0302f3bc[0xe] = 0;
  return;
}



/* Address: 0302f388 */

void FUN_0302f388(void)

{
  undefined *puVar1;
  int iVar2;
  
  iVar2 = FUN_0302ece0();
  puVar1 = PTR_DAT_0302f3bc;
  if (iVar2 != 0) {
    PTR_DAT_0302f3bc[0x11] = PTR_DAT_0302f3bc[0x11] & 0xfe | 1;
    FUN_0302f370(2);
    FUN_0302eca0(0);
    puVar1[0x11] = puVar1[0x11] & 0xfe;
  }
  return;
}



/* Address: 0302f3d0 */

bool FUN_0302f3d0(void)

{
  bool bVar1;
  byte bVar2;
  
  bVar2 = PTR_DAT_0302f550[9] & 0x3f;
  if ((bVar2 + 0x3f & 0x3f) < 0x20) {
    if ((PTR_DAT_0302f550[9] & 0x3f) == 0) {
      bVar1 = false;
    }
    else if ((byte)*PTR_DAT_0302f554 < bVar2) {
      bVar1 = false;
    }
    else if ((byte)PTR_DAT_0302f554[0x5c] < 2) {
      bVar1 = false;
    }
    else {
      bVar1 = (byte)PTR_DAT_0302f554[0x5c] < 0x11;
    }
  }
  else {
    bVar1 = false;
  }
  return bVar1;
}



/* Address: 0302f418 */

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



/* Address: 0302f780 */

void FUN_0302f780(void)

{
  undefined *puVar1;
  undefined1 uVar2;
  undefined1 local_1c;
  undefined1 uStack_1b;
  undefined1 uStack_1a;
  byte bStack_19;
  char cStack_18;
  undefined1 uStack_17;
  undefined1 uStack_16;
  byte bStack_15;
  char cStack_14;
  
  uVar2 = FUN_0300f594(0x11);
  FUN_0300f71c(uVar2,0xe00,&local_1c,9);
  *PTR_DAT_0302f908 = local_1c;
  puVar1 = PTR_DAT_0302f90c;
  FUN_0302e0e0(1,*(undefined4 *)(PTR_DAT_0302f90c + 8),&uStack_1b);
  FUN_0302e0e0(0,*(undefined4 *)(puVar1 + 0xc),&bStack_19);
  FUN_0302e0e0(1,*(undefined4 *)puVar1,&uStack_17);
  FUN_0302e0e0(0,*(undefined4 *)(puVar1 + 4),&bStack_15);
  puVar1 = PTR_DAT_0302f910;
  *PTR_DAT_0302f910 = bStack_19 << 4;
  puVar1[1] = bStack_19 >> 4 | cStack_18 << 4;
  puVar1[2] = uStack_1b;
  puVar1[3] = uStack_1a;
  FUN_0302f6a4(1);
  puVar1 = PTR_DAT_0302f914;
  *PTR_DAT_0302f914 = bStack_15 << 4;
  puVar1[1] = bStack_15 >> 4 | cStack_14 << 4;
  puVar1[2] = uStack_17;
  puVar1[3] = uStack_16;
  FUN_0302f6a4(0);
  FUN_0300f71c(uVar2,0xe10,&local_1c,1);
  puVar1 = PTR_DAT_0302f918;
  PTR_DAT_0302f918[0x5e] = local_1c;
  FUN_0300f780(0x11,0,puVar1,1);
  if (0x20 < (byte)*puVar1) {
    *puVar1 = 0x20;
  }
  puVar1 = PTR_DAT_0302f918;
  PTR_DAT_0302f918[0x10] = PTR_DAT_0302f918[0x10] & 0x7f;
  puVar1[3] = 6;
  return;
}



/* Address: 0304d07c */

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



/* Address: 0304d970 */

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



/* Address: 0304d9c4 */

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



/* Address: 0305680c */

void FUN_0305680c(uint param_1,uint param_2,uint param_3)

{
  byte bVar1;
  undefined *puVar2;
  undefined *puVar3;
  uint uVar4;
  uint uVar5;
  undefined2 local_3c;
  undefined1 auStack_3a [2];
  undefined4 local_38;
  undefined4 uStack_34;
  uint uStack_30;
  undefined4 uStack_2c;
  undefined1 uStack_28;
  
  puVar3 = PTR_DAT_03056998;
  puVar2 = PTR_DAT_03056994;
  param_2 = param_2 & 0xff;
  param_3 = param_3 & 0xff;
  local_38 = 0;
  uStack_34 = 0;
  uStack_30 = 0;
  uStack_2c = 0;
  uStack_28 = 0;
  if (param_3 != 0) {
    uVar4 = (param_2 - (param_1 & 0xff)) + 1 & 0xff;
    uVar5 = 0;
    do {
      if ((int)uVar4 < (int)(param_3 - 1)) {
        FUN_03055c90(uVar4 + 1 & 0xff,auStack_3a,&local_3c);
        FUN_0300f780(auStack_3a[0],local_3c,&local_38,0x10);
        if (uVar4 == param_2) {
          FUN_03018c70(uVar5 + 1,&local_38,1);
          FUN_0002b338(PTR_DAT_0305699c,&local_38,0x10);
        }
        else {
          FUN_03018c70(uVar5 + 1,&local_38,0);
        }
        *PTR_DAT_030569a0 = 2;
        FUN_03039e34(uVar5 + 1,uVar4);
      }
      else {
        if ((puVar2[0x30] & 0x40) == 0) {
          FUN_0002b338(&local_38,PTR_DAT_030569a4,8);
        }
        else {
          FUN_0002b338(&local_38,PTR_s_Add_Zone_030569a8,8);
        }
        uStack_30 = uStack_30 & 0xffffff00;
        bVar1 = puVar3[uVar5];
        if (uVar4 == param_2) {
          FUN_03018c70(uVar5 + 1,&local_38,1);
          FUN_0303900c(0xc,bVar1 + 4,0x11,0x11,PTR_DAT_030569ac);
        }
        else {
          FUN_03018c70(uVar5 + 1,&local_38,0);
          FUN_0303900c(0xc,bVar1 + 4,0x11,0x11,PTR_DAT_030569b0);
        }
      }
      uVar4 = uVar4 + 1 & 0xff;
      if ((param_3 <= uVar4) || (uVar5 == 7)) {
        if ((PTR_DAT_03056994[0x30] & 0x40) == 0) {
          FUN_030704c4(&local_38,PTR_DAT_030569b4,param_2 + 1,param_3);
        }
        else {
          FUN_030704c4(&local_38,PTR_s_Zone_List__d__d_030569b8,param_2 + 1,param_3);
        }
        FUN_03019ac0(0,0);
        FUN_03018af4(1,0xffff,0,&local_38);
        return;
      }
      uVar5 = uVar5 + 1;
    } while ((uVar5 & 0xff) < param_3);
  }
  return;
}



/* Address: 0307050c */

undefined4 * FUN_0307050c(int param_1,undefined4 param_2,undefined4 param_3,undefined *param_4)

{
  undefined4 *puVar1;
  undefined4 *puVar2;
  undefined *puVar3;
  undefined4 *puVar4;
  undefined *puVar5;
  undefined4 *puVar6;
  undefined4 *unaff_r6;
  
  FUN_03070e44(PTR_DAT_03070598);
  puVar5 = PTR_DAT_030705a0;
  puVar3 = PTR_DAT_0307059c;
  if (*(int *)PTR_DAT_0307059c == 0) {
    *(undefined **)(PTR_DAT_0307059c + 4) = PTR_DAT_030705a0;
    *(undefined4 *)puVar5 = 0;
    param_4 = PTR_DAT_030705a4 + (-8 - (int)puVar5);
    *(undefined **)(puVar5 + 4) = param_4;
    *(undefined4 *)puVar3 = 1;
  }
  puVar5 = (undefined *)(param_1 + 7U & 0xfffffff8);
  puVar1 = (undefined4 *)0x0;
  puVar4 = *(undefined4 **)(puVar3 + 4);
  puVar6 = (undefined4 *)(puVar3 + 4);
  while (puVar2 = puVar4, puVar2 != (undefined4 *)0x0) {
    puVar3 = (undefined *)puVar2[1];
    if ((puVar5 <= puVar3) && ((puVar1 == (undefined4 *)0x0 || (puVar3 < param_4)))) {
      puVar1 = puVar2;
      param_4 = puVar3;
      unaff_r6 = puVar6;
    }
    puVar6 = puVar2;
    puVar4 = (undefined4 *)*puVar2;
  }
  if (puVar1 != (undefined4 *)0x0) {
    if (puVar1[1] - (int)puVar5 < 0xf) {
      *unaff_r6 = *puVar1;
    }
    else {
      puVar4 = (undefined4 *)((int)puVar1 + (int)(puVar5 + 8));
      *puVar4 = *puVar1;
      puVar4[1] = (puVar1[1] + -8) - (int)puVar5;
      *unaff_r6 = puVar4;
      puVar1[1] = puVar5;
    }
    puVar1 = puVar1 + 2;
  }
  FUN_03070e48(PTR_DAT_03070598);
  return puVar1;
}



/* Address: 030705a8 */

void FUN_030705a8(int param_1)

{
  undefined4 *puVar1;
  undefined4 *puVar2;
  undefined4 *puVar3;
  undefined4 *puVar4;
  undefined4 *puVar5;
  
  FUN_03070e44(PTR_DAT_03070618);
  if (param_1 != 0) {
    puVar2 = (undefined4 *)(param_1 + -8);
    puVar1 = (undefined4 *)(param_1 + *(int *)(param_1 + -4));
    puVar3 = *(undefined4 **)PTR_DAT_0307061c;
    puVar5 = (undefined4 *)PTR_DAT_0307061c;
    while( true ) {
      puVar4 = puVar3;
      if (puVar1 == puVar3) {
        *(int *)(param_1 + -4) = *(int *)(param_1 + -4) + puVar1[1] + 8;
        puVar4 = (undefined4 *)*puVar1;
      }
      if (puVar4 == (undefined4 *)0x0) {
        puVar3 = (undefined4 *)0x0;
      }
      else {
        puVar3 = (undefined4 *)(puVar4[1] + 8 + (int)puVar4);
      }
      if (puVar3 == puVar2) {
        puVar4[1] = puVar4[1] + puVar3[1] + 8;
        puVar3[1] = 0;
        *puVar3 = puVar4;
        *puVar5 = puVar4;
        goto LAB_0307060c;
      }
      if (puVar3 < puVar2) break;
      puVar3 = (undefined4 *)*puVar4;
      puVar5 = puVar4;
    }
    *puVar5 = puVar2;
    *puVar2 = puVar4;
  }
LAB_0307060c:
  FUN_03070e48(PTR_DAT_03070618);
  return;
}



/* Address: 0002e174 */

void FUN_0002e174(void)

{
  undefined *puVar1;
  undefined1 auStack_10 [4];
  
  FUN_0002bb9c();
  FUN_0002c9b8();
  FUN_0306d670();
  FUN_00010d5c(auStack_10);
  puVar1 = PTR_DAT_0002e1cc;
  FUN_0002b350(PTR_DAT_0002e1cc,0,0xb40);
  FUN_00012dd8(PTR_DAT_0002e1d0,PTR_s_task_init_0002e1d4,PTR_LAB_0002e1d8,0,0x1e,puVar1,0,0x2d0,0,0,
               0,3,auStack_10);
  FUN_00010a04(auStack_10);
  return;
}



/* Address: 0001064a */

undefined4 FUN_0001064a(void)

{
  undefined4 *puVar1;
  uint uVar2;
  undefined4 uVar3;
  undefined4 *puVar4;
  undefined4 local_44 [14];
  
  puVar4 = local_44;
  for (puVar1 = (undefined4 *)0x0; puVar1 < (undefined4 *)0x35; puVar1 = puVar1 + 1) {
    *puVar4 = *puVar1;
    puVar4 = puVar4 + 1;
  }
  *(undefined4 **)PTR_DAT_000106b4 = local_44;
  FUN_00010894();
  puVar4 = DAT_000106c4;
  *DAT_000106c4 = 4;
  uVar2 = (int)(char)((uint)puVar4 >> 0x10) - 0x20;
  (*(code *)(*(uint *)(PTR_DAT_000106c8 + uVar2 * 4) & 0xfffffffe))(uVar2 & 0x3fffffff);
  FUN_000108b0();
  puVar4 = *(undefined4 **)PTR_DAT_000106b4;
  *(undefined4 *)PTR_DAT_000106b4 = 0;
  uVar3 = puVar4[0xf];
  for (puVar1 = (undefined4 *)0x0; puVar1 < (undefined4 *)0x35; puVar1 = puVar1 + 1) {
    *puVar1 = *puVar4;
    puVar4 = puVar4 + 1;
  }
  return uVar3;
}



/* Address: 0303b6ac */

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



/* Address: 03038500 */

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


