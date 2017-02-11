@echo off

call commit "***Manual Release process started - commiting any unsubmitted changes first"
echo "returned"

GetNextVersion .\WC\Release.ver

commit "***Manual release performed"
exit /B

