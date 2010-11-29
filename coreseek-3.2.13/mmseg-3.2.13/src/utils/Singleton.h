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

#ifndef CSR_SINGLETON_H
#define CSR_SINGLETON_H

#ifdef HAVE_ATEXIT
#	ifdef HAVE_CSTDLIB
#include <cstdlib>
using std::atexit;
#	else
#include <stdlib.h>
#	endif
#endif

/**
 * A template class that implements the Singleton pattern.
 * FIXME: should I impl HAVE_ATEXIT mode? like bzflag?
 */
template <typename T>
class CSR_Singleton
{
	static T* ms_instance;
public:
	/**
	 * Static method to access the only pointer of this instance.
	 * \return a pointer to the only instance of this 
	 */
	static T* Get();

	/**
	 * Release resources.
	 */
	static void Free();

protected:
	/**
	 * Default constructor.
	 */
	CSR_Singleton();

	/**
	 * Destructor.
	 */
	virtual ~CSR_Singleton();
	
	static void destroy() {
		if ( ms_instance != 0 ) {
		delete(ms_instance);
		ms_instance = 0;
		}
	}
};
template <typename T>
T* CSR_Singleton<T>::ms_instance = 0;

template <typename T>
CSR_Singleton<T>::CSR_Singleton()
{
}

template <typename T>
CSR_Singleton<T>::~CSR_Singleton()
{
}

template <typename T>
T* CSR_Singleton<T>::Get()
{
	if(!ms_instance){
		ms_instance = new T();
		// destroy the singleton when the application terminates
#ifdef HAVE_ATEXIT
		atexit(CSR_Singleton::destroy);
#endif
	}
	return ms_instance;
}

template <typename T>
void CSR_Singleton<T>::Free()
{
	if( ms_instance )
	{
		delete ms_instance;
		ms_instance = 0;
	}
}

#endif // CSR_SINGLETON_H
