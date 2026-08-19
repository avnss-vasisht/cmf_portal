**How To Run The Project**



* Extract the zip file to a local folder.



* Open the extracted folder in Visual Studio Code. Make sure that IIS express is installed in the system.



* Open a PowerShell terminal in the project folder.



* Start IIS Express:

\& "C:\\Program Files\\IIS Express\\iisexpress.exe" /**path:"C:\\Path\\To\\CMF\_Portal\_Demo**" /port:8080



Replace **"C:\\Path\\To\\CMF\_Portal\_Demo"** with the actual extracted folder path.



* Open the portal in a browser:

http://localhost:8080/CMF\_Web\_portal.aspx



* If port **8080** is already in use, run with another port:



\& "C:\\Program Files\\IIS Express\\iisexpress.exe" /**path:"C:\\Path\\To\\CMF\_Portal\_Demo"** /port:8081



Then open:



http://localhost:8081/CMF\_Web\_portal.aspx

