#  NppToR: R in Notepad++
#  by Andrew Redd 2008 <halpo@users.sourceforge.net>
#  use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
#
#  GenerateSntaxFiles.rb is a part of NppToR.  This file reads the R library and fills in syntax words for
#


#Dir.chdir("C:/Users/Andrew/Documents/Projects/npptor.sf.net/syntax")

require 'rexml/document'
require 'win32/registry'


rbase = REXML::Document.new(File.open("R_UDL_Base.xml"))
UDL = REXML::Document.new(File.open("#{ENV['APPDATA']}/Notepad++/userDefineLang.xml"))

PkgPriority = { 
"base"       =>	"base"       ,
"boot"       =>	"recommended",
"class"      =>	"recommended",
"cluster"    =>	"recommended",
"codetools"  =>	"recommended",
"datasets"   =>	"base"       ,
"foreign"    =>	"recommended",
"graphics"   =>	"base"       ,
"grDevices"  =>	"base"       ,
"grid"       =>	"base"       ,
"KernSmooth" =>	"recommended",
"lattice"    =>	"recommended",
"MASS"       =>	"recommended",
"methods"    =>	"base"       ,
"mgcv"       =>	"recommended",
"nlme"       =>	"recommended",
"nnet"       =>	"recommended",
"rpart"      =>	"recommended",
"spatial"    =>	"recommended",
"splines"    =>	"base"       ,
"stats"      =>	"base"       ,
"stats4"     =>	"base"       ,
"survival"   =>	"recommended",
"tcltk"      =>	"base"       ,
"tools"      =>	"base"       ,
"utils"      =>	"base"       
}
PkgPriority.default = 'other'

#operators = {'+', '-', '*', '/', '%%', '^', '&lt;', '&lt;=', '&gt;', '&gt;=', '==', '!=!', '&amp;', '|', '~', '-&lt;', '&gt;-', '$', '@', ':', '[', ']'}

Words={
'base' => Array.new(),
'recommended' => Array.new(),
'other' => Array.new()
}


if ARGV[0] then Rlibpath = ARGV[0]
else
	Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\R-core\R') do |reg|
		reg_type, reg_val = reg.read('InstallPath')
		Rlibpath = reg_val.concat('\\library')
	end
end
if File.directory?(Rlibpath) 
then
	if File.readable?(Rlibpath)
	then 
		Rlib=Dir.new(Rlibpath)
	else raise "R library not readable"
	end
else raise "R library not found"
end
puts "using R library: #{Rlib.path}"
Rlib.each{
	|foldername| 
	if (File.directory?(Rlib.path.concat("\\").concat(foldername)) && File.exists?(Rlib.path.concat("\\").concat(foldername).concat('\\INDEX'))) then
		puts "Processing #{foldername}"
		priority = PkgPriority[foldername]
		File.open(Rlib.path.concat("\\").concat(foldername).concat('\\INDEX'),'r') do |file|
		  while line = file.gets
			key = line.slice(/^[A-Za-z0-9\._]+\s/)
			if !key.nil? then 
				key.strip!
				Words[priority] << key
			end
		  end
		end
	end
}

rlang = rbase.elements["//UserLang[@name='R']"]
rlang.elements["//Keywords[@name='Words2']"].text = Words['base'].uniq.join(" ")
rlang.elements["//Keywords[@name='Words3']"].text = Words['recommended'].uniq.join(" ")
rlang.elements["//Keywords[@name='Words4']"].text = Words['other'].uniq.join(" ")

if !UDL.elements["//UserLang[@name='R']"].nil? then
	UDL.elements["//UserLang[@name='R']"]=rlang
else
	UDL.root.add_element(rlang)
end

newUDL = File.open("#{ENV['APPDATA']}/Notepad++/userDefineLang.xml","w")
UDL.write(newUDL)
newUDL.close
