#!/bin/sh

SCRIPT=`readlink -f $0`
PATH=/usr/local/elm/Elm-Platform/0.18/.cabal-sandbox/bin:/usr/local/ghc7/bin:$PATH

install_ghc7 ()
{
    cd /tmp

    if [ -e ghc-7.10.3 ]; then
        rm -r ghc-7.10.3
    fi
    fetch "https://downloads.haskell.org/~ghc/7.10.3/ghc-7.10.3-x86_64-portbld-freebsd.tar.xz"
    tar -xf ghc-7.10.3-x86_64-portbld-freebsd.tar.xz

    cd ghc-7.10.3
    env CC=gcc ./configure --with-gcc=gcc --with-ld=/usr/local/bin/ld --prefix=/usr/local/ghc7
    gmake install
}

install_cabal ()
{
    if [ ! -e /tmp/cabal ]; then
        git clone https://github.com/haskell/cabal.git /tmp/cabal
    fi
    cd /tmp/cabal
    git checkout cabal-install-v1.22.9.0

    cd /tmp/cabal/cabal-install
    env CC=gcc GHC=/usr/local/ghc7/bin/ghc GHC_PKG=/usr/local/ghc7/bin/ghc-pkg PREFIX=/usr/local/ghc7 \
        ./bootstrap.sh --global --no-doc
}

build_elm ()
{
    mkdir -p /usr/local/elm
    cd /usr/local/elm

    fetch https://raw.githubusercontent.com/elm-lang/elm-platform/master/installers/BuildFromSource.hs
    if patch < `dirname $SCRIPT`/patch-BuildFromSource.hs; then
        runhaskell BuildFromSource.hs 0.18
    fi
}

link_elm ()
{
    for cmd in /usr/local/elm/Elm-Platform/0.18/.cabal-sandbox/bin/elm*; do
        [ -e /usr/local/bin/`basename $cmd` ] || ln -s $cmd /usr/local/bin/
    done
}

pkg install -y ca_root_nss compat8x-amd64 gcc gmake perl5 libiconv git

[ -e /usr/local/ghc7/bin/ghc ] || install_ghc7
[ -e /usr/local/ghc7/bin/cabal ] || install_cabal
build_elm && link_elm
