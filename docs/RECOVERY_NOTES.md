# Dorks Dilemma - Source Recovery Notes

## Recovery Overview

The Dorks Dilemma source code was recovered from original 1980s floppy disks. During extraction, some files were corrupted or truncated.

## File Format Conversion

### Original C16 Format
The C16 assembler stored source files in a compact semicolon-separated format:
```
; >S:BOMB-CODE; PUT "BOMB-CODE";;; ALL THE TIME-BOMB STUFF;BOMB;LDA BOMBON  ;* BOMB ALREADY ON ?BNE BM1;...
```

### Converted Format
For modern ca65 assembler, converted to standard multi-line:
```asm
; >S:BOMB-CODE
; PUT "BOMB-CODE"
;
; ALL THE TIME-BOMB STUFF
BOMB:
    LDA BOMBON      ; BOMB ALREADY ON ?
    BNE BM1
    ...
```

## Corrupted Files

### filler-bomb.asm
**Status:** Truncated mid-file

**Missing routines:**
1. `CHKBMB` - Checks if bomb explosion coordinates are valid
2. `CLEXP` - Clears explosion characters from screen
3. `FILLEX` - Controls explosion expansion direction

**Recovery source:** C64 `FILLERBO.TXT` (complete version)

**Adaptations required:**
| C64 Address | C16 Address | Purpose |
|-------------|-------------|---------|
| $0429 | $0C29 | Screen + 1 row |
| $2160 | $3960 | Character RAM |
| $27A0 | $3FA0 | Bomb char data |
| $D800 | $0800 | Color RAM |

## Comparison Summary

### Files with Identical Logic
Most source files have identical logic between C16 and C64 versions, with only address differences:

- `bomb-code.asm` ↔ `BOMBCODE.TXT` ✓
- `aliens-mega-code.asm` ↔ `ALIENSME.TXT` ✓
- `move-pixel.asm` ↔ `MOVEPIXE.TXT` ✓
- `animate-chars.asm` ↔ `ANIMATEC.TXT` ✓
- Most other pairs ✓

### Files with Platform-Specific Code
| File | Difference |
|------|------------|
| `main-vars.asm` | TED registers vs VIC-II/SID |
| `irq.asm` | TED IRQ vs VIC raster |
| `joystik.asm` | TED $FF08 vs CIA $DC00 |
| `setup.asm` | TED initialization |

### Files Only in C64
| File | Purpose |
|------|---------|
| `BRICKCHA.TXT` | Brick character data |
| `OBJ.TXT` | Object definitions |
| `ODES.TXT` | Object descriptions |

### Files Only in C16
| File | Purpose |
|------|---------|
| `des-ani.asm` | Designer animation |
| `des-irq.asm` | Designer IRQ |

## Address Translation Table

### Screen Memory
| Purpose | C64 | C16 |
|---------|-----|-----|
| Screen RAM | $0400 | $0C00 |
| Color RAM | $D800 | $0800 |
| Screen + row | $0428 | $0C28 |

### Character RAM
| Purpose | C64 | C16 |
|---------|-----|-----|
| Base | $2000 | $3800 |
| Bomb chars | $2160 | $3960 |
| Animation | $20E0 | $38E0 |
| Bomb data | $27A0 | $3FA0 |

### Hardware Registers
| Purpose | C64 | C16 |
|---------|-----|-----|
| Graphics chip | $D000 | $FF00 |
| Sound vol | $D418 | $FF11 |
| Border | $D020 | $FF19 |
| Background | $D021 | $FF15 |

## Verification

### Working Reference
The file `C16_Recovered_Source/dorks dilemma.prg` (12KB) is a working compiled version of the game. This can be used to:
1. Verify gameplay behavior
2. Compare memory addresses
3. Test individual routines

### Disassembly Notes
Key addresses from the working PRG:
- Entry point: $100D (SYS 4109)
- Main loop: Approximately $1100
- IRQ handler: Set at $0314/$0315

## Future Work

### Incomplete Stub Routines
The consolidated source has placeholder stubs for:
- `MESSVE` - Message scrolling
- `BDRGLP` - Border gloop animation
- `DEATH` - Full death sequence
- `CHGROM` - Room change logic
- `ROOMON` - Room loading
- `COMAND` - Command processing
- `ROOMS` - Room setup
- `SCATER` - Jigsaw scatter
- `JMPBAK` - Jump back to screen
- `SCORE` - Score handling
- `KILLED` - Kill counting
- `GETDEF` - Get alien definition

These need to be reconstructed from:
1. Other C16 source files
2. C64 equivalents
3. Disassembly of working PRG
