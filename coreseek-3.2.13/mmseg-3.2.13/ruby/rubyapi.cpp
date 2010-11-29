#include <fstream>
#include <string>
#include <iostream>
#include <cstdio>

#include <ctype.h>
#include <ruby.h>

/* Ruby 1.7 defines NUM2LL(), LL2NUM() and ULL2NUM() macros */
#ifndef NUM2LL
#define NUM2LL(x) NUM2LONG((x))
#endif
#ifndef LL2NUM
#define LL2NUM(x) INT2NUM((long) (x))
#endif
#ifndef ULL2NUM
#define ULL2NUM(x) UINT2NUM((unsigned long) (x))
#endif

/* Ruby 1.7 doesn't (yet) define NUM2ULL() */
#ifndef NUM2ULL
#ifdef HAVE_LONG_LONG
#define NUM2ULL(x) rb_num2ull((x))
#else
#define NUM2ULL(x) NUM2ULONG(x)
#endif
#endif

/* RSTRING_LEN, etc are new in Ruby 1.9, but ->ptr and ->len no longer work */
/* Define these for older versions so we can just write code the new way */
#ifndef RSTRING_LEN
# define RSTRING_LEN(x) RSTRING(x)->len
#endif
#ifndef RSTRING_PTR
# define RSTRING_PTR(x) RSTRING(x)->ptr
#endif
#ifndef RARRAY_LEN
# define RARRAY_LEN(x) RARRAY(x)->len
#endif
#ifndef RARRAY_PTR
# define RARRAY_PTR(x) RARRAY(x)->ptr
#endif

#include <stdio.h>
#include <stdexcept>

/* calling conventions for Windows */
#ifndef SWIGSTDCALL
# if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#   define SWIGSTDCALL __stdcall
# else
#   define SWIGSTDCALL
# endif
#endif

#include "SegmenterManager.h"
#include "Segmenter.h"

#ifdef __cplusplus
extern "C" {
#endif

//fixme, unload when so unload?
css::SegmenterManager g_mgr;
int g_bInited = 0;

static void
mmseg_dfree
    (void *cd)
{
	//printf("needs to clean up");
}

#define MMSEG_FREE mmseg_dfree

static VALUE
mmseg_free
	(VALUE cd)
{
	//do free here.
    return Qnil;
}

static VALUE
check_mmseg
    (VALUE obj)
{
    Check_Type(obj, T_DATA);
    if (RDATA(obj)->dfree != MMSEG_FREE) {
		rb_raise(rb_eArgError, "mmseg expected (%s)", rb_class2name(CLASS_OF(obj)));
    }
    return (VALUE)DATA_PTR(obj);
}
static VALUE
mmseg_s_allocate
    (VALUE klass)
{
    return Data_Wrap_Struct(klass, 0, MMSEG_FREE, 0);
}

static VALUE
mmseg_initialize(VALUE self){
	mmseg_free(check_mmseg(self));
    DATA_PTR(self) = NULL;
	rb_iv_set(self, "@start", INT2NUM(0));
	rb_iv_set(self, "@end", INT2NUM(0));
	return self;
}

static VALUE mmseg_next(VALUE self)
{
  u2 tok_len = 0;
  int nPos = 0;
  css::Segmenter* seg = NULL;
  Data_Get_Struct(self, css::Segmenter, seg);
  //printf("%d",seg); //check is got it
  if(seg){
	u2 len = 0, symlen = 0;
	char* tok = (char*)seg->peekToken(len,symlen);
	//printf("%s\t",tok);
	//FIXME: if ruby version do not enbale symlen, the len and symlen always the same.
	if(!tok || !*tok || !len)
		tok_len = 0;
	else
		tok_len = len;
	seg->popToken(len);
  }
  //update position info
  VALUE vPos = rb_iv_get(self, "@end");
  if(!NIL_P(vPos)){
	nPos = FIX2INT(vPos);
  }
  rb_iv_set(self, "@start", INT2NUM(nPos));
  rb_iv_set(self, "@end", INT2NUM(nPos+tok_len));
  if(tok_len)
	return self;
  else
	return Qnil;
}

static VALUE mmseg_start(VALUE self) {  
    return rb_iv_get(self, "@start");
}

static VALUE mmseg_end(VALUE self) {  
    return rb_iv_get(self, "@end");
}


static VALUE
mmseg_settext
(VALUE self, VALUE str)
{
	int len;
	const char* pstr;
	if (TYPE(str) == T_STRING) {
		len = RSTRING_LEN(str);
		pstr = STR2CSTR(str);
		//printf("%d:%s\n",len,pstr);
	}else
		return Qnil;
	
	css::Segmenter* seg = NULL;
	Data_Get_Struct(self, css::Segmenter, seg);
	//printf("%s",pstr);
	seg->setBuffer((u1*)pstr,len);
	rb_iv_set(self, "@start", INT2NUM(0));
	rb_iv_set(self, "@end", INT2NUM(0));
	return self;
}


static VALUE
mmseg_open
	(VALUE self, VALUE dict_path, VALUE str)
{
  int len;
  const char* pstr;
  if (TYPE(str) == T_STRING) {
	len = RSTRING_LEN(str);
	pstr = STR2CSTR(str);
	//printf("%d:%s\n",len,pstr);
  }else
	return Qnil;
  
  if (!g_bInited && TYPE(dict_path) == T_STRING) {
	int nRet = g_mgr.init(STR2CSTR(dict_path));
	if(nRet != 0) {
		// should throw an exception
		rb_fatal("Can NOT init the segment library.");
		return Qnil;
	}
	g_bInited = 1;
  }
  if(g_bInited){
	//do segment
	css::Segmenter* seg = g_mgr.getSegmenter();
	//hacking
	long ptr = (long)seg;
	seg->setBuffer((u1*)pstr,len);
	self = Data_Wrap_Struct(self, NULL, MMSEG_FREE, (void *)seg);
  }else
	return Qnil;
	
  return self;
}
	
VALUE cMMseg;

void Init_mmseg() {
  cMMseg = rb_define_class("Mmseg", rb_cData);
  rb_define_alloc_func(cMMseg, mmseg_s_allocate);
  rb_define_singleton_method(cMMseg, "createSeg", RUBY_METHOD_FUNC(mmseg_open), 2);
  rb_define_method(cMMseg, "initialize", RUBY_METHOD_FUNC(mmseg_initialize), 0);
  rb_define_method(cMMseg, "setText", RUBY_METHOD_FUNC(mmseg_settext), 1);
  rb_define_method(cMMseg, "next", RUBY_METHOD_FUNC(mmseg_next), 0);
  rb_define_method(cMMseg, "start", RUBY_METHOD_FUNC(mmseg_start), 0);
  rb_define_method(cMMseg, "end", RUBY_METHOD_FUNC(mmseg_end), 0);
}

#ifdef __cplusplus
}
#endif