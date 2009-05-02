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
require 'optparse'
require 'ostruct'

load "GenericFilter.rb"
load "R_UDL_Base.xml.rb"
load "process_namespace.rb"

opts = OptionParser.new
options = OpenStruct.new
options.rhome = String.new
options.npp_config_dir = String.new
options.base = false
options.recommended = false
options.other = true
options.include = []
options.exclude = []
options.fileout = String.new
options.filein = String.new

opts.on_tail( "-h", "--help", "Print help menu"){
	puts opts
	exit
}
opts.on( "-R",	"--RHome=VAL",	String ){|val| 
puts val
options.rhome = val
}
opts.on( "-c",	"--npp-config=VAL", String){|val| options.npp_config_dir = val}
opts.on( "-b",	"--do-base", "include base packages in syntax generation"){ options.base = true}
opts.on( "-m",	"--do-recommended", "include recommended packages in syntax generation"){ options.recommended = true}
opts.on( "-N",	"--no-other-packages","Do not include non-standard packages."){ options.other = false }
opts.on( "-i",	"--include=VAL","also include the packages listed", String){ |list|
	options.include = list.split(/,\s*/)
}
opts.on( "-x",	"--exclude=VAL","exclude the packages listed.", String){ |list|
	options.include = list.split(/,\s*/)
}
opts.on( "-o=FILE","--out=FILE","Output generated syntax to FILE", String){ |FILE|
	puts "Reading R laguage syntax file from #{FILE}."
	options.fileout=FILE
}
opts.on( "-f=FILE","--file=FILE","Syntax file for reading and writing unless --out is specified", String){ |FILE|
	puts "Reading R laguage syntax file from #{FILE}."
	options.filein=FILE
}

opts.parse(ARGV)

raise "no package classes specified." if(!options.base && !options.recommended && !options.other && options.include.length==0)

if  if options.rhome == "" then
	Win32::Registry::HKEY_LOCAL_MACHINE.open('Software\R-core\R') do |reg|
		reg_type, options.rhome = reg.read('InstallPath')
	end
end
raise "no Rhome directory found" if options.rhome.empty?
puts "R home directory: #{options.rhome}"
r_exe = options.rhome ? "#{options.rhome}\\bin\\Rterm.exe" : nil 
if options.npp_config_dir == "" then 
	options.npp_config_dir = "#{ENV['APPDATA']}\\Notepad++"
end
raise "no Notepad++ config directory found or sspecified." if options.npp_config_dir.empty?
puts "Notepad++ Config Directory:#{options.npp_config_dir}"


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
getpkgpriorities=[]
getpkgpriorities << 'base' if options.base
getpkgpriorities << 'recommended' if options.recommended
getpkgpriorities << 'NA' if options.other
r_pkgs = thisR.pull "unique(installed.packages(priority=c(#{getpkgpriorities.join(', ')}))[,'Package'])"
r_pkgs = r_pkgs + options.include - options.exclude
r_pkgs.uniq!

puts "processing R packages..."
keyword_loader=R_keywords.new()
r_pkgs.each{|pkg|
	priority = (thisR.pull "pkg_priority('#{pkg}')")
	priority.downcase!
	puts "#{pkg}(#{priority})"
	if not options.include.include?('pkg') then case priority
		when "base": next if !options.base
		when "recommended": next if !options.recommended
		when "other": next if !options.other
		else raise "unknown package priority for package #{pkg}"
	end end 
	puts "processing #{pkg}"
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

options.filein  = "#{options.npp_config_dir}/userDefineLang.xml" if options.infile == ""
options.fileout = options.filein if options.fileout == ""

if File.exists?(options.filein) then
	rbase = REXML::Document.new(File.open(options.filein)) 
	if rbase.key?("//UserLang[@name='R']") then 
		puts "extracting syntax given from ${options.filein}"
		rlang = rbase.elements["//UserLang[@name='R']"] 
	else 
		puts "failed to find defined R language, reverting to internally stored syntax"
		rbase = REXML::Document.new(R_UDL_Base)
		rlang = rbase.elements["//UserLang[@name='R']"]
	end
else 
	puts "using internal syntax as a base"
	rbase = REXML::Document.new(R_UDL_Base)
	rlang = rbase.elements["//UserLang[@name='R']"]
end

rlang.elements["//Keywords[@name='Words2']"].text = words['base'].join(" ") if options.base
rlang.elements["//Keywords[@name='Words3']"].text = words['recommended'].join(" ") if options.recommended
rlang.elements["//Keywords[@name='Words4']"].text = words['other'].join(" ") if options.other

# if !UDL.elements["//UserLang[@name='R']"].nil? then
	# UDL.elements["//UserLang[@name='R']"]=rlang
# else
	# UDL.root.add_element(rlang)
# end

out = File.open(options.fileout,"w")
rbase.write(out)
out.close

end