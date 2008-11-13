NppToR README
(c) 2008 Andrew Redd
http://www.stat.tamu.edu/~aredd

Thank you for downloading ScripToR, my utility for passing code into R from notepad++.
The package consists of three parts.
	1.	Notepad++ Syntax Highlighting and code folding
	2. 	Auto Completion
	3.	Code passing via a hotkey utility
	
See Install.txt for installation instructions.

Upon running the utility,it sets keyboard shortcuts to pass code into R.  These are the defaults:
	F8: Run line or Selection
	Ctrl+F8: Run entire file.
	Ctrl+Alt+F8: Run entire file in R CMD BATCH + open in Notepad++

the defaults can be changed in the npptor.ini file.  Please read iniparameters for reference on changing these settings.	
To close the utility down right click the system tray icon and select exit.
This version runs only for the Rgui running in single document interface (SDI).

Note:
This requires R to be installed to start R.  It can be used with a portable version of R if R is already started.
Some feature will not work for portable versions of R or Notepad++.