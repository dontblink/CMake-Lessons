# you can set this to 1 to see all commands that are being run
VERBOSE ?= 0
BUILDRESULTS ?= buildresults
LTO ?= 0
CROSS ?= 0
NATIVE ?= 0
DEBUG ?= 0
SANITIZER ?= 0

SUBPROJECT_DEP = subprojects/printf
CONFIGURED_BUILD_DEP = $(BUILDRESULTS)/build.ninja

INTERNAL_OPTIONS = 
OPTIONS = 

ifeq($(DEBUG),1)
	INTERNAL_OPTIONS += -Ddebug=false -Doptimization=2
else
	INTERNAL_OPTIONS += -Ddebug=true -Doptimization=g
endif

ifneq ($(NATIVE),)
	NATIVE_2 := $(subst :, ,$(NATIVE))
	INTERNAL_OPTIONS += $(foreach FILE,$(NATIVE_2),--native-file=build/native/$(FILE).txt)
endif

ifneq ($(CROSS),)
	CROSS_2 := $(subst :, ,$(CROSS))
	INTERNAL_OPTIONS += $(foreach FILE,$(CROSS_2),--cross-file=build/cross/$(FILE).txt)
endif

ifeq ($(LTO),1)
	INTERNAL_OPTIONS += -Db_lto=true -Ddisable-builtins=true
endif

ifneq ($(SANITIZER),NONE)
	INTERNAL_OPTIONS += -Db_sanitize=$(SANITIZER) -Db_lundef=false
endif

ifeq ($(VERBOSE),1)
export Q :=
export VERBOSE := 1
else
export Q := @
export VERBOSE := 0
endif

all: default 

.PHONY: default
default: | $(CONFIGURED_BUILD_DEP)
	$(Q)ninja -C $(BUILDRESULTS)

# Runs whenever the build has not been configured successfully
$(CONFIGURED_BUILD_DEP): | $(SUBPROJECT_DEP)
	$(Q) meson $(BUILDRESULTS) $(INTERNAL_OPTIONS) $(OPTIONS)

# This prerequisite will download subprojects if they don't exist
subprojects/printf/:
	$(Q) meson subprojects download

.PHONY: clean
clean:
	$(Q) if [ -d "$(BUILDRESULTS)" ]; then ninja -C buildresults clean; fi

.PHONY: distclean
distclean:
	$(Q) rm -rf $(BUILDRESULTS)

.PHONY: reconfig
reconfig: 
	$(Q) meson $(BUILDRESULTS) --reconfigure $(INTERNAL_OPTIONS) $(OPTIONS)

.PHONY: cppcheck
cppcheck: | $(BUILDRESULTS)/build.ninja
	$(Q) ninja -C $(BUILDRESULTS) cppcheck

.PHONY: cppcheck-xml
cppcheck-xml: | $(BUILDRESULTS)/build.ninja
	$(Q) ninja -C $(BUILDRESULTS) cppcheck-xml

.PHONY: complexity
complexity: | $(SUBPROJECT_DEP) $(CONFIGURED_BUILD_DEP)
	$(Q) ninja -C $(BUILDRESULTS) complexity

.PHONY: complexity-full
complexity-full: | $(SUBPROJECT_DEP) $(CONFIGURED_BUILD_DEP)
	$(Q) ninja -C $(BUILDRESULTS) complexity-full

.PHONY: complexity-xml
complexity-xml: | $(SUBPROJECT_DEP) $(CONFIGURED_BUILD_DEP)
	$(Q) ninja -C $(BUILDRESULTS) complexity-xml

.PHONY: scan-build
scan-build: | $(CONFIGURED_BUILD_DEP)
	$(Q) ninja -C $(BUILDRESULTS) scan-build

.PHONY: tidy
tidy: | $(CONFIGURED_BUILD_DEP)
	$(Q) ninja -C $(BUILDRESULTS) clang-tidy

.PHONY: format
format: | $(CONFIGURED_BUILD_DEP)
	$(Q) ninja -C $(BUILDRESULTS) format

.PHONY: format-patch
format-patch: | $(CONFIGURED_BUILD_DEP)
	$(Q) ninja -C $(BUILDRESULTS) format-patch

.PHONY: test
test: | $(CONFIGURED_BUILD_DEP)
	$(Q) ninja -C $(BUILDRESULTS) test

.PHONY: docs
docs: | $(CONFIGURED_BUILD_DEP)
	$(Q) ninja -C $(BUILDRESULTS) docs

.PHONY: package
package: default docs
	$(Q) ninja -C $(BUILDRESULTS) package
	$(Q) ninja -C $(BUILDRESULTS) package-native

.PHONY: coverage
coverage: 
	$(Q)if [ ! -e "$(BUILDRESULTS)/coverage/build.ninja" ]; then meson $(BUILDRESULTS)/coverage $(INTERNAL_OPTIONS) $(OPTIONS) -Db_coverage=true; fi
	$(Q) ninja -C $(BUILDRESULTS)/coverage test
	$(Q) ninja -C $(BUILDRESULTS)/coverage coverage
.PHONY : help
help :
	@echo "usage: make [OPTIONS] <target>"
	@echo "  Options:"
	@echo "    > VERBOSE Show verbose output for Make rules. Default 0. Enable with 1."
	@echo "    > BUILDRESULTS Directory for build results. Default buildresults."
	@echo "    > OPTIONS Configuration options to pass to a build. Default empty."
	@echo "    > LTO Enable LTO builds. Default 0. Enable with 1."
	@echo "    > CROSS Enable a Cross-compilation build. Form is arch:chip."
	@echo "			Example: make CROSS=arm:cortex-m3"
	@echo "			For supported chips, see build/cross/"
	@echo "Targets:"
	@echo "  default: Builds all default targets ninja knows about"
	@echo "  clean: cleans build artifacts, keeping build files in place"
	@echo "  distclean: removes the configured build output directory"
	@echo "  reconfig: Reconfigure an existing build output folder with new settings"
	@echo "Static Analysis:"
	@echo "    cppcheck: runs cppcheck"
	@echo "    cppcheck-xml: runs cppcheck and generates an XML report (for build servers)"
```

