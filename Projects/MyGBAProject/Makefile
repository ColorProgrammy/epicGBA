# GBA Makefile
TARGET := MyGBAProject3
SOURCES := source
INCLUDES := include

# Tools
CC := C:/devkitPro/devkitARM/bin/arm-eabi-gcc.exe
OBJCOPY := C:/devkitPro/devkitARM/bin/arm-eabi-objcopy.exe

# Flags
CFLAGS := -mthumb -mthumb-interwork -O2 -Wall -std=c99 -I$(INCLUDES)
LDFLAGS := -mthumb -mthumb-interwork -specs=gba.specs

# Files
CFILES := $(SOURCES)/main.c
OBJFILES := main.o

# Rules
all: $(TARGET).gba

$(TARGET).gba: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@
	@echo ROM created: $(TARGET).gba

$(TARGET).elf: $(OBJFILES)
	$(CC) $(LDFLAGS) -o $@ $^

main.o: $(SOURCES)/main.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o *.elf *.gba

.PHONY: all clean
