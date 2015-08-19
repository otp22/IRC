@echo off
IF [%1] == [] GOTO noinput

:yesinput
echo yesinput
cd wc
REM svn commit -m %1
"C:\Program Files (x86)\Git\bin\git.exe" commit -am %1
"C:\Program Files (x86)\Git\bin\git.exe" push
cd ..
goto endxx


:noinput
echo noinput
cd wc
REM svn commit -m ""
"C:\Program Files (x86)\Git\bin\git.exe" commit -am ""
"C:\Program Files (x86)\Git\bin\git.exe" push
cd ..
goto end




:endxx
exit /B

