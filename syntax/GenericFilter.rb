require 'rinruby'

class GenericFilter
	def initialize(keywords=nil, extragenerics=Array.new,r_exe=nil, libs= nil)
    @extragenerics = extragenerics
		@generics=Array.new
		@specifics=Array.new
		@myR = RinRuby.new(echo=false,interactive=false,executable=r_exe)
		@myR.eval <<-ISGENERIC
				is.generic<-function(names){
					sapply(names,function(n)
						tryCatch(ifelse(length(methods(n))>0,TRUE,NA),
						error=function(e)NA,
						warning=function(w)NA))
				}
		ISGENERIC
		if(!libs.nil?) then libs.each{|lib|
			@myR.eval "library(#{lib})"
		} end
		# BEGIN FILTERING LIST OF KEYWORDS TO PARTS
		if(!keywords.nil?)
			keywords.delete_if{ |key|
				if(isgeneric?(key))
					@generics << key
					true
				else false end
			}
			keywords.delete_if{ |key|
				if(isspecific?(key))
					@specifics << key
					true
				else false end
			}
			@others = keywords
		else
			@generics=nil
			@others=nil
			@specifics=nil
		end
	end
public
	def allgenerics()
		@extragenerics+@generics
	end
	def isgeneric?(names)
		@myR.fnames = names
		@myR.eval "(isS3<-as.integer(is.generic(fnames)))"
		index = @myR.pull 'isS3'
	end
	def isspecific?(name)
		allgenerics().any?{|generic|
			name =~ /^#{generic.gsub(/\./,'\\\.')}\.[\.\w]+/
		}
	end
public
	def S3generics()
		@generics
	end
	def S3specifics()
		@specifics
	end
	def filtered()
		@generics+@others
	end
end
