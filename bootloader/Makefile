TARGET = bootloader

BUILD_DIR = build
SRCS_DIR = srcs
POSIX_UEFI = ../lib/posix-uefi

# ===================================================================================================================

# Makefile conf
SHELL = /bin/sh
.SUFIXES: # Suffixes used by the implicit rule, i.e none

# ALways x86_64
ARCH = x86_64
SRCS := $(wildcard $(SRCS_DIR)/*.c)
TMP := $(SRCS:.c=.o)
OBJS := $(TMP:$(SRCS_DIR)/%.o=$(BUILD_DIR)/%.o)

MYARCH = $(shell uname -m)
ifneq ($(ARCH),$(MYARCH))
	CC = $(ARCH)-elf-gcc
	LD = $(ARCH)-elf-ld
	OBJCOPY = $(ARCH)-elf-objcopy
else
	CC = gcc
	LD = ld
	OBJCOPY = objcopy
endif

# Setting up compiler flags
CFLAGS += -fshort-wchar -fno-strict-aliasing -ffreestanding -fno-stack-protector -fno-stack-check -I../lib/posix-uefi -I/usr/include -I/usr/include/efi -I/usr/include/efi/protocol -I/usr/include/efi/$(ARCH) -D__$(ARCH)__
CFLAGS += -DHAVE_USE_MS_ABI -mno-red-zone -maccumulate-outgoing-args
CFLAGS += -Wno-builtin-declaration-mismatch -fpic -fPIC

# Setting up linker flags
LDFLAGS += -nostdlib -shared -Bsymbolic -L$(POSIX_UEFI) -T link.ld
LIBS += $(POSIX_UEFI)/crt0.o -luefi -o $(BUILD_DIR)/$(TARGET).so
# Setting up objcopy flags
EFIARCH = efi-app-$(ARCH)

all: $(TARGET)


$(TARGET): $(BUILD_DIR)/$(TARGET).so
	$(OBJCOPY) -j .text -j .sdata -j .data -j .dynamic -j .dynsym  -j .rel -j .rela -j .rel.* -j .rela.* -j .reloc --target $(EFIARCH) --subsystem=10 $^ $@
	mcopy -i ../build $@ ::

$(BUILD_DIR)/$(TARGET).so: $(OBJS)
	$(LD) $(LDFLAGS) $^ $(LIBS)

$(BUILD_DIR)/%.o: $(SRCS_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

install:
	-mkdir build/

clean:
	-rm $(TARGET) $(BUILD_DIR)/*

distclean: clean
	-rm -d $(BUILD_DIR)
