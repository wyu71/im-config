PROGRAM	=	im-config
ifeq ($(wildcard debian/changelog),)
VERSION = VCS-$(shell date -u  +%Y%m%d%H%M)
else
VERSION = $(shell dpkg-parsechangelog --format dpkg|\
		sed -ne '/^Version/s/Version: *//p')
endif

FILES = \
	70im-config_launch \
	im-config.in \
	im-launch \
	share/common_function \
	share/logger_function \
	share/ui_function \
	$(wildcard data/*.conf) \
	$(wildcard data/*.x11_env) \
	$(wildcard data/*.x11_launch)

PRETESTS = $(addsuffix .pretest, $(FILES))

TESTS = $(addsuffix .test, $(FILES))

# escape  with \#
LANGS = $(shell grep -v '^\#' po/LINGUAS)

all: im-config im-config.desktop mo

im-config: im-config.in
	sed -e "s/@@VERSION@@/$(VERSION)/" <$< >$@

im-config.desktop: im-config.desktop.in
	msgfmt --desktop --template=$< -d po -o $@

po/locale/%/LC_MESSAGES/$(PROGRAM).mo: po/%.po
	mkdir -p po/locale/$*/LC_MESSAGES
	msgfmt -o $@ $<

# run test on all script first
%.pretest: %
	@/bin/sh -n $< ; echo $$? > $@

# stop if error was found
%.test: %.pretest
	@[ `cat $<` = "0" ]
	-touch $@

test:
	# check if any syntax check resulted in error
	@$(MAKE) $(PRETESTS)
	@$(MAKE) $(TESTS)
	-rm -f $(TESTS)
	-rm -f $(PRETESTS)
	echo "ALL TEST FINISHED"

mo:	$(addsuffix /LC_MESSAGES/$(PROGRAM).mo, $(addprefix po/locale/, $(LANGS)))

po:	$(addsuffix .po, $(addprefix po/, $(LANGS)))

foo:
	echo "$(addsuffix /LC_MESSAGES/$(PROGRAM).mo, $(addprefix po/locale/, $(LANGS)))"
	echo "-----"
	echo "$(addsuffix .po, $(addprefix po/, $(LANGS)))"

clean:
	-rm -f im-config
	-rm -f default/im-config
	-rm -f im-config.desktop
	rm -rf po/locale
	rm -f  po/*.po~ po/*.mo
	-rm -f $(PRETESTS)
	-rm -f $(TESTS)

distclean: clean

update:
	touch -t 200001010000 po/*.po
	$(MAKE) -C po update-po
	$(MAKE) -C po clean-po

.PHONY: all pot distclean clean mo update po test FORCE
