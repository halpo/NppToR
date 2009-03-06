
basenamespace<-grep("^[a-zA-z]+[_a-zA-z0-9\\.]*$",ls(.BaseNamespaceEnv),value=TRUE)

methodslist<-character(0)
for(generic in names(.knownS3Generics))methodslist<-append(methodslist,methods(generic))
setdiff(basenamespace,methodslist)

pkgname="stats"
pkgmethods<-get('S3methods',envir=get('.__NAMESPACE__.',envir=asNamespace(pkgname)))
pkgexports<-grep("^[a-zA-z]+[_a-zA-z0-9\\.]*$",ls(get('exports',envir=get('.__NAMESPACE__.',envir=asNamespace(pkgname))),all.names=T),value=TRUE)
setdiff(pkgexports,pkgmethods)

installed.packages()[,c('Package','Priority')]


# def process_NAMESPACE(filename)
# def process_NAMESPACE(filename)
	

# end

