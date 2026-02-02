# Dorks Dilemma - C16/Plus4 Version

Restored 1980s maze/puzzle game for the Commodore C16/Plus4. Recovered from original floppy disks and rebuilt with modern tooling.

![Dorks Dilemma Title Screen](https://github.com/anthonyjclarke/Dorks_Dilemma_v2/blob/main/docs/title_screen.png)

## About

**Dorks Dilemma** is a classic maze/puzzle game originally developed by Anthony Clarke in the 1980s for the Commodore C16 and Plus/4 computers. This project represents a complete restoration from recovered source files found on original floppy disks.

### Game Features
- 25 unique maze levels with randomized layouts
- Jigsaw puzzle collection mechanic
- Alien enemies with AI pathfinding
- Bomb power-up system
- High score table
- Sound effects and animated graphics

## Quick Start

### Download & Play
1. Download [dorks_dilemma.prg](build/dorks_dilemma.prg)
2. Load in VICE C16/Plus4 emulator or real hardware
3. Type: `LOAD"dorks_dilemma.prg",8,1`
4. Type: `SYS 6496`

### Controls
- **Z** = Move Left
- **X** = Move Right
- **K** = Move Up
- **N** = Move Down
- **SPACE** = Fire / Drop Bomb / Start Game

## Building from Source

### Requirements
- [cc65 toolchain](https://cc65.github.io/) (ca65 assembler and ld65 linker)
- Make

### Build Instructions
```bash
cd build
make
```

This produces `dorks_dilemma.prg` (12,290 bytes) ready to run on C16/Plus4.

See [BUILD.md](docs/BUILD.md) for detailed build information.

## Project Structure

```
Dorks_Dilemma_v2/
├── build/                      # Build system and consolidated source
│   ├── dorks_dilemma.asm       # Main assembled source (4,300+ lines)
│   ├── dorks_dilemma.prg       # Compiled game (12KB)
│   ├── c16.cfg                 # Linker configuration
│   ├── Makefile                # Build script
│   ├── chars.bin               # Character set data (2KB)
│   ├── screens.bin             # Compressed screen data (2.4KB)
│   └── parse_asm.py            # Source parsing utility
├── C16_Recovered_Source/       # Original C16 source files (semicolon format)
│   ├── *.asm                   # ~50 source modules
│   └── *.prg                   # Binary data files
├── C64_Original_Source_Disk/   # Reference C64 version
│   └── *.TXT                   # C64 source files
└── docs/                       # Documentation
    ├── BUILD.md                # Build instructions
    ├── CODE_STRUCTURE.md       # Code architecture
    └── RECOVERY_NOTES.md       # Recovery process details
```

## Technical Details

### Platform
- **Target:** Commodore C16/Plus4 (TED chip)
- **CPU:** 6502 @ 1.76 MHz (PAL)
- **RAM:** 16KB (12KB usable after BASIC ROM)
- **Display:** 320×200 (40×25 text mode with multicolor characters)

### Memory Map
| Address Range | Usage |
|---------------|-------|
| `$1000-$195F` | Compressed screen data (2400 bytes) |
| `$1960-$37FF` | Main program code |
| `$3800-$3FFF` | Character set graphics (2KB) |
| `$0C00-$0FFF` | Screen RAM |
| `$0800-$0BFF` | Color RAM |

### Key Systems
- **TED Chip:** Graphics, sound, and keyboard I/O via `$FF08`
- **Raster IRQ:** Split-screen effects and animation timing
- **Screen Decoder:** Decompresses 25 maze screens from 2.4KB data
- **Jigsaw Logic:** 5×5 grid tracking system

## Recovery Story

The original source files were recovered from 40-year-old floppy disks using specialized hardware. Files were stored in a unique semicolon-separated format that required custom parsing to convert to standard assembly syntax.

Some files were corrupted or missing. Missing routines (`FILLEX`, `CHKBMB`, `CLEXP`) were reconstructed by comparing the C16 binary to C64 source code and adapting for TED chip differences.

See [RECOVERY_NOTES.md](docs/RECOVERY_NOTES.md) for the complete recovery process.

## Development

### Current Status
- ✅ Full source reconstruction complete
- ✅ Builds successfully to 12,290 byte PRG
- ✅ Title screen displays correctly
- ✅ Keyboard controls implemented
- 🔧 Game flow testing in progress

### Branches
- `main` - Stable releases
- `dev` - Active development

## License

This is a restoration of 1980s software. Original code © 1980s Anthony Clarke.

Restoration work and build system by the community.

## Credits

- **Original Game:** Anthony Clarke (1980s)
- **Restoration:** Claude Sonnet 4.5 & Anthony Clarke (2025)
- **Tools:** cc65 assembler suite, VICE emulator
- **Reference:** Plus/4 World Encyclopedia

## Links

- [cc65 Compiler Suite](https://cc65.github.io/)
- [VICE Emulator](https://vice-emu.sourceforge.io/)
- [Plus/4 World](http://plus4world.powweb.com/)
- [TED Chip Reference](https://www.c64-wiki.com/wiki/TED)
