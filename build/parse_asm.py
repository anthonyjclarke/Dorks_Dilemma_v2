#!/usr/bin/env python3
"""
Dorks Dilemma Assembly Parser

Converts C16 semicolon-separated assembly format to proper multi-line format
and identifies missing code by comparing to C64 sources.
"""

import os
import re
from pathlib import Path

def parse_c16_asm(content):
    """
    Parse C16 assembly that uses semicolons as line separators.
    Format: text;text;text where ; followed by space is comment, ; alone is line break
    """
    lines = []

    # The C16 files use ; as both comment delimiter AND line separator
    # Pattern: when ; is followed by text that looks like code, it's a line break
    # when ; is followed by * or descriptive text, it's a comment

    # Split on semicolons that represent line breaks
    # Comments start with ;* or just ; followed by text

    i = 0
    current_line = ""
    in_string = False

    while i < len(content):
        char = content[i]

        if char == "'" or char == '"':
            in_string = not in_string
            current_line += char
        elif char == ';' and not in_string:
            # This is either a comment or line separator
            # Look ahead to see what follows
            rest = content[i+1:i+50] if i+1 < len(content) else ""

            # If followed by newline or nothing, end line
            if not rest or rest[0] == '\n':
                if current_line.strip():
                    lines.append(current_line.rstrip())
                current_line = ""
            # If followed by *, it's a comment on same line, then line break
            elif rest.startswith('*') or rest.startswith(' *'):
                # Comment - find the next ; or newline
                comment_end = rest.find(';')
                if comment_end == -1:
                    comment_end = len(rest)
                comment = rest[:comment_end].rstrip()
                current_line += ";" + comment
                lines.append(current_line.rstrip())
                current_line = ""
                i += comment_end
            # If followed by space then uppercase word or instruction, it's likely a comment
            elif rest.startswith(' ') and len(rest) > 1:
                # Check if this looks like a comment (description) or code
                words = rest.strip().split()
                if words and (words[0].isupper() or words[0].startswith('-') or
                             words[0].startswith('=') or words[0].startswith('>')):
                    # Likely a comment or divider
                    comment_end = rest.find(';')
                    if comment_end == -1:
                        comment_end = len(rest)
                    comment = rest[:comment_end].rstrip()
                    current_line += ";" + comment
                    lines.append(current_line.rstrip())
                    current_line = ""
                    i += comment_end
                else:
                    # Just a line break
                    lines.append(current_line.rstrip())
                    current_line = ""
            else:
                # Line break - new instruction follows
                if current_line.strip():
                    lines.append(current_line.rstrip())
                current_line = ""
        elif char == '\n':
            # Actual newline in source
            if current_line.strip():
                lines.append(current_line.rstrip())
            current_line = ""
        else:
            current_line += char

        i += 1

    # Don't forget last line
    if current_line.strip():
        lines.append(current_line.rstrip())

    return lines


def simple_parse(content):
    """
    Simpler parsing approach - split on ; and analyze each segment
    """
    lines = []

    # Remove the initial file header line if present
    content = content.strip()

    # Split on semicolons
    segments = content.split(';')

    for seg in segments:
        seg = seg.strip()
        if not seg:
            continue

        # Check if this is a comment line (starts with description text)
        # or actual code (starts with label, opcode, directive)

        # Comments typically are descriptions like "ALL THE TIME-BOMB STUFF"
        # or start with * like "* BOMB ALREADY ON ?"

        if seg.startswith('*'):
            # This is a comment continuation
            lines.append(';' + seg)
        elif seg.startswith('>') or seg.startswith('-'):
            # Divider or directive comment
            lines.append(';' + seg)
        elif seg.isupper() and ' ' in seg and not any(op in seg.upper() for op in
             ['LDA', 'LDX', 'LDY', 'STA', 'STX', 'STY', 'JSR', 'JMP', 'BNE', 'BEQ',
              'BCC', 'BCS', 'BMI', 'BPL', 'RTS', 'RTI', 'SEI', 'CLI', 'CLC', 'SEC',
              'ADC', 'SBC', 'AND', 'ORA', 'EOR', 'INC', 'DEC', 'INX', 'INY', 'DEX',
              'DEY', 'TAX', 'TAY', 'TXA', 'TYA', 'PHA', 'PLA', 'PHP', 'PLP', 'ASL',
              'LSR', 'ROL', 'ROR', 'CMP', 'CPX', 'CPY', 'BIT', 'NOP', '.BYTE', '.WORD',
              '*=', 'PUT', '.END']):
            # Likely a comment (all uppercase description)
            lines.append('; ' + seg)
        else:
            # Actual code
            lines.append(seg)

    return lines


def convert_file(input_path):
    """Convert a C16 .asm file to proper format"""
    with open(input_path, 'r', encoding='latin-1') as f:
        content = f.read()

    # Check if already in multi-line format (C64 style)
    if content.count('\n') > 10:
        # Already properly formatted
        return content.split('\n')

    return simple_parse(content)


def get_file_mapping():
    """Map C16 files to their C64 equivalents"""
    return {
        'alien-chek-print.asm': 'ALIENCHE.TXT',
        'aliens-mega-code.asm': 'ALIENSME.TXT',
        'animate-chars.asm': 'ANIMATEC.TXT',
        'bomb-code.asm': 'BOMBCODE.TXT',
        'border.asm': 'BORDER.TXT',
        'change-room.asm': 'CHANGERO.TXT',
        'check-man.asm': 'CHECKMAN.TXT',
        'command.asm': 'COMMAND.TXT',
        'decoder.asm': 'DECODER.TXT',
        'designer.asm': 'DESIGNER.TXT',
        'dumper.asm': 'DUMPER.TXT',
        'edit-jigsaw.asm': 'EDITJIGS.TXT',
        'filler-bomb.asm': 'FILLERBO.TXT',
        'hall-of-fame.asm': 'HALLOFFA.TXT',
        'hexer.asm': 'HEXER.TXT',
        'high-print.asm': 'HIGHPRIN.TXT',
        'init-rooms.asm': 'INITROOM.TXT',
        'inkey.asm': 'INKEY.TXT',
        'irq.asm': 'IRQ.TXT',
        'jigsaw-code.asm': 'JIGSAWCO.TXT',
        'joystik.asm': 'JOYSTIK.TXT',
        'macros.asm': 'MACROS.TXT',
        'main-vars.asm': 'MAINVARS.TXT',
        'message-stuff.asm': 'MESSAGES.TXT',
        'move-pixel.asm': 'MOVEPIXE.TXT',
        'des-irq.asm': 'DESIRQ.TXT',
        'vars.asm': 'VARS.TXT',
        'play-game.asm': 'PLAYGAME.TXT',
        'radar-scanner.asm': 'RADARSCA.TXT',
        'raster-routines.asm': 'RASTERRO.TXT',
        'rooms-of-peril.asm': 'ROOMSOFP.TXT',
        'variety.asm': 'VARIETY.TXT',
        'scatter.asm': 'SCATTER.TXT',
        'setup.asm': 'SETUP.TXT',
        'tables.asm': 'TABLES.TXT',
        'utils.asm': 'UTILS.TXT',
        'screen-init.asm': 'SCREENIN.TXT',
        'whooppee-message.asm': 'WHOOPPEE.TXT',
        'alterables.asm': 'ALTERABL.TXT',
        'death-code.asm': 'DEATHCOD.TXT',
        'game-over.asm': 'GAMEOVER.TXT',
        'title-works.asm': 'TITLEWOR.TXT',
        'score-routines.asm': 'SCOREROU.TXT',
        'work-high.asm': 'WORKHIGH.TXT',
        'sword!.asm': 'SWORD.TXT',
        'extra-memory.asm': 'EXTRAMEM.TXT',
        'killer-code.asm': 'KILLERCO.TXT',
        'level-increase.asm': 'LEVELINC.TXT',
        'des-ani.asm': 'DESANI.TXT',
        'magnificent.asm': 'MAGNIFIC.TXT',
    }


if __name__ == '__main__':
    # Test parsing
    c16_dir = Path('/Users/ant/PlatformIO/Projects/Dorks_Dilemma_v2/C16_Recovered_Source')
    c64_dir = Path('/Users/ant/PlatformIO/Projects/Dorks_Dilemma_v2/C64_Original_Source_Disk')

    # Test with filler-bomb.asm which we know is truncated
    test_file = c16_dir / 'filler-bomb.asm'
    if test_file.exists():
        lines = convert_file(test_file)
        print(f"Parsed {test_file.name}: {len(lines)} lines")
        for i, line in enumerate(lines[:20]):
            print(f"  {i+1}: {line}")
