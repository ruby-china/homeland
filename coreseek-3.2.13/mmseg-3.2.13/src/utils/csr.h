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

#ifndef _CORESEEK_RUNTIME_COMMON_H_
#define _CORESEEK_RUNTIME_COMMON_H_

/*include types*/
#include "csr_typedefs.h"


#include "Utf8_16.h"
#include "StringTokenizer.h"

/*
#ifdef WIN32
typedef std::wstring unistring;
#else
*/
typedef std::basic_string<unsigned short> unistring;
//#endif

#ifdef WIN32
#define snprintf        _snprintf
#endif

#endif

