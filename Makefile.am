# This is a GNU -*- Makefile -*- fragment that is included by Automake
# Copyright 2019, Oath Inc.
# Licensed under the terms of the Apache-2.0 license.
# See the LICENSE file in https://github.com/yahoo/state-space-testing/blob/master/LICENSE for terms.

# [[FIXTHIS]] - ACLOCAL_AMFLAGS is evaluated by automake *before* make even runs
# It uses /bin/bash eval to evaluate the line ...
#    so make variables $(...) look like backticks
#    but make variables ${...} look like shell variables with defaults
#
# is a subshell
#    /usr/bin/libtoolize: line 3772: temerarious_flagship_datadir: command not found
#
# these must all be on a single line, no backslash continuations
#ACLOCAL_AMFLAGS = -I m4 -I ${temerarious_flagship_datadir:-/opt/tunitas/share/temerarious-flagship}/ac -I ${hypogeal_twilight_datadir:-/opt/scold/share/hypogeal-twilight}/m4
ACLOCAL_AMFLAGS = -I m4
AUTOMAKE_OPTIONS = no-define subdir-objects foreign

default:
# also configure.ac and TF_SUBMODULE_CONFIGURE
# SUBDIRS = @subdirs@
include @temerarious_flagship_datadir@/am/build.am

# These match with TF_WITH_MODULE in configure.ac
# You do not need them unless you are doing co-development of these packages *with* PrivacyChain SDK C++
DEVELOPMENT_AREAS = \
  $(module_json_prefix) \
  $(module_leveldb_prefix) \
  $(module_nonstd_prefix) \
  $(module_options_prefix) \
  $(module_posix_prefix) \
  $(module_rabinpoly_prefix) \
  $(module_std_prefix) \
  $(module_string_prefix) \
  $(module_sys_prefix) \
  $(module_uuid_prefix) \
  $(state_space_tooling_prefix) \
  $(tunitas_basics_prefix) \
  $(tunitas_butano_prefix) \
  $(hyperledger_fabric_sdk_prefix) \
  $(iab_privacychain_sdk_prefix) \
  $(end)
TESTING_AREAS = \
  $(module_cppunit_prefix) \
  $(module_rigging_prefix) \
  $(end)
INSTALLATION_AREAS = \
  $(nonstd_cppunit_prefix) \
  $(nonstd_gcc_prefix) \
  $(nonstd_jsoncpp_prefix) \
  $(nonstd_yaml_prefix) \
  $(std_scold_prefix) \
  $(std_tunitas_prefix) \
  $(std_hyperledger_fabric_prefix) \
  $(std_iab_privacychain_prefix) \
  $(end)

default: all

module_SOURCE_SET = $(none)

.PHONY: clean-local mostlyclean-local distclean-local
clean-local mostlyclean-local distclean-local::
clean-dependencies::
clean-local:: clean-dependencies

include src/tests/gravel/Makefrag.am
include src/tests/repsets/Makefrag.am
include src/tests/unit/Makefrag.am
include src/want/Makefrag.am

bin_PROGRAMS = \
  $(bin_full_of_gravel) \
  $(bin_reps_and_sets) \
  $(end)
sbin_PROGRAMS = $(none)
lib_LTLIBRARIES = $(none)
noinst_LTLIBRARIES = $(lib_libwant_la)
check_PROGRAMS = $(check_bin_unit)

include tests/unit/Makefrag.am
include tests/gravel/Makefrag.am
include tests/repsets/Makefrag.am
XFAIL_TESTS = \
  $(tests_unit_XFAIL_TESTS) \
  $(tests_gravel_XFAIL_TESTS) \
  $(tests_repsets_XFAIL_TESTS) \
  $(end)  
TESTS = \
  $(tests_unit_TESTS) \
  $(tests_gravel_TESTS) \
  $(tests_repsets_TESTS) \
  $(end)

SEARCHPATH = $(SEARCHPATH_SCOLD_MODULES)
LOADPATH   = $(LOADPATHPATH_SCOLD_MODULES)

# --- Mostly boilerplate beyond here
#
# -Wall      ... the language isn't complete without it
# -std=c++1y ... as close to C++14 and beyond as we can get
# -std=c++1z ... as close to C++17 and beyond as we can get
# -ggdb      ... and recall that -ggdb and -O2 don't play well together

Makefile_COMPILER_CPPFLAGS_SET =
Makefile_COMPILER_CFLAGS_SET   = -Wall @CFLAGS_gcc@   @CFLAGS_gdb@
Makefile_COMPILER_CXXFLAGS_SET = -Wall @CXXFLAGS_gcc@ @CXXFLAGS_gdb@
Makefile_COMPILER_LDFLAGS_SET  = -Wall @LDFLAGS_gcc@  @LDFLAGS_gdb@ @libstd_filesystem@

Makefile_nonstd_PACKAGE_CPPFLAGS_SET = @usr_local_CPPFLAGS@
Makefile_nonstd_PACKAGE_CFLAGS_SET   = @usr_local_CFLAGS@
Makefile_nonstd_PACKAGE_CXXFLAGS_SET = @usr_local_CXXFLAGS@
Makefile_nonstd_PACKAGE_LDFLAGS_SET  = @usr_local_LDFLAGS@

Makefile_PACKAGE_CPPFLAGS_SET = @CPPFLAGS_jsoncpp@
Makefile_PACKAGE_CFLAGS_SET   =   @CFLAGS_jsoncpp@
Makefile_PACKAGE_CXXFLAGS_SET = @CXXFLAGS_jsoncpp@
Makefile_PACKAGE_LDFLAGS_SET  =  @LDFLAGS_jsoncpp@

Makefile_nonstd_CHECK_CPPFLAGS_SET = 
Makefile_nonstd_CHECK_CFLAGS_SET   = 
Makefile_nonstd_CHECK_CXXFLAGS_SET = 
Makefile_nonstd_CHECK_LDFLAGS_SET  = 

Makefile_CHECK_CPPFLAGS_SET = @CPPFLAGS_cppunit@
Makefile_CHECK_CFLAGS_SET   = @CFLAGS_cppunit@
Makefile_CHECK_CXXFLAGS_SET = @CXXFLAGS_cppunit@
Makefile_CHECK_LDFLAGS_SET  = @LDFLAGS_cppunit@

AM_CPPFLAGS = $(PACKAGE_CPPFLAGS_SET)
AM_CFLAGS   = $(PACKAGE_CFLAGS_SET)
AM_CXXFLAGS = $(PACKAGE_CXXFLAGS_SET)
AM_LDFLAGS  = $(V_LDFLAGS_avoid.VERBOSE_Veq$(V))
AM_LIBTOOLFLAGS = $(V_LIBTOOLFLAGS_VERBOSE_Veq$(V))

# ----------------------------------------------------------------------------------------------------
# Later versions of temerarious-flagship [which?] provide these definitions implicitly
# 

# reminder: ${TOOL}FLAGS remains reserved to the command line; e.g. CPPFLAGS, CFLAGS, CXXFLAGS, LDFLAGS
PACKAGE_CPPFLAGS_SET = $(__DC_SEARCHPATH) $(Makefile_PACKAGE_CPPFLAGS_SET) $(Makefile_nonstd_PACKAGE_CPPFLAGS_SET) $(Makefile_COMPILER_CPPFLAGS_SET)
PACKAGE_CFLAGS_SET   =                    $(Makefile_PACKAGE_CFLAGS_SET)   $(Makefile_nonstd_PACKAGE_CFLAGS_SET)   $(Makefile_COMPILER_CFLAGS_SET)
PACKAGE_CXXFLAGS_SET =                    $(Makefile_PACKAGE_CXXFLAGS_SET) $(Makefile_nonstd_PACKAGE_CXXFLAGS_SET) $(Makefile_COMPILER_CXXFLAGS_SET)
PACKAGE_LDFLAGS_SET  = $(__DC_LOADPATH)   $(Makefile_PACKAGE_LDFLAGS_SET)  $(Makefile_nonstd_PACKAGE_LDFLAGS_SET)  $(Makefile_COMPILER_LDFLAGS_SET)

# Reminder: most of the 'CHECK_' series is incremental
#           it is appended to AM_{CPP,C,CXX}FLAGS
#
# Usage (in 'make check' code):
#
#     bin_unit_LDFLAGS = $(PACKAGE_LDFLAGS_SET) $(AND_CHECK_LDFLAGS_SET)
#     $(bin_unit_OBJECTS): AM_CPPFLAGS+=$(CHECK_CPPFLAGS_SET)
#     $(bin_unit_OBJECTS): AM_CXXFLAGS+=$(CHECK_CXXFLAGS_SET)
#
AND_CHECK_CPPFLAGS_SET = $(Makefile_CHECK_CPPFLAGS_SET) $(Makefile_nonstd_CHECK_CPPFLAGS_SET)
AND_CHECK_CFLAGS_SET   = $(Makefile_CHECK_CFLAGS_SET)   $(Makefile_nonstd_CHECK_CFLAGS_SET)  
AND_CHECK_CXXFLAGS_SET = $(Makefile_CHECK_CXXFLAGS_SET) $(Makefile_nonstd_CHECK_CXXFLAGS_SET)
AND_CHECK_LDFLAGS_SET  = $(Makefile_CHECK_LDFLAGS_SET)  $(Makefile_nonstd_CHECK_LDFLAGS_SET) 

CHECK_CPPFLAGS_SET = $(PACKAGE_CPPFLAGS_SET) $(AND_CHECK_CPPFLAGS_SET)
CHECK_CFLAGS_SET   = $(PACKAGE_CFLAGS_SET)   $(AND_CHECK_CFLAGS_SET)
CHECK_CXXFLAGS_SET = $(PACKAGE_CXXFLAGS_SET) $(AND_CHECK_CXXFLAGS_SET)
CHECK_LDFLAGS_SET  = $(PACKAGE_LDFLAGS_SET)  $(AND_CHECK_LDFLAGS_SET)

V_LIBTOOLFLAGS_VERBOSE_Veq0 = --silent
V_LIBTOOLFLAGS_VERBOSE_Veq1 = --verbose

# Whereas
#   AM_LDFLAGS is deprecating.
#   AM_LDFLAGS is variously used in automake theory.
# Do not use AM_LDFLAGS;
# though LDFLAGS remains reserved caller the top-level caller (of make).
#
# A catalog of the use of AM_LDFLAGS
# used by CXXLINK
#         which is used to make convenience libraries; e.g. libwant.la
#         this appears to be a leftover accident.
#         in this case there is libwant_la_LIBADD but no libwant_la_LDFLAGS
# NOT used by lib_lib${LIBRARY}_la_LINK, e.g. lib/libsomething.la
#             which is used to make final-link{ed,able} shared libraries.
# NOT used by bin_${PROGRAM}_LINK, e.g. bin/unit
#             which is used o make final-linked executables.
#
V_LDFLAGS_avoid.VERBOSE_Veq0 = $(empty)
V_LDFLAGS_avoid.VERBOSE_Veq1 = $(warning warning: $@, \
CXXLINK still uses the AM_LDFLAGS variable is which is deprecated,  instead, use \
$(subst .,_,$(subst -,_,$(@F)_LIBADD)) \
or if available, \
$(subst .,_,$(subst -,_,$(@F)_LDFLAGS)))
