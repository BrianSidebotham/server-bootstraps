# Useful functions that can be reused throughout the server bootstraps

# libdir must already be set, otherwise we're in trouble.
if [ "${libdir}X" = "X" ]; then
    echo "libdir should be set" >&2
    exit 1
fi

source "${libdir}/functions.sh"

detect_os
