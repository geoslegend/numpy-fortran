program a
use types, only: dp
use compute, only: init, register_func, run, eq, destroy, get_context
use iso_c_binding, only: c_ptr, c_loc, c_f_pointer

type my_data
    ! Material coefficients:
    real(dp) :: a11, a12, a21, a22
    ! There can be a lot of variables and big arrays here, this needs
    ! to be passed around by reference.
end type

type(eq), pointer :: d
type(my_data), target :: data1, data2

data1%a11 = 0
data1%a12 = -1
data1%a21 = 1
data1%a22 = 0

data2%a11 = 0
data2%a12 = 1
data2%a21 = 1
data2%a22 = 0

call init(d)
call register_func(d, derivs, c_loc(data1))
call run(d, [0.0_dp, 1.0_dp], 0.1_dp, 10)
call print_material_parameters(d)
print *
call register_func(d, derivs, c_loc(data2))
call run(d, [0.0_dp, 1.0_dp], 0.1_dp, 10)
call print_material_parameters(d)
call destroy(d)

contains

subroutine print_material_parameters(d)
type(eq), intent(in) :: d
type(my_data), pointer :: ctx
call c_f_pointer(get_context(d), ctx)
print "('Material parameters: ', f0.6, ' ', f0.6, ' ', f0.6, ' ', f0.6)", &
    ctx%a11, ctx%a12, ctx%a21, ctx%a22
end subroutine

function derivs(x, data) result(y)
use types, only: dp
real(dp), intent(in) :: x(2)
type(c_ptr), intent(in) :: data
real(dp) :: y(2)
type(my_data), pointer :: d
call c_f_pointer(data, d)
y(1) = d%a11 * x(1) + d%a12 * x(2)
y(2) = d%a21 * x(1) + d%a22 * x(2)
end function

end program
