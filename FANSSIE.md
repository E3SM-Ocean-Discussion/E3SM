# FAnSSIE ocean–ice-sheet coupling branch

`fanssie-ocn-glc-coupling` on E3SM-Ocean-Discussion/E3SM is a long-lived, shared development branch for coupling MPAS-Ocean and MALI in E3SM, as part of FAnSSIE, the Framework for Antarctic System Science in E3SM. Polaris pins it as the submodule `e3sm_submodules/FAnSSIE` for its ocean–ice-sheet tasks, which are regression-tested with Polaris's `fanssie_pr` suite. Everything else in Polaris builds from E3SM-Project.

## Rules

- The branch only gains commits. Never force-push or rebase it.
- Work starts from this branch and merges back in through pull requests to it, so that each pull request shows only its own changes. Pull requests are merged with a merge commit. Upstream pull requests the work depends on are merged in as they are. Small fixes, and changes to this file, may be committed directly.
- E3SM master is merged in from time to time.
- Every change except to this file gets a row in the ledger below, so that nothing is lost. The row is added by a direct commit right after the pull request merges, not in the pull request, so that a pull request holds only code. The row gives the merge commit and names any other change on this branch that the change needs.
- Moving changes into E3SM is encouraged but not required. To move one, cherry-pick its pull request's commits (`git log <merge>^1..<merge>^2`) onto E3SM master. Bring any changes made in upstream review back to this branch before master is next merged in.
- Test each change to the code with Polaris's `fanssie_pr` suite against a baseline from the previous commit of this branch.

## Ledger

Base: E3SM master `6816738295` (2026-10-15).

| Change | Source | Upstream | Status (2026-10-16) |
|---|---|---|---|
| New land-ice melt equations and options | cbegeman:ocn/modify-land-ice-melt-equations | E3SM#8047 | draft |
| Fixes for E3SM#8047 | xylar:ocn/modify-land-ice-melt-equations-fixes | suggested for cherry-picking on E3SM#8047 | not yet in E3SM#8047 |
| Two-way land-ice coupling in driver-moab | E3SM-Project:rljacob/mbcpl/port-mali | E3SM#8661 | approved, open |
| Ice-shelf melt coupling between MPAS-Ocean and MALI, including the three rows above | xylar:ocn-glc/ice-shelf-melt-coupling | E3SM#8887 | draft |
| Wetting and drying with RK4 and a subglacial thin film | cbegeman:ocn/limit-grounded-land-ice-pressure | E3SM-Ocean-Discussion#119 | draft |
| Copy land-ice pressure only over nCellsAll, a fix for E3SM-Ocean-Discussion#119 | `26fb0b6bed` from xylar:ocn/thin-film-wetting-drying, cherry-picked | suggested on E3SM-Ocean-Discussion#119 | not yet in E3SM-Ocean-Discussion#119 |
| Zero land-ice fluxes where the ice is grounded | xylar:ocn/fix-land-ice-fluxes-in-grounded-cells | E3SM-Ocean-Discussion#141 | open |
| Keep the floating mask zero where there is no land ice | xylar:ocn/fix-floating-mask-in-open-ocean | E3SM-Ocean-Discussion#142 | open |
| Advance the time-varying forcing clock with every time integrator | xylar:ocn/fix-time-varying-forcing-clock (E3SM-Ocean-Discussion#143, merged as `c1df64a79c`) | none yet | — |
| Make the submesoscale parameterization respect wetting and drying | xylar:ocn/fix-submesoscale-wetting-drying (E3SM-Ocean-Discussion#145, merged as `e41c36ea28`) | none yet | — |
| Keep the top drag in KPP's friction velocity with implicit drag | xylar:ocn/fix-implicit-top-drag-friction-velocity (E3SM-Ocean-Discussion#146, merged as `e81b3b0223`) | none yet | — |
| Avoid dividing by zero in the sea-ice salt limit | xylar:ocn/fix-sea-ice-salt-limiter (E3SM-Ocean-Discussion#147, merged as `58b634e761`) | none yet | — |
| Add an option to limit Jacobian_from_TS to each cell's water column | xylar:ocn/limit-jacobian-pressure-gradient (E3SM-Ocean-Discussion#148, merged as `cf11862786`) | none yet | — |
| Add an option to evaluate jm at each layer's depth | xylar:ocn/jm-eos-at-actual-depth (E3SM-Ocean-Discussion#149, merged as `a368328ed2`) | none yet | — |
| Set the melt rate from the heat balance in nearly fresh water | xylar:ocn/fix-fresh-water-melt-rate (E3SM-Ocean-Discussion#150, merged as `9bc9914a4b`) | none yet | — |
| Merge MALI-Dev's `develop` at `5e80df1145` (2026-10-09) | MALI-Dev:develop via xylar:mali/merge-mali-dev-develop (E3SM-Ocean-Discussion#151, merged as `a026eeb597`) | none yet | — |
| Remove the surface air temperature lapse rate from MALI's namelist | xylar:mali/remove-lapse-rate-from-namelist (E3SM-Ocean-Discussion#156, merged as `d1c104ddb4`) | MALI-Dev/E3SM#213 | open |
| Let case variables name MALI's input files | xylar:mali/inputs-named-by-case-variables (E3SM-Ocean-Discussion#157, merged as `5cda8a32a0`) | MALI-Dev/E3SM#214 | open |
| Let the MCT driver run a prognostic ocean without an atmosphere | xylar:cpl/allow-ocean-without-atmosphere (E3SM-Ocean-Discussion#158, merged as `4a0786855c`) | none yet | — |
| Add wetting and drying and tidal forcing to E3SM's MPAS-Ocean | xylar:ocn/wetting-drying-tidal-forcing-in-e3sm (E3SM-Ocean-Discussion#159, merged as `5431b386d1`) | none yet | — |
| Keep the input floating fraction with wetting and drying | xylar:ocn/keep-floating-fraction-with-wetting-drying (E3SM-Ocean-Discussion#160, merged as `f1bf51f815`) | none yet | — |
| Let case variables name MPAS-Ocean's input files | xylar:ocn/inputs-named-by-case-variables (E3SM-Ocean-Discussion#161, merged as `ca14c03594`) | none yet | — |
| Add an option that keeps glc's runoff out of the ocean | xylar:cpl/glc-runoff-to-ocean-option (E3SM-Ocean-Discussion#162, merged as `07136f62cf`) | none yet | — |
| Conserve glc-ocean fluxes under ice shelves and without an atmosphere | xylar:cpl/ocean-coupler-areas-from-glc-map (E3SM-Ocean-Discussion#163, merged as `4bb91b23e3`); needs E3SM-Ocean-Discussion#162 | none yet | — |
| Apply the grounded-ice pressure cap in one threaded loop, a fix for E3SM-Ocean-Discussion#119 | xylar:ocn/thread-safe-land-ice-pressure-cap (E3SM-Ocean-Discussion#164, merged as `771214f3f7`) | suggested for E3SM-Ocean-Discussion#119 | not yet in E3SM-Ocean-Discussion#119 |
| Convert land-ice pressure to depth with one ocean density, a fix for E3SM-Ocean-Discussion#119 | xylar:ocn/land-ice-pressure-cap-ocean-density (E3SM-Ocean-Discussion#165, merged as `059ee8fa41`); needs E3SM-Ocean-Discussion#164 | suggested for E3SM-Ocean-Discussion#119 | not yet in E3SM-Ocean-Discussion#119 |
| Update the land-ice mask from the ice fraction during a run | xylar:ocn/land-ice-mask-from-fraction (E3SM-Ocean-Discussion#166, merged as `76001323e6`) | none yet | — |
| Write the land-ice geometry to monthly means when coupled to glc | xylar:ocn/land-ice-geometry-in-monthly-means (E3SM-Ocean-Discussion#167, merged as `bf0c452408`) | none yet | — |
| Make MALI's data-mode export follow its thickness file | xylar:mali/update-masks-after-data-mode-read (E3SM-Ocean-Discussion#168, merged as `62ef616442`) | MALI-Dev/E3SM#216 | open |
| Skip frazil and melt where glc has too little floating ice to receive them | xylar:ocn/skip-frazil-without-glc-floating-ice (E3SM-Ocean-Discussion#169, merged as `3022261e84`) | none yet | — |
| Treat slivers of imported land ice as open ocean | xylar:ocn/ignore-tiny-glc-ice-fractions (E3SM-Ocean-Discussion#170, merged as `a9d9e2ff64`); needs E3SM-Ocean-Discussion#169 | none yet | — |
