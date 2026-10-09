#include <assert.h>
#include <stdio.h>
#include "mod_core.h"
#include "codeplug_reader.h"
#include "firmware_zone_bridge.h"
#include "codeplug_zone_fixture.h"
typedef struct { FILE *file; long offsets[256]; } file_blocks;
static file_blocks *active_blocks;
static bool raw_read(void *context, uint8_t block, uint16_t offset, void *data, uint16_t size) {
    file_blocks *blocks = (file_blocks *)context;
    if (blocks->offsets[block] < 0 || (unsigned)offset + size > 4095) return false;
    if (fseek(blocks->file, blocks->offsets[block] + offset, SEEK_SET) != 0) return false;
    return fread(data, 1, size, blocks->file) == size;
}
void dm32_test_firmware_read(uint8_t block, uint16_t offset, void *data, uint16_t size) {
    assert(raw_read(active_blocks, block, offset, data, size));
}
int main(void) {
    dm32_zone_scan scan; dm32_zone_reader reader; dm32_storage storage;
    file_blocks blocks; unsigned zone, index; uint16_t channel = 0; long offset, size;
    assert(fopen_s(&blocks.file, "C:/Users/Rafal/Downloads/TEMPLATE/DMR1.data", "rb") == 0);
    for (index = 0; index < 256; ++index) blocks.offsets[index] = -1;
    assert(fseek(blocks.file, 0, SEEK_END) == 0); size = ftell(blocks.file);
    for (offset = 0; offset < size; offset += 4096) {
        int tag;
        assert(fseek(blocks.file, offset + 4095, SEEK_SET) == 0); tag = fgetc(blocks.file);
        assert(tag != EOF);
        if (tag > 0 && tag < 255) blocks.offsets[tag] = offset;
    }
    storage.context = &blocks; storage.read = raw_read;
    active_blocks = &blocks;
    reader = dm32_codeplug_zone_reader(&storage);
    for (zone = 1; zone <= REAL_ZONE_COUNT; ++zone) {
        dm32_zone_init(&scan);
        assert(dm32_zone_select(&scan, &reader, (uint8_t)zone));
        assert(!scan.enabled);
        assert(dm32_zone_switch(&scan, &reader, true));
        for (index = 0; index < real_counts[zone - 1]; ++index) {
            assert(dm32_zone_next(&scan, &reader, &channel));
            assert(channel == real_channels[zone - 1][index]);
        }
        assert(dm32_zone_next(&scan, &reader, &channel));
        assert(channel == real_channels[zone - 1][0]);
        assert(dm32_zone_switch(&scan, &reader, false));
        assert(!dm32_zone_next(&scan, &reader, &channel));
        dm32_zone_init(&scan);
        assert(dm32_firmware_zone_select(&scan, (uint8_t)zone));
        assert(!scan.enabled);
        assert(dm32_firmware_zone_switch(&scan, true));
        for (index = 0; index < real_counts[zone - 1]; ++index) {
            assert(dm32_firmware_zone_next(&scan, &channel));
            assert(channel == real_channels[zone - 1][index]);
        }
        assert(dm32_firmware_zone_next(&scan, &channel));
        assert(channel == real_channels[zone - 1][0]);
        assert(dm32_firmware_zone_switch(&scan, false));
    }
    printf("PASS: reader and firmware bridge callback contracts for all %u zones of DMR1.data\n", (unsigned)REAL_ZONE_COUNT);
    assert(fclose(blocks.file) == 0);
    return 0;
}
