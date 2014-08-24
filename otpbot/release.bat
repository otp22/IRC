@echo off

call commit "***Automatic Release process started - commiting any unsubmitted changes first"

rd /S /Q C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release
svn checkout http://otpbot.googlecode.com/svn/trunk/ C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release
del C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.zip
del C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.txt
del C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.ver
del C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\WC\Release.ver
svnversion C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release > C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.ver
svnversion C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release > C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\WC\Release.ver
rd /S /Q C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\.svn


:releasetxt
DATE /T > C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.txt
echo This release archive was automatically generated. >> C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.txt
::echo This folder is a Subversion (SVN) Read-Only working-copy; >> C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.txt
::echo This means you can update the files using the SVN UPDATE command if you desire. >> C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.txt
echo ------------------------ >> C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.txt
svn info C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release >> C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.txt
svn status C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release >> C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.txt


del C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.zip
if exist C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release\Release.zip goto errorxd1
7za a -tzip C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\WC\Release.zip C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\Release

svn add C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\WC\Release.zip
commit "***Auto-Generated Release Archive"

exit /B


:errorxd1
echo ERROR: Release.zip not deleted from clean Release folder.
exit /B

