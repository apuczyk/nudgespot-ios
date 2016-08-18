#!/bin/sh
diff "${PODS_ROOT}/../Podfile.lock" "${PODS_ROOT}/Manifest.lock" > /dev/null
<<<<<<< HEAD
if [ $? != 0 ] ; then
    # print error to STDERR
    echo "error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation." >&2
=======
if [[ $? != 0 ]] ; then
    cat << EOM
error: The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.
EOM
>>>>>>> Fcm_additions
    exit 1
fi

