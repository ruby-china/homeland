## sys_siglist.m4 -- determine whether the system library provides sys_siglist
## Copyright (C) 2000 Gary V. Vaughan
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# serial 1 SIC_VAR_SYS_SIGLIST

AC_DEFUN(SIC_VAR_SYS_SIGLIST,
[AC_CACHE_CHECK([for sys_siglist],
sic_cv_var_sys_siglist,
[AC_TRY_LINK([int *p;], [extern int sys_siglist; p = &sys_siglist;],
	    sic_cv_var_sys_siglist=yes, sic_cv_var_sys_siglist=no)])
if test x"$sic_cv_var_sys_siglist" = xyes; then
  AC_DEFINE(HAVE_SYS_SIGLIST, 1,
           [Define if your system libraries have a sys_siglist variable.])
fi])
