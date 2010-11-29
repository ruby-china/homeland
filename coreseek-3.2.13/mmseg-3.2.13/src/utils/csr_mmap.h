#ifndef _CSR_MMAP_H_
#define _CSR_MMAP_H_

#include "csr_typedefs.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _csr_mmap_t csr_mmap_t;

/* mmap.c */
csr_mmap_t *csr_mmap_file(const char*,unsigned char bLoadMem);
csr_mmap_t *csr_mmap_file_w(const char*);
void csr_munmap_file(csr_mmap_t*);
void *csr_mmap_map(csr_mmap_t*);
csr_offset_t csr_mmap_size(csr_mmap_t*); 

#ifdef __cplusplus
}
#endif	

#endif
 
