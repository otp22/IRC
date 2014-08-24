@echo off
IF [%1] == [] GOTO noinput

:yesinput
echo yesinput
cd wc
svn commit -m %1
cd ..
goto endxx


:noinput
echo noinput
cd wc
svn commit -m ""
cd ..
goto end




:endxx
exit /B

