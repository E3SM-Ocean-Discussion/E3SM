# FAnSSIE ocean–ice-sheet coupling branch

`fanssie-ocn-glc-coupling` on E3SM-Ocean-Discussion/E3SM is a long-lived, shared development branch for coupling MPAS-Ocean and MALI in E3SM, as part of FAnSSIE, the Framework for Antarctic System Science in E3SM. Polaris pins it as the submodule `e3sm_submodules/FAnSSIE` for its ocean–ice-sheet tasks, which are regression-tested with Polaris's `fanssie_pr` suite. Everything else in Polaris builds from E3SM-Project.

## Rules

- The branch only gains commits. Never force-push or rebase it.
- Work starts from this branch and merges back in through pull requests to it, so that each pull request shows only its own changes. Pull requests are merged with a merge commit. Upstream pull requests the work depends on are merged in as they are. Small fixes, and changes to this file, may be committed directly.
- E3SM master is merged in from time to time.
- Every change except to this file gets a row in the ledger below, so that nothing is lost. The row is added by a direct commit right after the pull request merges, not in the pull request, so that a pull request holds only code. The row gives the merge commit and names any other change on this branch that the change needs. The Upstream column links the pull request that carries the change upstream, whose state is on GitHub; the row notes only how this branch's copy differs from it.
- Moving changes into E3SM is encouraged but not required. To move one, cherry-pick its pull request's commits (`git log <merge>^1..<merge>^2`) onto E3SM master. Bring any changes made in upstream review back to this branch before master is next merged in.
- Test each change to the code with Polaris's `fanssie_pr` suite against a baseline from the previous commit of this branch.

## Ledger

Base: E3SM master `6816738295` (2026-10-15).

| Change | Source | Upstream |
|---|---|---|
| New land-ice melt equations and options | cbegeman:ocn/modify-land-ice-melt-equations | E3SM#8047 |
| Fixes for E3SM#8047 | xylar:ocn/modify-land-ice-melt-equations-fixes | suggested for cherry-picking on E3SM#8047; not in it yet |
| Two-way land-ice coupling in driver-moab | E3SM-Project:rljacob/mbcpl/port-mali | E3SM#8661 |
| Ice-shelf melt coupling between MPAS-Ocean and MALI, including the three rows above | xylar:ocn-glc/ice-shelf-melt-coupling | E3SM#8887, rebased onto master on 2026-11-06; FAnSSIE has the pre-rebase commits (`456d451074`) |
| Wetting and drying with RK4 and a subglacial thin film | cbegeman:ocn/limit-grounded-land-ice-pressure | E3SM-Ocean-Discussion#119 |
| Copy land-ice pressure only over nCellsAll, a fix for E3SM-Ocean-Discussion#119 | `26fb0b6bed` from xylar:ocn/thin-film-wetting-drying, cherry-picked | suggested on E3SM-Ocean-Discussion#119; not in it yet |
| Zero land-ice fluxes where the ice is grounded | xylar:ocn/fix-land-ice-fluxes-in-grounded-cells | E3SM-Ocean-Discussion#141 |
| Keep the floating mask zero where there is no land ice | xylar:ocn/fix-floating-mask-in-open-ocean | E3SM-Ocean-Discussion#142 |
| Advance the time-varying forcing clock with every time integrator | xylar:ocn/fix-time-varying-forcing-clock (E3SM-Ocean-Discussion#143, merged as `c1df64a79c`) | none yet |
| Make the submesoscale parameterization respect wetting and drying | xylar:ocn/fix-submesoscale-wetting-drying (E3SM-Ocean-Discussion#145, merged as `e41c36ea28`) | none yet |
| Keep the top drag in KPP's friction velocity with implicit drag | xylar:ocn/fix-implicit-top-drag-friction-velocity (E3SM-Ocean-Discussion#146, merged as `e81b3b0223`) | none yet |
| Avoid dividing by zero in the sea-ice salt limit | xylar:ocn/fix-sea-ice-salt-limiter (E3SM-Ocean-Discussion#147, merged as `58b634e761`) | none yet |
| Add an option to limit Jacobian_from_TS to each cell's water column | xylar:ocn/limit-jacobian-pressure-gradient (E3SM-Ocean-Discussion#148, merged as `cf11862786`) | none yet |
| Add an option to evaluate jm at each layer's depth | xylar:ocn/jm-eos-at-actual-depth (E3SM-Ocean-Discussion#149, merged as `a368328ed2`) | none yet |
| Set the melt rate from the heat balance in nearly fresh water | xylar:ocn/fix-fresh-water-melt-rate (E3SM-Ocean-Discussion#150, merged as `9bc9914a4b`) | none yet |
| Merge MALI-Dev's `develop` at `5e80df1145` (2026-10-09) | MALI-Dev:develop via xylar:mali/merge-mali-dev-develop (E3SM-Ocean-Discussion#151, merged as `a026eeb597`) | E3SM#9149 |
| Remove the surface air temperature lapse rate from MALI's namelist | xylar:mali/remove-lapse-rate-from-namelist (E3SM-Ocean-Discussion#156, merged as `d1c104ddb4`) | MALI-Dev/E3SM#213 |
| Let case variables name MALI's input files | xylar:mali/inputs-named-by-case-variables (E3SM-Ocean-Discussion#157, merged as `5cda8a32a0`) | MALI-Dev/E3SM#214 |
| Let the MCT driver run a prognostic ocean without an atmosphere | xylar:cpl/allow-ocean-without-atmosphere (E3SM-Ocean-Discussion#158, merged as `4a0786855c`) | none yet |
| Add wetting and drying and tidal forcing to E3SM's MPAS-Ocean | xylar:ocn/wetting-drying-tidal-forcing-in-e3sm (E3SM-Ocean-Discussion#159, merged as `5431b386d1`) | none yet |
| Keep the input floating fraction with wetting and drying | xylar:ocn/keep-floating-fraction-with-wetting-drying (E3SM-Ocean-Discussion#160, merged as `f1bf51f815`) | none yet |
| Let case variables name MPAS-Ocean's input files | xylar:ocn/inputs-named-by-case-variables (E3SM-Ocean-Discussion#161, merged as `ca14c03594`) | none yet |
| Add an option that keeps glc's runoff out of the ocean | xylar:cpl/glc-runoff-to-ocean-option (E3SM-Ocean-Discussion#162, merged as `07136f62cf`) | none yet |
| Conserve glc-ocean fluxes under ice shelves and without an atmosphere | xylar:cpl/ocean-coupler-areas-from-glc-map (E3SM-Ocean-Discussion#163, merged as `4bb91b23e3`); needs E3SM-Ocean-Discussion#162 | none yet |
| Apply the grounded-ice pressure cap in one threaded loop, a fix for E3SM-Ocean-Discussion#119 | xylar:ocn/thread-safe-land-ice-pressure-cap (E3SM-Ocean-Discussion#164, merged as `771214f3f7`) | suggested for E3SM-Ocean-Discussion#119; not in it yet |
| Convert land-ice pressure to depth with one ocean density, a fix for E3SM-Ocean-Discussion#119 | xylar:ocn/land-ice-pressure-cap-ocean-density (E3SM-Ocean-Discussion#165, merged as `059ee8fa41`); needs E3SM-Ocean-Discussion#164 | suggested for E3SM-Ocean-Discussion#119; not in it yet |
| Update the land-ice mask from the ice fraction during a run | xylar:ocn/land-ice-mask-from-fraction (E3SM-Ocean-Discussion#166, merged as `76001323e6`) | none yet |
| Write the land-ice geometry to monthly means when coupled to glc | xylar:ocn/land-ice-geometry-in-monthly-means (E3SM-Ocean-Discussion#167, merged as `bf0c452408`) | none yet |
| Make MALI's data-mode export follow its thickness file | xylar:mali/update-masks-after-data-mode-read (E3SM-Ocean-Discussion#168, merged as `62ef616442`) | MALI-Dev/E3SM#216 |
| Skip frazil and melt where glc has too little floating ice to receive them | xylar:ocn/skip-frazil-without-glc-floating-ice (E3SM-Ocean-Discussion#169, merged as `3022261e84`) | none yet |
| Treat slivers of imported land ice as open ocean | xylar:ocn/ignore-tiny-glc-ice-fractions (E3SM-Ocean-Discussion#170, merged as `a9d9e2ff64`); needs E3SM-Ocean-Discussion#169 | none yet |
| Take the heat capacity of land ice from E3SM's constants, as MALI does | xylar:ocn/land-ice-heat-capacity-matches-mali (E3SM-Ocean-Discussion#171, merged as `9f52dc417d`) | none yet |
| Book the enthalpy of ice-shelf water in glc's heat budget | xylar:cpl/ice-enthalpy-in-glc-heat-budget (E3SM-Ocean-Discussion#172, merged as `7611b2feca`) | none yet |
| Melt in thin-film cells under glc's floating ice | xylar:ocn/thin-film-melt-under-glc-floating-ice (E3SM-Ocean-Discussion#173, merged as `609a726fb9`) | none yet |
| Let a case variable set MALI's data-mode reference time | xylar:landice/data-mode-reference-time (E3SM-Ocean-Discussion#174, merged as `2bb65b8d15`); needs E3SM-Ocean-Discussion#157 | MALI-Dev/E3SM#219 |
| Split the PV-flux Coriolis form between the split integrators' modes, behind `config_split_pv_coriolis` (default off) | xylar:se-pv-coriolis (E3SM-Ocean-Discussion#176, merged as `50788758b0`) | E3SM-Ocean-Discussion#177 (for discussion, against master) |
| Skip MALI's ocean thermal-forcing fields when their packages are off | xylar:landice/skip-inactive-thermal-forcing-fields (E3SM-Ocean-Discussion#178, merged as `5beb3f4f34`) | MALI-Dev/E3SM#219 (second commit) |
| Let E3SM namelists set `config_split_pv_coriolis` | xylar:se-pv-coriolis (E3SM-Ocean-Discussion#180, merged as `83956f591f`); needs E3SM-Ocean-Discussion#176 | E3SM-Ocean-Discussion#177 (second commit; for discussion, against master) |
| Let a case map glc's ice-shelf geometry to the ocean with its own map, `GLC2OCN_SHELF_SMAPNAME` (MCT driver; default the flux map) | xylar:cpl/smoothed-glc-geometry-map (E3SM-Ocean-Discussion#179, merged as `46549a6b31`) | none yet |
| Ramp the land-ice pressure MPAS-Ocean imports from glc over each glc coupling interval, behind `config_glc_ice_shelf_coupling_ramp_land_ice_pressure` (default off) | xylar:ocn-glc/ramp-land-ice-pressure (E3SM-Ocean-Discussion#181, merged as `9d52375cfa`) | none yet |
| Rebuild MALI's FEM grid only when its masks change; `config_always_compute_fem_grid` now defaults to `.false.` | xylar:mali/fix-fem-grid-rebuild-check-fanssie, the commits of MALI-Dev/E3SM#211 cherry-picked (E3SM-Ocean-Discussion#182, merged as `8ad4a25be0`) | MALI-Dev/E3SM#211 |
| Merge MALI-Dev's `develop` at `10664726d3` (2026-11-07) | MALI-Dev:develop via xylar:mali/merge-mali-dev-develop-2026-11-07 (E3SM-Ocean-Discussion#183, merged as `7f3288a4a9`) | E3SM#9149 |
| Add `normalLayerThicknessFlux`, the thickness flux the integrator applies, for exact mean transports, behind `config_compute_normal_layer_thickness_flux` (default off) | xylar:ocn/add-normal-layer-thickness-flux (E3SM-Ocean-Discussion#184, merged as `c77fad6d3b`) | none yet |
| Use the edge-mean thickness in momentum vertical advection, which upwind flux thicknesses at film edges had made run away | xylar:ocn/vadv-edge-mean-thickness (E3SM-Ocean-Discussion#185, merged as `3cafa3f0d7`) | none yet |
| Initialize CVMix's boundary-layer index without KPP, so convection applies over the whole column and runs repeat | xylar:ocn/fix-uninitialized-cvmix-obl-index-fanssie (E3SM-Ocean-Discussion#186, merged as `8341aa1592`) | E3SM-Project/E3SM#8984 |
| Limit split-explicit tracer advection against the state it updates, not the time-centered one, which let salinity overshoot its bounds | xylar:ocn/fix-split-explicit-tracer-fct-base-state (E3SM-Ocean-Discussion#187, merged as `c0bb6902ab`) | none yet (branch is on E3SM master's history) |
| Update the Physical Constants Dictionary to 0.3.0, which Polaris main requires | E3SM master's `1f86b72890` and `e15d4e6995` cherry-picked, via xylar:ocn/update-pcd-to-0.3.0-fanssie (E3SM-Ocean-Discussion#188, merged as `256d1c6d19`) | already on E3SM master |
| Add an option (`config_thin_film_cap_inflow_thickness`, off by default) to cap the flux thickness of inflow into thin wetting-and-drying columns, whose upwind value drove jets through films opening at the grounding line | xylar:ocn/cap-thin-film-inflow-flux-thickness (E3SM-Ocean-Discussion#189, merged as `541e83b42d`) | none yet (branch is on E3SM master's history) |
| Renormalize the vertical distribution of surface fluxes (and of subglacial runoff) over each column, instead of putting what would pass below the sea floor into the bottom layer, which in thin columns under ice shelves made frazil and concentrated salt | xylar:ocn/renormalize-surface-flux-absorption (E3SM-Ocean-Discussion#190, merged as `7b66c46036`) | none yet (branch is on E3SM master's history) |

## Plan for E3SM pull requests

The changes in the ledger reach E3SM master through a few pull requests, each with one conceptual focus, so that they can be reviewed and merged by early 2027. The land-ice melt equations and the ice-shelf melt coupling go first; everything else builds on them. This plan is updated as pull requests open and merge. Numbers without a repository are E3SM-Ocean-Discussion pull requests.

"Production" below means E3SM's default ocean configuration: the `split_explicit_ab2` time integrator, centered flux thickness, no wetting and drying and explicit top drag. Pull requests that change production results need full non-BFB testing. Two pull requests change results only in configurations no production run uses: the `split_explicit` time integrator and prognostic MALI coupled to the ocean. Whether those count as production for testing is still open.

| E3SM pull request | Includes | Production results | Notes |
|---|---|---|---|
| Modify land ice melt equations (E3SM#8047) | the fixes for E3SM#8047 | change for cryosphere configurations with active melt; unchanged without it | first |
| Couple ice-shelf melt between MPAS-Ocean and MALI (E3SM#8887) | E3SM#8661, merged | change | after E3SM#8047; take in as much of the moving-grounding-line coupling below as possible before review. E3SM#8887 already takes glc's cell areas from the glc-to-ocean map and adds glc's side to the coupler budgets, so check how far 163 and 172 overlap it |
| Fix ice-shelf melt and boundary-layer edge cases | 146, 150, 171, 147, 190 | likely change with active melt (171's land-ice heat capacity); 190 changes columns under ice shelves thinner than a few hundred meters; 146 matters only with implicit top drag, 150 only in nearly fresh water | after E3SM#8047; 147 (sea-ice salt limit) could instead be a separate one-line fix |
| Add pressure-gradient and equation-of-state options for ice-shelf cavities | 148, 149 | unchanged (options off by default) | independent |
| Support wetting and drying under land ice with a subglacial thin film | 119 with its fixes (`26fb0b6bed`, 164, 165), 141, 142, 145, 159, 160, 185, 189 | unchanged; 185 is unconditional but identical with centered flux thickness; 141 and 142 expected unchanged in cryosphere meshes, not yet checked | the largest; 185 and 189 (flux thickness at the thin film's edge) could be split off |
| Support wetting and drying with the split-explicit time integrator | 175 | unchanged without wetting and drying or tidal forcing | after the thin-film pull request; 175 is a draft until its melt gap against RK4 closes |
| Fix the split-explicit time integrator | 187, 176 and 180 (upstream draft 177), possibly 153 | unchanged: 187 touches `split_explicit`, not `split_explicit_ab2`; whether 153 changes `split_explicit_ab2` is not yet checked | changes `split_explicit` results |
| Couple MPAS-Ocean and MALI for moving grounding lines | 162, 163, 166, 169, 170, 172, 173, 179, 181 | unchanged; results change only with prognostic MALI coupled to the ocean | move as much as possible into E3SM#8887 before it is reviewed; 173 needs the thin-film pull request |
| Support idealized ice-shelf cases in E3SM | 143, 158, 161, 167, 184 | unchanged | independent |

MALI's changes reach E3SM through MALI-Dev rather than through these pull requests: 151 and 183 (merges of MALI-Dev's `develop`), 156 (MALI-Dev/E3SM#213), 157 (MALI-Dev/E3SM#214), 168 (MALI-Dev/E3SM#216), 174 and 178 (MALI-Dev/E3SM#219) and 182 (MALI-Dev/E3SM#211). E3SM#9149 brings all of them to E3SM master. Already on E3SM master: 186 (E3SM#8984) and 188.
