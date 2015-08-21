@echo off

call commit "***Manual Release process started - commiting any unsubmitted changes first"
echo "returned"

GetNextVersion C:\Users\Crash\Desktop\otp22\code\IRC\otpbot\WC\Release.ver

commit "***Manual release performed"
exit /B

