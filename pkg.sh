#!/bin/sh

echo_manifest ()
{
    echo name: elm-lang
    echo version: "0.18.0"
    echo arch: amd64
    echo origin: lang/elm
    echo comment: "The Elm programming language"
    echo desc: "The Elm programming language."
    echo www: http://elm-lang.org/
    echo maintainer: psagers@ignorare.net
    echo prefix: /usr/local
    echo flatsize: `echo_flatsize`

    echo "files {"
    for cmd in /usr/local/elm/Elm-Platform/0.18/.cabal-sandbox/bin/elm*; do
        echo "    $cmd: `sha256 -q $cmd`"
    done

    for cmd in /usr/local/elm/Elm-Platform/0.18/.cabal-sandbox/bin/elm*; do
        echo "    /usr/local/bin/`basename $cmd`: -"
    done
    echo "}"
}

echo_flatsize ()
{
    { echo -n 0;
      for cmd in /usr/local/elm/Elm-Platform/0.18/.cabal-sandbox/bin/elm*; do
          echo -n "+" `stat -f "%z" $cmd`;
      done;
      echo; } | bc
}

echo_manifest > /tmp/elm-manifest.txt
pkg create -o /tmp/ -M /tmp/elm-manifest.txt
ls -lh /tmp/elm-lang-0.18.0.txz
