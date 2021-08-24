SUBDIRS = bootloader

INSTALLTARGETS = $(foreach target,$(SUBDIRS),install$(target))
CLEANTARGETS = $(foreach target,$(SUBDIRS),clean$(target))
DISTCLEANTARGETS = $(foreach target,$(SUBDIRS),distclean$(target))

.PHONY: all install run clean distclean $(SUBDIRS) $(CLEANTARGETS) $(DISTCLEANTARGETS)

all: PotatOS.img

PotatOS.img: $(SUBDIRS)
	@echo ===== $@ =====
	dd if=build of=PotatOS.img bs=512 count=91669 seek=2048 conv=notrunc
	@echo

$(SUBDIRS):
	@echo ===== $@ =====
	@$(MAKE) -C $@/
	@echo


run:
	qemu-system-x86_64 -cpu qemu64 -net none \
		-drive if=pflash,format=raw,unit=0,file=OVMF/OVMF_CODE-pure-efi.fd,readonly=on \
		-drive if=pflash,format=raw,unit=1,file=OVMF/OVMF_VARS-pure-efi.fd \
		-drive if=ide,file=PotatOS.img

install: $(INSTALLTARGETS)
	@echo ===== $@ =====
	# Final disk image containing OS + bootloader
	-dd if=/dev/zero of=PotatOS.img bs=512 count=93750
	parted PotatOS.img -s -a minimal mklabel gpt
	parted PotatOS.img -s -a minimal mkpart EFI FAT16 2048s 93716s
	parted PotatOS.img -s -a minimal toggle 1 boot
	@echo
	# Tmp partition
	-dd if=/dev/zero of=build bs=512 count=91669
	mformat -i build -h 32 -t 32 -n 64 -c 1
	@echo

$(INSTALLTARGETS):
	@echo ===== $@ =====
	@$(MAKE) -C $(patsubst install%,%,$@)/ install 
	@echo


# Clean target
clean: $(CLEANTARGETS)
	@echo ===== $@ =====
	-mdel -i build $(SUBDIRS)
	@echo

$(CLEANTARGETS):
	@echo ===== $@ =====
	@$(MAKE) -C $(patsubst clean%,%,$@)/ clean
	@echo

distclean: $(DISTCLEANTARGETS)
	@echo ===== $@ =====
	-rm PotatOS.img build
	@echo

$(DISTCLEANTARGETS):
	@echo ===== $@ ======
	@$(MAKE) -C $(patsubst distclean%,%,$@)/ distclean
	@echo

