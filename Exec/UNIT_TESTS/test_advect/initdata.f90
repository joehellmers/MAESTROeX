
module initdata_module

  use parallel, only: parallel_IOProcessor
  use network, only: nspec
  use amrex_fort_module, only : amrex_spacedim
  use base_state_geometry_module, only: nr_fine, max_radial_level, center
  use meth_params_module, only: nscal, rho_comp, rhoh_comp, temp_comp, spec_comp, pi_comp, &
       prob_lo, prob_hi, base_cutoff_density
  use probin_module, only: dir

  implicit none

  private

  ! width of the gaussian
  double precision, parameter :: W = 0.05

contains

  subroutine initdata(lev, time, lo, hi, &
       scal, scal_lo, scal_hi, nc_s, &
       vel, vel_lo, vel_hi, nc_v, &
       s0_init, p0_init, &
       dx) bind(C, name="initdata")

    integer         , intent(in   ) :: lev, lo(3), hi(3)
    integer         , intent(in   ) :: scal_lo(3), scal_hi(3), nc_s
    integer         , intent(in   ) :: vel_lo(3), vel_hi(3), nc_v
    double precision, intent(in   ) :: time
    double precision, intent(inout) :: scal(scal_lo(1):scal_hi(1), &
         scal_lo(2):scal_hi(2), &
         scal_lo(3):scal_hi(3), 1:nc_s)
    double precision, intent(inout) :: vel(vel_lo(1):vel_hi(1), &
         vel_lo(2):vel_hi(2), &
         vel_lo(3):vel_hi(3), 1:nc_v)
    double precision, intent(in   ) :: s0_init(0:max_radial_level,0:nr_fine-1,1:nscal)
    double precision, intent(in   ) :: p0_init(0:max_radial_level,0:nr_fine-1)
    double precision, intent(in   ) :: dx(3)

    integer          :: i,j,k

    double precision :: x, y, z, dist

    ! set velocity to zero
    vel(lo(1):hi(1),lo(2):hi(2),lo(3):hi(3),1:nc_v) = 0.0d0
    scal(lo(1):hi(1),lo(2):hi(2),lo(3):hi(3),1:nc_s) = 0.0d0

    do k=lo(3),hi(3)
       z = (dble(k)+0.5d0)*dx(3) + prob_lo(3) - center(3)
       do j=lo(2),hi(2)
          y = (dble(j)+0.5d0)*dx(2) + prob_lo(2) - center(2)
          do i=lo(1),hi(1)
             x = (dble(i)+0.5d0)*dx(1) + prob_lo(1) - center(1)

             dist = sqrt(x**2 + y**2 + z**2)

             scal(i,j,k,rho_comp)  = max(exp(-dist**2/W**2),base_cutoff_density)

             scal(i,j,k,spec_comp) = scal(i,j,k,rho_comp)

             select case (dir)

             case(-1)
                 vel(i,j,k,1) = -1.0d0

             case(1)
                 vel(i,j,k,1) = 1.0d0

             case(-2)
                 vel(i,j,k,2) = -1.0d0

             case(2)
                 vel(i,j,k,2) = 1.0d0

             case(-3)
                 vel(i,j,k,3) = -1.0d0

             case(3)
                 vel(i,j,k,3) = 1.0d0

             end select

          end do
       end do
    end do

    ! do k=lo(3),hi(3)
    !    do j=lo(2),hi(2)
    !       do i=lo(1),hi(1)
    !
    !          if (amrex_spacedim .eq. 1) then
    !             r = i
    !          else if (amrex_spacedim .eq. 2) then
    !             r = j
    !          else if (amrex_spacedim .eq. 3) then
    !             r = k
    !          end if
    !
    !          ! set scalars using s0
    !          scal(i,j,k,rho_comp)  = s0_init(lev,r,rho_comp)
    !          scal(i,j,k,rhoh_comp) = s0_init(lev,r,rhoh_comp)
    !          scal(i,j,k,temp_comp) = s0_init(lev,r,temp_comp)
    !          scal(i,j,k,spec_comp:spec_comp+nspec-1) = &
    !               s0_init(lev,r,spec_comp:spec_comp+nspec-1)
    !
    !          ! initialize pi to zero for now
    !          scal(i,j,k,pi_comp) = 0.d0
    !
    !       end do
    !    end do
    ! end do

  end subroutine initdata


  subroutine initdata_sphr(time, lo, hi, &
       scal, scal_lo, scal_hi, nc_s, &
       vel, vel_lo, vel_hi, nc_v, &
       s0_init, p0_init, &
       dx, r_cc_loc, r_edge_loc, &
       cc_to_r, ccr_lo, ccr_hi) bind(C, name="initdata_sphr")

    integer         , intent(in   ) :: lo(3), hi(3)
    integer         , intent(in   ) :: scal_lo(3), scal_hi(3), nc_s
    integer         , intent(in   ) :: vel_lo(3), vel_hi(3), nc_v
    double precision, intent(in   ) :: time
    double precision, intent(inout) :: scal(scal_lo(1):scal_hi(1), &
         scal_lo(2):scal_hi(2), &
         scal_lo(3):scal_hi(3), nc_s)
    double precision, intent(inout) :: vel(vel_lo(1):vel_hi(1), &
         vel_lo(2):vel_hi(2), &
         vel_lo(3):vel_hi(3), nc_v)
    double precision, intent(in   ) :: s0_init(0:max_radial_level,0:nr_fine-1,1:nscal)
    double precision, intent(in   ) :: p0_init(0:max_radial_level,0:nr_fine-1)
    double precision, intent(in   ) :: dx(3)
    double precision, intent(in   ) :: r_cc_loc (0:max_radial_level,0:nr_fine-1)
    double precision, intent(in   ) :: r_edge_loc(0:max_radial_level,0:nr_fine)
    integer         , intent(in   ) :: ccr_lo(3), ccr_hi(3)
    double precision, intent(in   ) :: cc_to_r(ccr_lo(1):ccr_hi(1), &
         ccr_lo(2):ccr_hi(2),ccr_lo(3):ccr_hi(3))

  end subroutine initdata_sphr

end module initdata_module
