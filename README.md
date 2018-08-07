# elm-freebsd

These are tools for building [Elm][] on FreeBSD. There are two main ways to use
them: building locally for personal use and building a package for
distribution.

## Building locally

First, you'll need a few packages installed:

    pkg install ca_root_nss compat8x-amd64 gcc gmake perl5 libiconv git

From here, the makefile will download and install the necessary versions of
[GHC][] and [Cabal][] and then use them to build Elm. The default (and
currently only) target is elm-0.18.

    make elm-0.18

> Note: Elm's build script tries to build everything in the right order, but
it's not entirely reliable. If you get an error building elm-reactor, try
iterating a couple of times and see if it sorts itself out.

By default, Haskell will be built in ./build and installed to ./local. Elm will
be built in ~/.local/share/elm. You'll probably want to symlink
~/.local/share/elm/Elm-Platform/0.18/.cabal-sandbox/bin/elm\* to ~/.local/bin/
or similar.

Three makefile variables allow you to customize the build/install directories:
BUILD\_PATH, LOCAL\_PATH, and ELM\_PREFIX. For example:

    make BUILD_PATH=/tmp LOCAL_PATH=/tmp/local ELM_PREFIX=$HOME/elm

## Building the package

If you want a package to install on other systems, run pkg.sh as root. This
will install GHC and Cabal to /tmp, build Elm in /usr/local/elm, and produce a
package archive in ./dist/. The version, install prefix, and maintainer email
can be configured; here are all options with their current defaults:

    ./pkg.sh -v 0.18 -p /usr/local/elm -m nobody@example.com

I recommend running pkg.sh in a clean jail to avoid cluttering up your machine
with build artifacts. The package will only contain the Elm binaries, plus
symlinks in /usr/local/bin. You can install it on another jail/machine with

    pkg add <path-or-url-to-pkg>

The package is named `elm-lang`, with a (spurious) origin of `lang/elm`.


[Elm]: http://elm-lang.org/
[GHC]: https://www.haskell.org/ghc/
[Cabal]: https://www.haskell.org/cabal/
