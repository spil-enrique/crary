.PHONY: deps test
SHELL := /bin/bash	#to make sure we can use BASH shell (for piqi_src)
REBAR := rebar
DEPS := deps
APP := $(shell basename src/*.app.src .app.src)

export ERL_LIBS=${PWD}/${DEPS}/

# Generic entry-point targets, inherited by the parent
all: getdeps compile

# Dummy setup
setup:

# Replacement for go.sh files, starts the application
go:
	erl -pa ebin -s $(APP) -name $(APP)

# Gets the dependencies to the deps folder
getdeps::
	${REBAR} get-deps

docs::
	@mkdir -p DOC
	${REBAR} skip_deps=true doc

# Final make targets:

compile:
	@${REBAR} compile
	@${REBAR} skip_deps=true xref

quick:
	@${REBAR} skip_deps=true compile xref

# Gets the dependencies to the deps folder. It does try to compile them
deps:
	${REBAR} get-deps && ${REBAR} compile

# Cleans everything but the deps
clean: docsclean
	@-rm -f erl_crash.dump;
	${REBAR} clean
	rm -f test/ebin/*

docsclean:
	rm -f DOC/*.html DOC/*.css DOC/*.png DOC/edoc-info

# Cleans everything AND the deps
distclean: clean
	${REBAR} delete-deps

# Run the unit tests
test:
	${REBAR} skip_deps=true eunit

# Run Eunit tests of a specific module, you also don't need to specify the
# _eunit part of the module.
# Usage: 'make test/score_facade' will run tests from score_facade_eunit.erl
test/%:
	${REBAR} skip_deps=true eunit suites=$*_eunit

# While developing with vi, :!make dialyzer | grep '%:t' can be used to run dialyzer in the current file
dialyzer: clean compile
	@dialyzer -Wno_return -Wno_opaque -c ebin

typer: compile
	typer --show-exported -I deps/*/include -I include -pa deps/erlanglibs/ebin/ -r src/

