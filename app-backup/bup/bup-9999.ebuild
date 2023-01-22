# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A highly efficient backup system based on the git packfile format"
HOMEPAGE="https://bup.github.io/ https://github.com/bup/bup"

PYTHON_COMPAT=( python3_{9,10,11} )
inherit python-single-r1
EGIT_REPO_URI="https://github.com/bup/bup.git"
inherit git-r3

LICENSE="LGPL-2"
SLOT="0"
IUSE="+doc test web"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	app-arch/par2cmdline
	sys-libs/readline:0
	dev-vcs/git
	$(python_gen_cond_dep '
		dev-python/fuse-python[${PYTHON_USEDEP}]
		dev-python/pylibacl[${PYTHON_USEDEP}]
		dev-python/pyxattr[${PYTHON_USEDEP}]
		web? ( www-servers/tornado[${PYTHON_USEDEP}] )
	')"
DEPEND="${RDEPEND}
	test? (
		dev-lang/perl
		net-misc/rsync
	)
	doc? ( app-text/pandoc )
"

# triggers permission errors with https://bugs.gentoo.org/590084 but the tests seem to pass anyway...
RESTRICT="test"

PATCHES=( "${FILESDIR}"/${P}-sitedir.patch )

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
