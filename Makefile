DEFAULT_BUILD_PATH := $(.PARSEDIR)/build
DEFAULT_LOCAL_PATH := $(.PARSEDIR)/local
DEFAULT_ELM_PREFIX := ${HOME}/.local/share/elm

# GHC and Cabal are built in $(BUILD_PATH) and installed to $(LOCAL_PATH). Elm
# is built under $(ELM_PREFIX).
BUILD_PATH ?= $(DEFAULT_BUILD_PATH)
LOCAL_PATH ?= $(DEFAULT_LOCAL_PATH)
ELM_PREFIX ?= $(DEFAULT_ELM_PREFIX)

CC = /usr/local/bin/gcc
LD = /usr/local/bin/ld

FILES_PATH := $(.PARSEDIR)/files
ELM_CMDS = elm elm-make elm-package elm-reactor elm-repl
ELM_CMDS_PAT != echo -n "{"; echo -n $(ELM_CMDS) | tr " " ","; echo -n "}"

.BEGIN:
	@mkdir -p $(BUILD_PATH) $(LOCAL_PATH) $(ELM_PREFIX)

# The default target builds the latest supported version of Elm.
.MAIN: elm-0.18


#
# GHC 7.10.3 with cabal-install 1.22.9.0
#

GHC_7_10_TAR_PATH := $(BUILD_PATH)/ghc-7.10.3-x86_64-portbld-freebsd.tar.xz
GHC_7_10_BUILD_PATH := $(BUILD_PATH)/ghc-7.10.3
GHC_7_10_CABAL_TAR_PATH := $(BUILD_PATH)/cabal-install-v1.22.9.0.tar.gz
GHC_7_10_CABAL_BUILD_PATH := $(BUILD_PATH)/cabal-cabal-install-v1.22.9.0
GHC_7_10_PREFIX := $(LOCAL_PATH)/ghc-7.10

# Use this target if you just want GHC and Cabal to play with.
ghc-7.10: .PHONY $(GHC_7_10_PREFIX)/bin/cabal

$(GHC_7_10_PREFIX)/bin/ghc: $(GHC_7_10_BUILD_PATH)
	(cd $(GHC_7_10_BUILD_PATH) && \
	 env CC=$(CC) ./configure --with-gcc=$(CC) --with-ld=$(LD) --prefix=$(GHC_7_10_PREFIX) && \
	 gmake install)

$(GHC_7_10_BUILD_PATH): $(GHC_7_10_TAR_PATH) UNTAR

$(GHC_7_10_TAR_PATH):
	fetch -o $(.TARGET) "https://downloads.haskell.org/~ghc/7.10.3/`basename $(.TARGET)`"

$(GHC_7_10_PREFIX)/bin/cabal: $(GHC_7_10_CABAL_BUILD_PATH)/cabal-install/.cabal-sandbox/bin/cabal
	ln -sf $(.ALLSRC) $(.TARGET)

$(GHC_7_10_CABAL_BUILD_PATH)/cabal-install/.cabal-sandbox/bin/cabal: $(GHC_7_10_PREFIX)/bin/ghc $(GHC_7_10_CABAL_BUILD_PATH)
	(cd $(GHC_7_10_CABAL_BUILD_PATH)/cabal-install && \
	 env PATH=$(GHC_7_10_PREFIX)/bin:${PATH} CC=$(CC) \
	     PREFIX=$(GHC_7_10_PREFIX) EXTRA_CONFIGURE_OPTS="" \
	     ./bootstrap.sh --sandbox --no-doc)

$(GHC_7_10_CABAL_BUILD_PATH): $(GHC_7_10_CABAL_TAR_PATH) UNTAR

$(GHC_7_10_CABAL_TAR_PATH):
	fetch -o $(.TARGET) "https://github.com/haskell/cabal/archive/`basename $(.TARGET)`"


#
# Elm
#

# Elm 0.18
ELM_18_PREFIX := $(ELM_PREFIX)/Elm-Platform/0.18
ELM_18_BIN := $(ELM_18_PREFIX)/.cabal-sandbox/bin

# elm-reactor is the last binary built, so we use it as a proxy for the whole
# process.
elm-0.18: .PHONY $(ELM_18_BIN)/elm-reactor

$(ELM_18_BIN)/$(ELM_CMDS_PAT): $(GHC_7_10_PREFIX)/bin/cabal $(ELM_PREFIX)/BuildFromSource.hs
	(cd $(ELM_PREFIX) && \
	 env PATH=$(GHC_7_10_PREFIX)/bin:$(ELM_PREFIX)/Elm-Platform/0.18/.cabal-sandbox/bin:${PATH} \
		 runhaskell BuildFromSource.hs 0.18)


$(ELM_PREFIX)/BuildFromSource.hs:
	fetch -o $(.TARGET) https://raw.githubusercontent.com/elm-lang/elm-platform/master/installers/BuildFromSource.hs


#
# Util
#

UNTAR: .USE
	tar -C `dirname $(.TARGET)` -xf $(.ALLSRC)

clean: .PHONY clean-ghc clean-elm

clean-ghc: .PHONY
	rm -rf $(BUILD_PATH) $(LOCAL_PATH)

clean-elm: .PHONY
	rm -rf $(ELM_PREFIX)
