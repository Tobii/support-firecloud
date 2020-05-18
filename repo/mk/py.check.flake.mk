# Adds a 'check-flake' internal target to run 'flake8'
# over SF_FLAKE_FILES (defaults to all committed and staged *.py files).
# The 'check-flake' target is automatically added to the 'check' target via SF_CHECK_TARGETS.
#
# For CI builds the flake8 executable must be installed using pip3 in the Brewfile.
# The arguments to the flake executable can be changed via FLAKE_ARGS.
#
# For convenience, specific files can be ignored
# via grep arguments given to SF_FLAKE_FILES_IGNORE:
# SF_FLAKE_FILES_IGNORE += \
#	-e "^path/to/dir/" \
#	-e "^path/to/file$" \
#
# NOTE transcrypted files are automatically ignored.
#
# ------------------------------------------------------------------------------

SF_IS_TRANSCRYPTED ?= false

# Expects flake8 to be in the path. This can be done by adding:
# pip3 install flake8 in the Brewfile.
FLAKE = flake8

FLAKE_ARGS +=

SF_FLAKE_FILES_IGNORE += \
	-e "^$$" \
	$(SF_VENDOR_FILES_IGNORE) \

SF_FLAKE_FILES += $(shell $(GIT_LS) . | \
	$(GREP) -e "\.py$$" | \
	$(GREP) -Fvxf <($(SF_IS_TRANSCRYPTED) || [[ ! -x $(GIT_ROOT)/transcrypt ]] || $(GIT_ROOT)/transcrypt -l) | \
	$(GREP) -Fvxf <($(GIT) config --file .gitmodules --get-regexp path | $(CUT) -d' ' -f2 || true) | \
	$(GREP) -v $(SF_FLAKE_FILES_IGNORE) | \
	$(SED) "s/^/'/g" | \
	$(SED) "s/$$/'/g")

SF_CHECK_TARGETS += \
	check-flake \

# ------------------------------------------------------------------------------

.PHONY: check-flake
check-flake:
	$(FLAKE) $(FLAKE_ARGS) $(SF_FLAKE_FILES)
