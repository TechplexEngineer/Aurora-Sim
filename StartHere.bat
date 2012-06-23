@ECHO OFF

echo ========================================================
echo ===================== OpenPlexSim ======================
echo ========================================================
echo.

rem ## Default Visual Studio choice (2008, 2010)
set vstudio=2010
set dev_vstudio=%vstudio%

rem ## Default .NET Framework (3_5, 4_0 (Unsupported on VS2008))
set framework=3_5
set def_framework=%framework%

rem ## Default architecture (86 (for 32bit), 64, AnyCPU)
set bits=AnyCPU
set def_bits=%bits%

rem ## Default "configuration" choice ((r)elease, (d)ebug)
set configuration=r
set def_configuration=%configuration%

rem ## Default "run compile batch" choice (y(es),n(o))
set compile_at_end=y
set def_compile_at_end=%compile_at_end%

echo I will now ask you three questions regarding your build:
echo.

:vstudio
set /p vstudio="Choose your Visual Studio version (2008, 2010) [%vstudio%]: "
if %vstudio%==2008 goto framework
if %vstudio%==2010 goto framework
echo "%vstudio%" isn't a valid choice!
set vstudio=%dev_vstudio%
goto vstudio

:framework
set /p framework="Choose your .NET framework (3_5, 4_0 (Unsupported on VS2008)) [%framework%]: "
if %framework%==3_5 goto bits
if %framework%==4_0 goto frameworkcheck
echo "%framework%" isn't a valid choice!
set framework=%def_framework%
goto framework

    :frameworkcheck
    if %vstudio%==2008 goto frameworkerror
    goto bits

    :frameworkerror
    echo Sorry! Visual Studio 2008 only supports 3_5.
    goto framework

:bits
set /p bits="Choose your architecture (AnyCPU, x86, x64) [%bits%]: "
if %bits%==86 goto configuration
if %bits%==x86 goto configuration
if %bits%==64 goto configuration
if %bits%==x64 goto configuration
if %bits%==AnyCPU goto configuration
echo "%bits%" isn't a valid choice!
set bits=%def_bits%
goto bits

:configuration
set /p configuration="Choose your configuration ((r)elease or (d)ebug)? [%configuration%]: "
if %configuration%==r goto final
if %configuration%==d goto final
if %configuration%==release goto final
if %configuration%==debug goto final
echo "%configuration%" isn't a valid choice!
set configuration=%def_configuration%
goto configuration

:final
echo.
echo.

if exist Compile.*.bat (
    echo Deleting previous compile batch file...
    echo.
    del Compile.*.bat
)

echo Calling Prebuild for target %vstudio% with framework %framework%...
bin\Prebuild.exe /target vs%vstudio% /targetframework v%framework%

echo.
echo Creating compile batch file for your convinence...
if %framework%==3_5 set fpath=C:\WINDOWS\Microsoft.NET\Framework\v3.5\msbuild
if %framework%==4_0 set fpath=C:\WINDOWS\Microsoft.NET\Framework\v4.0.30319\msbuild
if %bits%==x64 set args=/p:Platform=x64
if %bits%==x86 set args=/p:Platform=x86
if %configuration%==r  (
    set cfg=/p:Configuration=Release
    set configuration=release
)
if %configuration%==d  (
set cfg=/p:Configuration=Debug
set configuration=debug
)
if %configuration%==release set cfg=/p:Configuration=Release
if %configuration%==debug set cfg=/p:Configuration=Debug
set filename=Compile.VS%vstudio%.net%framework%.%bits%.%configuration%.bat

echo %fpath% OpenPlex.sln %args% %cfg% > %filename% /p:DefineConstants=ISWIN

echo.
set /p compile_at_end="Done, %filename% created. Compile now? (y,n) [%def_compile_at_end%]"
if %compile_at_end%==y (
    %filename%
    pause
)



