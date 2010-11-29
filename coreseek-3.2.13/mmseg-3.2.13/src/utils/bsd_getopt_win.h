/* bsd_getopt.h
 *
 * Chris Collins <chris@collins.id.au>
 */

/** header created for NetBSD getopt/getopt_long */

#ifndef HAVE_GETOPT_LONG
#ifndef _BSD_GETOPT_H
#define _BSD_GETOPT_H

#ifdef __cplusplus
extern "C" {
#endif

extern int    opterr;
extern int    optind;
extern int    optopt;
extern int    optreset;
extern char  *optarg;

struct option {
    char  *name;
    int    has_arg;
    int   *flag;
    int    val;
};

#define no_argument        0
#define required_argument  1
#define optional_argument  2

extern int getopt(int nargc, char * const *nargv, const char *options);
extern int getopt_long(int nargc, char * const *nargv, const char *options, const struct option *long_options, int *idx);

#ifdef __cplusplus
}
#endif

#endif /* _BSD_GETOPT_H */
#endif
