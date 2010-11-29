dnl prog-ensure.m4 -- Require that a program be found in the PATH.
dnl $Id: prog-ensure.m4 6544 2003-12-26 03:23:31Z rra $
dnl
dnl This is a version of AC_PATH_PROG that requires that the program being
dnl searched for is found in the user's PATH.

AC_DEFUN([INN_PATH_PROG_ENSURE],
[AC_PATH_PROG([$1], [$2])
if test x"${$1}" = x ; then
    AC_MSG_ERROR([$2 was not found in path and is required])
fi])


dnl python.m4 -- Probe for the details needed to embed Python.
dnl $Id: python.m4 6544 2003-12-26 03:23:31Z rra $
dnl
dnl Defines INN_ARG_PYTHON, which sets up the --with-python command line
dnl argument and also sets various flags needed for embedded Python if it is
dnl requested.

AC_DEFUN([INN_ARG_PYTHON],
[AC_ARG_VAR([PYTHON], [Location of Python interpretor])
AC_ARG_WITH([python],
    [AC_HELP_STRING([--with-python], [Embedded Python datasource support [no]])],
    [case $withval in
    yes) USE_PYTHON=DO
         AC_DEFINE(USE_PYTHON, 1,
             [Define to compile in Python datasource support.])
         ;;
    no)  USE_PYTHON=DONT ;;
    *)   AC_MSG_ERROR([invalid argument to --with-python]) ;;
    esac],
    USE_PYTHON=DONT)

dnl A better way of doing this rather than grepping through the Makefile would
dnl be to use distutils.sysconfig, but this module isn't available in older
dnl versions of Python.
if test x"$USE_PYTHON" = xDO ; then
    INN_PATH_PROG_ENSURE([PYTHON], [python])
    AC_MSG_CHECKING([for Python linkage])
    py_prefix=`$PYTHON -c 'import sys; print sys.prefix'`
    py_ver=`$PYTHON -c 'import sys; print sys.version[[:3]]'`
    py_libdir="$py_prefix/lib/python$py_ver"
    PYTHON_CPPFLAGS="-I$py_prefix/include/python$py_ver"
    py_linkage=""
    for py_linkpart in LIBS LIBC LIBM LOCALMODLIBS BASEMODLIBS \
                       LINKFORSHARED LDFLAGS ; do
        py_linkage="$py_linkage "`grep "^${py_linkpart}=" \
                                       $py_libdir/config/Makefile \
                                  | sed -e 's/^.*=//'`
    done
    dnl PYTHON_LIBS="-L$py_libdir/config -lpython$py_ver $py_linkage"
    PYTHON_LIBS="-L$py_libdir/config -lpython$py_ver "
    PYTHON_LIBS=`echo $PYTHON_LIBS | sed -e 's/[ \\t]*/ /g'`
    AC_MSG_RESULT([$py_libdir])
else
    PYTHON_CPPFLAGS=
    PYTHON_LIBS=
fi
AC_SUBST([PYTHON_CPPFLAGS])
AC_SUBST([PYTHON_LIBS])])
