#!/bin/sh

main ()
{
    version=0.18
    prefix=/usr/local/elm
    maintainer=nobody@example.com

    while getopts v:m: arg; do
        case arg in
            v) version=${OPTARG};;
            p) prefix=${OPTARG};;
            m) maintainer=${OPTARG};;
            *) usage "Unknown option: $arg";;
        esac
    done

    elm_bin=${prefix}/Elm-Platform/${version}/.cabal-sandbox/bin
    manifest_version=`manifest_version ${version}`

    pkg install -y ca_root_nss compat8x-amd64 gcc gmake perl5 libiconv git
    make BUILD_PATH=/tmp LOCAL_PATH=/tmp/local ELM_PREFIX=${prefix} elm-${version}

    if [ -e ${elm_bin}/elm-reactor ]; then
        ln -sf ${elm_bin}/elm* /usr/local/bin/

        mkdir -p dist
        echo_manifest > /tmp/elm-manifest.txt
        pkg create -v -o dist/ -M /tmp/elm-manifest.txt

        echo
        echo "elm-lang-${manifest_version}.txz is in ./dist."
        echo
    fi
}

usage ()
{
    echo "$0 [-v version] [-p prefix] [-m maintainer-email]"
    if [ -n "$1" ]; then
        echo
        echo "  $1"
        echo
    fi

    exit 1
}

echo_manifest ()
{
    echo name: elm-lang
    echo version: "${manifest_version}"
    echo arch: amd64
    echo origin: lang/elm
    echo comment: "The Elm programming language."
    echo desc: "The Elm programming language."
    echo www: http://elm-lang.org/
    echo maintainer: ${maintainer}
    echo prefix: /usr/local
    echo flatsize: `echo_flatsize`

    echo "files {"
    for cmd in ${elm_bin}/elm*; do
        echo "    ${cmd}: `sha256 -q ${cmd}`"
    done

    for cmd in ${elm_bin}/elm*; do
        echo "    /usr/local/bin/`basename ${cmd}`: -"
    done
    echo "}"
}

# pkg requires three version components.
manifest_version ()
{
    echo -n ${version} | sed -E 's/^[[:digit:]]+\.[[:digit:]]+$/&.0/'
}

echo_flatsize ()
{
    { echo -n 0;
      for cmd in ${elm_bin}/elm*; do
          echo -n "+" `stat -f "%z" ${cmd}`;
      done;
      echo; } | bc
}


if [ `id -u` -ne 0 ]; then
    usage "This script must be run as root, preferably in a clean jail."
fi

main
