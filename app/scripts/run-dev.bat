@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul

REM ============================================================
REM  Gerenciador Flutter Android/iOS
REM ============================================================
REM
REM  Salve este arquivo em:
REM    nome-do-projeto\scripts\run-dev.bat
REM
REM  Como usar:
REM    scripts\run-dev.bat
REM
REM  Observacao:
REM    - Android roda no Windows com Android Studio/SDK.
REM    - iOS pode ser criado no projeto, mas build/execucao iOS exige macOS/Xcode.
REM
REM ============================================================

title Gerenciador Flutter Android/iOS

REM ============================================================
REM  Caminhos principais
REM ============================================================

set "FLUTTER_DIR=C:\flutter"

REM Este script deve ficar em nome-do-projeto\scripts\
REM Por isso a raiz do projeto e a pasta acima de scripts.
cd /d "%~dp0.."

REM ============================================================
REM  Cores do terminal
REM ============================================================

for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "CYAN=%ESC%[96m"
set "BLUE=%ESC%[94m"
set "RESET=%ESC%[0m"

REM ============================================================
REM  Menu principal
REM ============================================================

:menu
cls
echo %CYAN%============================================================%RESET%
echo %CYAN%  Gerenciador Flutter Android/iOS%RESET%
echo %CYAN%============================================================%RESET%
echo.
echo  Pasta do projeto:
echo  %CD%
echo.
echo  1 - Verificar setup Flutter / Android
echo  2 - Iniciar novo projeto Flutter Android/iOS nesta pasta
echo  3 - Baixar dependencias ^(flutter pub get^)
echo  4 - Listar dispositivos e emuladores
echo  5 - Executar app no Android
echo  6 - Build APK Android ^(release^)
echo  7 - Limpar projeto ^(flutter clean^)
echo  8 - Flutter doctor -v
echo  0 - Sair
echo.
echo %CYAN%============================================================%RESET%
echo.

set "OPCAO="
set /p "OPCAO=Escolha uma opcao: "

if "%OPCAO%"=="1" goto :verificar_setup
if "%OPCAO%"=="2" goto :iniciar_projeto
if "%OPCAO%"=="3" goto :pub_get
if "%OPCAO%"=="4" goto :listar_devices
if "%OPCAO%"=="5" goto :rodar_android
if "%OPCAO%"=="6" goto :build_apk
if "%OPCAO%"=="7" goto :flutter_clean
if "%OPCAO%"=="8" goto :doctor_v
if "%OPCAO%"=="0" goto :fim

echo.
echo %RED%[ERRO]%RESET% Opcao invalida.
pause
goto :menu

REM ============================================================
REM  Funcao: garantir Flutter no PATH
REM ============================================================

:garantir_flutter
where flutter >nul 2>&1

if errorlevel 1 (
    if exist "%FLUTTER_DIR%\bin\flutter.bat" (
        echo %YELLOW%[AVISO]%RESET% Flutter nao estava no PATH.
        echo %GREEN%[OK]%RESET% Flutter encontrado em %FLUTTER_DIR%\bin
        echo %YELLOW%[INFO]%RESET% Adicionando ao PATH desta sessao...
        set "PATH=%FLUTTER_DIR%\bin;%PATH%"
    ) else (
        echo.
        echo %RED%[ERRO]%RESET% Flutter nao encontrado.
        echo.
        echo Verifique se o Flutter esta instalado em:
        echo %FLUTTER_DIR%
        echo.
        echo Ou instale/adiciona ao PATH:
        echo %FLUTTER_DIR%\bin
        echo.
        exit /b 1
    )
)

exit /b 0

REM ============================================================
REM  Funcao: garantir que existe pubspec.yaml
REM ============================================================

:garantir_projeto
if not exist "pubspec.yaml" (
    echo.
    echo %RED%[ERRO]%RESET% pubspec.yaml nao encontrado.
    echo.
    echo Isso indica que esta pasta ainda nao e um projeto Flutter.
    echo Use a opcao 2 para iniciar o projeto nesta pasta.
    echo.
    exit /b 1
)

exit /b 0

REM ============================================================
REM  Funcao: verificar Android SDK Command-line Tools
REM ============================================================

:verificar_android_cmdline_tools
set "SDKMANAGER_FOUND="

where sdkmanager >nul 2>&1
if not errorlevel 1 (
    set "SDKMANAGER_FOUND=1"
)

if exist "%LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" (
    set "SDKMANAGER_FOUND=1"
)

if exist "%LOCALAPPDATA%\Android\Sdk\cmdline-tools\bin\sdkmanager.bat" (
    set "SDKMANAGER_FOUND=1"
)

if defined ANDROID_HOME (
    if exist "%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat" (
        set "SDKMANAGER_FOUND=1"
    )
)

if defined ANDROID_SDK_ROOT (
    if exist "%ANDROID_SDK_ROOT%\cmdline-tools\latest\bin\sdkmanager.bat" (
        set "SDKMANAGER_FOUND=1"
    )
)

if not defined SDKMANAGER_FOUND (
    echo.
    echo %YELLOW%============================================================%RESET%
    echo %YELLOW%  AVISO - Android SDK Command-line Tools nao encontrado%RESET%
    echo %YELLOW%============================================================%RESET%
    echo.
    echo %YELLOW%O Flutter encontrou o Android SDK, mas nao encontrou o sdkmanager.%RESET%
    echo %YELLOW%Para corrigir, faca o seguinte:%RESET%
    echo.
    echo %YELLOW%1. Abra o Android Studio.%RESET%
    echo %YELLOW%2. Va em More Actions ^> SDK Manager.%RESET%
    echo %YELLOW%3. Se abrir um projeto, va em Tools ^> SDK Manager.%RESET%
    echo %YELLOW%4. Na aba SDK Platforms, marque uma API Android recente.%RESET%
    echo.
    echo %YELLOW%5. Na aba SDK Tools, marque:%RESET%
    echo %YELLOW%   - Android SDK Command-line Tools%RESET%
    echo %YELLOW%   - Android SDK Platform-Tools%RESET%
    echo %YELLOW%   - Android SDK Build-Tools%RESET%
    echo %YELLOW%   - Android Emulator%RESET%
    echo.
    echo %YELLOW%6. Clique em Apply e aguarde instalar.%RESET%
    echo.
    echo %YELLOW%Depois feche e abra o terminal novamente.%RESET%
    echo.
    echo %YELLOW%============================================================%RESET%
    echo.
    exit /b 1
)

exit /b 0

REM ============================================================
REM  1 - Verificar setup Flutter / Android
REM ============================================================

:verificar_setup
cls
echo %CYAN%============================================================%RESET%
echo %CYAN%  1 - Verificar setup Flutter / Android%RESET%
echo %CYAN%============================================================%RESET%
echo.

call :garantir_flutter
if errorlevel 1 (
    pause
    goto :menu
)

echo %BLUE%------------------------------------------------------------%RESET%
echo %BLUE% Flutter version%RESET%
echo %BLUE%------------------------------------------------------------%RESET%
echo.
call flutter --version

echo.
echo %BLUE%------------------------------------------------------------%RESET%
echo %BLUE% Flutter doctor%RESET%
echo %BLUE%------------------------------------------------------------%RESET%
echo.
call flutter doctor

echo.
echo %BLUE%------------------------------------------------------------%RESET%
echo %BLUE% Licencas Android%RESET%
echo %BLUE%------------------------------------------------------------%RESET%
echo.

call :verificar_android_cmdline_tools

if errorlevel 1 (
    echo %YELLOW%[AVISO]%RESET% Licencas Android nao foram verificadas porque o sdkmanager nao foi encontrado.
    echo.
) else (
    echo Se aparecer alguma pergunta, digite y para aceitar.
    echo.
    call flutter doctor --android-licenses
)

echo.
echo %BLUE%------------------------------------------------------------%RESET%
echo %BLUE% Dispositivos encontrados%RESET%
echo %BLUE%------------------------------------------------------------%RESET%
echo.
call flutter devices

echo.
pause
goto :menu

REM ============================================================
REM  2 - Iniciar novo projeto Flutter
REM ============================================================

:iniciar_projeto
cls
echo %CYAN%============================================================%RESET%
echo %CYAN%  2 - Iniciar novo projeto Flutter Android/iOS%RESET%
echo %CYAN%============================================================%RESET%
echo.

call :garantir_flutter
if errorlevel 1 (
    pause
    goto :menu
)

if exist "pubspec.yaml" (
    echo %YELLOW%[AVISO]%RESET% Esta pasta ja possui pubspec.yaml.
    echo O projeto Flutter ja parece estar criado.
    echo.
    pause
    goto :menu
)

echo Este comando criara o projeto Flutter nesta pasta:
echo %CD%
echo.
echo Plataformas:
echo - Android
echo - iOS
echo.
echo %YELLOW%Obs:%RESET% iOS precisa de macOS/Xcode para rodar/buildar futuramente.
echo.

set "PROJECT_NAME="
set /p "PROJECT_NAME=Nome interno do projeto [my_app]: "

if "%PROJECT_NAME%"=="" set "PROJECT_NAME=my_app"

echo %PROJECT_NAME%| findstr /r "^[a-z][a-z0-9_]*$" >nul
if errorlevel 1 (
    echo.
    echo %RED%[ERRO]%RESET% Nome invalido.
    echo Use apenas letras minusculas, numeros e underscore.
    echo Exemplo: my_app
    echo.
    pause
    goto :menu
)

echo.
set "CONFIRMA="
set /p "CONFIRMA=Confirma criar o projeto '%PROJECT_NAME%' aqui? (S/N): "

if /I not "%CONFIRMA%"=="S" (
    echo.
    echo Cancelado.
    pause
    goto :menu
)

echo.
echo %BLUE%------------------------------------------------------------%RESET%
echo %BLUE% Criando projeto Flutter%RESET%
echo %BLUE%------------------------------------------------------------%RESET%
echo.

call flutter create --platforms=android,ios --project-name %PROJECT_NAME% .

if errorlevel 1 (
    echo.
    echo %RED%[ERRO]%RESET% Falha ao criar o projeto.
    echo Veja a mensagem acima.
    echo.
    pause
    goto :menu
)

echo.
echo %GREEN%[OK]%RESET% Projeto criado com sucesso.
echo.

call flutter pub get

echo.
pause
goto :menu

REM ============================================================
REM  3 - flutter pub get
REM ============================================================

:pub_get
cls
echo %CYAN%============================================================%RESET%
echo %CYAN%  3 - Baixar dependencias%RESET%
echo %CYAN%============================================================%RESET%
echo.

call :garantir_flutter
if errorlevel 1 (
    pause
    goto :menu
)

call :garantir_projeto
if errorlevel 1 (
    pause
    goto :menu
)

call flutter pub get

if errorlevel 1 (
    echo.
    echo %RED%[ERRO]%RESET% Falha ao executar flutter pub get.
) else (
    echo.
    echo %GREEN%[OK]%RESET% Dependencias atualizadas.
)

echo.
pause
goto :menu

REM ============================================================
REM  4 - Listar dispositivos e emuladores
REM ============================================================

:listar_devices
cls
echo %CYAN%============================================================%RESET%
echo %CYAN%  4 - Listar dispositivos e emuladores%RESET%
echo %CYAN%============================================================%RESET%
echo.

call :garantir_flutter
if errorlevel 1 (
    pause
    goto :menu
)

echo %BLUE%------------------------------------------------------------%RESET%
echo %BLUE% Dispositivos%RESET%
echo %BLUE%------------------------------------------------------------%RESET%
echo.
call flutter devices

echo.
echo %BLUE%------------------------------------------------------------%RESET%
echo %BLUE% Emuladores%RESET%
echo %BLUE%------------------------------------------------------------%RESET%
echo.
call flutter emulators

echo.
pause
goto :menu

REM ============================================================
REM  5 - Executar app no Android
REM ============================================================

:rodar_android
cls
echo %CYAN%============================================================%RESET%
echo %CYAN%  5 - Executar app no Android%RESET%
echo %CYAN%============================================================%RESET%
echo.

call :garantir_flutter
if errorlevel 1 (
    pause
    goto :menu
)

call :garantir_projeto
if errorlevel 1 (
    pause
    goto :menu
)

echo %BLUE%------------------------------------------------------------%RESET%
echo %BLUE% Dispositivos encontrados%RESET%
echo %BLUE%------------------------------------------------------------%RESET%
echo.
call flutter devices

echo.
echo Dica:
echo - Abra o emulador Android antes de executar.
echo - Ou conecte um celular com Depuracao USB ativada.
echo.
set "DEVICE_ID="
set /p "DEVICE_ID=Device ID especifico ou ENTER para automatico: "

echo.
call flutter pub get

echo.
if "%DEVICE_ID%"=="" (
    call flutter run
) else (
    call flutter run -d "%DEVICE_ID%"
)

if errorlevel 1 (
    echo.
    echo %RED%[ERRO]%RESET% Nao foi possivel executar o app.
    echo.
    echo Verifique:
    echo - Android Studio instalado
    echo - Android SDK configurado
    echo - Emulador aberto
    echo - Celular com Depuracao USB ativada
    echo.
)

echo.
pause
goto :menu

REM ============================================================
REM  6 - Build APK Android
REM ============================================================

:build_apk
cls
echo %CYAN%============================================================%RESET%
echo %CYAN%  6 - Build APK Android ^(release^)%RESET%
echo %CYAN%============================================================%RESET%
echo.

call :garantir_flutter
if errorlevel 1 (
    pause
    goto :menu
)

call :garantir_projeto
if errorlevel 1 (
    pause
    goto :menu
)

set "CONFIRMA="
set /p "CONFIRMA=Deseja gerar APK release? (S/N): "

if /I not "%CONFIRMA%"=="S" (
    echo.
    echo Cancelado.
    pause
    goto :menu
)

echo.
call flutter build apk --release

if errorlevel 1 (
    echo.
    echo %RED%[ERRO]%RESET% Falha ao gerar APK.
) else (
    echo.
    echo %GREEN%[OK]%RESET% APK gerado com sucesso.
    echo Local:
    echo build\app\outputs\flutter-apk\app-release.apk
)

echo.
pause
goto :menu

REM ============================================================
REM  7 - Flutter clean
REM ============================================================

:flutter_clean
cls
echo %CYAN%============================================================%RESET%
echo %CYAN%  7 - Limpar projeto%RESET%
echo %CYAN%============================================================%RESET%
echo.

call :garantir_flutter
if errorlevel 1 (
    pause
    goto :menu
)

call :garantir_projeto
if errorlevel 1 (
    pause
    goto :menu
)

call flutter clean

if errorlevel 1 (
    echo.
    echo %RED%[ERRO]%RESET% Falha ao limpar o projeto.
) else (
    echo.
    echo %GREEN%[OK]%RESET% Projeto limpo.
    echo.
    echo Rodando flutter pub get novamente...
    call flutter pub get
)

echo.
pause
goto :menu

REM ============================================================
REM  8 - Flutter doctor -v
REM ============================================================

:doctor_v
cls
echo %CYAN%============================================================%RESET%
echo %CYAN%  8 - Flutter doctor -v%RESET%
echo %CYAN%============================================================%RESET%
echo.

call :garantir_flutter
if errorlevel 1 (
    pause
    goto :menu
)

call flutter doctor -v

echo.
pause
goto :menu

REM ============================================================
REM  0 - Sair
REM ============================================================

:fim
endlocal
exit /b 0