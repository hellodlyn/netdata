#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck source=packaging/makeself/functions.sh
. "$(dirname "${0}")/../functions.sh" "${@}" || exit 1

# shellcheck disable=SC2015
[ "${GITHUB_ACTIONS}" = "true" ] && echo "::group::Building fping" || true

fetch "fping-5.1" "https://fping.org/dist/fping-5.1.tar.gz" \
    1ee5268c063d76646af2b4426052e7d81a42b657e6a77d8e7d3d2e60fd7409fe

export CFLAGS="-static -I/openssl-static/include"
export LDFLAGS="-static -L/openssl-static/lib"
export PKG_CONFIG_PATH="/openssl-static/lib/pkgconfig"

run ./configure \
  --prefix="${NETDATA_INSTALL_PATH}" \
  --enable-ipv4 \
  --enable-ipv6

cat > doc/Makefile << EOF
all:
clean:
install:
EOF

run make clean
run make -j "$(nproc)"
run make install

if [ "${NETDATA_BUILD_WITH_DEBUG}" -eq 0 ]; then
  run strip "${NETDATA_INSTALL_PATH}"/bin/fping
fi

# shellcheck disable=SC2015
[ "${GITHUB_ACTIONS}" = "true" ] && echo "::endgroup::" || true
