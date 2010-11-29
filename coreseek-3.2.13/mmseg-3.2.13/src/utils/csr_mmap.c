/*
 * Copyright (c) 2006 coreseek.com
 * All rights reserved.
 * $Id: csr_mmap.c
 */

#include "os.h"

#if ! defined _WIN32 && ! defined __CYGWIN__
#define O_BINARY 0
#endif

///FIXME: should support share.
#ifndef HAVE_MMAP
#define PROT_WRITE  2
#define PROT_READ   1
#endif

#include "csr_mmap.h"
#include "csr_utils.h"
#include <fcntl.h>
#include <stdio.h>

#ifdef WIN32
#include <io.h>
#else
#include   <string.h>
#include   <sys/types.h>  
#include   <sys/timeb.h>  
#endif

#ifdef __cplusplus
extern "C" {
#endif

struct _csr_mmap_t {
    void *map;
    csr_offset_t size;
	u4	bLoadMem;
#if !defined HAVE_MMAP && defined HAVE_WINDOWS_H
    HANDLE hfile;
    HANDLE hmap;
#endif
};

static csr_mmap_t *
mmap_file(const char *filename, int prot,unsigned char bLoadMem)
{
    csr_mmap_t *mm;
	int fd;
	struct stat st;
#if !defined HAVE_MMAP && defined HAVE_WINDOWS_H
    unsigned long file_mode, map_mode, view_mode;
#else
    int flag = O_RDONLY;
#endif

    mm = malloc(sizeof(csr_mmap_t));
	memset(mm,0,sizeof(csr_mmap_t));
	if(bLoadMem){
		mm->bLoadMem = bLoadMem;
		if ((fd = open(filename, O_RDONLY)) < 0)
			//csr_exit_perror(filename);
			return NULL;
		if (fstat(fd, &st) < 0)
			//csr_exit_perror(filename);
			return NULL;
		mm->size = st.st_size;
		mm->map = malloc(mm->size);
		if (read(fd, mm->map, mm->size) < 0)
			//csr_exit_perror(filename);
			return NULL;
		close(fd);
		return mm;
	}
#if !defined HAVE_MMAP && defined HAVE_WINDOWS_H
    if ((prot & PROT_WRITE) != 0) {
	file_mode = GENERIC_READ | GENERIC_WRITE;
	map_mode = PAGE_READWRITE;
	view_mode = FILE_MAP_WRITE;
    } else {
	file_mode = GENERIC_READ;
	map_mode = PAGE_READONLY;
	view_mode = FILE_MAP_READ;
    }

    mm->hfile = CreateFile(filename, file_mode, 0, NULL,
			   OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (mm->hfile == INVALID_HANDLE_VALUE)
        //csr_exit_perror(filename);
		return NULL;

    mm->size = GetFileSize(mm->hfile, NULL);

    mm->hmap = CreateFileMapping(mm->hfile, NULL, map_mode, 0, 0, NULL);
    if (mm->hmap == NULL) {
		CloseHandle(mm->hfile);
		//csr_exit_perror(filename);
		return NULL;
    }
				
    mm->map = MapViewOfFile(mm->hmap, view_mode, 0, 0, 0);
    if (mm->map == NULL) {
		CloseHandle(mm->hfile);
		CloseHandle(mm->hmap);
		//csr_exit_perror(filename);
		return NULL;
    }

#else /* !defined HAVE_MMAP && defined HAVE_WINDOWS_H */
    if ((prot & PROT_WRITE) != 0)
	flag = O_RDWR;
	
    if ((fd = open(filename, flag)) < 0)
		//csr_exit_perror(filename);
		return NULL;
    if (fstat(fd, &st) < 0)
		//csr_exit_perror(filename);
		return NULL;
    mm->size = st.st_size;
#ifdef HAVE_MMAP
    if ((mm->map = mmap((void *)0, mm->size, prot, MAP_SHARED, fd, 0)) == MAP_FAILED) {
		//csr_exit_perror(filename);
		return NULL;
    }
#else /* HAVE_MMAP */
    mm->map = malloc(mm->size);
    if (read(fd, mm->map, mm->size) < 0)
		//csr_exit_perror(filename);
		return NULL;
#endif /* HAVE_MMAP */
    close(fd);

#endif /* HAVE_MMAP && defined HAVE_WINDOWS_H */
    return mm;
}

csr_mmap_t *
csr_mmap_file(const char *filename,unsigned char bLoadMem)
{
    return mmap_file(filename, PROT_READ,bLoadMem);
}

csr_mmap_t *
csr_mmap_file_w(const char *filename)
{
    return mmap_file(filename, PROT_READ | PROT_WRITE,0);
}

void
csr_munmap_file(csr_mmap_t *mm)
{
	if(mm->bLoadMem){
		free(mm->map);
		free(mm);
		return;
	}
#if !defined HAVE_MMAP && defined HAVE_WINDOWS_H
    UnmapViewOfFile(mm->map);
    CloseHandle(mm->hmap);
    CloseHandle(mm->hfile);
#else /* !defined HAVE_MMAP && defined HAVE_WINDOWS_H */
#ifdef HAVE_MMAP
    munmap(mm->map, mm->size);
#else /* HAVE_MMAP */
    free(mm->map);
#endif /* HAVE_MMAP */
#endif /* !defined HAVE_MMAP && defined HAVE_WINDOWS_H */
    free(mm);
}

void *
csr_mmap_map(csr_mmap_t *mm)
{
    return mm->map;
}

csr_offset_t
csr_mmap_size(csr_mmap_t *mm)
{
    return mm->size;
}

#ifdef __cplusplus
}
#endif
