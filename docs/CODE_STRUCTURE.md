# Dorks Dilemma - Code Structure Analysis

## Overview

Dorks Dilemma is a 1980s maze/puzzle game originally developed for the Commodore C16/Plus4. The source code was recovered from original floppy disks, with some files corrupted during extraction.

## Source File Organization

### C16 Recovered Source (51 .asm files)

The C16 source files were stored in a semicolon-separated format where `;` serves as both:
- Line separator between instructions
- Comment delimiter (when followed by `*` or descriptive text)

### C64 Original Source (43 .TXT files)

The C64 version contains properly formatted multi-line assembly with the same modular structure. Used as reference to reconstruct missing C16 code.

## Module Categories

### Core Game Logic
| File | Purpose |
|------|---------|
| `play-game.asm` | Main game loop, initialization |
| `game-over.asm` | Game over handling |
| `title-works.asm` | Title screen routines |
| `score-routines.asm` | Score calculation and display |

### Player/Character Management
| File | Purpose |
|------|---------|
| `move-pixel.asm` | Pixel-based player movement (4KB - largest) |
| `check-man.asm` | Collision detection for player |
| `animate-chars.asm` | Character animation (glop effects) |
| `death-code.asm` | Death sequence handling |

### Alien/Enemy Systems
| File | Purpose |
|------|---------|
| `aliens-mega-code.asm` | Alien AI and movement |
| `alien-chek-print.asm` | Alien collision and rendering |
| `killer-code.asm` | Killer enemy logic |

### Bomb/Weapon System
| File | Purpose |
|------|---------|
| `bomb-code.asm` | Time bomb mechanics |
| `filler-bomb.asm` | Explosion fill effect (**was truncated**) |

### Environment/Room Management
| File | Purpose |
|------|---------|
| `change-room.asm` | Room transition logic |
| `rooms-of-peril.asm` | Room hazard definitions |
| `init-rooms.asm` | Room initialization |
| `level-increase.asm` | Level progression |
| `decoder.asm` | Screen data decompression |

### Graphics & Display
| File | Purpose |
|------|---------|
| `raster-routines.asm` | Split-screen raster IRQ effects |
| `border.asm` | Border animation |
| `screen-init.asm` | Screen setup |
| `designer.asm` | Level designer tool |

### Jigsaw Puzzle System
| File | Purpose |
|------|---------|
| `jigsaw-code.asm` | Jigsaw piece mechanics |
| `edit-jigsaw.asm` | Jigsaw editor |
| `scatter.asm` | Piece scattering logic |

### Input/Control
| File | Purpose |
|------|---------|
| `joystik.asm` | Joystick reading (TED port) |
| `inkey.asm` | Keyboard input |
| `key-scan.asm` | Keyboard scanning |

### Utilities & Infrastructure
| File | Purpose |
|------|---------|
| `utils.asm` | Common utilities (XY, DELAY, RANDOM) |
| `irq.asm` | IRQ setup and handling |
| `tables.asm` | Lookup tables |
| `macros.asm` | Assembler macros |

### Data & Variables
| File | Purpose |
|------|---------|
| `main-vars.asm` | TED hardware equates |
| `vars.asm` | Zero page variables |
| `work-high.asm` | High memory variables |
| `alterables.asm` | Game-modifiable data |

## Memory Map (C16/Plus4)

```
$0002-$00C3   Zero Page Variables
$0400-$07BF   Screen Buffer
$0C00-$0FFF   Video RAM (screen)
$0800-$0BFF   Color RAM
$1000-$1FFF   Compressed Screen Data
$3800-$3FFF   Character Set (2KB)
$4000+        Game Code
```

## Key Hardware Differences (C16 vs C64)

| Feature | C16 (TED) | C64 (VIC-II + SID) |
|---------|-----------|-------------------|
| Graphics | TED $FF00 | VIC $D000 |
| Sound | TED 2-ch | SID 3-ch |
| Colors | 121 | 16 |
| Screen RAM | $0C00 | $0400 |
| Color RAM | $0800 | $D800 |
| Joystick | $FF08 | $DC00 |

## Recovered Missing Code

### filler-bomb.asm Reconstruction

The C16 `filler-bomb.asm` was truncated mid-file. The following routines were reconstructed from the C64 `FILLERBO.TXT`:

1. **FILBMB** - Bomb fill main routine (complete)
2. **CHKBMB** - Check bomb position validity (**MISSING - RESTORED**)
3. **CLEXP** - Clear explosion from screen (**MISSING - RESTORED**)
4. **FILLEX** - Fill expansion control (**MISSING - RESTORED**)

Address adaptations made:
- C64 `$429` → C16 `$0C29` (screen base offset)
- C64 `$2160` → C16 `$3960` (character RAM)

## IRQ System

The game uses a dual-raster IRQ system:

1. **RAST1** (line $C1) - Main play area
   - Multicolor mode
   - Character animation
   - Random number generation

2. **RAST2** (line $00) - Message area
   - 38-column mode for smooth scrolling
   - Joystick reading
   - Player/alien movement
   - Bomb updates

## Animation Systems

### Character Animation
- Glop effect using TED timer-based randomness
- 4-frame animation cycles for player and aliens
- Brick wall "breathing" animation

### Bomb Animation
- Charging animation (scrolling character data)
- Flash effect during countdown
- Random explosion character generation

## Build System

See [BUILD.md](BUILD.md) for build instructions.
