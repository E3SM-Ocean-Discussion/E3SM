# MPAS Design Documents

A design document describes a planned change to the MPAS framework or to an MPAS component in
E3SM, before the code is written.

## Where design documents go

- A design for one component goes in `components/mpas-<component>/docs/design/`.
- A design for the framework, or for work that spans components, goes in
  `components/mpas-framework/docs/design/`.
- Each design document is a Markdown file listed in the `nav` of its component's `mkdocs.yml`, so
  it is published with the rest of E3SM's documentation.
- A design document is reviewed in the pull request that adds it. It is revised as the design
  changes and kept after the work lands.

MALI has no documentation tree in E3SM yet. The first MALI design document creates
`components/mpas-albany-landice/mkdocs.yml` and its `docs/` directory.

## Structure

Follow the existing documents:

1. `Summary`
2. `Open Questions`, if any remain
3. `Requirements`, with one `### Requirement:` heading per requirement, each followed by its
   design resolution
4. the design
5. `Testing`
6. `Decisions`, which records rejected alternatives and is cited from the sections they affect

Requirements say what a capability must do, not how the software will do it.

## Documents

- [Standalone CMake builds for MPAS components](standalone-cmake-build.md)

## Earlier design documents

Earlier MPAS design documents are elsewhere and have not been moved.

| Location | Contents | Format |
| --- | --- | --- |
| [MPAS-Documents](https://github.com/MPAS-Dev/MPAS-Documents) | framework designs in `shared/`, plus `ocean/` and `landice/` | LaTeX |
| [`components/mpas-ocean/docs/design_docs`](https://github.com/E3SM-Project/E3SM/tree/master/components/mpas-ocean/docs/design_docs) | MPAS-Ocean designs, moved from MPAS-Model in 2022 | RST and LaTeX |
| E3SM Confluence | designs written under E3SM's [Code Review and New Feature Process](https://e3sm.atlassian.net/wiki/spaces/DOC/pages/3438608385), in group spaces such as Polar Dynamics and FAnSSIE | wiki |
| [Omega documentation](https://docs.e3sm.org/Omega/develop/index.html) | Omega designs, in `components/omega/doc/design/` of the Omega repository | Markdown |
