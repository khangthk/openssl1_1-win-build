setlocal

set OPENSSL_VER=1.1.1w
set OPENSSL_VER_SED=1\.1\.1w
set OPENSSL_BASE=openssl-%OPENSSL_VER%
set OPENSSL_BASE_SED=openssl-%OPENSSL_VER_SED%
set OPENSSL_DIR=..\%OPENSSL_BASE%
set OPENSSL_DIR_SED=\.\.\\\\openssl-%OPENSSL_VER_SED%

set ZLIB_DIR=..\zlib

mkdir dll64
mkdir lib64
mkdir dll32
mkdir lib32
mkdir dllarm64
mkdir libarm64
mkdir dllarm32
mkdir libarm32

pushd dll64
perl %OPENSSL_DIR%\Configure --prefix="%ProgramFiles%\OpenSSL-1_1" --with-zlib-include=%ZLIB_DIR% --with-zlib-lib=%ZLIB_DIR%\build\x64\Release\libz-static.lib VC-WIN64A-masm no-dynamic-engine zlib
call :genfile
call :clndir
popd

pushd lib64
perl %OPENSSL_DIR%\Configure --prefix="%ProgramFiles%\OpenSSL-1_1" --with-zlib-include=%ZLIB_DIR% --with-zlib-lib=%ZLIB_DIR%\build\x64\Release\libz-static.lib VC-WIN64A-masm no-shared no-dynamic-engine zlib
call :genfile
call :clndir
popd

pushd dll32
perl %OPENSSL_DIR%\Configure --prefix="%ProgramFiles(x86)%\OpenSSL-1_1" --with-zlib-include=%ZLIB_DIR% --with-zlib-lib=%ZLIB_DIR%\build\Release\libz-static.lib VC-WIN32 no-dynamic-engine zlib
call :genfile
call :clndir
popd

pushd lib32
perl %OPENSSL_DIR%\Configure --prefix="%ProgramFiles(x86)%\OpenSSL-1_1" --with-zlib-include=%ZLIB_DIR% --with-zlib-lib=%ZLIB_DIR%\build\Release\libz-static.lib VC-WIN32 no-shared no-dynamic-engine zlib
call :genfile
call :clndir
popd

pushd dllarm64
perl %OPENSSL_DIR%\Configure --prefix="%ProgramFiles%\OpenSSL-1_1" --with-zlib-include=%ZLIB_DIR% --with-zlib-lib=%ZLIB_DIR%\build\ARM64\Release\libz-static.lib VC-WIN64-ARM no-dynamic-engine zlib
call :genfile
call :clndir
popd

pushd libarm64
perl %OPENSSL_DIR%\Configure --prefix="%ProgramFiles%\OpenSSL-1_1" --with-zlib-include=%ZLIB_DIR% --with-zlib-lib=%ZLIB_DIR%\build\ARM64\Release\libz-static.lib VC-WIN64-ARM no-shared no-dynamic-engine zlib
call :genfile
call :clndir
popd

pushd dllarm32
perl %OPENSSL_DIR%\Configure --prefix="%ProgramFiles%\OpenSSL-1_1" --with-zlib-include=%ZLIB_DIR% --with-zlib-lib=%ZLIB_DIR%\build\ARM\Release\libz-static.lib VC-WIN32-ARM no-dynamic-engine zlib
call :genfile
call :clndir
popd

pushd libarm32
perl %OPENSSL_DIR%\Configure --prefix="%ProgramFiles%\OpenSSL-1_1" --with-zlib-include=%ZLIB_DIR% --with-zlib-lib=%ZLIB_DIR%\build\ARM\Release\libz-static.lib VC-WIN32-ARM no-shared no-dynamic-engine zlib
call :genfile
call :clndir
popd

goto :end

:genfile
perl -I. -Mconfigdata %OPENSSL_DIR%\util\dofile.pl -omakefile %OPENSSL_DIR%\include\crypto\bn_conf.h.in > bn_conf.h
perl -I. -Mconfigdata %OPENSSL_DIR%\util\dofile.pl -omakefile %OPENSSL_DIR%\include\crypto\dso_conf.h.in > dso_conf.h
perl -I. -Mconfigdata %OPENSSL_DIR%\util\dofile.pl -omakefile %OPENSSL_DIR%\include\openssl\opensslconf.h.in > opensslconf.h
perl -I. -Mconfigdata %OPENSSL_DIR%\util\dofile.pl -omakefile %OPENSSL_DIR%\apps\CA.pl.in > apps\CA.pl
perl -I. -Mconfigdata %OPENSSL_DIR%\util\dofile.pl -omakefile %OPENSSL_DIR%\apps\tsget.in > apps\tsget.pl
perl -I. -Mconfigdata %OPENSSL_DIR%\util\dofile.pl -omakefile %OPENSSL_DIR%\tools\c_rehash.in > tools\c_rehash.pl
ren configdata.pm configdata.pm.org
@rem Redirection must be at front for "^^" to work. Strange.
>configdata.pm sed -e "s/%OPENSSL_DIR_SED%/\./g" -e "s/RANLIB => \"CODE(0x[0-9a-f]\+)\"/RANLIB => \"CODE(0xf1e2d3c4)\"/" -e "s/\<\(multilib\)\>/#\1/" -e "s/1_1-arm\(64\)\?\>/1_1/" configdata.pm.org
dos2unix bn_conf.h dso_conf.h opensslconf.h apps\CA.pl apps\tsget.pl tools\c_rehash.pl
exit /b

:clndir
@echo off
call :clndir0
@echo on
exit /b

:clndir0
for /d %%d in ( * ) do (
    pushd %%d
    call :clndir0
    popd
    rmdir %%d 2>nul
)
exit /b

:end
endlocal
