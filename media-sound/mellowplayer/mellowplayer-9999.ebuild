# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake flag-o-matic toolchain-funcs xdg-utils

MY_PN="MellowPlayer"

DESCRIPTION="Cloud music integration for your desktop"
HOMEPAGE="https://colinduquesnoy.gitlab.io/MellowPlayer"

if [[ ${PV} == 9999 ]];then
	inherit git-r3
	EGIT_REPO_URI="https://gitlab.com/colinduquesnoy/${MY_PN}"
else
	MY_P="${MY_PN}-${PV}"
	KEYWORDS="-* ~amd64"
	SRC_URI="https://gitlab.com/colinduquesnoy/${MY_PN}/-/archive/${PV}/${MY_P}.tar.bz2"
	S="${WORKDIR}/${MY_P}"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="widevine"
RESTRICT="mirror"

COMMON_DEPEND="
	>=dev-qt/qtquickcontrols2-5.9:5[widgets]
	>=dev-qt/qtquickcontrols-5.9:5[widgets]
	>=dev-qt/qtwebengine-5.9:5[-bindist,widgets]
	>=dev-qt/qttranslations-5.9:5
	>=dev-qt/qtgraphicaleffects-5.9:5"

DEPEND="
	${COMMON_DEPEND}
	dev-libs/libevent:0=
	>=dev-qt/linguist-tools-5.9:5
	media-libs/mesa"

RDEPEND="
	${COMMON_DEPEND}
	x11-libs/libnotify
	widevine? ( www-plugins/chrome-binary-plugins:* )"

BDEPEND="
	>=dev-util/cmake-3.10
	widevine? ( sys-devel/binutils:= )"

pkg_pretend() {
	if test-flags-CXX -std=c++17;then
		if tc-is-gcc; then
			[ $(gcc-major-version) -lt 6 ] && die "You need at least GCC 6.0 in order to build ${MY_PN}"
		fi
		if tc-is-clang; then
			[ $(clang-major-version) -lt 3.5 ] && die "You need at least Clang 3.5 in order to build ${MY_PN}"
		fi
	else
		die "You need a c++17 compatible compiler in order to build ${MY_PN}"
	fi
}

src_install() {
	cmake_src_install
	if use widevine; then
		# Create a symlink in order to use the Widevine plugin
		dodir /usr/$(get_libdir)/qt5/plugins/ppapi
		dosym ../../../chromium-browser/WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so \
			/usr/$(get_libdir)/qt5/plugins/ppapi/libwidevinecdm.so
	fi
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}
