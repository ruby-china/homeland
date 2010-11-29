## sys_errlist.m4 -- determine whether the system library provides sys_errlist
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

# serial 1 SIC_VAR_SYS_ERRLIST

AC_DEFUN(SIC_VAR_SYS_ERRLIST,
[AC_CACHE_CHECK([for sys_errlist],
sic_cv_var_sys_errlist,
[AC_TRY_LINK([int *p;], [extern int sys_errlist; p = &sys_errlist;],
	    sic_cv_var_sys_errlist=yes, sic_cv_var_sys_errlist=no)])
if test x"$sic_cv_var_sys_errlist" = xyes; then
  AC_DEFINE(HAVE_SYS_ERRLIST, 1,
           [Define if your system libraries have a sys_errlist variable.])
fi])
