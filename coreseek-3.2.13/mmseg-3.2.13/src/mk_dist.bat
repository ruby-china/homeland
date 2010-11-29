md include
copy *.h include\
copy css\*.h include\
copy utils\*.h include\
md lib
md lib\debug
md lib\release
copy win32\release\*.lib lib\release\
copy win32\debug\*.lib lib\debug\
copy win32\release\*.lib lib\
