/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* ***** BEGIN LICENSE BLOCK *****
* Version: GPL 2.0
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License. You should have
* received a copy of the GPL license along with this program; if you
* did not, you can find it at http://www.gnu.org/
*
* Software distributed under the License is distributed on an "AS IS" basis,
* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
* for the specific language governing rights and limitations under the
* License.
*
* The Original Code is Coreseek.com code.
*
* Copyright (C) 2007-2008. All Rights Reserved.
*
* Author:
*	Li monan <li.monan@gmail.com>
*
* ***** END LICENSE BLOCK ***** */

#include <stdlib.h>
#include <string.h>

#include <stdio.h>
#include "csr_utils.h"

#include <stdarg.h>
//#define _CLCOMPILER_MSVC 0

#if WIN32
#include <sys/types.h>
#include <sys/timeb.h>
#else
#include <time.h>
#include <sys/types.h>
#include <sys/timeb.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

int
csr_atoi (const char *nptr)
{
	return (int) strtol (nptr, (char **) NULL, 10);
}

u2 u2_length(const u2* p){
	const u2* ptr = p;
	while(*ptr)
		ptr++;
	return ptr-p;
}

int Cha_lineno, Cha_lineno_error;
int Cha_errno = 0;
static FILE *cha_stderr = NULL;

void
csr_exit(int status, char *format, ...)
{
	va_list ap;

	if (Cha_errno)
		return;

	if (!cha_stderr)
		cha_stderr = stderr;
	else if (cha_stderr != stderr)
		fputs("500 ", cha_stderr);

	va_start(ap, format);
	vfprintf(cha_stderr, format, ap);
	va_end(ap);
	if (status >= 0) {
		fputc('\n', cha_stderr);
		if (cha_stderr == stderr)
			exit(status);
		Cha_errno = 1;
	}
}

void
csr_perror(const char *s)
{
	csr_exit(-1, "");
	perror(s);
}

void
csr_exit_perror(const char *s)
{
	csr_perror(s);
	exit(1);
}

unsigned long currentTimeMillis() {
#if WIN32 //|| defined(__MINGW32__)
	struct _timeb tstruct;
	_ftime(&tstruct);

	return (((unsigned long) tstruct.time) * 1000) + tstruct.millitm;
#else

	struct timeval tstruct;
	if (gettimeofday(&tstruct, NULL) < 0) {
		fprintf(stderr,"Error in gettimeofday call.");
	}

	return (((long) tstruct.tv_sec) * 1000) + tstruct.tv_usec / 1000;
#endif
}

u4 countBitsU4(u4 bits)
{
	bits = bits - ((bits >> 1) & 0x55555555);
	bits = ((bits >> 2) & 0x33333333) + (bits & 0x33333333);
	bits = ((bits >> 4) + bits) & 0x0F0F0F0F;
	return (bits * 0x01010101) >> 24;
}
u2 countBitsU2(u2 bits)
{
	bits = bits - ((bits >> 1) & 0x5555);
	bits = ((bits >> 2) & 0x3333) + (bits & 0x3333);
	bits = ((bits >> 4) + bits) & 0x0F0F;
	return ((bits * 0x0101) >> 8)&0x0F;
}
u1 countBitsU1(u1 bits)
{
	bits = bits - ((bits >> 1) & 0x55);
	bits = ((bits >> 2) & 0x33) + (bits & 0x33);
	bits = ((bits >> 4) + bits) & 0x0F;
	return (bits * 0x01);
}



#ifdef __cplusplus
};
#endif
