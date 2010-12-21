cat("\nThis is a session spawned by NppToR.\n\n")
if(file.exists(".Rprofile"))source(".Rprofile")  else 
if(file.exists(path.expand("~/Rprofile"))) source(path.expand("~/Rprofile"))
if(file.exists(path.expand("~/.Rprofile"))) source(path.expand("~/.Rprofile"))
if(file.exists(path.expand("~/Rprofile.R"))) source(path.expand("~/Rprofile.R"))
options(editor="C:\\Program Files (x86)\\NppToR\\NppEditR.exe")

