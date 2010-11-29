require 'mkmf'

#mmseg_config = with_config('mmseg-config', 'mmseg-config')
#use_mmseg_config = enable_config('mmseg-config')
#have_library("mmseg")
#have_header('SegmenterManager.h')
dir_config('mmseg')
$libs = append_library($libs, "libcss")
create_makefile("mmseg")
