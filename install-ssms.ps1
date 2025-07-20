Invoke-WebRequest -Uri "https://aka.ms/ssmsfullsetup" -OutFile "SSMS-Setup.exe"
Start-Process ".\SSMS-Setup.exe" -ArgumentList "/install", "/quiet", "/norestart" -Wait
