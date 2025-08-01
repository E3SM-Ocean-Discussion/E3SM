#ifndef GW_UNIT_TESTS_COMMON_HPP
#define GW_UNIT_TESTS_COMMON_HPP

#include "share/eamxx_types.hpp"
#include "share/util/eamxx_setup_random_test.hpp"
#include "gw_functions.hpp"
#include "ekat/util/ekat_test_utils.hpp"
#include "gw_test_data.hpp"

#include <vector>
#include <sstream>

namespace scream {
namespace gw {
namespace unit_test {

/*
 * Unit test infrastructure for gw unit tests.
 *
 * gw entities can friend scream::gw::unit_test::UnitWrap to give unit tests
 * access to private members.
 *
 * All unit test impls should be within an inner struct of UnitWrap::UnitTest for
 * easy access to useful types.
 */

struct UnitWrap {

  template <typename D=DefaultDevice>
  struct UnitTest : public KokkosTypes<D> {

    using Device      = D;
    using MemberType  = typename KokkosTypes<Device>::MemberType;
    using TeamPolicy  = typename KokkosTypes<Device>::TeamPolicy;
    using RangePolicy = typename KokkosTypes<Device>::RangePolicy;
    using ExeSpace    = typename KokkosTypes<Device>::ExeSpace;

    template <typename S>
    using view_1d = typename KokkosTypes<Device>::template view_1d<S>;
    template <typename S>
    using view_2d = typename KokkosTypes<Device>::template view_2d<S>;
    template <typename S>
    using view_3d = typename KokkosTypes<Device>::template view_3d<S>;

    template <typename S>
    using uview_1d = typename ekat::template Unmanaged<view_1d<S> >;

    using Functions          = scream::gw::Functions<Real, Device>;
    // using view_ice_table     = typename Functions::view_ice_table;
    // using view_collect_table = typename Functions::view_collect_table;
    // using view_1d_table      = typename Functions::view_1d_table;
    // using view_2d_table      = typename Functions::view_2d_table;
    // using view_dnu_table     = typename Functions::view_dnu_table;
    using Scalar             = typename Functions::Scalar;
    using Spack              = typename Functions::Spack;
    // using Pack               = typename Functions::Pack;
    // using IntSmallPack       = typename Functions::IntSmallPack;
    // using Smask              = typename Functions::Smask;
    // using TableIce           = typename Functions::TableIce;
    // using TableRain          = typename Functions::TableRain;
    // using Table3             = typename Functions::Table3;
    // using C                  = typename Functions::C;

    static constexpr Int max_pack_size = 16;
    static constexpr Int num_test_itrs = max_pack_size / Spack::n;

    struct Base : public UnitBase {

      Base() :
        UnitBase()
      {
        // Functions::gw_init(); // just in case there is ever global gw data
      }

      ~Base() = default;
    };

    // Put struct decls here
    struct TestGwdComputeTendenciesFromStressDivergence;
    struct TestGwProf;
    struct TestMomentumEnergyConservation;
    struct TestGwdComputeStressProfilesAndDiffusivities;
    struct TestGwdProjectTau;
    struct TestGwdPrecalcRhoi;
    struct TestGwDragProf;
    struct TestGwFrontProjectWinds;
    struct TestGwFrontGwSources;
    struct TestGwCmSrc;
    struct TestGwConvectProjectWinds;
    struct TestGwHeatingDepth;
    struct TestGwStormSpeed;
    struct TestGwConvectGwSources;
    struct TestGwBeresSrc;
    struct TestGwEdiff;
    struct TestGwDiffTend;
    struct TestGwOroSrc;
  }; // UnitWrap
};

} // namespace unit_test
} // namespace gw
} // namespace scream

#endif
