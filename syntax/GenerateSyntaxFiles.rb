#  NppToR: R in Notepad++
#  by Andrew Redd 2008 <halpo@users.sourceforge.net>
#  use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
#
#  GenerateSntaxFiles.rb is a part of NppToR.  This file reads the R library and fills in syntax words for
#


#Dir.chdir("C:/Documents and Settings/AREDD/My Documents/Projects/npptor.sf.net/syntax")  #for development

require 'rexml/document'
require 'win32/registry'
load "GenericFilter.rb"


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

words={
'base' => Array.new(),
'recommended' => Array.new(),
'other' => Array.new()
}
libraries={
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
	if (File.directory?(Rlib.path.concat("\\").concat(foldername)) && File.exists?(Rlib.path.concat("\\").concat(foldername).concat('\\CONTENTS'))) then
		puts "Processing #{foldername}"
		priority = PkgPriority[foldername]
		libraries[priority] << foldername
		lines = IO.readlines(Rlib.path.concat("\\").concat(foldername).concat('\\CONTENTS'))
		aliases = lines.grep(/^Aliases/)
		aliases.each{ |line|
			lwords = line.split
			lwords.delete_at(0)
			words[priority] << lwords.grep(/^[A-Za-z]+[A-Za-z\._]*[A-Za-z0-9\._]*$/)
			words[priority].flatten!
		}
	end
}

BuiltInWords = %w{if else for while repeat break next in TRUE FALSE NULL Inf NaN NA NA_integer_ NA_real_ NA_complex_ NA_character_ ... ..1 ..2 ..3 ..4 ..5 ..6 ..7 ..8 ..9}

words['base'] = words['base'].uniq - BuiltInWords
words['recommended']= (words['recommended'].uniq - BuiltInWords) - words['base']
words['other']= (((words['other'].uniq - BuiltInWords) - words['recommended']) - words['base'])

puts "filtering base package keywords"
base_filter=GenericFilter.new(words['base'],libraries=libraries['base'])
puts "filtering recommended package keywords"
recommended_filter=GenericFilter.new(words['recommended'], base_filter.S3generics,libraries=libraries['recommended'])
puts "filtering other packages keywords"
other_filter=GenericFilter.new(words['other'], base_filter.S3generics+recommended_filter.S3generics,libraries=libraries['other'])


rlang = rbase.elements["//UserLang[@name='R']"]
rlang.elements["//Keywords[@name='Words2']"].text = base_filter.filtered.join(" ")
rlang.elements["//Keywords[@name='Words3']"].text = recommended_filter.filtered.join(" ")
rlang.elements["//Keywords[@name='Words4']"].text = other_filter.filtered.join(" ")

if !UDL.elements["//UserLang[@name='R']"].nil? then
	UDL.elements["//UserLang[@name='R']"]=rlang
else
	UDL.root.add_element(rlang)
end

newUDL = File.open("#{ENV['APPDATA']}/Notepad++/userDefineLang.xml","w")
UDL.write(newUDL)
newUDL.close
