# Dorks Dilemma v2 - Project Instructions

## Project Overview

This is a restoration project for "Dorks Dilemma", a 1980s maze/puzzle game originally developed for the Commodore C16/Plus4. The source code was recovered from original floppy disks, with some files corrupted.

## Architecture

### Target Platform
- **Commodore C16/Plus4** using the TED chip
- 6502 CPU @ 1.76 MHz (PAL) / 1.79 MHz (NTSC)
- TED graphics/sound at $FF00

### Build System
- **Assembler:** ca65 (cc65 suite)
- **Linker:** ld65 with custom c16.cfg

## Directory Structure

```
Dorks_Dilemma_v2/
├── build/                      # Build output and consolidated source
│   ├── dorks_dilemma.asm       # Main consolidated source file
│   ├── c16.cfg                 # ca65 linker configuration
│   ├── Makefile                # Build script
│   └── parse_asm.py            # Source parsing utility
├── C16_Recovered_Source/       # Original recovered C16 files
│   ├── *.asm                   # Source files (semicolon-separated format)
│   ├── dorks dilemma.prg       # Working compiled game (reference)
│   └── *.prg                   # Binary data files
├── C64_Original_Source_Disk/   # Reference C64 version
│   └── *.TXT                   # C64 source files (proper format)
└── docs/                       # Documentation
    ├── BUILD.md                # Build instructions
    ├── CODE_STRUCTURE.md       # Code analysis
    └── RECOVERY_NOTES.md       # Recovery details
```

## Build Commands

```bash
cd build
make              # Build PRG file
make clean        # Clean build artifacts
make run          # Build and run in xplus4
```

## Key Technical Details

### Memory Map
| Address | Purpose |
|---------|---------|
| $0002-$00C3 | Zero page variables |
| $0C00-$0FFF | Video RAM (screen) |
| $0800-$0BFF | Color RAM |
| $3800-$3FFF | Character set (2KB) |
| $1001+ | Program code |

### TED Chip Registers
| Register | Address | Purpose |
|----------|---------|---------|
| BORDER | $FF19 | Border color |
| BACKGR | $FF15 | Background color |
| JPORT | $FF08 | Joystick port |
| VOL | $FF11 | Sound volume |
| IRQREG | $FF09 | IRQ status |
| RASCOM | $FF0B | Raster compare |

## Source File Format

### Original C16 Format
Files use semicolon as line separator:
```
;LABEL;LDA VALUE;STA TARGET;RTS;
```

### Converted ca65 Format
Standard multi-line assembly:
```asm
LABEL:
    lda VALUE
    sta TARGET
    rts
```

## Recovered Code Status

### Complete Modules
- Bomb system (bomb-code.asm)
- Player movement (move-pixel.asm)
- Alien AI (aliens-mega-code.asm)
- Animation (animate-chars.asm)
- IRQ handling (irq.asm)

### Reconstructed from C64
- `CHKBMB` - Bomb position validation
- `CLEXP` - Explosion clearing
- `FILLEX` - Fill expansion

### Stub Routines (need completion)
- `MESSVE` - Message scrolling
- `DEATH` - Death sequence
- `ROOMS` - Room setup
- `SCORE` - Scoring system

## Development Notes

### When Adding New Code
1. Follow ca65 syntax (lowercase opcodes accepted)
2. Use `.byte` for data, not `DB` or `!byte`
3. Labels need colons OR use `.feature labels_without_colons`
4. Test against working PRG in emulator

### Address Conversions (C64 → C16)
- Screen: $0400 → $0C00
- Color: $D800 → $0800
- Chars: $2000 → $3800
- VIC-II → TED ($D000 → $FF00)

### Common Issues
1. Screen addresses wrong → Check SCRPOS table
2. No display → Check TED register initialization
3. No input → Joystick is at $FF08, not $DC00

## Testing

1. Build: `make`
2. Run: `xplus4 dorks_dilemma.prg`
3. Compare behavior to `C16_Recovered_Source/dorks dilemma.prg`

## References

- [cc65 Documentation](https://cc65.github.io/doc/)
- [C16/Plus4 Programming](https://www.c64-wiki.com/wiki/Plus/4)
- [TED Chip Reference](https://www.c64-wiki.com/wiki/TED)
