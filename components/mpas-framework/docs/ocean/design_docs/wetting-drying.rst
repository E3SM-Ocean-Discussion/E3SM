
Wetting and drying in coastal and ice-shelf settings
====================================================

date: 2022/02/16 

Contributors: Carolyn Begeman, Darren Engwirda, Xylar Asay-Davis



Summary
-------

"Wetting and drying" refers to the capability to have cells switch between
wet and dry in time corresponding to changes in ocean extent. This
implementation uses a "thin film" approach in which cells with water column
thickness below a threshold are considered dry. Instabilities have been noted
when MPAS-Ocean is run with shallow water columns, precluding stable wetting
and drying. We aim to produce stable and accurate thin-film wetting and drying
for both coastal and ice-shelf settings.



Requirements
------------

Requirement: Monotonic thickness advection scheme
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

The thickness advection scheme needs to be monotonic to prevent layer
thicknesses from becoming negative. 


Requirement: Maximize energy conservation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

The advection scheme should still approximate energy conservation.


Requirement: Maximize mass conservation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

The advection scheme should still approximate mass conservation.


Requirement: Stability under existing time-stepping algorithms
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

The wetting and drying algorithm should be stable for both RK4 and split-
explicit time stepping.


Requirement: Avoid new constraints on the time step
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Wetting and drying must not significantly decrease the time step required for
stability beyond constraint already present in MPAS-O.
Ensure that it is impossible to completely empty a cell within one time step.


Requirement: Avoid significant depreciation in performance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Wetting and drying algorithm should be scalable and not increase run time by
more than about 5%.


Requirement: Allow baroclinic velocities in shallow, wet cells
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

The wetting and drying algorithm should be compatible with baroclinic velocities
as cells become wet on the barotropic time step.


Requirement: Allow tracer diffusion within the thin film
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Tracer diffusion should be permitted in the thin film to avoid large changes in
tracer concentration during wetting. Other tracer tendencies will be set to
zero.


Requirement: Algorithm is appropriate for grounding line motion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Stability and consistency of continuity and momentum equations is preserved in
land ice settings where gradients in sea surface pressure (land ice pressure)
are much larger than coastal settings.


Requirement: Water is evacuated from isolated lakes when drying occurs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Ideally, when isolated lakes occur after a cycle of wetting and drying, the
water in those lakes is evacuated. It would also be best for mass conservation
if that water were returned to the ocean. This is particularly desirable for
grounding line migration.


Algorithm Design (optional)
---------------------------

Algorithm Design: Maximize energy conservation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Energy conservation in the advection scheme is only guaranteed for centered
thicknesses, not upwinded thicknesses. Thus, we only conduct upwinding of layer
thicknesses in the shallow water regions where it is necessary to preserve
stability, as determined by a water column thickness threshold. In order to
transition gradually between upwinded and centered solutions, we implement a
ramping function with water column thickness as an input.

.. math::

   \beta_{e} = 1 - \min\left(1,\, \max\left(0,\,
   \frac{H_{\text{edge}}^{*}}{H_{\text{upwind}}} - 1\right)\right)

where :math:`H_{\text{upwind}}` is the water column thickness at which only
upwinding is used, with a ramp between upwinding and centered thicknesses from
:math:`H_{\text{upwind}}` to :math:`2H_{\text{upwind}}`.
:math:`H_{\text{edge}}^{*}` is the harmonic mean of the water column thickness
of the adjacent cells:

.. math::

   H_{\text{edge}}^{*} = \frac{2\, H_{c_1} H_{c_2}}{H_{c_1} + H_{c_2}}

Additionally, any enhancement of drag in cells with a thin water column needed
for stability should not dissipate excessive amounts of energy (e.g., tidal
energy).


Algorithm design: Stability under existing time-stepping algorithms
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Stability of the wet/dry interface is achieved through a damping function on the
volume fluxes and velocities out of a dry cell

.. math::

   \alpha_{e} = \min\left(1,\, \max\left(0,\,
   \frac{H_{\text{edge}}^{*}}{H_{\text{thin}}} - 1\right)\right)

An alternative to damping the fluxes and velocities at dry cells is removing
terms from the momentum equation.


Algorithm design: Allow baroclinic velocities in shallow, wet cells
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

We follow O'Dea et al. (2020) [NEMO] in scaling baroclinic fluxes and
velocities by the mean of the factor \alpha over the barotropic substeps. Thus,
baroclinic velocities are permitted as the cell transitions from wet to dry.


Implementation
--------------

Implementation: Monotonic thickness advection scheme
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

First-order thickness upwinding is sufficient to produce monotonicity.
The option to choose upwinded thickness advection rather than centered
thickness advection is already implemented with flag 
`config_thickness_flux_type`. 


Implementation: Maximize energy conservation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

In addition to the option to have centered edge thicknesses and upwinded edge
thicknesses, we add a third option which is either centered, upwinded, or a
blend of the two as a function of water column thickness. This is 
`config_thickness_flux_type = 'thickness-dependent'`.

The ramping function is implemented in `ocn_diagnostic_solve_layerThickEdge`
in order to weight both centered and upwinded layerThickEdge. The water column
thickness input to the ramping function is the harmonic mean of water column
thicknesses in the two cells adjacent to the edge at which layerThickEdge is
computed.

We need to ensure that the upwinded or hybrid layerThickEdge is appropriate
everywhere it is used. In most terms it is appropriate as it is linked with the
volumetric flux through edges.

Is is appropriate to use upwinded layerThickEdge in the computation of the 
horizontal gradient of density at the top of edges in mpas_ocn_gm.F_?

.. _mpas_ocn_gm.F: https://github.com/E3SM-Project/E3SM/blob/460ef4af4b91d01213ea0d00290236c996d100f2/components/mpas-ocean/src/shared/mpas_ocn_gm.F#L455-L493


Implementation: Stability under existing time-stepping algorithms
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Add additional options for damping thickness fluxes and velocities to the
existing `ocn_wetting_drying` module. 

Existing options for damping thickness fluxes and velocities:

If `config_zero_drying_velocity` is true, every cell that would reach
the minimum thin film thickness (plus an optional tolerance
`config_drying_safety_height`) through the outgoing flux alone in that 
timestep has `normalVelocity` and `normalTransportVelocity` set to zero. 

If `config_zero_drying_velocity` is false, for only edges where the flux is
outgoing:

.. math::

   u_{\text{Trans}} = u_{\text{Trans}} + u_{\text{Wet}}
   u = u + u_{\text{Wet}}
   u_{\text{Wet}} = - u * min(max(0,\\
                                 (1 - \nabla \cdot F_{\text{out}})^2)\\
                              1)
   u_{\text{tend}} = u_{\text{tend}} * (1 - u_{\text{Wet}})
   u = u * (1 - u_{\text{Wet}}) \text{(diagnostic update)}

In addition, `normalVelocity` and `normalTransportVelocity` are set to zero
when :math:`|u_{\text{Trans}} + u_{\text{Wet}}| < \varepsilon` where
:math:`\varepsilon` is some small tolerance, designed to prevent spurious fluxes.

Each of these updates are applied on each RK4 iteration.


Implementation: Avoid new constraints on the time step
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

We hope that in most physical conditions the velocities are insufficiently
high to evacuate all of the water from a cell in one barotropic timestep. One
way to mitigate this possibility is to either increase the thin film thickness
or to increase the width of the water column thickness transition between wet
and dry dynamics (i.e., damping fluxes and velocity in cells close to the thin
film threshold).


Implementation: Water is evacuated from isolated lakes when drying occurs
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Evaluate when wet/dry interface makes a closed loop. Reduce water column
thickness to the threshold thin film thickness. Set a flux equivalent to that
evacuated volume using existing distributed river flux implementation.

Testing
-------

Testing and Validation: Monotonic thickness advection scheme
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

No testing is needed as this is an existing capability.


Testing and Validation: Maximize energy conservation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Ensure that the solution with `config_thickness_flux_type = 'thickness-dependent'`
is identical to the solution with `config_thickness_flux_type = 'centered'`
when all cells in the domain have water column thicknesses greater than the
threshold at which ramping to upwinded thicknesses begins. This should be
tested in the global ocean configuration with ecosystem tracers.


Testing and Validation: Maximize mass conservation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Compute the total mass evolution in the uniform bed slope case.


Testing and Validation: Stability under existing time-stepping algorithms
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

We test both the uniformly sloping bed test case and the dam break test case
with RK4 and split-explicit time-stepping schemes. 


Testing and Validation: Avoid new constraints on the time step
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Verify that no cells drop below the minimum thickness in either uniform sloping
bottom or dam break test cases.


Testing and Validation: Avoid significant depreciation in performance
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Test scalability of wetting and drying through the uniform bed slope test
cases. Test performance relative to non-wetting and drying cases by comparing
the former test case to the same test case with wetting and drying disabled.


Testing and Validation: Allow baroclinic velocities in shallow, wet cells
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

TBD


Testing and Validation: Allow tracer diffusion within the thin film
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

Verify that tracers are diffused into the thin film by initializing the uniform
bed slope simulation with a discontinuity in tracer concentrations across the
wet/dry interface.


Testing and Validation: Algorithm is appropriate for grounding line motion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

TBD: need to develop new test case for ice shelf cavity. We could add a tidal
signal at the open boundary of ISOMIP+ Ocean0.


Testing and Validation: Water is evacuated from isolated lakes
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Date last modified: YYYY/MM/DD

Contributors: (add your name to this list if it does not appear)

The uniformly sloping bed test case can be modified to include a depression that
would fill with water to ensure that the emptying algorithm functions as
expected.
