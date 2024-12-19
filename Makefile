.PHONY: install-deps uninstall-deps compile compile-test clean clean-lua clean-test test install
SRC_DIR := fnl
OUT_DIR := hex-coord
TST_DIR := test
TST_MACRO_DIR := ${TST_DIR}/macros/*.fnl
TST_OUT_DIR := test-lua
ROCKS := .luamodules
MODULES := modules
SRCS := $(wildcard ${SRC_DIR}/*.fnl)
OUTS := $(SRCS:${SRC_DIR}/%.fnl=${OUT_DIR}/%.lua)
TST_SRCS := $(wildcard ${TST_DIR}/*.fnl)
TST_OUTS := $(TST_SRCS:${TST_DIR}/%.fnl=${TST_OUT_DIR}/%.lua)
CURRENT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
LUA_CMD ?= lua

export LUA_PATH="${CURRENT_DIR}?/?.lua;${CURRENT_DIR}${ROCKS}/share/lua/5.4/?.lua;${CURRENT_DIR}${MODULES}/?.lua;;"

compile: ${ROCKS} ${OUT_DIR} ${OUTS}

install-deps: ${ROCKS}

${ROCKS}:
	luarocks install --tree ${ROCKS} luaunit

uninstall-deps:
	rm -rfv .luamodules

${OUT_DIR}:
	mkdir -pv ${OUT_DIR}

${TST_OUT_DIR}:
	mkdir -pv ${TST_OUT_DIR}

${OUT_DIR}/%.lua: ${SRC_DIR}/%.fnl
	fennel --compile $< > $@

${TST_OUT_DIR}/%.lua: ${TST_DIR}/%.fnl
	fennel --add-macro-path ${TST_MACRO_DIR} --compile $< > $@

compile-test: ${TST_OUT_DIR} ${TST_OUTS}

test: compile compile-test
	@${LUA_CMD} ${TST_OUT_DIR}/main_test.lua

clean-lua:
	rm -rfv ${OUT_DIR}

clean-test:
	rm -rfv ${TST_OUT_DIR}

clean: clean-lua clean-test

install:
ifndef DESTDIR
	@echo "DESTDIR is not defined"
endif
ifdef DESTDIR
	cp -r ${OUT_DIR} $(DESTDIR)
endif
