# elm-freebsd

These are tools for building [Elm][] on FreeBSD. There are two main ways to use
them: building locally for personal use and building a package for
distribution.

## Building locally

In order to bootstrap GHC 7.10, you'll need a few packages installed:

    pkg install ca_root_nss compat8x-amd64 gcc gmake perl5 libiconv

For Elm 0.18, you'll also need git.

From here, the makefile will download and install the necessary versions of
[GHC][] and [Cabal][] and then use them to build Elm. The default target is
elm-0.19, but elm-0.18 is also supported.

    make

Four makefile variables allow you to customize the build/install directories:

* **BUILD\_PATH**: Scratch directory for building GHC and Cabal.
* **LOCAL\_PATH**: Prefix directory for installing GHC and Cabal.
* **ELM\_PREFIX**: Directory for building Elm 0.18. This is ignored by 0.19.
* **PREFIX**: Standard prefix directory for installing (or symlinking) the Elm
  binaries.

The default values are equivalent to:

    make BUILD_PATH=$PWD/build \
         LOCAL_PATH=$PWD/local \
         ELM_PREFIX=$HOME/.local/share/elm \
         PREFIX=$HOME/.local

If you want to see what make is going to do before you jump in, just run `make
-n`. To clean up, you can run `make clean` or, more specifically, `make
clean-ghc` and `make clean-elm`.

## Building the package

If you want a package to install on other systems, run pkg.sh as root. This
will install GHC and Cabal to /tmp and produce a package archive in ./dist/.
Elm 0.18 will be built in /usr/local/elm and symlinked to /usr/local/bin/elm\*;
Elm 0.19 only has one binary, which will be built directly into /usr/local/bin.
The version, build prefix, and maintainer email can be configured; here are all
options with their current defaults:

    ./pkg.sh -v 0.19 -p /usr/local/elm -m nobody@example.com

(The -p option is ignored in this case, as 0.19 does not require it.)

For 0.18, I recommend running pkg.sh in a clean jail to avoid cluttering up
your machine with build artifacts; the package will only contain the Elm
binaries from /usr/local/elm/Elm-Platform/0.18/.cabal-sandbox/bin, plus
symlinks. 0.19 has a much cleaner build system that will only pollute /tmp.

You can install the package on another jail/machine with

    pkg add <path-or-url-to-pkg>

The package is named `elm-lang`, with a (spurious) origin of `lang/elm`.


[Elm]: http://elm-lang.org/
[GHC]: https://www.haskell.org/ghc/
[Cabal]: https://www.haskell.org/cabal/
