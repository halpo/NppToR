#  NppToR: R in Notepad++
#  by Andrew Redd 2008 <halpo@users.sourceforge.net>
#  use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
#
#  GenerateSntaxFiles.rb is a part of NppToR.  This file reads the R library and fills in syntax words for
#


#Dir.chdir("C:/Documents and Settings/AREDD/My Dogcuments/Projects/npptor.sf.net/syntax")  #for development

require 'rexml/document'
require 'win32/registry'
load "GenericFilter.rb"
load "R_UDL_Base.xml.rb"

puts ARGV

if ARGV[0] then r_home = ARGV[0]
else
	Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\R-core\R') do |reg|
		reg_type, r_home = reg.read('InstallPath')
	end
end
puts "R home directory: #{r_home}"
r_exe = r_home ? "#{r_home}\\bin\\Rterm.exe" : nil 
if ARGV[1] then npp_config = ARGV[1]
else
	npp_config = "#{ENV['APPDATA']}\\Notepad++"
end
puts "Notepad++ Config Directory:#{npp_config}"

# rbase = REXML::Document.new(File.open("R_UDL_Base.xml"))
rbase = REXML::Document.new(R_UDL_Base)
begin
	UDL = REXML::Document.new(File.open("#{npp_config}\\userDefineLang.xml"))
rescue Errno::ENOENT
	UDL = rbase.clone
end 

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

thisR=RinRuby.new(echo=false,interactive=false,executable=r_exe)
r_libs = thisR.pull '.libPaths()'
thisR.quit
puts "libraries:"
puts r_libs

r_libs.each{|libpath|
lib=Dir.new(libpath)
puts "reading R library: #{libpath}"
lib.each{
	|foldername| 
	if (File.directory?(lib.path.concat("\\").concat(foldername)) && File.exists?(lib.path.concat("\\").concat(foldername).concat('\\CONTENTS'))) then
		puts "Processing #{foldername}"
		priority = PkgPriority[foldername]
		libraries[priority] << foldername
		lines = IO.readlines(lib.path.concat("\\").concat(foldername).concat('\\CONTENTS'))
		aliases = lines.grep(/^Aliases/)
		aliases.each{ |line|
			lwords = line.split
			lwords.delete_at(0)
			words[priority] << lwords.grep(/^[A-Za-z]+[A-Za-z\._]*[A-Za-z0-9\._]*$/)
			words[priority].flatten!
		}
	end
}
}
BuiltInWords = %w{if else for while repeat break next in TRUE FALSE NULL Inf NaN NA NA_integer_ NA_real_ NA_complex_ NA_character_ ... ..1 ..2 ..3 ..4 ..5 ..6 ..7 ..8 ..9}

words['base'] = words['base'].uniq - BuiltInWords
words['recommended']= (words['recommended'].uniq - BuiltInWords) - words['base']
words['other']= (((words['other'].uniq - BuiltInWords) - words['recommended']) - words['base'])

puts "filtering base package keywords"
base_filter=GenericFilter.new(words['base'],[],r_exe, libraries['base'])
puts "filtering recommended package keywords"
recommended_filter=GenericFilter.new(words['recommended'], base_filter.S3generics, r_exe, libraries['recommended'])
puts "filtering other packages keywords"
other_filter=GenericFilter.new(words['other'], base_filter.S3generics+recommended_filter.S3generics, r_exe, libraries['other'])


rlang = rbase.elements["//UserLang[@name='R']"]
rlang.elements["//Keywords[@name='Words2']"].text = base_filter.filtered.join(" ")
rlang.elements["//Keywords[@name='Words3']"].text = recommended_filter.filtered.join(" ")
rlang.elements["//Keywords[@name='Words4']"].text = other_filter.filtered.join(" ")

if !UDL.elements["//UserLang[@name='R']"].nil? then
	UDL.elements["//UserLang[@name='R']"]=rlang
else
	UDL.root.add_element(rlang)
end

newUDL = File.open("#{npp_config}/userDefineLang.xml","w")
UDL.write(newUDL)
newUDL.close
