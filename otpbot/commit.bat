@echo off
IF [%1] == [] GOTO noinput

:yesinput
echo yesinput
cd wc
svn commit -m %1
git commit -am %1
cd ..
goto endxx


:noinput
echo noinput
cd wc
svn commit -m ""
git commit -am ""
cd ..
goto end




:endxx
exit /B

