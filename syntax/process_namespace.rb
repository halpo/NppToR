require 'rinruby'

class R_keywords
	load 'find_methods.R.rb'
	load 'iss3generic.R.rb'
	def initialize(exe=nil, port=38442, port_width=1000)
		@R=RinRuby.new(false, false, exe,port,port_width) 
		@R.eval "rm(list=ls())"
		@R.eval @@is_s3generic_r_code
		@R.eval @@find_methods_rcode
	end
	def get_keywords(pkgname)
		@R.eval "keywords<-try(get_pkg_names('#{pkgname}'),TRUE)"
		@R.eval "keywords_error<-as.numeric(class(keywords)=='try-error')"
		if (@R.pull("keywords_error")==0) then
			@R.pull("keywords") 
		else
			@R.eval "error_message<-as.character(keywords)"
			raise @R.pull("error_message")
		end
	end
end
