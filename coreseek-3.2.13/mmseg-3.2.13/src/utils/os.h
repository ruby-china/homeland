#ifndef _CSR_INNER_COMMON_H_
#define _CSR_INNER_COMMON_H_
/* import win32's setting */
#ifdef WIN32
#include "config.win.h"
#else
#include "config.h"
#endif

#ifdef HAVE_UNISTD_H
#include <unistd.h>
#endif
#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif
#ifdef HAVE_SYS_STAT_H
#include <sys/stat.h>
#endif
#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif
#ifdef HAVE_SYS_PARAM_H
#include <sys/param.h>
#endif

#ifdef __MINGW32__
#undef HAVE_MMAP
#endif
#ifdef HAVE_MMAP
#include <sys/mman.h>
#endif

#if !defined HAVE_MMAP && defined HAVE_WINDOWS_H
#include <windows.h>
#endif

#endif

