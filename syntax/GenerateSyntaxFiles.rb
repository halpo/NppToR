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
options.retain = true
options.verbose = false
options.quiet = false

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
opts.on( "-r",	"--do-recommended", "include recommended packages in syntax generation"){ options.recommended = true}
opts.on( "-N",	"--no-other-packages","Do not include non-standard packages."){ options.other = false }
opts.on( "-i",	"--include=LIST","also include the packages listed", String){ |list|
	puts "extra includes: #{list}"
	options.include = list.split(/,\s*/)
}
opts.on( "-x",	"--exclude=LIST","exclude the packages listed.", String){ |list|
	puts "exclude packages: #{list}"
	options.include = list.split(/,\s*/)
}
opts.on( "-o=FILE","--out=OUTFILE","Output generated syntax to OUTFILE", String){ |file|
	puts "syntax file output to #{file}."
	options.fileout=file
}
opts.on( "-f=FILE","--file=INFILE","Syntax file for reading and writing unless --out is specified", String){ |file|
	puts "Reading R laguage syntax file from #{file}."
	options.filein=file
}
opts.on("","--no-retain", "replace generated sections with new words rather than the default of merging"){options.retain=false}
opts.on("-v","--verbose", "verbose"){options.verbose=true}
opts.on("-q","--quiet", "run as silently as possible"){options.quiet=true}

opts.parse(ARGV)

# raise "no package classes specified." if not options.merge && !options.base && !options.recommended && !options.other && options.include.length==0


if  options.rhome == "" then
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
raise "no Notepad++ config directory found or sspecified." if options.npp_config_dir.empty? && options.outfile.empty?
puts "Notepad++ Config Directory:#{options.npp_config_dir}"

pkgpriorities=['base','recommended','other']
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
if getpkgpriorities.empty? then
	r_pkgs = []
else
	rcmd = "unique(installed.packages(priority=c('#{getpkgpriorities.join("', '")}'))[,'Package'])"
	r_pkgs = thisR.pull rcmd
end 

r_pkgs = r_pkgs + options.include - options.exclude
r_pkgs.uniq!

puts "processing R packages..."
keyword_loader=R_keywords.new()
r_pkgs.each do |pkg|
	priority = (thisR.pull "pkg_priority('#{pkg}')")
	priority.downcase!
	if not options.include.include?(pkg) then case priority
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
end 

options.filein  = "#{options.npp_config_dir}\\userDefineLang.xml" if options.filein.empty?
options.fileout = options.filein if options.fileout.empty?

if (not options.filein == "internal") and File.exists?(options.filein) then
	rbase = REXML::Document.new(File.open(options.filein)) 
	rbase.elements.each("NotepadPlus/UserLang"){|e| p e}
	unless rbase.elements["NotepadPlus/UserLang[@name='R']"].nil? then 
		puts "extracting syntax given from #{options.filein}"
		rlang = rbase.elements["NotepadPlus/UserLang[@name='R']"] 
	else 
		puts "failed to find defined R language, ..."
		rlang = REXML::Document.new(R_UDL_Base).elements["NotepadPlus/UserLang[@name='R']"]
	end
else 
	puts "using internal syntax as a base"
	rbase = REXML::Document.new(R_UDL_Base)
	rlang = rbase.elements["//UserLang[@name='R']"]
end
# puts "rlang = "
# puts rlang
# puts "end rlang"

BuiltInWords = %w{if else for while repeat break next in TRUE FALSE NULL Inf NaN NA NA_integer_ NA_real_ NA_complex_ NA_character_ ... ..1 ..2 ..3 ..4 ..5 ..6 ..7 ..8 ..9}

oldwords={
'builtin'=>Array.new(),
'base' => Array.new(),
'recommended' => Array.new(),
'other' => Array.new()
}

p rlang.elements["//Keywords[@name='Words1']"].text
oldwords['builtin'] 	= rlang.elements["//Keywords[@name='Words1']"].text.split(/\s/) unless rlang.elements["//Keywords[@name='Words1']"].text.nil?
oldwords['base'] 		= rlang.elements["//Keywords[@name='Words2']"].text.split(/\s/) unless rlang.elements["//Keywords[@name='Words2']"].text.nil?
oldwords['recommended']	= rlang.elements["//Keywords[@name='Words3']"].text.split(/\s/) unless rlang.elements["//Keywords[@name='Words3']"].text.nil?
oldwords['other']		= rlang.elements["//Keywords[@name='Words4']"].text.split(/\s/) unless rlang.elements["//Keywords[@name='Words4']"].text.nil? 

words['base'] = words['base'] - BuiltInWords - oldwords['builtin']
words['base']+= oldwords['base'] if options.retain
words['recommended'] = (words['recommended'] - BuiltInWords) - words['base']
words['recommended']+= oldwords['recommended'] if options.retain
words['other'] = (((words['other'] - BuiltInWords) - words['recommended']) - words['base'])
words['other']+= oldwords['other'] if options.retain

rlang.elements["//Keywords[@name='Words2']"].text = words['base'].join(" ") unless libraries['base'].empty?
rlang.elements["//Keywords[@name='Words3']"].text = words['recommended'].join(" ") unless libraries['recommended'].empty? 
newotherwords = words['other'].join(" ")
if newotherwords.length > 1024*30 then 
	raise "Keywords for non high priority packages exceeds the allowable limit for Notepad++.  This shortcoming can be bypassed by regenerating the syntax files and specifying a subset of packages to have highlighting for (-N with --include=libs)."
else
	rlang.elements["//Keywords[@name='Words4']"].text = newotherwords unless libraries['other'].empty?
end
rbase.elements.delete("NotepadPlus/UserLang[@name='R']") unless rbase.elements["NotepadPlus/UserLang[@name='R']"].nil?
rbase.root.add(rlang)
puts "writing to #{options.fileout}"
rbase.write(File.open(options.fileout,"w"))

