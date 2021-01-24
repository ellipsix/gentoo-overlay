# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{6,7,8} )

inherit python-single-r1

DESCRIPTION="A highly efficient backup system based on the git packfile format"
HOMEPAGE="https://bup.github.io/ https://github.com/bup/bup"
SRC_URI="https://github.com/bup/bup/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+doc test web"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	app-arch/par2cmdline
	sys-apps/acl
	sys-libs/readline:0
	dev-vcs/git
	$(python_gen_cond_dep '
		dev-python/fuse-python[${PYTHON_MULTI_USEDEP}]
		dev-python/pyxattr[${PYTHON_MULTI_USEDEP}]
		web? ( www-servers/tornado[${PYTHON_MULTI_USEDEP}] )
	')"
DEPEND="${RDEPEND}
	test? (
		dev-lang/perl
		net-misc/rsync
	)
	doc? ( app-text/pandoc )
"

# testing triggers permission errors (see https://bugs.gentoo.org/590084) but
# the tests should pass anyway, therefore we do not use RESTRICT=test
RESTRICT="mirror"

PATCHES=( "${FILESDIR}"/bup-py3-sitedir-r1.patch )

src_configure() {
	# only build/install docs if enabled
	export PANDOC=$(usex doc pandoc "")

	./configure || die
}

src_prepare() {
	eapply "${PATCHES[@]}"
	eapply_user

	# remove a module only needed for Python 2 compatibility
	rm lib/bup/py2raise.py
}

src_test() {
	emake test
}

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr DOCDIR="/usr/share/${PF}" SITEDIR="$(python_get_sitedir)" install
	python_optimize "${ED}"
}
