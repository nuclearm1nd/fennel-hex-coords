.PHONY: install-deps uninstall-deps compile compile-test clean clean-lua clean-test test
CURRENT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
ROCKS := .luamodules
MODULES := src
TST_MACRO_DIR := test/macros/*.fnl
SRCS := $(foreach sdir,${MODULES},$(wildcard ${sdir}/*/*.fnl))
OUTS := $(patsubst src/%.fnl,out/%.lua,${SRCS})
OUT_DIRS := $(dir ${OUTS})
TST_SRCS := $(wildcard test/*.fnl)
TST_OUTS := $(TST_SRCS:test/%.fnl=test-out/%.lua)

LUA_CMD ?= lua

export LUA_PATH="${CURRENT_DIR}?/?.lua;${CURRENT_DIR}${ROCKS}/share/lua/5.4/?.lua;${CURRENT_DIR}out/?.lua;;"

compile: ${ROCKS} ${OUT_DIRS} ${OUTS}

install-deps: ${ROCKS}

${ROCKS}:
	luarocks install --tree ${ROCKS} luaunit

uninstall-deps:
	rm -rfv .luamodules

${OUT_DIRS}:
	@mkdir -p $@

test-out:
	mkdir -pv test-out

${OUTS}: ${SRCS}
	fennel --compile $< > $@

test-out/%.lua: test/%.fnl
	fennel --add-macro-path ${TST_MACRO_DIR} --compile $< > $@

compile-test: test-out ${TST_OUTS}

test: compile compile-test
	@${LUA_CMD} test-out/main_test.lua

clean-lua:
	rm -rfv out

clean-test:
	rm -rfv test-out

clean: clean-lua clean-test
