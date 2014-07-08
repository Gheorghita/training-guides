#!/bin/bash

function setup_directory {
    SET_LANG=$1
    shift
    for BOOK_DIR in "$@" ; do
        echo "   $BOOK_DIR"
        openstack-generate-docbook -l $SET_LANG -b $BOOK_DIR
    done
}


function setup_lang {
    SET_LANG=$1
    shift
    echo "Setting up files for $SET_LANG"
    echo "======================="
    echo "  Directories:"
    setup_directory $SET_LANG "$@"
}

function test_ja {
    setup_lang 'ja'

    setup_directory 'ja' 'training-guides'
    case "$PURPOSE" in
        test)
            openstack-doc-test -v --check-build -l ja
            RET=$?
            ;;
        publish)
            openstack-doc-test -v --publish --check-build -l ja
            RET=$?
            ;;
    esac
    if [ "$RET" -eq "0" ] ; then
        echo "... succeeded"
    else
        echo "... failed"
        BUILD_FAIL=1
    fi
}

function test_language () {

    case "$language" in
        all)
            # Currently no language added since there's nothing
            # translated yet. Japenese is just shown as an example.
            ;;
        ja)
            test_ja
            ;;
        *)
            BUILD_FAIL=1
            echo "Language $language not handled"
            ;;
    esac
}

function usage () {
    echo "Call the script as: "
    echo "$0 PURPOSE LANGUAGE1 LANGUAGE2..."
    echo "PURPOSE is either 'test' or 'publish'."
    echo "LANGUAGE can also be 'all'."
}

if [ "$#" -lt 2 ] ; then
    usage
    exit 1
fi
if [ "$1" = "test" ] ; then
   PURPOSE="test"
elif [ "$1" = "publish" ] ; then
   PURPOSE="publish"
else
    usage
    exit 1
fi
shift
BUILD_FAIL=0
for language in "$@" ; do
  echo
  echo "Building for language $language"
  echo
  test_language "$language"
done

exit $BUILD_FAIL
