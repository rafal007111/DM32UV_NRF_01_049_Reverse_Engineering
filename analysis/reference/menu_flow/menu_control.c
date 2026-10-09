
/* Address: 03038500; expanded instructions=822 */

void FUN_03038500(void)

{
  char cVar1;
  uint uVar2;
  undefined4 *puVar3;
  undefined4 local_1c;
  undefined4 uStack_18;
  undefined4 uStack_14;
  undefined4 uStack_10;
  undefined1 uStack_c;
  
  local_1c = 0;
  uStack_18 = 0;
  uStack_14 = 0;
  uStack_10 = 0;
  uStack_c = 0;
  if ((*PTR_DAT_0303855c & 2) != 0) {
    return;
  }
  FUN_03017be8(0,0,0xf0,0x1b,0);
  uVar2 = (byte)PTR_DAT_03038550[3] - 7 & 0xff;
  puVar3 = (undefined4 *)PTR_DAT_03038e30;
  if (uVar2 < 0x32) {
                    /* WARNING: Switch is manually overridden */
    switch(*(uint *)(PTR_switchdataD_030b0c8c_03038560 + uVar2 * 4) & 0xfffffffe) {
    case 0x3038564:
      puVar3 = (undefined4 *)
               **(undefined4 **)(PTR_PTR_030385b8 + ((byte)PTR_DAT_030385b4[0x30] >> 6 & 1) * 8);
      break;
    case 0x303857a:
      puVar3 = *(undefined4 **)
                (*(int *)(PTR_PTR_030385c4 + ((byte)PTR_DAT_030385b4[0x30] >> 6 & 1) * 8) +
                (uint)(byte)PTR_DAT_030385c0[(byte)PTR_DAT_030385bc[1] + 2] * 4);
      break;
    case 0x303859c:
      puVar3 = (undefined4 *)PTR_DAT_0303875c;
      if ((byte)PTR_DAT_030385c0[(byte)PTR_DAT_030385bc[1] + 2] < 10) {
                    /* WARNING: Switch is manually overridden */
        switch(*(uint *)(PTR_switchdataD_030b0d54_030385c8 +
                        (uint)(byte)PTR_DAT_030385c0[(byte)PTR_DAT_030385bc[1] + 2] * 4) &
               0xfffffffe) {
        case 0x30385d2:
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_0303876c + ((byte)PTR_DAT_03038760[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038768[(byte)PTR_DAT_03038764[2] + 2] * 4);
          break;
        case 0x30385f4:
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038770 + ((byte)PTR_DAT_03038760[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038768[(byte)PTR_DAT_03038764[2] + 2] * 4);
          break;
        case 0x3038616:
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038774 + ((byte)PTR_DAT_03038760[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038768[(byte)PTR_DAT_03038764[2] + 2] * 4);
          break;
        case 0x3038638:
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038778 + ((byte)PTR_DAT_03038760[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038768[(byte)PTR_DAT_03038764[2] + 2] * 4);
          break;
        case 0x303865a:
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_0303877c + ((byte)PTR_DAT_03038760[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038768[(byte)PTR_DAT_03038764[2] + 2] * 4);
          break;
        case 0x303867c:
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038780 + ((byte)PTR_DAT_03038760[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038768[(byte)PTR_DAT_03038764[2] + 2] * 4);
          break;
        case 0x303869e:
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038784 + ((byte)PTR_DAT_03038760[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038768[(byte)PTR_DAT_03038764[2] + 2] * 4);
          break;
        case 0x30386c0:
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038788 + ((byte)PTR_DAT_03038760[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038768[(byte)PTR_DAT_03038764[2] + 2] * 4);
          break;
        case 0x30386e2:
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_0303878c + ((byte)PTR_DAT_03038760[0x30] >> 6 & 1) * 8) + 0x24
                    );
          break;
        case 0x3038dfc:
          puVar3 = (undefined4 *)PTR_DAT_03038e58;
        }
      }
      break;
    case 0x30386f8:
      cVar1 = PTR_DAT_03038790[(byte)PTR_DAT_03038764[1] + 2];
      if (cVar1 == '\x05') {
        cVar1 = PTR_DAT_03038768[(byte)PTR_DAT_03038764[2] + 2];
        if (cVar1 == '\0') {
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038798 + ((byte)PTR_DAT_03038760[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038794[(byte)PTR_DAT_03038764[3] + 2] * 4);
        }
        else if (cVar1 == '\x01') {
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_0303879c + ((byte)PTR_DAT_03038760[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038794[(byte)PTR_DAT_03038764[3] + 2] * 4);
        }
        else if (cVar1 == '\x03') {
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_0303893c + ((byte)PTR_DAT_03038930[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038938[(byte)PTR_DAT_03038934[3] + 2] * 4);
        }
        else if (cVar1 == '\x04') {
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038940 + ((byte)PTR_DAT_03038930[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038938[(byte)PTR_DAT_03038934[3] + 2] * 4);
        }
        else if (cVar1 == '\x05') {
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038944 + ((byte)PTR_DAT_03038930[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038938[(byte)PTR_DAT_03038934[3] + 2] * 4);
        }
        else if (cVar1 == '\x06') {
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038948 + ((byte)PTR_DAT_03038930[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038938[(byte)PTR_DAT_03038934[3] + 2] * 4);
        }
      }
      else if (cVar1 == '\0') {
        cVar1 = PTR_DAT_0303894c[(byte)PTR_DAT_03038934[2] + 2];
        puVar3 = (undefined4 *)PTR_DAT_03038e58;
        if (((cVar1 != '\0') && (puVar3 = (undefined4 *)PTR_DAT_03038e5c, cVar1 != '\x02')) &&
           (puVar3 = (undefined4 *)PTR_DAT_03038e30, cVar1 == '\x04')) {
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038950 + ((byte)PTR_DAT_03038930[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038938[(byte)PTR_DAT_03038934[3] + 2] * 4);
        }
      }
      else if (cVar1 == '\x01') {
        puVar3 = (undefined4 *)PTR_DAT_03038958;
        if (PTR_DAT_0303894c[(byte)PTR_DAT_03038934[2] + 2] == '\x01') {
          puVar3 = (undefined4 *)PTR_DAT_03038954;
        }
      }
      else if (cVar1 == '\x03') {
        puVar3 = (undefined4 *)
                 **(undefined4 **)(PTR_PTR_0303895c + ((byte)PTR_DAT_03038930[0x30] >> 6 & 1) * 4);
      }
      else {
        puVar3 = (undefined4 *)PTR_DAT_03038e60;
        if (cVar1 != '\x04') {
          if (cVar1 == '\x06') {
            puVar3 = *(undefined4 **)
                      (*(int *)(PTR_PTR_03038960 + ((byte)PTR_DAT_03038930[0x30] >> 6 & 1) * 8) +
                      0x18);
          }
          else if (cVar1 == '\a') {
            puVar3 = (undefined4 *)PTR_DAT_03038e58;
            if ((PTR_DAT_0303894c[(byte)PTR_DAT_03038934[2] + 2] != '\x01') &&
               (puVar3 = (undefined4 *)PTR_DAT_03038e30,
               PTR_DAT_0303894c[(byte)PTR_DAT_03038934[2] + 2] == '\x02')) {
              puVar3 = *(undefined4 **)
                        (*(int *)(PTR_PTR_03038964 + ((byte)PTR_DAT_03038930[0x30] >> 6 & 1) * 8) +
                        8);
            }
          }
          else {
            puVar3 = (undefined4 *)PTR_DAT_03038e30;
            if ((cVar1 == '\b') && (PTR_DAT_0303894c[(byte)PTR_DAT_03038934[2] + 2] == '\x01')) {
              puVar3 = (undefined4 *)
                       **(undefined4 **)
                         (PTR_PTR_03038968 + ((byte)PTR_DAT_03038930[0x30] >> 6 & 1) * 4);
            }
          }
        }
      }
      break;
    case 0x303896c:
      cVar1 = PTR_DAT_03038aec[(byte)PTR_DAT_03038ae8[1] + 2];
      if (cVar1 == '\x03') {
        puVar3 = *(undefined4 **)
                  (*(int *)(PTR_PTR_03038af8 + ((byte)PTR_DAT_03038af0[0x30] >> 6 & 1) * 8) +
                  (uint)(byte)PTR_DAT_03038af4[(byte)PTR_DAT_03038ae8[2] + 2] * 4);
      }
      else if (cVar1 == '\x05') {
        if (PTR_DAT_03038af4[(byte)PTR_DAT_03038ae8[2] + 2] == '\0') {
          cVar1 = PTR_DAT_03038afc[(byte)PTR_DAT_03038ae8[3] + 2];
          if (cVar1 == '\0') {
            puVar3 = *(undefined4 **)
                      (*(int *)(PTR_PTR_03038b04 + ((byte)PTR_DAT_03038af0[0x30] >> 6 & 1) * 8) +
                      (uint)(byte)PTR_DAT_03038b00[(byte)PTR_DAT_03038ae8[4] + 2] * 4);
          }
          else if (cVar1 == '\x01') {
            puVar3 = *(undefined4 **)
                      (*(int *)(PTR_PTR_03038b08 + ((byte)PTR_DAT_03038af0[0x30] >> 6 & 1) * 8) +
                      (uint)(byte)PTR_DAT_03038b00[(byte)PTR_DAT_03038ae8[4] + 2] * 4);
          }
          else if (cVar1 == '\x02') {
            puVar3 = *(undefined4 **)
                      (*(int *)(PTR_PTR_03038b0c + ((byte)PTR_DAT_03038af0[0x30] >> 6 & 1) * 8) +
                      (uint)(byte)PTR_DAT_03038b00[(byte)PTR_DAT_03038ae8[4] + 2] * 4);
          }
          else {
            puVar3 = (undefined4 *)PTR_DAT_03038ff0;
            if (cVar1 == '\x03') {
              puVar3 = *(undefined4 **)
                        (*(int *)(PTR_PTR_03038b10 + ((byte)PTR_DAT_03038af0[0x30] >> 6 & 1) * 8) +
                        (uint)(byte)PTR_DAT_03038b00[(byte)PTR_DAT_03038ae8[4] + 2] * 4);
            }
          }
        }
        else {
          puVar3 = (undefined4 *)PTR_DAT_03038ff0;
          if (PTR_DAT_03038af4[(byte)PTR_DAT_03038ae8[2] + 2] == '\x01') {
            cVar1 = PTR_DAT_03038afc[(byte)PTR_DAT_03038ae8[3] + 2];
            if (cVar1 == '\x03') {
              puVar3 = *(undefined4 **)
                        (*(int *)(PTR_PTR_03038b14 + ((byte)PTR_DAT_03038af0[0x30] >> 6 & 1) * 8) +
                        (uint)(byte)PTR_DAT_03038b00[(byte)PTR_DAT_03038ae8[4] + 2] * 4);
            }
            else {
              puVar3 = (undefined4 *)PTR_DAT_03038ff4;
              if (((cVar1 != '\a') && (puVar3 = (undefined4 *)PTR_DAT_03038ff8, cVar1 != '\f')) &&
                 (puVar3 = (undefined4 *)PTR_DAT_03038ff0, cVar1 == '\x0f')) {
                puVar3 = *(undefined4 **)
                          (*(int *)(PTR_PTR_03038b18 + ((byte)PTR_DAT_03038af0[0x30] >> 6 & 1) * 8)
                          + (uint)(byte)PTR_DAT_03038b00[(byte)PTR_DAT_03038ae8[4] + 2] * 4);
              }
            }
          }
        }
      }
      else if (cVar1 == '\0') {
        cVar1 = PTR_DAT_03038af4[(byte)PTR_DAT_03038ae8[2] + 2];
        if (cVar1 == '\0') {
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038b1c + ((byte)PTR_DAT_03038af0[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038b00[(byte)PTR_DAT_03038ae8[4] + 2] * 4);
        }
        else if (cVar1 == '\x03') {
          FUN_0002b338(&local_1c,PTR_DAT_03038c90,0x10);
          puVar3 = &local_1c;
        }
        else {
          puVar3 = (undefined4 *)PTR_DAT_03038ff0;
          if ((cVar1 == '\x04') &&
             (puVar3 = (undefined4 *)PTR_DAT_03038ff0,
             PTR_DAT_03038c98[(byte)PTR_DAT_03038c94[3] + 2] == '\0')) {
            puVar3 = *(undefined4 **)
                      (*(int *)(PTR_PTR_03038ca4 + ((byte)PTR_DAT_03038c9c[0x30] >> 6 & 1) * 8) +
                      (uint)(byte)PTR_DAT_03038ca0[(byte)PTR_DAT_03038c94[4] + 2] * 4);
          }
        }
      }
      else {
        puVar3 = (undefined4 *)PTR_DAT_03038cac;
        if (cVar1 == '\x02') {
          puVar3 = (undefined4 *)PTR_DAT_03038ca8;
        }
      }
      break;
    case 0x3038b76:
      cVar1 = PTR_DAT_03038cb0[(byte)PTR_DAT_03038c94[1] + 2];
      if (cVar1 == '\x03') {
        puVar3 = *(undefined4 **)
                  (*(int *)(PTR_PTR_03038cb8 + ((byte)PTR_DAT_03038c9c[0x30] >> 6 & 1) * 8) +
                  (uint)(byte)PTR_DAT_03038cb4[(byte)PTR_DAT_03038c94[2] + 2] * 4);
      }
      else if (cVar1 == '\x05') {
        cVar1 = PTR_DAT_03038c98[(byte)PTR_DAT_03038c94[3] + 2];
        if (cVar1 == '\x01') {
          puVar3 = (undefined4 *)
                   **(undefined4 **)(PTR_PTR_03038cbc + ((byte)PTR_DAT_03038c9c[0x30] >> 6 & 1) * 8)
          ;
        }
        else if (cVar1 == '\x02') {
          puVar3 = (undefined4 *)PTR_DAT_03038ff0;
          if (PTR_DAT_03038ca0[(byte)PTR_DAT_03038c94[4] + 2] == '\x11') {
            puVar3 = *(undefined4 **)
                      (*(int *)(PTR_PTR_03038cc4 + ((byte)PTR_DAT_03038c9c[0x30] >> 6 & 1) * 8) +
                      (uint)(byte)PTR_DAT_03038cc0[(byte)PTR_DAT_03038c94[5] + 2] * 4);
          }
        }
        else {
          puVar3 = (undefined4 *)PTR_DAT_03038ff0;
          if ((cVar1 == '\x03') &&
             (puVar3 = (undefined4 *)PTR_DAT_03038ff0,
             PTR_DAT_03038ca0[(byte)PTR_DAT_03038c94[4] + 2] == '\x03')) {
            puVar3 = *(undefined4 **)
                      (*(int *)(PTR_PTR_03038cc8 + ((byte)PTR_DAT_03038c9c[0x30] >> 6 & 1) * 8) +
                      (uint)(byte)PTR_DAT_03038cc0[(byte)PTR_DAT_03038c94[5] + 2] * 4);
          }
        }
      }
      else if (cVar1 == '\0') {
        if (PTR_DAT_03038cb4[(byte)PTR_DAT_03038c94[2] + 2] == '\0') {
          puVar3 = (undefined4 *)
                   **(undefined4 **)(PTR_PTR_03038ccc + ((byte)PTR_DAT_03038c9c[0x30] >> 6 & 1) * 4)
          ;
        }
        else {
          puVar3 = (undefined4 *)PTR_DAT_03038ff0;
          if (PTR_DAT_03038cb4[(byte)PTR_DAT_03038c94[2] + 2] == '\x03') {
            FUN_0002b338(&local_1c,PTR_DAT_03038c90,0x10);
            puVar3 = &local_1c;
          }
        }
      }
      else if (cVar1 == '\x01') {
        puVar3 = (undefined4 *)PTR_DAT_03038ff0;
        if (PTR_DAT_03038cb4[(byte)PTR_DAT_03038c94[2] + 2] == '\x01') {
          puVar3 = (undefined4 *)
                   **(undefined4 **)(PTR_PTR_03038cd0 + ((byte)PTR_DAT_03038c9c[0x30] >> 6 & 1) * 4)
          ;
        }
      }
      else if (cVar1 == '\x04') {
        puVar3 = (undefined4 *)
                 **(undefined4 **)(PTR_PTR_03038e28 + ((byte)PTR_DAT_03038e24[0x30] >> 6 & 1) * 4);
      }
      else if (cVar1 == '\a') {
        puVar3 = (undefined4 *)PTR_DAT_03038e2c;
      }
      break;
    case 0x3038cfc:
      cVar1 = PTR_DAT_03038e38[(byte)PTR_DAT_03038e34[1] + 2];
      if (cVar1 == '\x03') {
        if ((PTR_DAT_03038e3c[6] & 0x10) == 0) {
          puVar3 = *(undefined4 **)
                    (*(int *)(PTR_PTR_03038e44 + ((byte)PTR_DAT_03038e24[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03038e40[(byte)PTR_DAT_03038e34[2] + 2] * 4);
        }
        else {
          FUN_03018af4(1,0xffff,0,
                       **(undefined4 **)
                         (PTR_PTR_03038e28 + ((byte)PTR_DAT_03038e24[0x30] >> 6 & 1) * 4));
          puVar3 = (undefined4 *)PTR_DAT_03038e30;
        }
      }
      else if (cVar1 == '\x01') {
        puVar3 = (undefined4 *)
                 **(undefined4 **)(PTR_PTR_03038e48 + ((byte)PTR_DAT_03038e24[0x30] >> 6 & 1) * 8);
      }
      else if (cVar1 == '\x05') {
        puVar3 = (undefined4 *)PTR_DAT_03038ff0;
        if (PTR_DAT_03038e4c[(byte)PTR_DAT_03038e34[3] + 2] == '\f') {
          puVar3 = (undefined4 *)
                   **(undefined4 **)(PTR_PTR_03038e50 + ((byte)PTR_DAT_03038e24[0x30] >> 6 & 1) * 4)
          ;
        }
      }
      else {
        puVar3 = (undefined4 *)PTR_DAT_03038ff0;
        if ((cVar1 == '\0') &&
           (puVar3 = (undefined4 *)PTR_DAT_03038ff0,
           PTR_DAT_03038e40[(byte)PTR_DAT_03038e34[2] + 2] == '\x03')) {
          FUN_0002b338(&local_1c,PTR_DAT_03038e54,0x10);
          puVar3 = &local_1c;
        }
      }
      break;
    case 0x3038dba:
      puVar3 = (undefined4 *)PTR_DAT_03038ff0;
      if ((PTR_DAT_03038e38[(byte)PTR_DAT_03038e34[1] + 2] == '\x03') &&
         (puVar3 = (undefined4 *)PTR_DAT_03038ff0, (PTR_DAT_03038e3c[6] & 0x10) != 0)) {
        FUN_03018af4(1,0xffff,0,
                     **(undefined4 **)
                       (PTR_PTR_03038e28 + ((byte)PTR_DAT_03038e24[0x30] >> 6 & 1) * 4));
        puVar3 = (undefined4 *)PTR_DAT_03038e30;
      }
      break;
    case 0x3038df8:
      goto switchD_03038548_caseD_1;
    }
  }
  else {
switchD_03038548_caseD_1:
  }
  FUN_03018af4(1,0xffff,0,puVar3);
  return;
}



/* Address: 0303b6ac; expanded instructions=1484 */

void FUN_0303b6ac(void)

{
  bool bVar1;
  byte bVar2;
  char cVar3;
  undefined2 uVar4;
  undefined2 uVar5;
  ushort uVar6;
  bool bVar7;
  undefined *puVar8;
  undefined *puVar9;
  char cVar10;
  byte bVar11;
  short sVar12;
  int iVar13;
  undefined4 uVar14;
  uint uVar15;
  undefined4 uVar16;
  undefined4 uVar17;
  undefined1 auStack_28 [2];
  undefined1 auStack_26 [22];
  undefined1 auStack_10 [4];
  
  bVar11 = PTR_DAT_0303b6f4[2];
  if ((bVar11 == 1) && ((*PTR_DAT_0303b6f8 & 2) == 0)) {
    FUN_0303b374();
    return;
  }
  if (8 < (byte)*PTR_DAT_0303b6fc) {
    *PTR_DAT_0303b6fc = 8;
  }
  if ((byte)*PTR_DAT_0303b700 < 0x35) {
                    /* WARNING: Switch is manually overridden */
    switch(*(uint *)(PTR_switchdataD_030b0d7c_0303b704 + (uint)(byte)*PTR_DAT_0303b700 * 4) &
           0xfffffffe) {
    case 0x303b708:
      FUN_03038500();
      uVar6 = *(ushort *)PTR_DAT_0303b890;
      if (uVar6 < 9) {
        *PTR_DAT_0303b894 = (char)uVar6;
      }
      else {
        *PTR_DAT_0303b894 = 8;
      }
      if (uVar6 == 0) {
        FUN_03036bb0();
        *(ushort *)PTR_DAT_0303b890 = (ushort)(byte)*PTR_DAT_0303b898;
        PTR_DAT_0303b89c[4] = 0;
        return;
      }
      if (*(int *)PTR_DAT_0303b8a0 == 0) {
        FUN_03017eec(0);
        return;
      }
      if (*PTR_DAT_0303b8a4 == '\x02') {
        FUN_03017eec(0);
        FUN_030415dc();
LAB_0303b770:
        if (*PTR_DAT_0303b8a4 == '\x13') {
          FUN_03017be8(0,0x122,0xf0,0x140,0);
          iVar13 = FUN_0002ded4();
          if ((iVar13 == 1) || (iVar13 = FUN_0002ded4(), iVar13 == 3)) {
            FUN_03018930(0x122,0xc,
                         **(undefined4 **)
                           (PTR_PTR_0303b8ac + ((byte)PTR_DAT_0303b8a8[0x30] >> 6 & 1) * 8),0xffff,0
                        );
          }
          bVar1 = false;
          FUN_03018930(0x122,0xb4,
                       **(undefined4 **)
                         (PTR_PTR_0303b8b0 + ((byte)PTR_DAT_0303b8a8[0x30] >> 6 & 1) * 8),0xffff,0);
          break;
        }
      }
      else if (*PTR_DAT_0303b8a4 == '\x13') {
        FUN_03017eec(0);
        FUN_0301200c();
        goto LAB_0303b770;
      }
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303b7f0:
      bVar11 = *PTR_DAT_0303b8b4;
      *(ushort *)PTR_DAT_0303b890 = (ushort)bVar11;
      if (bVar11 == 0) {
        FUN_03036bb0();
        *(ushort *)PTR_DAT_0303b890 = (ushort)(byte)*PTR_DAT_0303b898;
        PTR_DAT_0303b89c[4] = 0;
        return;
      }
      FUN_03019b9c();
      FUN_03052cd4(*PTR_DAT_0303b8b8);
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303b82a:
      bVar11 = *PTR_DAT_0303b8b4;
      *(ushort *)PTR_DAT_0303b890 = (ushort)bVar11;
      if (bVar11 < 9) {
        *PTR_DAT_0303b894 = bVar11;
      }
      else {
        *PTR_DAT_0303b894 = 8;
      }
      if (bVar11 != 0) {
        FUN_03017eec(0);
      }
      FUN_03052c04(*PTR_DAT_0303b8b8);
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303b860:
      FUN_03017be8(0x14,0x5a,0xdc,0xaa,0x7e0);
      FUN_03048f50();
      bVar1 = (byte)(*PTR_DAT_0303b8bc - 1) < 2;
      FUN_03019bd4();
      break;
    case 0x303b8c0:
      bVar11 = *PTR_DAT_0303ba60;
      *(ushort *)PTR_DAT_0303ba64 = (ushort)bVar11;
      if (bVar11 != 0) {
        FUN_03047108();
      }
      bVar1 = false;
      FUN_03017be8(0,0x122,0xf0,0x140,0);
      FUN_03019c60(0);
      break;
    case 0x303b8ee:
      if ((*(uint *)PTR_DAT_0303ba68 & 0x18000) == 0x8000) {
        if ((PTR_DAT_0303ba6c[0x2d] & 0x80) == 0) {
          iVar13 = 0xb1;
        }
        else {
          iVar13 = 0x3b;
        }
        if (PTR_DAT_0303ba6c[0x6c] == '\0') {
          iVar13 = 0x59;
        }
        uVar15 = iVar13 + 0x2dU & 0xff;
        bVar1 = false;
        FUN_03017be8(10,uVar15,0xe3,uVar15 + 0x1b,0);
      }
      else if ((PTR_DAT_0303ba70[6] & 0xc) == 0) {
        FUN_03019b9c();
        bVar1 = true;
      }
      else {
        if ((PTR_DAT_0303ba6c[0x2d] & 0x80) == 0) {
          sVar12 = 0x3b;
        }
        else {
          sVar12 = 0xb1;
        }
        if (PTR_DAT_0303ba6c[0x6c] == '\0') {
          bVar1 = false;
          FUN_03017be8(8,0x59,0xeb,0x74,0);
        }
        else {
          bVar1 = false;
          FUN_03017be8(8,sVar12 + -5,0xeb,sVar12 + 0x23,0);
        }
      }
      FUN_0305953c();
      bVar11 = PTR_DAT_0303ba70[4];
      if ((bVar11 & 0x10) == 0) {
        if ((bVar11 & 0x60) != 0) {
          uVar15 = ((byte)PTR_DAT_0303ba70[4] & 0x7f) >> 5;
          if (uVar15 < 3) {
            FUN_03018af4(1,0xffff,0,
                         *(undefined4 *)
                          (*(int *)(PTR_PTR_0303ba78 + ((byte)PTR_DAT_0303ba6c[0x30] >> 6 & 1) * 8)
                          + (uVar15 - 1) * 4));
            bVar7 = true;
          }
          else {
            FUN_03018af4(1,0xffff,0,
                         *(undefined4 *)
                          (*(int *)(PTR_PTR_0303ba74 + ((byte)PTR_DAT_0303ba6c[0x30] >> 6 & 1) * 8)
                          + 0x50));
            bVar7 = true;
          }
          goto LAB_0303bbd4;
        }
        if ((bVar11 & 0x80) != 0) {
          FUN_03018af4(1,0xffff,0,
                       *(undefined4 *)
                        (*(int *)(PTR_PTR_0303ba74 + ((byte)PTR_DAT_0303ba6c[0x30] >> 6 & 1) * 8) +
                        0x1c));
          bVar7 = true;
          goto LAB_0303bbd4;
        }
        bVar11 = PTR_DAT_0303bbf8[5];
        if ((bVar11 & 4) != 0) {
          FUN_03018af4(1,0xffff,0,
                       *(undefined4 *)
                        (*(int *)(PTR_PTR_0303bc00 + ((byte)PTR_DAT_0303bbfc[0x30] >> 6 & 1) * 4) +
                        ((byte)PTR_DAT_0303bbf8[3] >> 2 & 1) * 4));
          bVar7 = true;
          goto LAB_0303bbd4;
        }
        if ((bVar11 & 0x10) != 0) {
          FUN_03018af4(1,0xffff,0,
                       *(undefined4 *)
                        (*(int *)(PTR_PTR_0303bc04 + ((byte)PTR_DAT_0303bbfc[0x30] >> 6 & 1) * 8) +
                        8));
          bVar7 = true;
          goto LAB_0303bbd4;
        }
        bVar2 = PTR_DAT_0303bbf8[6];
        if ((bVar2 & 4) == 0) {
          if ((bVar2 & 8) == 0) {
            if ((bVar2 & 0x40) == 0) {
              if ((bVar11 & 0x80) == 0) {
                if ((bVar11 & 0x40) == 0) goto LAB_0303c820;
                if (PTR_DAT_0303bc14[(byte)PTR_DAT_0303bc10[1] + 2] == '\0') {
                  bVar7 = false;
                  FUN_03017be8(0,0x122,0xf0,0x140,0);
                  FUN_03019c98(0);
                  if ((PTR_DAT_0303bbf8[3] & 4) == 0) {
                    FUN_03019cc4(0);
                  }
                  else {
                    bVar7 = false;
                  }
                }
                else {
                  bVar7 = true;
                }
                FUN_03018af4(1,0xffff,0,
                             *(undefined4 *)
                              (*(int *)(PTR_PTR_0303bc00 +
                                       ((byte)PTR_DAT_0303bbfc[0x30] >> 6 & 1) * 4) +
                              ((byte)PTR_DAT_0303bbf8[3] >> 2 & 1) * 4));
                FUN_03059c90(1);
              }
              else {
                FUN_03018af4(1,0xffff,0,
                             *(undefined4 *)
                              (*(int *)(PTR_PTR_0303bc0c +
                                       ((byte)PTR_DAT_0303bbfc[0x30] >> 6 & 1) * 8) + 4));
                FUN_03059c90(1);
                bVar7 = true;
              }
            }
            else {
              FUN_03018af4(1,0xffff,0,
                           *(undefined4 *)
                            (PTR_PTR_0303bc08 + ((byte)PTR_DAT_0303bbfc[0x30] >> 6 & 1) * 4));
              bVar7 = true;
            }
            goto LAB_0303bbd4;
          }
          bVar1 = false;
        }
LAB_0303c820:
        bVar7 = true;
      }
      else {
        FUN_03018af4(1,0xffff,0,
                     *(undefined4 *)
                      (*(int *)(PTR_PTR_0303ba74 + ((byte)PTR_DAT_0303ba6c[0x30] >> 6 & 1) * 8) +
                      0x18));
        bVar7 = true;
LAB_0303bbd4:
        if ((PTR_DAT_0303bbf8[5] & 0x10) != 0) {
          FUN_03017be8(0,0x122,0xf0,0x140,0);
          break;
        }
      }
      if ((((PTR_DAT_0303bdb8[6] & 0xc) == 0) && ((*(uint *)PTR_DAT_0303bdbc & 0x18000) != 0x8000))
         && (bVar7)) {
        FUN_03019bd4();
      }
      break;
    case 0x303bc46:
      FUN_0306bc6c(PTR_DAT_0303bdc0,0,0,auStack_10);
      FUN_03019b9c();
      FUN_03018af4(1,0xffff,0,
                   **(undefined4 **)(PTR_PTR_0303bdc8 + ((byte)PTR_DAT_0303bdc4[0x30] >> 6 & 1) * 8)
                  );
      FUN_03059c90(1);
      bVar1 = false;
      FUN_03017be8(0,0x122,0xf0,0x140,0);
      FUN_03059904();
      break;
    case 0x303bc96:
      uVar14 = FUN_03034fc0();
      bVar1 = false;
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03017eec(0);
      uVar16 = FUN_03034db4(uVar14);
      FUN_03034268(uVar14,*(undefined2 *)PTR_DAT_0303bdcc,*(undefined2 *)PTR_DAT_0303bdd0,uVar16);
      FUN_03019bd4();
      break;
    case 0x303bcd0:
      uVar14 = FUN_03034fc0();
      bVar1 = false;
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03017eec(0);
      sVar12 = FUN_03034db4(uVar14);
      FUN_03033ffc(uVar14,*(undefined2 *)PTR_DAT_0303bdcc,*(undefined2 *)PTR_DAT_0303bdd0,sVar12 + 1
                  );
      FUN_03019bd4();
      break;
    case 0x303bd0c:
      if (*(short *)PTR_DAT_0303bdd4 == 0) {
        *(ushort *)PTR_DAT_0303bdd4 = (ushort)(byte)*PTR_DAT_0303bdd8;
        FUN_03035e68(*(undefined1 *)((uint)bVar11 + DAT_0303bddc),0);
        *PTR_DAT_0303bde0 = 2;
        return;
      }
      FUN_03017eec(0);
      FUN_03033730(*(undefined4 *)PTR_DAT_0303bde4,*(undefined4 *)PTR_DAT_0303bde8,
                   *(undefined4 *)PTR_DAT_0303bdec);
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303bd54:
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03018af4(1,0xffff,0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0303bdf0 + ((byte)PTR_DAT_0303bdc4[0x30] >> 6 & 1) * 8) + 8));
      FUN_03017eec(0);
      if (PTR_DAT_0303bdf8[(byte)PTR_DAT_0303bdf4[1] + 2] == '\x01') {
        uVar14 = FUN_0302e810(*PTR_DAT_0303bdfc,*(undefined2 *)(PTR_DAT_0303bdb8 + 0x12));
        *(short *)PTR_DAT_0303be00 = (short)uVar14;
        FUN_03056ed4(*(undefined2 *)PTR_DAT_0303bdcc,*(undefined2 *)PTR_DAT_0303bdd0,uVar14);
      }
      else if (PTR_DAT_0303bdf8[(byte)PTR_DAT_0303bdf4[1] + 2] == '\x02') {
        bVar11 = *PTR_DAT_0303bfa0;
        sVar12 = *(short *)(PTR_DAT_0303bfa4 + 0x12);
        *(ushort *)PTR_DAT_0303bfa8 = sVar12 - (ushort)bVar11;
        *(ushort *)PTR_DAT_0303bfac = sVar12 - (ushort)bVar11;
        FUN_03056bac(*(undefined2 *)PTR_DAT_0303bfb0,*(undefined2 *)PTR_DAT_0303bfb4);
      }
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303be32:
      bVar1 = false;
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03018af4(1,0xffff,0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0303bfbc + ((byte)PTR_DAT_0303bfb8[0x30] >> 6 & 1) * 8) + 8));
      FUN_03017eec(0);
      cVar10 = PTR_DAT_0303bfc0[6];
      cVar3 = *PTR_DAT_0303bfc4;
      *PTR_DAT_0303bfc8 = cVar10 - cVar3;
      *(ushort *)PTR_DAT_0303bfcc = (ushort)(byte)(cVar10 - cVar3);
      FUN_03066d34(*PTR_DAT_0303bfd0,*PTR_DAT_0303bfd4);
      break;
    case 0x303be8a:
      bVar11 = *PTR_DAT_0303bfd8;
      *(ushort *)PTR_DAT_0303bfcc = (ushort)bVar11;
      if (bVar11 < 9) {
        *PTR_DAT_0303bfdc = bVar11;
      }
      else {
        *PTR_DAT_0303bfdc = 8;
      }
      FUN_03017eec(0);
      FUN_03058ec0(PTR_DAT_0303bfe0[2] + '\x01');
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303bebe:
      *PTR_DAT_0303bfe4 = 0x12;
      return;
    case 0x303bec8:
      bVar11 = *PTR_DAT_0303bfd8;
      *(ushort *)PTR_DAT_0303bfcc = (ushort)bVar11;
      iVar13 = **(int **)PTR_DAT_0303bfe8;
      if (iVar13 != 0) {
        if (bVar11 == 1) {
          FUN_0301ab40(0x30,0x30,PTR_DAT_0303bff0,iVar13,PTR_DAT_0303bfec);
        }
        else if (bVar11 == 2) {
          FUN_0301ab40(0x30,0x30,PTR_DAT_0303bff0,iVar13,(*(int **)PTR_DAT_0303bfe8)[1]);
        }
        else if (bVar11 == 3) {
          FUN_03018af4(0x72,0,0xc618);
          puVar8 = PTR_DAT_0303bfe8;
          FUN_03018af4(0x90,0,0xc618,*(undefined4 *)(*(int *)PTR_DAT_0303bfe8 + 4));
          FUN_03018af4(0xae,0,0xc618,*(undefined4 *)(*(int *)puVar8 + 8));
        }
      }
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303bf40:
      FUN_03019b9c();
      bVar11 = PTR_DAT_0303bfa4[5];
      if ((bVar11 & 8) == 0) {
        if ((PTR_DAT_0303bfa4[6] & 0x10) == 0) {
          if ((bVar11 & 1) == 0) {
            if ((PTR_DAT_0303bfa4[6] & 0x20) == 0) {
              if ((bVar11 & 0x20) == 0) {
                FUN_03018af4(1,0xffff,0,
                             **(undefined4 **)
                               (PTR_PTR_0303c1c8 + ((byte)PTR_DAT_0303c1bc[0x30] >> 6 & 1) * 4));
              }
              else {
                FUN_03018af4(1,0xffff,0,
                             **(undefined4 **)
                               (PTR_PTR_0303c1c4 + ((byte)PTR_DAT_0303c1bc[0x30] >> 6 & 1) * 4));
              }
            }
            else {
              FUN_03018af4(1,0xffff,0,
                           *(undefined4 *)
                            (*(int *)(PTR_PTR_0303c1c0 + ((byte)PTR_DAT_0303c1bc[0x30] >> 6 & 1) * 8
                                     ) + 0x2c));
            }
          }
          else {
            FUN_03018af4(1,0xffff,0,
                         *(undefined4 *)
                          (*(int *)(PTR_PTR_0303c1c0 + ((byte)PTR_DAT_0303c1bc[0x30] >> 6 & 1) * 8)
                          + 0x20));
          }
        }
        else {
          FUN_03018af4(1,0xffff,0,
                       **(undefined4 **)
                         (PTR_PTR_0303bff8 + ((byte)PTR_DAT_0303bfb8[0x30] >> 6 & 1) * 4));
        }
      }
      else {
        FUN_03018af4(1,0xffff,0,
                     **(undefined4 **)
                       (PTR_PTR_0303bff4 + ((byte)PTR_DAT_0303bfb8[0x30] >> 6 & 1) * 4));
      }
      FUN_03059c90(*PTR_DAT_0303c1cc);
      FUN_03059f08();
      bVar1 = true;
      break;
    case 0x303c0a8:
      cVar10 = FUN_030567ec();
      FUN_03017eec(0);
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03018af4(1,0xffff,0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0303c1d0 + ((byte)PTR_DAT_0303c1bc[0x30] >> 6 & 1) * 8) + 8));
      if (*(ushort *)PTR_DAT_0303c1d4 < 9) {
        *PTR_DAT_0303c1d8 = (char)*(ushort *)PTR_DAT_0303c1d4;
      }
      else {
        *PTR_DAT_0303c1d8 = 8;
      }
      FUN_0305680c(*PTR_DAT_0303c1dc,*PTR_DAT_0303c1e0,cVar10 + '\x01');
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303c110:
      cVar10 = FUN_03066600();
      FUN_03017eec(0);
      bVar1 = false;
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03018af4(1,0xffff,0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0303c1e4 + ((byte)PTR_DAT_0303c1bc[0x30] >> 6 & 1) * 8) + 4));
      FUN_030668c8(*PTR_DAT_0303c1dc,*PTR_DAT_0303c1e0,cVar10 + '\x01');
      FUN_03019bd4();
      break;
    case 0x303c162:
      FUN_03017eec(0);
      if (PTR_DAT_0303c1ec[(byte)PTR_DAT_0303c1e8[3] + 2] == '\x04') {
        uVar4 = *(undefined2 *)(PTR_DAT_0303c1f0 + 0x13);
      }
      else {
        uVar4 = *(undefined2 *)(PTR_DAT_0303c1f0 + 0x11);
      }
      iVar13 = FUN_03031140(uVar4);
      *PTR_DAT_0303c1d8 = 8;
      if (iVar13 == 1) {
        uVar14 = 0x32;
      }
      else {
        uVar14 = 0x69;
      }
      FUN_030311c8(*PTR_DAT_0303c1dc,*PTR_DAT_0303c1e0,uVar14);
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303c1f4:
      FUN_03017eec(0);
      FUN_03018af4(0x28,0xffff,0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0303c3a8 + ((byte)PTR_DAT_0303c39c[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_0303c3a4[(byte)PTR_DAT_0303c3a0[2] + 2] * 4));
      FUN_03018d78(0x68,0x50,0x20,0x88,PTR_DAT_0303c3ac,0xffff);
      if ((PTR_DAT_0303c3b0[4] & 2) == 0) {
        FUN_030300d0(DAT_0303c3b4);
      }
      else {
        FUN_03030130(DAT_0303c3b4);
      }
      bVar11 = FUN_0300e3b4(*(undefined2 *)(PTR_DAT_0303c3b8 + 0x11));
      PTR_DAT_0303c3bc[0x35] = PTR_DAT_0303c3bc[0x35] & 0xf3 | (bVar11 & 3) << 2;
      FUN_0300e218();
      bVar1 = false;
      break;
    case 0x303c27e:
      FUN_03017eec(0);
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03018af4(1,0xffff,0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0303c3a8 + ((byte)PTR_DAT_0303c39c[0x30] >> 6 & 1) * 8) + 4));
      if (*(ushort *)PTR_DAT_0303c3c0 < 9) {
        *PTR_DAT_0303c3c4 = (char)*(ushort *)PTR_DAT_0303c3c0;
      }
      else {
        *PTR_DAT_0303c3c4 = 8;
      }
      FUN_0302e820(*PTR_DAT_0303c3cc,*PTR_DAT_0303c3d0,*PTR_DAT_0303c3c8 + '\x01');
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303c2e4:
      FUN_03017eec(0);
      FUN_0302e9c4(*PTR_DAT_0303c3cc,*PTR_DAT_0303c3d0,PTR_DAT_0303c3c8[1] + '\x01');
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303c308:
      FUN_03017eec(0);
      bVar1 = false;
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03058708(*PTR_DAT_0303c3cc,*PTR_DAT_0303c3d0,(byte)*PTR_DAT_0303c3d4 + 1);
      FUN_03019bd4();
      break;
    case 0x303c338:
      FUN_03017eec(0);
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03018af4(1,0xffff,0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0303c3d8 + ((byte)PTR_DAT_0303c39c[0x30] >> 6 & 1) * 8) + 0x30
                    ));
      if (*(ushort *)PTR_DAT_0303c3c0 < 9) {
        *PTR_DAT_0303c3c4 = (char)*(ushort *)PTR_DAT_0303c3c0;
      }
      else {
        *PTR_DAT_0303c3c4 = 8;
      }
      FUN_03055e4c(*PTR_DAT_0303c3cc,*PTR_DAT_0303c3d0,(byte)*PTR_DAT_0303c3dc + 2);
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303c3e0:
      FUN_03017eec(0);
      bVar1 = false;
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03018af4(1,0xffff,0,
                   *(undefined4 *)(PTR_PTR_0303c5b8 + ((byte)PTR_DAT_0303c5b4[0x30] >> 6 & 1) * 4));
      FUN_030560cc(*PTR_DAT_0303c5c0,*PTR_DAT_0303c5c4,(byte)*PTR_DAT_0303c5bc + 1,*PTR_DAT_0303c5c8
                  );
      FUN_03019bd4();
      break;
    case 0x303c430:
      FUN_03017eec(0);
      bVar1 = false;
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03018af4(1,0xffff,0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0303c5cc + ((byte)PTR_DAT_0303c5b4[0x30] >> 6 & 1) * 8) + 4));
      FUN_030569e4(*PTR_DAT_0303c5c0,*PTR_DAT_0303c5c4,*PTR_DAT_0303c5d0);
      FUN_03019bd4();
      break;
    case 0x303c47a:
      FUN_03017eec(0);
      bVar1 = false;
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03018af4(1,0xffff,0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0303c5cc + ((byte)PTR_DAT_0303c5b4[0x30] >> 6 & 1) * 8) + 4));
      FUN_03066b90(*PTR_DAT_0303c5c0,*PTR_DAT_0303c5c4,*PTR_DAT_0303c5d4);
      FUN_03019bd4();
      break;
    case 0x303c4c4:
      FUN_03017eec(0);
      uVar17 = *(undefined4 *)PTR_DAT_0303c5d8;
      uVar16 = *(undefined4 *)PTR_DAT_0303c5dc;
      uVar14 = FUN_03010cf8();
      FUN_03061b60(uVar17,uVar16,uVar14);
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303c4e8:
      FUN_03017eec(0);
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03018af4(1,0xffff,0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0303c5e0 + ((byte)PTR_DAT_0303c5b4[0x30] >> 6 & 1) * 8) + 4));
      if (*(ushort *)PTR_DAT_0303c5e4 < 9) {
        *PTR_DAT_0303c5e8 = (char)*(ushort *)PTR_DAT_0303c5e4;
      }
      else {
        *PTR_DAT_0303c5e8 = 8;
      }
      FUN_0305cec0(*PTR_DAT_0303c5c0,*PTR_DAT_0303c5c4,(byte)*PTR_DAT_0303c5ec + 1);
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303c54a:
      FUN_03017eec(0);
      uVar4 = *(undefined2 *)PTR_DAT_0303c5f0;
      uVar5 = *(undefined2 *)PTR_DAT_0303c5f4;
      uVar14 = FUN_03062e20();
      FUN_030633d8(uVar4,uVar5,uVar14);
      FUN_03019bd4();
      bVar1 = false;
      break;
    case 0x303c56e:
      FUN_03017eec(0);
      bVar1 = false;
      FUN_03017be8(0,0,0xf0,0x1b,0);
      FUN_03018af4(1,0xffff,0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0303c5f8 + ((byte)PTR_DAT_0303c5b4[0x30] >> 6 & 1) * 8) + 0xc)
                  );
      FUN_0306369c(*PTR_DAT_0303c5c0,*PTR_DAT_0303c5c4);
      FUN_03019bd4();
      break;
    case 0x303c5fc:
      cVar10 = *PTR_DAT_0303c7d0;
      if (cVar10 == '\0') {
        FUN_03061fb4();
      }
      else if (cVar10 == '\x01') {
        FUN_03019b9c();
        FUN_03062e98(*(undefined2 *)PTR_DAT_0303c7d4);
      }
      else if (cVar10 == '\x02') {
        FUN_03017be8(0,0,0xf0,0x1b,0);
        puVar8 = PTR_DAT_0303c7dc;
        FUN_03018af4(1,0xffff,0,
                     *(undefined4 *)
                      (*(int *)(PTR_PTR_0303c7e4 + ((byte)PTR_DAT_0303c7d8[0x30] >> 6 & 1) * 8) +
                      (uint)(byte)PTR_DAT_0303c7dc[(byte)PTR_DAT_0303c7e0[3] + 0x8f] * 4));
        if (*(ushort *)puVar8 < 9) {
          *PTR_DAT_0303c7e8 = (char)*(ushort *)puVar8;
        }
        else {
          *PTR_DAT_0303c7e8 = 8;
        }
        FUN_03041698();
      }
      bVar1 = false;
      FUN_03017be8(0,0x122,0xf0,0x140,0);
      FUN_03019c60(0);
      break;
    case 0x303c68e:
      FUN_03019b80();
      FUN_030332e0(*(undefined2 *)(PTR_DAT_0303c7ec + 1),auStack_28);
      FUN_03018af4(0x90,0,0xc618,auStack_26);
      FUN_03018af4(0xae,0,0xc618,
                   **(undefined4 **)(PTR_PTR_0303c7f0 + ((byte)PTR_DAT_0303c7d8[0x30] >> 6 & 1) * 4)
                  );
      bVar1 = false;
      FUN_03017be8(0,0x122,0xf0,0x140,0);
      FUN_03019c60(0);
      break;
    case 0x303c6ec:
      FUN_03019b80();
      puVar9 = PTR_PTR_0303c7f4;
      puVar8 = PTR_DAT_0303c7d8;
      FUN_03018af4(0x90,0,0xc618,
                   **(undefined4 **)(PTR_PTR_0303c7f4 + ((byte)PTR_DAT_0303c7d8[0x30] >> 6 & 1) * 4)
                  );
      FUN_03018af4(0xae,0,0xc618,
                   *(undefined4 *)(*(int *)(puVar9 + ((byte)puVar8[0x30] >> 6 & 1) * 4) + 4));
      bVar1 = false;
      break;
    case 0x303c72c:
      uVar6 = *(ushort *)PTR_DAT_0303c7dc;
      if (uVar6 < 9) {
        *PTR_DAT_0303c7e8 = (char)uVar6;
      }
      else {
        *PTR_DAT_0303c7e8 = 8;
      }
      if (uVar6 == 0) {
        FUN_03036bb0();
        *(ushort *)PTR_DAT_0303c7dc = (ushort)(byte)*PTR_DAT_0303c7f8;
        PTR_DAT_0303c7fc[4] = 0;
        return;
      }
      if (*(int *)PTR_DAT_0303c800 == 0) {
        FUN_03017eec(0);
        return;
      }
      FUN_03017eec(0);
      FUN_03033fa8(*(int *)PTR_DAT_0303c804 + 1);
      bVar1 = false;
      break;
    case 0x303c77e:
      goto switchD_0303b6f0_caseD_7;
    }
  }
  else {
switchD_0303b6f0_caseD_7:
    bVar1 = false;
  }
  cVar10 = *PTR_DAT_0303c808;
  if (((((cVar10 != '\b') && (cVar10 != '\x05')) &&
       ((cVar10 != '\x06' &&
        ((((cVar10 != '\x04' && (cVar10 != '\x18')) && (cVar10 != '\x03')) &&
         ((cVar10 != '\n' && (cVar10 != '\x17')))))))) && (cVar10 != '%')) &&
     ((cVar10 != '/' && ((cVar10 != '\x16' || (*PTR_DAT_0303c7d0 != '\x01')))))) {
    FUN_03039368();
  }
  if (bVar1) {
    FUN_0306bd74(PTR_DAT_0303c80c,auStack_10);
  }
  else {
    FUN_0306bc6c(PTR_DAT_0303c98c,0,0,auStack_10);
  }
  return;
}



/* Address: 03048f50; expanded instructions=397 */

void FUN_03048f50(undefined4 param_1,uint param_2)

{
  undefined *puVar1;
  undefined *puVar2;
  undefined *puVar3;
  uint uVar4;
  char cVar5;
  byte bStack_f;
  byte bStack_e;
  byte bStack_b;
  
  puVar3 = PTR_DAT_03049338;
  puVar2 = PTR_DAT_0304932c;
  puVar1 = PTR_DAT_03049168;
  if ((byte)*PTR_DAT_03048f6c < 0x6d) {
                    /* WARNING: Switch is manually overridden */
    switch(*(uint *)(PTR_switchdataD_030b1e38_03048f7c + (uint)(byte)*PTR_DAT_03048f6c * 4) &
           0xfffffffe) {
    case 0x3048f80:
      uVar4 = FUN_0301c238();
      puVar1 = PTR_DAT_03049154;
      bStack_f = (byte)(uVar4 >> 8);
      bStack_e = (byte)(uVar4 >> 0x10);
      cVar5 = (char)((uVar4 & 0xff) / 10);
      *PTR_DAT_03049154 = cVar5;
      puVar1[1] = (char)uVar4 + cVar5 * -10;
      puVar1[2] = bStack_f / 10;
      puVar1[3] = bStack_f % 10;
      puVar1[4] = bStack_e / 10;
      puVar1[5] = bStack_e % 10;
      *PTR_DAT_03049158 = 0;
      *(undefined2 *)PTR_DAT_0304915c = 100;
      *(undefined2 *)PTR_DAT_03049160 = 0x48;
      *(undefined2 *)PTR_DAT_03049164 = 0x48;
      FUN_03048850();
      break;
    case 0x3048fe2:
      FUN_0301c238();
      puVar1 = PTR_DAT_03049154;
      bStack_b = (byte)(param_2 >> 8);
      uVar4 = (param_2 >> 0x10) % 100;
      cVar5 = (char)(uVar4 / 10);
      *PTR_DAT_03049154 = cVar5;
      puVar1[1] = (char)uVar4 + cVar5 * -10;
      puVar1[2] = bStack_b / 10;
      puVar1[3] = bStack_b % 10;
      puVar1[4] = (char)((param_2 & 0xff) / 10);
      puVar1[5] = (char)((param_2 & 0xff) % 10);
      *PTR_DAT_03049158 = 0;
      *(undefined2 *)PTR_DAT_0304915c = 100;
      *(undefined2 *)PTR_DAT_03049160 = 0x54;
      *(undefined2 *)PTR_DAT_03049164 = 0x54;
      FUN_030488ac();
      break;
    case 0x3049052:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0304916c + ((byte)PTR_DAT_03049168[0x30] >> 6 & 1) * 8) + 4));
      if ((byte)puVar1[0x36] == 0) {
        FUN_0301abe4(0);
      }
      else {
        FUN_0301abe4(((byte)puVar1[0x36] - 1) * 5 + 0xf);
      }
      break;
    case 0x3049092:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0304916c + ((byte)PTR_DAT_03049168[0x30] >> 6 & 1) * 8) + 8));
      FUN_0301abe4(*PTR_DAT_03049170);
      break;
    case 0x30490ba:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_03049174 + ((byte)PTR_DAT_03049168[0x30] >> 6 & 1) * 8) + 0x10
                    ));
      FUN_0301abe4((uint)(byte)*PTR_DAT_03049170 * 0x1e);
      break;
    case 0x30490ec:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_03049178 + ((byte)PTR_DAT_03049168[0x30] >> 6 & 1) * 8) + 4));
      FUN_03018af4(0x82,0,0x7e0,PTR_s__d_Min__0304917c,*PTR_DAT_03049170);
      break;
    case 0x3049120:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_03049188 + ((byte)PTR_DAT_03049168[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03049184[(byte)PTR_DAT_03049180[2] + 2] * 4));
      FUN_0302f86c(PTR_DAT_03049154);
      break;
    case 0x304918c:
      FUN_03018af4(100,0,0x7e0,
                   **(undefined4 **)(PTR_PTR_03049330 + ((byte)PTR_DAT_0304932c[0x30] >> 6 & 1) * 8)
                  );
      FUN_03018af4(0x82,0,0x7e0,PTR_s__d_S__03049334,puVar2[0x57]);
      puVar2[0x3c] = puVar2[0x57];
      break;
    case 0x30491c8:
      *PTR_DAT_03049338 = PTR_DAT_0304932c[0x5c];
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_0304933c + ((byte)puVar2[0x30] >> 6 & 1) * 8) + 0x2c));
      FUN_0301aba0((uint)(byte)*puVar3 * 5);
      break;
    case 0x30491fa:
      *PTR_DAT_03049338 = PTR_DAT_0304932c[0x5f];
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_03049340 + ((byte)puVar2[0x30] >> 6 & 1) * 8) + 0x10));
      FUN_0301aba0(*puVar3);
      break;
    case 0x3049228:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_03049344 + ((byte)PTR_DAT_0304932c[0x30] >> 6 & 1) * 8) + 0x40
                    ));
      FUN_0301abe4((uint)(byte)*PTR_DAT_03049338 * 5);
      break;
    case 0x3049256:
      FUN_03018af4(100,0,0x7e0,
                   **(undefined4 **)(PTR_PTR_03049348 + ((byte)PTR_DAT_0304932c[0x30] >> 6 & 1) * 8)
                  );
      FUN_030686e4(*PTR_DAT_03049338);
      break;
    case 0x304927e:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_03049348 + ((byte)PTR_DAT_0304932c[0x30] >> 6 & 1) * 8) + 8));
      FUN_03068740(*PTR_DAT_03049338);
      break;
    case 0x30492a6:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_03049348 + ((byte)PTR_DAT_0304932c[0x30] >> 6 & 1) * 8) + 0xc)
                  );
      FUN_03068714(*PTR_DAT_03049338);
      break;
    case 0x30492ce:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_03049354 + ((byte)PTR_DAT_0304932c[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_03049350[(byte)PTR_DAT_0304934c[3] + 2] * 4));
      FUN_03064488(*PTR_DAT_03049338);
      break;
    case 0x3049304:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_03049354 + ((byte)PTR_DAT_0304932c[0x30] >> 6 & 1) * 8) + 8));
      FUN_030686e4(*PTR_DAT_03049338);
      break;
    case 0x3049358:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_030493e4 + ((byte)PTR_DAT_030493e0[0x30] >> 6 & 1) * 8) + 0xc)
                  );
      FUN_03068740(*PTR_DAT_030493e8);
      break;
    case 0x3049380:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_030493f4 + ((byte)PTR_DAT_030493e0[0x30] >> 6 & 1) * 8) +
                    (uint)(byte)PTR_DAT_030493f0[(byte)PTR_DAT_030493ec[3] + 2] * 4));
      FUN_03067c60(*PTR_DAT_030493e8);
      break;
    case 0x30493b6:
      FUN_03018af4(100,0,0x7e0,
                   *(undefined4 *)
                    (*(int *)(PTR_PTR_030493f4 + ((byte)PTR_DAT_030493e0[0x30] >> 6 & 1) * 8) + 0x18
                    ));
      FUN_03067c88(*PTR_DAT_030493e8);
    }
  }
  return;
}


