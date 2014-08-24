@echo off
IF [%1] == [] GOTO noinput

:yesinput
echo yesinput
cd wc
svn commit -m %1
git commit -am %1
git push
cd ..
goto endxx


:noinput
echo noinput
cd wc
svn commit -m ""
git commit -am ""
git push
cd ..
goto end




:endxx
exit /B

