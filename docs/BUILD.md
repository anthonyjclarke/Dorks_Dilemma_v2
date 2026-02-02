# Dorks Dilemma - Build Instructions

## Prerequisites

### Required Tools
- **ca65** - 6502 assembler (part of cc65 suite)
- **ld65** - Linker (part of cc65 suite)

### Optional Tools
- **xplus4** - VICE C16/Plus4 emulator for testing
- **Python 3** - For source parsing utilities

### Installing cc65 on macOS
```bash
brew install cc65
```

## Quick Build

```bash
cd build
make
```

This produces:
- `dorks_dilemma.prg` - C16/Plus4 executable
- `dorks_dilemma.map` - Memory map
- `dorks_dilemma.lst` - Assembly listing

## Manual Build

### Assemble
```bash
ca65 -t none --cpu 6502 -l dorks_dilemma.lst -o dorks_dilemma.o dorks_dilemma.asm
```

### Link
```bash
ld65 -C c16.cfg -o dorks_dilemma.prg -m dorks_dilemma.map dorks_dilemma.o
```

## Build Options

### Makefile Targets

| Target | Description |
|--------|-------------|
| `make` or `make all` | Build the PRG file |
| `make clean` | Remove build artifacts |
| `make run` | Build and run in xplus4 emulator |
| `make verbose` | Build with verbose output |

## Running in Emulator

### VICE (xplus4)
```bash
xplus4 build/dorks_dilemma.prg
```

### Alternative Emulators
- **YAPE** (Windows) - Open PRG file directly
- **Minus4** - Load with `LOAD "DORKS DILEMMA",8,1` then `RUN`

## Memory Layout

The linker configuration (`c16.cfg`) defines:

| Segment | Address | Purpose |
|---------|---------|---------|
| LOADADDR | $0FFF | PRG load address header |
| BASIC | $1001 | BASIC stub for auto-run |
| CODE | $100D+ | Main program code |

## BASIC Stub

The PRG includes a BASIC stub that auto-runs the machine code:
```basic
2024 SYS 4109
```

This calls the entry point at $100D (4109 decimal).

## Troubleshooting

### "Unresolved external" errors
Ensure all referenced labels are defined. Check the `.lst` file for undefined symbols.

### PRG doesn't run
1. Verify load address is $1001
2. Check BASIC stub points to correct SYS address
3. Confirm TED registers are initialized correctly

### Wrong colors/graphics
- C16 uses TED at $FF00, not VIC-II
- Screen RAM at $0C00, not $0400
- Character RAM at $3800

## Project Structure

```
Dorks_Dilemma_v2/
├── build/
│   ├── dorks_dilemma.asm    # Consolidated source
│   ├── c16.cfg              # Linker configuration
│   ├── Makefile             # Build script
│   └── parse_asm.py         # Source parser utility
├── C16_Recovered_Source/    # Original C16 files
├── C64_Original_Source_Disk/# Reference C64 files
└── docs/
    ├── BUILD.md             # This file
    └── CODE_STRUCTURE.md    # Code analysis
```

## Version History

- **v2.0** - Consolidated source with ca65 build system
- **v1.0** - Original recovered source (some files truncated)
