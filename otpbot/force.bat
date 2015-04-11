@echo off

call commit "***Manual Release process started - commiting any unsubmitted changes first"
echo "returned"

REM del C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\WC\Release.ver
GetNextVersion C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\WC\Release.ver > C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\WC\Release.ver
commit "***Manual release performed - no archive generated"
exit /B

