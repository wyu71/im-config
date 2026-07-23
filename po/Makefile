# To be run when files with translatable strings have changed.
# Navigate to the po/ directory and run "make im-config.pot"
# etc. as appropriate.
#
# The make and gettext packages need bo be installed.

POTFILESIN = $(shell grep -v '^\#' POTFILES.in)

im-config.pot:
	if (-f $@); then \
		echo "make: '$@' is up to date."; \
	else \
		make im-config.pot-update; \
	fi

im-config.pot-update:
	cd ..; xgettext -o po/im-config.pot --language=Shell $(POTFILESIN); \
	       xgettext --join-existing -o po/im-config.pot im-config.desktop.in

update-po:
	make im-config.pot-update
	for PO in *.po; do \
		msgmerge -U --backup=off $$PO im-config.pot; \
	done

# clean obsolete
clean-po:
	make im-config.pot-update
	for PO in *.po; do \
		msgattrib --no-obsolete -o $$PO $$PO; \
	done
