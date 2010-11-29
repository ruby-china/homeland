#ifndef _CSR_TYPEDEFS_H_
#define _CSR_TYPEDEFS_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifndef NULL
#define NULL 0
#endif

typedef char				i1;
typedef unsigned char			u1;
typedef short				i2;
typedef unsigned short			u2;
typedef int				i4;
typedef unsigned int			u4;
typedef long long			i8;
typedef unsigned long long		u8;

typedef u4	csr_offset_t;
/*
#if U8_AVAILABLE
typedef signed long int         s8;
typedef unsigned long int       u8;
#else
typedef struct {u4 low, high;}  u8;
#define s8 u8
#endif
*/

#define CSR_INT8_MIN	-128
#define CSR_INT8_MAX	127
#define CSR_UINT8_MAX	255

#define CSR_INT16_MIN	-32768
#define CSR_INT16_MAX	32767
#define CSR_UINT16_MAX	65535

/*
 * Note that "int" is 32 bits on all currently supported Unix-like operating
 * systems, but "long" can be either 32 bits or 64 bits, thus the 32 bit
 * constants are not qualified with "L".
 */
#define CSR_INT32_MIN	-2147483648
#define CSR_INT32_MAX	2147483647
#define CSR_UINT32_MAX	4294967295U

#define CSR_INT64_MIN	-9223372036854775808LL
#define CSR_INT64_MAX	9223372036854775807LL
#define CSR_UINT64_MAX	18446744073709551615ULL


#ifdef WIN32
#undef  HIBYTE
#undef  LOBYTE
#undef  MAKEWORD
#endif

#ifndef WIN32
typedef unsigned char BYTE;
typedef unsigned short WORD;
#ifndef _WINDEF_
typedef unsigned int DWORD;
#endif
#endif

#ifndef WIN32

#define HIBYTE(W)  (((W) >> 8) & 0xFF)
#define LOBYTE(W)  ((W) & 0xFF)
#define MAKEWORD(low,high) \
        ((WORD)(((BYTE)(low)) | ((WORD)((BYTE)(high))) << 8))

#endif //end win32

#undef HIWORD
#ifndef HIWORD
#define HIWORD(dw) ((dw)>>16)
#endif

#undef LOWORD
#ifndef LOWORD
#define LOWORD(dw) ((dw)&0xffff)
#endif

#undef MAKEDWORD

#ifndef MAKEDWORD
#define MAKEDWORD(hw,lw) (((hw)<<16)|(lw))
#endif

#ifdef __cplusplus
}
#endif		
#endif

