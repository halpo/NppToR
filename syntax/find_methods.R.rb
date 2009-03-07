@@find_methods_rcode=<<RCODEFINDMETHODS
	get_base_names<-function(S3Methods=FALSE){
		basenamespace<-grep("^[a-zA-z]+[_a-zA-z0-9\\\\.]*$",ls(.BaseNamespaceEnv),value=TRUE)
		if(S3Methods)return(basenamespace);end<-FALSE  # end here is purely for syntax highlighting in notepad++
		methodslist<-character(0)
		for(generic in names(.knownS3Generics))methodslist<-append(methodslist,methods(generic));end<-FALSE
		setdiff(basenamespace,methodslist);
	}
	get_namespace<-function(pkgname)get('.__NAMESPACE__.',envir=asNamespace(pkgname),mode="environment")
	get_pkg_names<-function(pkgname, S3Methods=FALSE){
		if(pkgname=='base')return(get_base_names(S3Methods));end<-FALSE	
		pkgnamespace<-try(get_namespace(pkgname),TRUE)
		if(class(pkgnamespace)=="try-error"){ if(!is.na(installed.packages()[pkgname,'Priority']) && (installed.packages()[pkgname,'Priority']=="base")) {
			if(pkgname=='datasets')stop("pkg 'datasets' has no namespace.")
			pkgexports<-grep("^[a-zA-z]+[_a-zA-z0-9\\\\.]*$",ls(asNamespace(pkgname)),value=TRUE)
			pkgexports<-sort(pkgexports)
			for(i in 1:length(pkgexports)){
				if(i>length(pkgexports)) break
				generic<-is.S3Generic(pkgexports[i])
				pkgexports<-setdiff(pkgexports,attr(generic,'methods'))				
			}
			pkgexports
		} else stop(gettextf("The package '%s' doen not have defined namespace nor is it a base package.",pkgname))}
		pkgexports<-grep("^[a-zA-z]+[_a-zA-z0-9\\\\.]*$",ls(get('exports',envir=pkgnamespace)),value=TRUE)
		if(S3Methods)return(pkgexports);end<-FALSE
		pkgmethods<-get('S3methods',envir=get_namespace(pkgname))
		setdiff(pkgexports,pkgmethods)
	}
RCODEFINDMETHODS