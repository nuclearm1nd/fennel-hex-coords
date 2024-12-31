.PHONY: install-deps uninstall-deps test test-inner

CURRENT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
ROCKS := .luamodules
TST_MACRO_DIR := test/macros/?.fnl
FENNEL_PATH := "${CURRENT_DIR}src/?.fnl;${CURRENT_DIR}lib/?.fnl;;"
PACKAGE_PATH := "${CURRENT_DIR}${ROCKS}/share/lua/5.4/?.lua;;"
MACRO_PATH := "${TST_MACRO_DIR};${CURRENT_DIR}src/?.fnl;${CURRENT_DIR}lib/?.fnl;;"

LUA_CMD ?= lua

test: ${ROCKS} test-inner

test-inner: test/main_test.fnl
	@fennel --lua ${LUA_CMD} --add-fennel-path ${FENNEL_PATH} --add-package-path ${PACKAGE_PATH} --add-macro-path ${MACRO_PATH} $^

install-deps: ${ROCKS}

${ROCKS}:
	luarocks install --tree ${ROCKS} luaunit

uninstall-deps:
	rm -rfv .luamodules
