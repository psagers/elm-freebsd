#!/bin/sh

main ()
{
    version='0.19'
    elm_prefix='/usr/local/elm'
    maintainer='nobody@example.com'

    while getopts 'v:p:m:' arg; do
        case ${arg} in
            v) version="${OPTARG}";;
            p) elm_prefix="${OPTARG}";;
            m) maintainer="${OPTARG}";;
            *) usage "Unknown option: $arg";;
        esac
    done

    case "${version}" in
        0.18) full_version=0.18.0;;
        0.19) full_version=0.19.0;;
        *) usage "Unknown version: ${version}";;
    esac

    pkg install -y ca_root_nss compat8x-amd64 gcc gmake perl5 libiconv
    case "${version}" in
        0.18) pkg install -y git
    esac

    make BUILD_PATH=/tmp LOCAL_PATH=/tmp/local ELM_PREFIX=${elm_prefix} PREFIX=/usr/local elm-${full_version}

    if [ -e /usr/local/bin/elm ]; then
        mkdir -p dist
        echo_manifest > /tmp/elm-manifest.txt
        pkg create -v -o dist/ -M /tmp/elm-manifest.txt

        echo
        echo "elm-lang-${full_version}.txz is in ./dist."
        echo
    fi
}

usage ()
{
    echo "$0 [-v {0.18|0.19}] [-p elm_prefix] [-m maintainer-email]"

    if [ -n "$1" ]; then
        echo
        echo "  $1"
        echo
    else
        echo
        echo "elm_prefix is only used by Elm 0.18. It defaults to /usr/local/elm."
        echo
    fi

    exit 1
}

echo_manifest ()
{
    echo name: elm-lang
    echo version: "${full_version}"
    echo arch: amd64
    echo origin: lang/elm
    echo comment: "The Elm programming language."
    echo desc: "A delightful language for reliable webapps. Generate JavaScript with great performance and no runtime exceptions."
    echo www: http://elm-lang.org/
    echo maintainer: ${maintainer}
    echo prefix: /usr/local
    echo flatsize: `echo_flatsize`

    echo "files {"
    for cmd in /usr/local/bin/elm*; do
        if [ -L ${cmd} ]; then
            echo "    ${cmd}: -"
            cmd=`readlink -fn ${cmd}`
        fi
        echo "    ${cmd}: `sha256 -q ${cmd}`"
    done
    echo "}"
}

echo_flatsize ()
{
    { echo -n 0;
      for cmd in /usr/local/bin/elm*; do
          echo -n "+" `stat -L -f "%z" ${cmd}`;
      done;
      echo; } | bc
}


if [ `id -u` -ne 0 ]; then
    usage "This script must be run as root, preferably in a clean jail."
fi

main "$@"
