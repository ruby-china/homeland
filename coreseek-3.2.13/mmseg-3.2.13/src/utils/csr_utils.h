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

#ifndef _CSR_UTILES_H_
#define _CSR_UTILES_H_
#include "csr_typedefs.h"

#ifdef __cplusplus
extern "C" {
#endif

//helper function
//#undef	atoi
/* Convert a string to an int.  */
int
csr_atoi (const char *nptr);

void	csr_perror(const char *s);
void	csr_exit_perror(const char *s);

unsigned long currentTimeMillis();
u4 countBitsU4(u4 num);
u2 countBitsU2(u2 num);
u1 countBitsU1(u1 num);
u2 u2_length(const u2* p);


#ifdef __cplusplus
};
#endif

#endif
