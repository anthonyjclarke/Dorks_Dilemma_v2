# Makefile for Dorks Dilemma C16/Plus4
# Uses ca65 assembler (cc65 suite)

# Assembler and linker
CA65 = ca65
LD65 = ld65

# Flags
CA65FLAGS = -t none --cpu 6502
LD65FLAGS = -C c16.cfg

# Source and output files
ASM_SRC = dorks_dilemma.asm
OBJ = dorks_dilemma.o
PRG = dorks_dilemma.prg
MAP = dorks_dilemma.map
LST = dorks_dilemma.lst

# Default target
all: $(PRG)

# Assemble
$(OBJ): $(ASM_SRC)
	$(CA65) $(CA65FLAGS) -o $@ -l $(LST) $<

# Link
$(PRG): $(OBJ) c16.cfg
	$(LD65) $(LD65FLAGS) -o $@ -m $(MAP) $<

# Clean
clean:
	rm -f $(OBJ) $(PRG) $(MAP) $(LST)

# Run in emulator (VICE xplus4)
run: $(PRG)
	xplus4 $(PRG)

# Verbose assembly with listing
verbose: $(ASM_SRC)
	$(CA65) $(CA65FLAGS) -v -l $(LST) -o $(OBJ) $<
	$(LD65) $(LD65FLAGS) -v -o $(PRG) -m $(MAP) $(OBJ)

.PHONY: all clean run verbose
