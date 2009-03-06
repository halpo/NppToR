#  NppToR: R in Notepad++
#  by Andrew Redd 2008 <halpo@users.sourceforge.net>
#  use govorned by the MIT license http://www.opensource.org/licenses/mit-license.php
#
#  GenerateSntaxFiles.rb is a part of NppToR.  This file reads the R library and fills in syntax words for
#


#Dir.chdir("C:/Documents and Settings/AREDD/My Dogcuments/Projects/npptor.sf.net/syntax")  #for development
puts "Welcome to the R Syntax Generator for NppToR"
puts "(c) 2009 Andrew Redd"

R="don't start R"

require 'rexml/document'
require 'win32/registry'
require 'pathname'
puts "loading required files"
load "GenericFilter.rb"
load "R_UDL_Base.xml.rb"
load "process_namespace.rb"


puts "reading arguments"
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

puts "finding R libraries"
thisR=RinRuby.new(echo=false,interactive=false,executable=r_exe)
thisR.eval "pkg_priority<-function(pkgname)((function(x){ifelse(is.na(x),'other',x)})(installed.packages()[pkgname,'Priority']))"
thisR.eval "pkg_location<-function(pkgname)(installed.packages()[pkgname,'LibPath'])"
r_libs = thisR.pull '.libPaths()'
r_pkgs = thisR.pull "unique(installed.packages()[,'Package'])"
# puts "libraries:"
# puts r_pkgs

puts "processing R packages"
keyword_loader=R_keywords.new()
r_pkgs.each{|pkg|
	puts "processing #{pkg}"
	priority = thisR.pull "pkg_priority('#{pkg}')"
	puts "priority: #{priority}"
	libraries[priority] << pkg
	words[priority] << pkg
	begin	
		words[priority] << keyword_loader.get_keywords(pkg)
	rescue	
		libpath = Pathname.new(thisR.pull("pkglibpath<-pkg_location('#{pkg}')"))
		libpath += pkg
		pkgwords=Array.new()
		if (File.directory?(libpath) && File.exists?(libpath+'CONTENTS')) then
			puts "Processing #{pkg} by CONTENTS file"
			libraries[priority] << pkg
			lines = (libpath+'CONTENTS').readlines
			lines.grep(/^Aliases/).each{ |line|
				lwords = line.split
				lwords.delete_at(0)
				pkgwords << lwords.grep(/^[A-Za-z]+[A-Za-z\._]*[A-Za-z0-9\._]*$/)
			}
			pkgwords.flatten!
		end
		puts "filtering out S3 methods for #{pkg}."
		words[priority] << GenericFilter.new(pkgwords, [], nil,pkg).filtered
	end

}

BuiltInWords = %w{if else for while repeat break next in TRUE FALSE NULL Inf NaN NA NA_integer_ NA_real_ NA_complex_ NA_character_ ... ..1 ..2 ..3 ..4 ..5 ..6 ..7 ..8 ..9}

words['base'] = words['base'].uniq - BuiltInWords
words['recommended']= (words['recommended'].uniq - BuiltInWords) - words['base']
words['other']= (((words['other'].uniq - BuiltInWords) - words['recommended']) - words['base'])


rlang = rbase.elements["//UserLang[@name='R']"]
rlang.elements["//Keywords[@name='Words2']"].text = words['base'].join(" ")
rlang.elements["//Keywords[@name='Words3']"].text = words['recommended'].join(" ")
rlang.elements["//Keywords[@name='Words4']"].text = words['other'].join(" ")

if !UDL.elements["//UserLang[@name='R']"].nil? then
	UDL.elements["//UserLang[@name='R']"]=rlang
else
	UDL.root.add_element(rlang)
end

newUDL = File.open("#{npp_config}/userDefineLang.xml","w")
UDL.write(newUDL)
newUDL.close
