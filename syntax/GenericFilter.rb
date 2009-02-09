require 'rinruby'
R.quit

class GenericFilter
	
	def initialize()
		@myR = RinRuby.new(echo=false,interactive=false)
@myR.eval <<SETGENERIC
		is.generic<-function(names){
			sapply(names,function(n)
				tryCatch(if(length(methods(n))>0) TRUE else NA,
				error=function(e)NA,
				warning=function(w)NA))
		}
SETGENERIC
	end
	def isgeneric?(names)
		@myR.fnames = names
		@myR.eval "(isS3<-as.integer(is.generic(fnames)))"
		index = @myR.pull 'isS3'
	end
	def generics(names)
		nisgeneric?(names)
		
end