#ifndef _PY_LAYER_H_
#define _PY_LAYER_H_
#include "sphinx.h"

#if USE_PYTHON

#ifdef _DEBUG
#define D_E_B_U_G
#undef   _DEBUG
#endif
#include   <Python.h>    
#ifdef	D_E_B_U_G
#undef  D_E_B_U_G
#define _DEBUG
#endif

//#include   <Python.h>    


//////////////////////////////////////////////////////////////////////////

bool			cftInitialize( const CSphConfigSection & hPython);
void			cftShutdown();

CSphSource * SpawnSourcePython ( const CSphConfigSection & hSource, const char * sSourceName);

#endif //USE_PYTHON

#endif

