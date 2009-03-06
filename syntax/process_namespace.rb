
basenamespace<-grep("^[_a-zA-z0-9\\.]*$",ls(.BaseNamespaceEnv),value=TRUE)

methodslist<-character(0)
for(generic in names(.knownS3Generics))methodslist<-append(methodslist,methods(generic))

setdiff(basenamespace,methodslist)


# get('S3methods',envir=get('.__NAMESPACE__.',envir=asNamespace("tcltk")))
# ls(get('exports',envir=get('.__NAMESPACE__.',envir=asNamespace("tcltk"))),all.names=T)


# def process_NAMESPACE(filename)
# def process_NAMESPACE(filename)
	

# end

