# makefile

#
# Patches/Installs/Builds DSDT patches for Dell G7-7588
#
# Created by RehabMan
#

# set build products
BUILDDIR=./build
AML_PRODUCTS=$(BUILDDIR)/SSDT-7588.aml
PRODUCTS=$(AML_PRODUCTS)

IASLFLAGS=-vw 2095 -vw 2146
IASL=iasl

.PHONY: all
all: $(PRODUCTS)

$(BUILDDIR)/SSDT-7588.aml: hotpatch/SSDT-7588.dsl
	$(IASL) $(IASLFLAGS) -p $@ $<

.PHONY: clean
clean:
	rm -f $(BUILDDIR)/*.dsl $(BUILDDIR)/*.aml


.PHONY: install
install: $(AML_PRODUCTS)
	$(eval EFIDIR:=$(shell ./mount_efi.sh))
	rm -f "$(EFIDIR)"/EFI/CLOVER/ACPI/patched/DSDT.aml
	rm -f "$(EFIDIR)"/EFI/CLOVER/ACPI/patched/SSDT-*.aml "$(EFIDIR)"/EFI/CLOVER/ACPI/patched/SSDT.aml
	cp $(AML_PRODUCTS) "$(EFIDIR)"/EFI/CLOVER/ACPI/patched
