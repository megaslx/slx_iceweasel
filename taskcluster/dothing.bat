@echo off&setlocal enabledelayedexpansion

if not defined SOURCE_DIR set SOURCE_DIR="%1"
if not exist "!SOURCE_DIR!" mkdir "!SOURCE_DIR!"&echo SOURCE_DIR: !SOURCE_DIR!
if not defined BUID_DIR set BUID_DIR=d:\works
if not exist "!BUID_DIR!" mkdir "!BUID_DIR!"&echo BUID_DIR: !BUID_DIR!

if not defined MY_BITS @echo mozconfig32 or mozconfig64 not exist.&EXIT /B 4
if not defined LIBPORTABLE_PATH @echo Build libportable need this path.&EXIT /B 4

@cd /d "!SOURCE_DIR!"
@git clone --depth=1 https://github.com/yxl0756/mozillabuild.git mozillabuild-src
@cd /d "!SOURCE_DIR!\mozillabuild-src"
@if exist bin.7z 7z x bin.7z -aoa -o!BUID_DIR!
@if exist clang-msvc-9.0.1.7z 7z x clang-msvc-9.0.1.7z -aoa -o!BUID_DIR!
@if exist msys-1.0.7z 7z x msys-1.0.7z -aoa -o!BUID_DIR!
@if exist nodejs.7z 7z x nodejs.7z -aoa -o!BUID_DIR!
@if exist nsis301.7z 7z x nsis301.7z -aoa -o!BUID_DIR!
@if exist kdiff3.7z 7z x kdiff3.7z -aoa -o!BUID_DIR!
@if exist hg.7z 7z x hg.7z -aoa -o!BUID_DIR!
@if exist rust-1.43.1.7z 7z x rust-1.43.1.7z -aoa -o!BUID_DIR!
@if exist rust-tools.7z 7z x rust-tools.7z -aoa -o!BUID_DIR!
@if exist python-2.7.18.7z 7z x python-2.7.18.7z -aoa -o!BUID_DIR!
@if exist python-3.7.7.7z 7z x python-3.7.7.7z -aoa -o!BUID_DIR!
@if exist msysdo.7z 7z x msysdo.7z -aoa -o!BUID_DIR!

@if not exist "!BUID_DIR!\mozillabuild\clang" @echo clang not exist&EXIT /B 4
@if not exist "!BUID_DIR!\mozillabuild\msys" @echo msys not exist&EXIT /B 4
@if not exist "!BUID_DIR!\mozillabuild\nodejs" @echo nodejs not exist&EXIT /B 4
@if not exist "!BUID_DIR!\mozillabuild\hg" @echo hg not exist&EXIT /B 4
@if not exist "!BUID_DIR!\mozillabuild\rust" @echo rust not exist&EXIT /B 4
@if not exist "!BUID_DIR!\mozillabuild\python" @echo python not exist&EXIT /B 4
@if not exist "!BUID_DIR!\mozillabuild\python3" @echo python3 not exist&EXIT /B 4
@if not exist "!BUID_DIR!\mozillabuild\msysdo.exe" @echo msysdo not exist&EXIT /B 4

@if "%MY_BITS%" == "win32" call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars32"
@if "%MY_BITS%" == "win64" call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64"

@echo ##########################
@set PATH=!BUID_DIR!\mozillabuild\bin;!BUID_DIR!\mozillabuild\clang\bin;%PATH%
@echo PATH: [%PATH%]
@echo ##########################

@echo ##########################
@echo List toolchain
cd /d "%BUID_DIR%\mozillabuild"
dir /a
@echo ##########################

@cd /d "!SOURCE_DIR!"
@git clone --depth=1 https://github.com/adonais/libportable.git libportable-src
@echo libportable-src:
@cd /d "!SOURCE_DIR!\libportable-src"
nmake -f Makefile.msvc CC=clang-cl clean
nmake -f Makefile.msvc CC=clang-cl install
@if not "%errorlevel%" == "0" @echo compile libportable failed.&EXIT /B %errorlevel%

@cd /d "!SOURCE_DIR!"
@git clone --depth=1 https://github.com/adonais/upcheck.git upcheck-src
@cd /d "!SOURCE_DIR!\upcheck-src"
nmake clean
nmake
@if not "%errorlevel%" == "0" @echo compile upcheck failed.EXIT /B %errorlevel%
@if exist "%LIBPORTABLE_PATH%" copy /y "Release\upcheck*.exe" "!LIBPORTABLE_PATH!\bin"

@echo ##########################
@cd /d %GITHUB_WORKSPACE%
@rd /s/q "!SOURCE_DIR!"
@echo GITHUB_WORKSPACE: [%GITHUB_WORKSPACE%]
@dir %GITHUB_WORKSPACE% /a
@echo ##########################
