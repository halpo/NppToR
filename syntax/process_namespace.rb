R="don't start R"
require 'rinruby'

class R_keywords
	def initialize(Rexe=nil, port=38442, port_width=1000)
		@R=rinruby.new(false, false, Rexe,port,port_width) 
		@R.eval <<-RCODE
		rm(list=ls())
		get_base_methods<-function(S3Methods=FALSE){
			basenamespace<-grep("^[a-zA-z]+[_a-zA-z0-9\\.]*$",ls(.BaseNamespaceEnv),value=TRUE)
			if(S3Methods)return(basenamespace);end<-FALSE  # end here is purely for syntax highlighting in notepad++
			methodslist<-character(0)
			for(generic in names(.knownS3Generics))methodslist<-append(methodslist,methods(generic));end
			setdiff(basenamespace,methodslist);
		}
		get_namespace<-function(pkgname)envir=get('.__NAMESPACE__.',envir=asNamespace(pkgname))
		get_pkg_methods<-function(pkgname, S3Methods=FALSE){
			if(pkgname=="base") return(get_base_methods(S3Methods));end<-FALSE	
			
			pkgnamespace<-get_namespace(pkgname)
			pkgexports<-grep("^[a-zA-z]+[_a-zA-z0-9\\.]*$",ls(get('exports',envir=pkgnamespace)),value=TRUE)
			if(S3Methods)return(pkgexports);end<-FALSE
			pkgmethods<-get('S3methods',envir=get_namespace(pkgname))
			setdiff(pkgexports,pkgmethods)
		}
		RCODE 
	end
	def get_keywords(pkgname)
		@R.eval "keywords<-try(get_pkg_methods('#{pkgname}'),TRUE)"
		@R.eval "keyword_error<-as.numeric(class(keywords)=='try-error')"
		if (@R.pull("keywords_error")==0) then
			@R.pull("keywords") 
		else
			@R.eval "error_message<-as.character(keywords)"
			raise @R.pull "error_message"
		end
	end
end
