@echo off

call commit "***Manual Release process started - commiting any unsubmitted changes first"
echo "returned"

del C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\WC\Release.ver
svnversion C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\WC > C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\WC\Release.ver
commit "***Manual release performed - no archive generated"
exit /B

