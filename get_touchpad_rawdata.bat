@echo off

echo ---------------------------------------------
echo 触屏 rawdata 获取
echo 请确保屏幕处于亮起状态
echo 请不要触摸屏幕
echo ---------------------------------------------

set count=0

:loop

adb wait-for-device
timeout /t 2
adb root
adb wait-for-device
timeout /t 2

set s_no=
set judge=
set tp_info=
set path=

for /f "tokens=1,4 delims=<>" %%s in ('adb shell getprop ro.serialno') do ( 
	set s_no=%%s 
)

for /f "tokens=1,4 delims=<>" %%s in ('adb shell cat /proc/tp_info') do ( 
	set tp_info=%%s 
)

echo 第(%count%)个设备,串号:%s_no%
echo TP信息:

rem 获取模组厂信息
echo %tp_info%>info.txt
findstr "Xinli" info.txt
if %errorlevel% equ 0 set path=Xinli

findstr "helitai" info.txt
if %errorlevel% equ 0 set path=TXD

findstr "txd" info.txt
if %errorlevel% equ 0 set path=TXD

rem 获取IC信息
findstr "9911" info.txt
if %errorlevel% equ 0 set path=%path%_icnl991c

findstr "7202" info.txt
if %errorlevel% equ 0 set path=%path%_gc7202

findstr "36525" info.txt
if %errorlevel% equ 0 set path=%path%_nt36525b

findstr "9882" info.txt
if %errorlevel% equ 0 set path=%path%_ili9882q

del info.txt

echo 保存路径:%path%
set path=%path%_%count%_csv_file_%s_no%

adb shell "cat /proc/ts*_selftest"
adb pull /data/vendor/touchpad rawdata/%path%
if %errorlevel% equ 0 (
	echo Rawdata已保存至: rawdata/%path%
	adb shell "rm -rf /data/vendor/touchpad/*"
) else (
	echo Rawdata获取失败
)

echo ---------------------------------------------
echo 更换设备后按"C" 采集下一个设备
echo (若要重新采集请勿更换设备直接按"C")
echo 按其他键退出
echo ---------------------------------------------

set /a count=%count%+1
set /p judge=

if %judge% equ C (
	goto loop
) else if %judge% equ c (
	goto loop
) else (
	goto quit
)

:quit
pause
