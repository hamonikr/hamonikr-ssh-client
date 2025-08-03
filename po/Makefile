# Makefile for Ásbrú Connection Manager translations

DOMAIN = asbru-cm
POTFILE = $(DOMAIN).pot
POFILES = ko.po
MOFILES = $(POFILES:.po=.mo)
LANGUAGES = ko

# Directories
SRCDIR = ..
LOCALEDIR = .

# Tools
XGETTEXT = xgettext
MSGMERGE = msgmerge
MSGFMT = msgfmt

.PHONY: all clean update-po extract-pot install

all: $(MOFILES)

# Extract translatable strings from source files
extract-pot:
	@echo "Extracting translatable strings..."
	@find $(SRCDIR)/lib -name "*.pm" > .tmp_files
	@find $(SRCDIR) -name "asbru-cm" >> .tmp_files
	$(XGETTEXT) --from-code=UTF-8 \
		--language=Perl \
		--keyword=__t \
		--keyword=__i18n \
		--keyword=__ni18n:1,2 \
		--package-name="$(DOMAIN)" \
		--package-version="6.4.0" \
		--msgid-bugs-address="https://github.com/asbru-cm/asbru-cm/issues" \
		--copyright-holder="Ásbrú Connection Manager team" \
		--output="$(POTFILE)" \
		--files-from=.tmp_files
	$(XGETTEXT) --from-code=UTF-8 \
		--language=Glade \
		--join-existing \
		--output="$(POTFILE)" \
		$(SRCDIR)/res/asbru.glade
	@rm -f .tmp_files
	@echo "POT file updated: $(POTFILE)"

# Update existing PO files with new POT
update-po: extract-pot
	@for po in $(POFILES); do \
		echo "Updating $$po..."; \
		$(MSGMERGE) --update $$po $(POTFILE); \
	done

# Compile PO files to MO files
%.mo: %.po
	@echo "Compiling $< to $@..."
	$(MSGFMT) $< -o $@

# Install MO files to locale directories
install: $(MOFILES)
	@for lang in $(LANGUAGES); do \
		mkdir -p $$lang/LC_MESSAGES; \
		mkdir -p $${lang}_*.UTF-8/LC_MESSAGES 2>/dev/null || true; \
		cp $$lang.mo $$lang/LC_MESSAGES/$(DOMAIN).mo; \
		for locale_dir in $${lang}_*.UTF-8; do \
			if [ -d "$$locale_dir" ]; then \
				cp $$lang.mo $$locale_dir/LC_MESSAGES/$(DOMAIN).mo; \
			fi; \
		done; \
		echo "Installed $$lang.mo"; \
	done

clean:
	rm -f $(MOFILES)
	rm -f .tmp_files
	rm -rf */LC_MESSAGES

help:
	@echo "Available targets:"
	@echo "  all         - Build all MO files"
	@echo "  extract-pot - Extract translatable strings to POT file"
	@echo "  update-po   - Update PO files with new strings from source"
	@echo "  install     - Install MO files to locale directories"
	@echo "  clean       - Remove generated files"