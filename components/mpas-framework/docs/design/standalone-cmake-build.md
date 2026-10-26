# Design Document: Standalone CMake builds for MPAS components

## Summary

Standalone builds of MPAS-Ocean, MPAS-Seaice and MALI use a recursive, in-source Make build.
Polaris, Compass and component developers all depend on it. The build races under `make -j`, and
every Fortran module dependency is written by hand. Its compiler flags are maintained separately
from the machine files E3SM maintains. Coupled E3SM builds of the same code already use CMake,
through CIME.

This design extends the coupled CMake build so that it also runs without CIME. Coupled and
standalone builds share one set of source lists and build functions. A standalone build takes
compilers and flags from E3SM's CIME machine files, or from compiler presets on machines CIME
does not know. It writes the files that Polaris and Compass read to the same relative paths as
today. Once both have switched, the Make build is removed.

The work lands as a series of PRs: six in E3SM and one each in Polaris and Compass
([Work packages](#work-packages)). Coupled builds stay bit-for-bit (BFB) throughout. All three
components are near the end of their life in E3SM, but the pain is daily and the human effort is
small ([Value and cost](#value-and-cost)).

This document also sets where MPAS design documents live, and it is the first one written there
([Requirement: A home for MPAS design documents](#requirement-a-home-for-mpas-design-documents)).

---

## Value and cost

*Date last modified: 2026-10-26.*

MPAS-Ocean is close to being replaced by Omega. MPAS-Seaice is slated for deprecation in E3SM v5,
and MALI's role in E3SM v5 is undecided. The work therefore has to pay for itself in the time
these components have left.

### Pain in the meantime

- **Every standalone build goes through Make.** That includes each Polaris and Compass build and
  each developer build. During the Omega transition, Polaris keeps building MPAS-Ocean to compare
  it with Omega.
- **Make maintenance does not stop.** Since January 2024, 25 commits by 14 developers have had to
  edit MPAS Makefiles. Only 5 of them also edited a `.cmake` list. Most of the rest added
  hand-written module dependencies, which CMake works out for itself.
- **Some of those commits fixed the Make build itself.** One added a missing dependency that was
  "only exposed with parallel invocation of make"
  ([f6008b8664](https://github.com/E3SM-Project/E3SM/commit/f6008b8664), 2025). Others added a
  missing `endif` ([5d454da4cf](https://github.com/E3SM-Project/E3SM/commit/5d454da4cf), 2024),
  added Cray OpenMP and link flags (2024), and worked around an ifx preprocessor bug (2026).
- **New compilers mean new targets.** Every new compiler or machine needs a new Make target, and
  an ifx target is in progress now.
- **Polaris keeps two build paths.** Omega builds with CMake and MPAS-Ocean with Make, each with
  its own per-machine settings (`<compiler>_<mpi>_target`). One CMake path removes one of them.
- **Coupled builds have two hazards of their own** ([Problems](#problems)). Edits to included
  registry files do not trigger regeneration, and a leftover in-source build silently shadows
  generated files. WP1 fixes both for every coupled case that still contains MPAS components.
- **Standalone MALI has users outside E3SM v5.** Compass builds standalone MALI for current work,
  such as ISMIP7 calibration, that does not depend on MALI's role in E3SM v5.

### Cost, with AI help

Most of the work is mechanical, because the inputs already exist: the source lists are in the
coupled `.cmake` files, the flags are in the Make targets, and the machine settings are in
`cime_config`. Claude Code writes the CMake, runs the structural diffs, and drives the Polaris and
Compass suites. People spend their time on four things:

- agreeing on the decisions;
- reviewing PRs;
- confirming BFB results;
- coordinating with Polaris, Compass and MALI-Dev.

Estimated human time, to be checked against WP1's actual cost:

| WP | Human work | Estimate |
| --- | --- | --- |
| WP0 | MPAS developers review this document | one round of comments and one meeting |
| WP1 | PR review and coupled BFB confirmation | 1-2 days |
| WP2 | PR review and Polaris BFB runs on three machines | 3-5 days |
| WP3 | PR review and Polaris sea-ice runs | 1 day |
| WP4 | PR review, Albany builds and Compass runs | 2-3 days |
| WP5 | Workflow review | half a day |
| WP6a, WP6b | Polaris and Compass PR review, plus rebaselining | 1-2 days each |
| WP7 | Review of deletions | half a day |

In total, that is two to three person-weeks, spread over several people and several months.

### Limits that keep the cost down

- Each work package pays off on its own. None exists only for long-term goals.
- The most valuable work comes first: WP1 (coupled fixes) and WP2 (MPAS-Ocean for Polaris).
- WP2 delivers the standalone framework pieces with MPAS-Ocean as their first user. If MPAS-Ocean
  retired before WP2 landed, the same pieces would land with MPAS-Seaice or MALI instead.
- WP3 and WP4 go ahead only if the sea-ice and land-ice teams want them. A component retired
  before its work package is skipped.
- The port aims at parity, with no new build features ([Decisions](#decisions), D8). The WP8
  follow-ups happen only on request.

---

## Open Questions

*Date last modified: 2026-10-26.*

These questions need agreement from MPAS developers. Each one cites the decision it would settle.

1. **Value** (D11): do MPAS developers agree that the work is worth its cost
   ([Value and cost](#value-and-cost))?
2. **Documentation home** (D0): do MPAS developers accept the convention in
   [MPAS design documents](index.md)?
3. **Machine settings** (D2): is it enough on every machine Polaris supports to read CIME's macro
   files directly, with an environment the caller loads? Or does MPAS need Omega's throwaway CIME
   case?
4. **Real promotion** (D3): should standalone builds keep `-fdefault-real-8` and its equivalents
   permanently, or converge on the coupled flags? If they converge, when?
5. **SHTNS**: is self-attraction and loading through SHTNS used enough to justify building FFTW
   and SHTNS in-tree?
6. **Single-file features** (D8): do the owners want PAPI, MAGMA, CUBLAS and GPU-aware MPI ported?
7. **`core_sw` and `core_test`**: the Make build cannot build these, because it detects only the
   three components. Should they be deleted, or should `core_test` come back as framework tests?
8. **Stale `Depends` entries**: `Depends.gnu.cmake` and `Depends.craygnu.cmake` de-optimize
   `core_seaice/column/ice_shortwave.f90`, which no longer exists. Should the entries be deleted,
   or retargeted at `icepack_shortwave.F90`? Retargeting is not BFB.
9. **Review**: who reviews each work package, and does MALI-Dev want WP4 to land there first?

---

## Requirements

*Date last modified: 2026-10-26. Contributors: Xylar Asay-Davis, with Claude Code.*

---

### Requirement: A home for MPAS design documents

MPAS design documents, including this one, must have one documented location. That location must
be versioned with the code, reviewable in pull requests, and published with E3SM's documentation.

**Design resolution.** [MPAS design documents](index.md) sets the convention:

- a design for one component goes in that component's `docs/design/`;
- a design for the framework, or one that spans components, goes in
  `components/mpas-framework/docs/design/`.

WP0 creates the framework's documentation tree. E3SM's documentation site picks it up through its
existing `components/*/mkdocs.yml` glob. Rejected alternatives are in [Decisions](#decisions), D0.

---

### Requirement: Standalone out-of-source builds

MPAS-Ocean, MPAS-Seaice and MALI must each build standalone with CMake, in a build directory
outside the source tree. Builds from one checkout must not interfere with each other, whether they
are of the same component or different ones.

**Design resolution.** Each component gets a thin `CMakeLists.txt` that calls the shared
standalone setup ([Build structure](#build-structure)).

---

### Requirement: Correct parallel and incremental builds

A build must succeed at any `-j`. After a change to any source, include or registry file, an
incremental build must rebuild exactly what depends on that file.

**Design resolution.** CMake's Fortran scanner orders modules, and preprocessing of sources and
registries records dependency files
([Preprocessing and generated code](#preprocessing-and-generated-code)).

---

### Requirement: One build description

Coupled and standalone builds must share one source list per component and one set of build
functions. Adding a source file to a component must take one edit.

**Design resolution.** [Build structure](#build-structure).

---

### Requirement: Machine settings from E3SM

On machines that CIME supports, a standalone build must take its compilers and flags from E3SM's
machine files. A fix made there must reach standalone builds with no second edit.

**Design resolution.** Machine mode ([Toolchain](#toolchain)).

---

### Requirement: Builds without a CIME machine

A standalone build must also work where CIME has no machine entry, such as laptops, conda
environments and CI containers.

**Design resolution.** Generic mode ([Toolchain](#toolchain)).

---

### Requirement: Downstream run-time paths unchanged

After a build, the build directory must contain the files that Polaris and Compass read today, at
the same relative paths: the executable, `default_inputs/` and `src/Registry_processed.xml`.

**Design resolution.** [Targets and layout](#targets-and-layout).

---

### Requirement: Parity for options in use

Every Make option that has users or live code must have a CMake equivalent.

**Design resolution.** [Options](#options) maps each option. Dropped options are in
[Decisions](#decisions), D8.

---

### Requirement: Coupled builds stay bit-for-bit

No work package may change coupled E3SM answers or coupled compile flags.

**Design resolution.** [Testing](#testing).

---

### Requirement: The Make build is retired

Once Polaris and Compass build with CMake, the Make build must be removed.

**Design resolution.** WP7 ([Work packages](#work-packages)).

---

### Desired: Install and package configuration (future)

A standalone build should be able to install to a prefix and export a CMake package config.

**Design resolution.** WP8, on request.

---

## Out of scope

- MOAB in standalone builds.
- Building the coupled model without CIME.
- The upstream MPAS-Model (NCAR) build.

---

## Build structure

Coupled builds enter through `build_mpas_models()` in `components/cmake/build_mpas_model.cmake`.
Standalone builds enter through `components/mpas-<component>/CMakeLists.txt`. Both reach
`components/mpas-framework/src/CMakeLists.txt`, where a variable `MPAS_BUILD_MODE` (`E3SM` or
`STANDALONE`) selects the mode-specific pieces.

```text
coupled (CIME)                        standalone (new)
components/CMakeLists.txt             components/mpas-<component>/CMakeLists.txt
  build_mpas_models()                   toolchain and dependency setup
  MPAS_BUILD_MODE=E3SM                  MPAS_BUILD_MODE=STANDALONE
            \                              /
             v                            v
      components/mpas-framework/src/CMakeLists.txt (shared)
        ezxml, tools, framework, operators
        registry -> generated .inc, default namelists and streams
        core_<core>/<core>.cmake: shared source lists + mode-specific additions
```

| Piece | Coupled | Standalone |
| --- | --- | --- |
| Compilers, flags, per-file overrides | `${CASEROOT}/Macros.cmake`, `Depends.*.cmake` | the same files read from `cime_config/machines/` (machine mode), or compiler presets (generic mode) |
| PIO | `spio` target from `FindPIO.cmake` | an installed SCORPIO found by a find module, or an in-tree build |
| Time manager, constants, timers | `csm_share` | `external/esmf_time_f90`, the local `shr_kind_mod` and `shr_const_mod` copies, native or GPTL timers |
| Driver | MCT driver in `components/mpas-*/driver/` | `mpas-framework/src/driver/` (`mpas.F`, `mpas_subdriver.F`) |
| Mode-specific defines | `-Dcoupled`, `MPAS_NO_LOG_REDIRECT`, `MPAS_NO_ESMF_INIT`, `MPAS_ESM_SHR_CONST`, `MPAS_PERF_MOD_TIMERS` | `MPAS_NATIVE_TIMERS` or `MPAS_GPTL_TIMERS`, `MPAS_GIT_VERSION` |
| Ocean init mode | excluded | included by default |
| Outputs | `e3sm.exe` | `<core>_model` and the staged layout ([Targets and layout](#targets-and-layout)) |

Everything else is shared:

- the framework, operator, ezxml and tool sources;
- each component's source list, including the submodule sources that coupled builds already
  compile directly;
- registry processing, and namelist and streams generation;
- per-component defines such as `CORE_OCEAN`, the Albany flags and `USE_LAPACK`;
- per-file no-optimization and `-qnosmp` handling.

Generated files sit at the same build-tree paths in both modes (`core_<core>/...`), so the
`Depends.*.cmake` per-file overrides apply to both.

**Rationale.** A separate standalone CMake tree would be a third copy of every source list, after
the Makefiles and the coupled `.cmake` files ([Decisions](#decisions), D1).

---

## Toolchain

**Machine mode** is chosen with `MPAS_CIME_MACHINE`, `MPAS_CIME_COMPILER` and `MPAS_CIME_MPILIB`.

- It includes the CIME macro files from `cime_config/machines/cmake_macros/`, in CIME's order:
  `universal`, `<compiler>`, `<machine>`, `<machine>_<compiler>`, `post_process`.
- The macros are read once inside a function before `project()`, to choose compilers and build
  type, and again afterwards for flags, as in `components/CMakeLists.txt`. The `Depends.*.cmake`
  files follow.
- The setup code sets the inputs that CIME normally provides: `MACH`, `COMPILER`, `MPILIB`,
  `DEBUG`, `compile_threaded`, `COMP_NAME` and `SRCROOT`.
- No case, no Python and no `cime` submodule are needed.
- The caller loads the environment first, using the Polaris or Compass load script, the machine's
  modules, or `get_case_env`. The macros read variables that the modules set, such as
  `NETCDF_PATH`, `PNETCDF_PATH` and `CRAY_LIBSCI_PREFIX_DIR`.

**Generic mode** applies when no machine is given.

- Presets are keyed on `CMAKE_<LANG>_COMPILER_ID`: GNU, Intel, IntelLLVM, Cray and NVHPC for
  Fortran, and GNU and Clang/AppleClang for C.
- The presets reproduce the flags of the Make targets that are still in use.
- Compilers default to the MPI wrappers on `PATH`.

In both modes, `MPAS_EXTRA_<LANG>_FLAGS` is appended after the macros, because `universal.cmake`
clears `CMAKE_<LANG>_FLAGS`.

**Rationale.** Including the macro files directly brings every machine fix that E3SM makes,
without the cost of Omega's configure-time CIME case ([Decisions](#decisions), D2). The generic
presets serve machines that CIME does not know. They are also the reference for showing BFB
against Make (D3).

---

## Dependencies

- **MPI**: compile with the MPI wrappers, as both Make and CIME do.
- **NetCDF-C, NetCDF-Fortran, PnetCDF**: find modules that honor `<Pkg>_ROOT`, and Make's
  `NETCDF`, `NETCDFF` and `PNETCDF` during the transition.
- **SCORPIO**: a find module that accepts `PIO_ROOT` and the legacy `PIO`, and links `piof`,
  `pioc` and any bundled GPTL. It replaces Make's `pio_test` target.
- **SCORPIO features**: ADIOS and HDF5 support are detected with `try_compile` instead of being
  assumed. Only PIO 2 is supported (D7). An optional `MPAS_BUILD_SCORPIO=ON` builds
  `externals/scorpio` in-tree, as Omega does (WP5).
- **OpenMP**: the macros' threading flags in machine mode, and `find_package(OpenMP)` in generic
  mode. This replaces `openmp_test`.
- **Optional**: LAPACK/BLAS, Albany (`find_package(Albany)`, as coupled builds already use), GPTL,
  SHTNS and FFTW, and PAPI.

---

## Preprocessing and generated code

- **Sources**: every `.F` file goes through external `cpp -P -traditional`, as in coupled builds
  (D4).
- **Source dependencies**: a `DEPFILE` (`-MD -MF`) re-preprocesses a source whenever one of its
  `.inc` files changes. With Makefile generators, `DEPFILE` needs CMake 3.20 or later, so coupled
  mode guards it (D10).
- **Registry**: `Registry.xml` is preprocessed with a `DEPFILE`, so every included XML file is
  tracked.
- **Registry parser**: the parser takes the core name, executable name and git version on its
  command line. Every `.inc` file it generates is declared as an output.
- **Include paths**: `#include "../inc/<file>.inc"` becomes `#include "<file>.inc"`. CMake adds
  `<build>/core_<core>/inc` to the include path, and the Make build adds `src/inc` for as long as
  it lasts.
- **In-source guard**: standalone configure stops if it finds in-source Make products
  (`src/inc/`, `Registry_processed.xml`, or `*.mod` files in source directories).
- **Module order**: CMake's Fortran scanner orders modules, so no module dependency is written by
  hand.

**Rationale.** `cpp` looks for a quoted include next to the source file before it tries any `-I`
path. A leftover in-source Make build's `src/inc/` therefore shadows the generated files of any
CMake build ([Problems](#problems)).

---

## Targets and layout

- **`ezxml`**: an object library shared by the framework and the tools.
- **Tools**: `parse`, `namelist_gen` and `streams_gen`.
- **`esmf_time`**: built only in standalone mode.
- **Framework and operators library**: called `common` today.
- **One library per component.**
- **`<core>_model`**: built only in standalone mode.
- **One component per tree**: a standalone tree builds one component (D5), while the shared
  machinery still builds several for coupled cases.
- **Layout**: after the build, the tree mirrors what downstream reads from the component directory
  today (D6):

```text
<build>/
  ocean_model
  default_inputs/namelist.ocean.forward, streams.ocean.forward, ...
  src/Registry_processed.xml
```

Polaris and Compass point their model path at the build directory, with no change at run time.

---

## Options

| Make | CMake (proposed names) | Notes |
| --- | --- | --- |
| `<target>` (`gfortran`, `gnu-cray`, ...) | `MPAS_CIME_MACHINE`, `MPAS_CIME_COMPILER`, `MPAS_CIME_MPILIB`, or `CMAKE_<LANG>_COMPILER` | machine or generic mode |
| `DEBUG=true` | `CMAKE_BUILD_TYPE=Debug` | adds `-DMPAS_DEBUG` |
| `OPENMP=true` | `MPAS_OPENMP=ON` | maps to `compile_threaded` |
| `OPENACC=true`, `OPENMP_OFFLOAD=true` | `MPAS_OPENACC`, `MPAS_OPENMP_OFFLOAD` | GPU validation is WP8 |
| `PRECISION=single` | `MPAS_DOUBLE_PRECISION=OFF` | upstream MPAS-Model's name |
| promotion flags in each target | `MPAS_REAL_PROMOTION` | D3 |
| `USE_PIO2`, `HAVE_ADIOS`, `HAVE_HDF5` | detected | PIO 2 only |
| `PIO`, `NETCDF`, `NETCDFF`, `PNETCDF` | `<Pkg>_ROOT` | old names honored during the transition |
| `TIMER_LIB=gptl` | `MPAS_TIMER_LIB=gptl` | default `native` |
| `USE_LAPACK=true` | `MPAS_USE_LAPACK=ON` | |
| `GEN_F90=true` | always | D4 |
| `SHAREDLIB=true` | `CMAKE_POSITION_INDEPENDENT_CODE=ON` | |
| `MPAS_TOOL_DIR` | `MPAS_TOOL_DIR` | prebuilt registry tools |
| `MPAS_EXTERNAL_LIBS`, `_INCLUDES`, `_CPPFLAGS` | `MPAS_EXTRA_LIBRARIES`, `_INCLUDE_DIRS`, `_DEFINITIONS` | escape hatch during the transition |
| `EXCLUDE_INIT_MODE=true` (ocean) | `MPAS_OCEAN_INIT_MODE=OFF` | |
| `USE_SHTNS=true` (ocean) | `MPAS_OCEAN_SHTNS=ON` | FFTW and SHTNS through `ExternalProject` or an install |
| `ALBANY=true` (MALI) | `MPAS_LANDICE_ALBANY=ON` | |
| `SLM=true` (MALI) | `MPAS_LANDICE_SLM=ON` | not yet in the coupled lists |
| `USE_PAPI`, `USE_MAGMA`, `USE_CUBLAS`, `USE_GPU_AWARE_MPI` | if owners want them | one source file each (D8) |
| `AUTOCLEAN`, `MPAS_SHELL`, `TAU`, `MOAB_PATH`, `LIFEV`, `PHG`, dead targets | dropped | D8 |

---

## Usage

```bash
# supported machine, with the Polaris or Compass environment (or the machine's modules) loaded
cmake -S components/mpas-ocean -B build-ocean \
    -DMPAS_CIME_MACHINE=pm-cpu -DMPAS_CIME_COMPILER=gnu -DMPAS_CIME_MPILIB=mpich \
    -DMPAS_OPENMP=ON
cmake --build build-ocean -j 32

# laptop or container with no CIME machine
cmake -S components/mpas-seaice -B build-seaice \
    -DCMAKE_Fortran_COMPILER=mpifort -DCMAKE_C_COMPILER=mpicc -DCMAKE_CXX_COMPILER=mpicxx
cmake --build build-seaice -j
```

---

## Work packages

*Date last modified: 2026-10-26.*

Each work package gets its own branch, worktree, plan and PR. Branch names follow the convention
of this branch, `<area>/<feature>`, pushed to a fork. WP2 is developed stacked on WP1, so that a
real user of WP1's abstractions tests them before WP1 merges.

Sizes count changed lines, roughly: S is under 300, M is 300 to 1,000 and L is over 1,000.

| WP | Branch | Repo | Depends on | Size |
| --- | --- | --- | --- | --- |
| WP0 | `mpas-framework/support-cmake-in-standalone` (this branch) | E3SM | none | document |
| WP1 | `mpas-framework/share-cmake-build-logic` | E3SM | WP0 | M |
| WP2 | `mpas-framework/add-standalone-cmake` | E3SM | WP1 | L |
| WP3 | `mpas-seaice/add-standalone-cmake` | E3SM | WP2 | S |
| WP4 | `mpas-albany-landice/add-standalone-cmake` | E3SM | WP2 | M |
| WP5 | `mpas-framework/add-standalone-cmake-ci` | E3SM | WP2, extended by WP3 and WP4 | S-M |
| WP6a | `build-mpas-ocean-with-cmake` | Polaris | WP2 | S-M |
| WP6b | `build-mpas-with-cmake` | Compass | WP2, and WP4 in MALI-Dev | M |
| WP7 | `mpas-framework/remove-make-build` | E3SM | WP3, WP4, WP6a, WP6b | S (mostly deletions) |
| WP8 | as needed | E3SM | WP2 | - |

```text
WP0 -> WP1 -> WP2 -+-> WP3 -------------------+
                   +-> WP4 ---> WP6b ---------+-> WP7
                   +-> WP6a ------------------+
                   +-> WP5 (CI)
                   +-> WP8 (follow-ups)
```

### WP0: Design and documentation home

**Scope.**

- This document.
- The framework's documentation tree: `components/mpas-framework/mkdocs.yml`, an introduction
  page, and [MPAS design documents](index.md).

**Done when.** MPAS developers have reviewed the [Open Questions](#open-questions) and settled them
or deferred them to a named work package, and the documentation tree builds with
`mkdocs build --strict`.

### WP1: Shared CMake build logic (coupled, BFB)

**Scope.**

- An `MPAS_BUILD_MODE` switch in `components/mpas-framework/src/CMakeLists.txt`.
- The coupled-only settings move behind it: the `CASEROOT` macro and `Depends` includes, the
  coupled defines, `spio` and `csm_share`, the MCT driver sources, and `EXCLUDE_INIT_MODE`.
- `STANDALONE` mode stops with "not yet implemented".
- Each `<core>.cmake` is split into a shared list plus mode-specific additions.
- Correct incremental rebuilds: a `DEPFILE` for registry and source preprocessing, and every
  parser output declared.
- The registry parser takes the core name, executable name and git version on its command line
  (`parse.c`, `gen_inc.c`). The Make build passes the same arguments, and coupled builds keep
  generating today's values.
- The `../inc/` includes (28 lines in 6 files) become plain names, and both build systems put the
  inc directory on the include path.
- `ezxml` becomes one object library, and `tools/CMakeLists.txt` stops reassigning
  `CMAKE_C_COMPILER`.

**Out of scope.**

- Anything standalone.
- The stale `Depends.*.cmake` entries ([Open Questions](#open-questions) 8).

**Done when.**

- The coupled cases in [Testing](#testing) compile the same files with the same flags as master.
- Their preprocessed `.f90` files are identical to master's, apart from the include-path change.
- Those cases are BFB against master on two machines.
- Touching `Registry_analysis_members.xml` regenerates the `.inc` files and recompiles the files
  that use them.
- Make builds still work, and Polaris `mpaso_pr` is BFB with a Make build of master.

**Risks.**

- Coupled builds might depend on the include-path hack in ways that are not obvious.
- The `DEPFILE` guard has to work on older CMake versions.

### WP2: Standalone framework and MPAS-Ocean

**Scope.**

- **Setup**: standalone setup helpers in `components/mpas-framework/cmake/`, and a
  `components/mpas-ocean/CMakeLists.txt` wrapper.
- **Toolchain**: machine and generic modes ([Toolchain](#toolchain)). The generic presets
  reproduce `gfortran`, `gfortran-clang`, `gnu-cray`, `intel-cray`, `cray-cray`, `intel-mpi`,
  `ifort`, and the `ifx` target that is in progress.
- **Dependencies**: dependency discovery ([Dependencies](#dependencies)).
- **Framework pieces for standalone builds**: the framework driver; `esmf_time_f90` with
  `-DHIDE_MPI`; one copy of `shr_kind_mod` and `shr_const_mod`; the `FFLAGS_FPIEEE` treatment of
  `mpas_global_sum_mod.F`; and the git version.
- **Ocean**: init mode, on by default, with its own source list; the CVMix, BGC, MARBL, GOTM and
  PPR lists, shared with coupled builds; LAPACK; and SHTNS and FFTW if they are cheap, otherwise
  WP8.
- **Layout and guards**: the staged layout, and the guard against in-source build products.
- **Configure summary**: a summary at configure time that replaces Make's end-of-build messages.
- **User documentation**: a page in the framework docs on building MPAS standalone with CMake.

The ocean has identical copies of `shr_kind_mod` and `shr_const_mod` in `analysis_members/` and in
`mode_init/`; only one copy is compiled.

**Out of scope.** Sea ice, land ice, CI, GPU validation and install.

**Done when.**

- The ocean builds in both modes on the machines listed in [Testing](#testing), in Release and
  Debug, with OpenMP on and off.
- In generic mode, Polaris `mpaso_pr` is BFB with the `make gfortran`, `make gnu-cray` and
  `make intel-cray` builds, and the structural diff against Make is clean.
- Machine-mode builds pass `mpaso_pr`, and any differences from Make are recorded in the PR.
- The robustness checks pass, and coupled builds are unchanged.

**Risks.**

- The CIME macros may read environment variables that the Polaris or Compass load scripts do not
  set.
- GOTM is compiled with MPAS flags rather than through its own CMake, which may not be BFB with
  Make.
- SCORPIO installs do not ship a CMake package config.

### WP3: MPAS-Seaice

**Scope.**

- A `components/mpas-seaice/CMakeLists.txt` wrapper.
- Standalone additions to `seaice.cmake`, which leave out `-Dcoupled -DCCSMCOUPLED`.
- The Icepack list, shared with coupled builds.
- A section in the user documentation.

The generic presets must not de-optimize `icepack_shortwave_data.F90`. Coupled builds de-optimize
it through `NOOPT_FILES`, but Make compiles it with normal flags.

**Done when.**

- In generic mode, the Polaris sea-ice `single_column` tasks (`standard_physics`, `exact_restart`)
  are BFB with Make.
- Machine-mode builds pass on two machines.

### WP4: MALI

**Scope.**

- A `components/mpas-albany-landice/CMakeLists.txt` wrapper.
- Standalone additions to `landice.cmake`.
- Albany: `find_package(Albany)` and Trilinos, the C++ interface `Interface_velocity_solver.cpp`,
  and linking with C++ and MPI C++.
- `MPAS_LANDICE_SLM`, which builds the SeaLevelModel sources.
- `LIFEV` and `PHG` dropped, if D8 stands.
- Coordination with MALI-Dev, so that the change reaches the MALI-Dev/E3SM fork that Compass uses.

**Done when.**

- The Compass landice `full_integration` suite is BFB with Make on Perlmutter and Chrysalis, with
  Albany.
- A build without Albany works in generic mode.

**Risks.**

- Compass builds `ALBANY_LINK_LIBS` by hand from `export_albany.in`, so Albany's package config may
  not carry everything this link needs.
- Kokkos, Trilinos and MPAS must be built with consistent compilers.

### WP5: CI

**Scope.**

- **The job**: a GitHub Actions job that runs in the E3SM container images used by the `e3sm-gh`
  workflow ([Testing on GitHub-hosted runners](https://github.com/E3SM-Project/E3SM/blob/master/docs/dev-guide/gh-hosted-testing.md)).
  The images are `gnu13-openmpi4` and `intel2024-openmpi4`.
- **Builds**: each standalone component, in Release and in Debug.
- **Triggers**: changes under `components/mpas-*`, `cime_config/machines/cmake_macros` and
  `externals/scorpio`.
- **SCORPIO**: `MPAS_BUILD_SCORPIO=ON`, unless the images provide SCORPIO.
- **Optional drift check**: while Make lasts, a check that the Makefile object lists and the
  `.cmake` lists agree.

**Done when.**

- The job passes on PRs, and fails when a source file is deliberately left out.
- It covers each component as WP3 and WP4 land.

### WP6a: Polaris

**Scope.**

- `build_mpas_ocean.template` runs `cmake` instead of `make`, following the Omega template.
- Machine, compiler and MPI library come from Polaris's existing configuration. The
  `<compiler>_<mpi>_target` options become optional extra CMake flags.
- The Make path stays until WP7.
- Documentation updates.

**Done when.** Polaris builds and tests MPAS-Ocean through CMake on its supported machines.
`mpaso_pr` passes, after a rebaseline if Polaris uses machine mode.

### WP6b: Compass

**Scope.**

- MPAS-Ocean and MALI build with CMake.
- Albany is found through `Albany_ROOT`, instead of `deploy/load.sh` building `MPAS_EXTERNAL_LIBS`.
- Machine configs and documentation are updated.
- Starts only once WP4 has reached MALI-Dev.

**Done when.** The Compass ocean and landice suites run from CMake builds. A check of mache comes
with this package: its load scripts must export the variables that the CIME macros read.

### WP7: Remove the Make build

**Scope.**

- Delete the build Makefiles, `build_options.mk`, `Makefile.icepack` and the three Makefile
  symlinks.
- Delete the MCT `driver/Makefile`s, after confirming they are unused.
- Delete the dead `components/mpas-framework/azure-pipelines.yml`, which targets ubuntu-16.04.
- Keep `components/mpas-ocean/docs/Makefile`, which belongs to Sphinx.
- Remove the fallbacks for the legacy environment-variable names, after an announced grace period.
- Settle the fate of `core_sw` and `core_test` ([Open Questions](#open-questions) 7).
- Update `INSTALL`, `README.md` and the component guides.

**Done when.**

- No build Makefile remains under `components/mpas-*`, and downstream needs none.
- The documentation describes only CMake.

### WP8: Follow-ups, on request

- `cmake --install` and an exported package config.
- Preprocessing that keeps `.F` line numbers (D4).
- `CMakePresets.json` for common machines.
- OpenACC and OpenMP-offload validation on Perlmutter GPU and Frontier.
- SHTNS and FFTW through `ExternalProject`, if WP2 deferred them.
- `core_test` as a CTest suite for the framework.

---

## Testing

*Date last modified: 2026-10-26.*

- **Structural diffs** cost little and need no runs. Export `compile_commands.json`. Coupled
  builds before and after a change must give the same files the same flags. Standalone CMake and a
  verbose Make log must give the same sources the same defines. One script does both comparisons.
- **BFB runs**: Polaris and Compass run unchanged against a CMake build directory, compared with a
  baseline built by Make (D6). The suites are Polaris `mpaso_pr` and the sea-ice `single_column`
  tasks, and Compass landice `full_integration` and ocean `nightly`.
- **Coupled BFB**: any change to shared files also runs these tests BFB against master baselines:
  `ERS_Ld5.T62_oQU120.CMPASO-NYF`, `ERS_Ld5.T62_oQU240.DTESTM` and
  `ERS_Vmct.ne30pg2_r05_IcoswISC30E3r5_gis4to40.MALISIA` from `e3sm_developer`, plus the
  `e3sm_ice_developer` and `e3sm_landice_developer` suites.
- **Build robustness**: ten clean builds at high `-j`. Then check that each of these triggers only
  the expected rebuild: touching an included registry XML file, a hand-written `.inc`, and a single
  `.F`.
- **Machines**: Chrysalis (intel, gnu), Perlmutter CPU (gnu, intel), Frontier (craygnu,
  craycray), and one laptop or container in generic mode.

---

## Downstream migration

1. **WP1 to WP5**: Make and CMake coexist. Make is frozen except for source-list additions, and
   the drift check in WP5 keeps the two in step if it is adopted.
2. **WP6**: Polaris and Compass switch, and rebaseline once if machine mode changes answers. The
   Make build prints a deprecation notice that points to the user documentation.
3. **WP7**: the Make build is removed, on a date announced in advance.

---

## The current build

Line references are to master at commit `0f3298812a` (2026-10-23).

### Standalone build: Make

- **Entry point**: `components/mpas-{ocean,seaice,albany-landice}/Makefile` are symlinks to
  [`components/mpas-framework/Makefile`](https://github.com/E3SM-Project/E3SM/blob/0f3298812afb5761a3fb24a4bfe4eebdd28bec93/components/mpas-framework/Makefile).
  That file is 1,204 lines long and works out which component to build from `$PWD`.
- **Compiler targets**: 16, each hard-coding compilers and flags.
- **In-source build**: framework objects land in `components/mpas-framework/src/` and are shared
  by every component. A checkout can therefore hold a build of only one component at a time (the
  `.mpas_core_<core>` marker and `AUTOCLEAN=true`). Component objects, `<core>_model`,
  `default_inputs/` and `src/Registry_processed.xml` land in the component directory.
- **Recursive Makefiles**: about 30, each listing its objects and its Fortran module dependencies
  by hand.
- **Libraries**: found through the `NETCDF`, `NETCDFF`, `PNETCDF` and `PIO` environment variables,
  plus flags such as `USE_PIO2` and `HAVE_ADIOS`. Compass links Albany through
  `MPAS_EXTERNAL_LIBS`.

Each submodule is built in its own source tree with its own tool:

| Submodule | Built with |
| --- | --- |
| CVMix, BGC, MARBL | Make |
| GOTM | its own CMake, in `gotm/build` |
| SHTNS, FFTW | autotools |
| Icepack | `Makefile.icepack` |
| SeaLevelModel | Make |

### Coupled build: CMake through CIME

- [`build_mpas_model.cmake`](https://github.com/E3SM-Project/E3SM/blob/0f3298812afb5761a3fb24a4bfe4eebdd28bec93/components/cmake/build_mpas_model.cmake)
  adds
  [`mpas-framework/src/CMakeLists.txt`](https://github.com/E3SM-Project/E3SM/blob/0f3298812afb5761a3fb24a4bfe4eebdd28bec93/components/mpas-framework/src/CMakeLists.txt)
  when a case has MPAS components.
- That file includes `${CASEROOT}/Macros.cmake`, which CIME assembles from
  `cime_config/machines/cmake_macros/`, along with the `Depends.*.cmake` per-file overrides. It
  links E3SM's `spio` and `csm_share` targets.
- Every `.F` file goes through `cpp -P -traditional` into a `.f90` in the build tree, and CMake's
  Fortran scanner orders the modules.
- The source lists in `framework.cmake`, `operators.cmake`, `ocean.cmake`, `seaice.cmake` and
  `landice.cmake` are a second hand-maintained copy of the Makefile object lists.
- Coupled-only settings are the defines `-Dcoupled`, `MPAS_NO_LOG_REDIRECT`, `MPAS_NO_ESMF_INIT`,
  `MPAS_ESM_SHR_CONST` and `MPAS_PERF_MOD_TIMERS`, the MCT driver sources, and `EXCLUDE_INIT_MODE`
  for the ocean.

### Problems

The Make build:

| Problem | Evidence |
| --- | --- |
| Races under `make -j` | [`external/ezxml/Makefile`](https://github.com/E3SM-Project/E3SM/blob/0f3298812afb5761a3fb24a4bfe4eebdd28bec93/components/mpas-framework/src/external/ezxml/Makefile) runs `all: clean`, then rebuilds `ezxml.o`. It is invoked from `external/`, `tools/registry/` and `tools/input_gen/`. `framework/` archives `../external/ezxml/ezxml.o`, and [`src/Makefile`](https://github.com/E3SM-Project/E3SM/blob/0f3298812afb5761a3fb24a4bfe4eebdd28bec93/components/mpas-framework/src/Makefile) does not order `frame` relative to `build_tools`. |
| Module dependencies by hand | Each subdirectory Makefile lists module dependencies; ocean `shared/Makefile` alone has about 160 lines of them. A missing edge shows up only under `-j`, as in [f6008b8664](https://github.com/E3SM-Project/E3SM/commit/f6008b8664). |
| Archive by `find` | ``ar -ru libdycore.a `find . -type f -name "*.o"` `` in each component's `src/Makefile` links whatever stale objects are present. |
| In-source build | One component per checkout, and build products in submodule working trees. |
| Atrophy | Of 16 compiler targets, Polaris and Compass use 7: `gfortran`, `gfortran-clang`, `gnu-cray`, `intel-cray`, `cray-cray`, `intel-mpi` and `ifort`. Ocean [`shared/Makefile`](https://github.com/E3SM-Project/E3SM/blob/0f3298812afb5761a3fb24a4bfe4eebdd28bec93/components/mpas-ocean/src/shared/Makefile#L251) hard-codes a developer's home directory, and lists `mpas_ocn_forcing_restoring.o` (line 68), which has no source file. The sea-ice `clean` target enters a `column/` directory that no longer exists. `-DHAVE_ADIOS` is on unless the user turns it off. |
| Separate machine maintenance | Fixes in E3SM's machine files never reach the Make targets, for example the ifx `-mllvm -disable-hir-temp-cleanup` workaround in `chrysalis_intel.cmake`. The ifx fpp `COMMA` bug needed a separate Make workaround (`GEN_F90=true` for `intel-cray`). |

The coupled CMake build:

- `Registry_processed.xml` depends only on `Registry.xml`
  ([`build_core.cmake`](https://github.com/E3SM-Project/E3SM/blob/0f3298812afb5761a3fb24a4bfe4eebdd28bec93/components/mpas-framework/src/build_core.cmake#L36-L41)).
  The registries `#include` other XML files, and the ocean has 75 `Registry*.xml` files, so editing
  an included file regenerates nothing in an incremental build.
- The `cpp` step in `genf90_targets` does not track the `.inc` files that a source includes.
- Core interface and config files use `#include "../inc/<file>.inc"`, 28 lines in 6 files. A
  leftover in-source Make build's `src/inc/` shadows the generated files of any CMake build,
  coupled builds included.
  [`ocean.cmake`](https://github.com/E3SM-Project/E3SM/blob/0f3298812afb5761a3fb24a4bfe4eebdd28bec93/components/mpas-ocean/src/ocean.cmake#L5)
  works around the path with an include-directory hack.
- The registry parser compiles in the core name, executable name and git version
  ([`gen_inc.c`](https://github.com/E3SM-Project/E3SM/blob/0f3298812afb5761a3fb24a4bfe4eebdd28bec93/components/mpas-framework/src/tools/registry/gen_inc.c#L23-L25)).
  One parser cannot serve several components.
- [`tools/CMakeLists.txt`](https://github.com/E3SM-Project/E3SM/blob/0f3298812afb5761a3fb24a4bfe4eebdd28bec93/components/mpas-framework/src/tools/CMakeLists.txt#L19)
  sets `CMAKE_C_COMPILER` after `project()`, where it has no effect.
- `Depends.gnu.cmake` and `Depends.craygnu.cmake` de-optimize
  `core_seaice/column/ice_shortwave.f90`, which no longer exists.

### What downstream reads

| Consumer | Builds with | Reads afterwards, relative to the component directory |
| --- | --- | --- |
| Polaris, MPAS-Ocean | `make <target>` in `components/mpas-ocean`. The target comes from `<compiler>_<mpi>_target` in the machine config, and the environment from Polaris's load script (`NETCDF`, `PNETCDF`, `PIO`, `USE_PIO2=true`, `OPENMP=true`). | `ocean_model`, `default_inputs/namelist.ocean.forward`, `default_inputs/streams.ocean.forward`, `src/Registry_processed.xml` |
| Polaris, MPAS-Seaice | built by the user, and found through `component_path` | `seaice_model`, `default_inputs/namelist.seaice`, `default_inputs/streams.seaice` |
| Compass, MPAS-Ocean and MALI | `make [ALBANY=true] <target>`. For Albany, `deploy/load.sh` builds `MPAS_EXTERNAL_LIBS`, and it sets `USE_PIO2=true` and `HAVE_ADIOS=false`. | `ocean_model`, `landice_model`, `default_inputs/namelist.{ocean.forward,ocean.init,landice}` and the matching streams files |

---

## Prior work

- **Omega**
  ([`OmegaBuild.cmake`](https://github.com/E3SM-Project/Omega/blob/develop/components/omega/OmegaBuild.cmake))
  builds standalone with CMake. At configure time it creates a throwaway CIME case with
  `create_newcase` and `case.setup`, and reads `Macros.cmake`, the machine environment and the MPI
  launcher from it. It builds SCORPIO, GPTL and Kokkos in-tree, and Polaris drives it through
  `OMEGA_CIME_MACHINE` and `OMEGA_CIME_COMPILER`. The throwaway case needs `--output-root` inside
  the build directory, or concurrent builds delete each other's directories. In coupled mode, the
  case's `spio` target is wrapped as `pioc` and `gptl` targets.
- **EAMxx** keeps its own per-machine CMake files and gets its environment from CIME's
  `get_case_env`.
- **Upstream MPAS-Model** (MPAS-Dev) has a CMake build for its atmosphere cores, with options such
  as `MPAS_CORES`, `MPAS_DOUBLE_PRECISION`, `MPAS_OPENMP` and `MPAS_USE_PIO`. It builds one
  registry parser per core, `mpas_parse_<core>`, and passes the core name, executable name and git
  version on the parser's command line. It preprocesses with the compiler, and has find modules
  for PIO, PnetCDF, NetCDF and GPTL. E3SM's framework has diverged too far to import that build,
  but its find modules can be reused.

---

## Decisions

*Date last modified: 2026-10-26.*

These are the rejected alternatives, cited from the sections they affect. All of them are proposals
until MPAS developers review them ([Open Questions](#open-questions)).

- **D0. Other homes for MPAS design documents.** The chosen home is in the E3SM repository, next
  to the code ([MPAS design documents](index.md)). Confluence is rejected because it is not
  versioned with the code, needs an E3SM login, and keeps the design apart from the PRs that
  implement it. MPAS-Documents is rejected because it uses LaTeX, in an MPAS-Dev repository shared
  with NCAR. E3SM's `docs/dev-guide/` is rejected because it serves all of E3SM, and MPAS
  developers do not maintain it. `components/mpas-ocean/docs/design_docs/` is rejected because it
  belongs to one component, uses RST and LaTeX, and is not built.
- **D1. A separate standalone CMake tree.** Rejected because it would be a third copy of every
  source list. See [Build structure](#build-structure).
- **D2. Omega's throwaway CIME case.** It would bring the machine environment and the default MPI
  library. Rejected, for now, because it is slow, needs CIME's Python and a project, and applies
  the environment only at configure time. See [Toolchain](#toolchain) and
  [Open Questions](#open-questions) 3.
- **D3. Coupled flags from the start.** Rejected because it would leave no BFB check of the port
  against Make. The chosen path shows BFB with the generic presets, then defaults to machine mode
  and rebaselines once. Real promotion stays on in standalone builds
  ([Open Questions](#open-questions) 4).
- **D4. Preprocessing by the compiler.** Rejected because ifx's fpp mishandles the `COMMA` macro
  idiom, which is why `GEN_F90` exists. The cost of external `cpp` is that compiler messages and
  debuggers point at lines of the generated `.f90`. Dropping `-P` may fix that (WP8).
- **D5. Several components per standalone tree.** Rejected because it needs a per-component
  output layout, which breaks [Requirement: Downstream run-time paths unchanged](#requirement-downstream-run-time-paths-unchanged).
- **D6. A new output layout.** Rejected because it needs run-time changes in Polaris and Compass.
- **D7. PIO 1.** Rejected because Polaris and Compass both use PIO 2 (`USE_PIO2=true`).
- **D8. Porting every option.** The dead compiler targets are dropped: `xlf`,
  `xlf-summit-omp-offload`, `pgi`, `pgi-summit`, `ftn`, `g95`, `llvm`, `ifort-scorep` and
  `ifort-gcc`. So are `TAU`, `AUTOCLEAN`, `MPAS_SHELL`, standalone MOAB, and `LIFEV` and `PHG`,
  since no source tests `LIFEV`. PAPI, MAGMA, CUBLAS and GPU-aware MPI wait on their owners
  ([Open Questions](#open-questions) 6).
- **D9. Removing Make with the first CMake PR.** Rejected because Polaris and Compass need both
  builds while they switch. See [Downstream migration](#downstream-migration).
- **D10. CMake 3.18 everywhere, without `DEPFILE`.** Rejected because incremental builds would miss
  include changes. Standalone builds require 3.21, as Omega does. Coupled builds keep E3SM's 3.18
  minimum, with a guard around `DEPFILE`.
- **D11. Patching the Make build until the components retire.** Rejected because the races,
  hand-written dependencies and separate flag maintenance would all remain, and every fix would be
  manual and recurring. The CMake work is mostly mechanical and is done once. See
  [Value and cost](#value-and-cost).
