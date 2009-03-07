is_S3Generic_R_code=S3GENERICRCODE
is.S3Generic<-function (generic.function, methods=TRUE) 
{
	if(missing(generic.function))stop('generic.function must be provided')
	S3MethodsStopList <- tools:::.make_S3_methods_stop_list(NULL)
	knownGenerics <- c(names(.knownS3Generics), tools:::.get_internal_S3_generics())
	sp <- search()
	an <- lapply(seq_along(sp), ls)
	names(an) <- sp
	an <- unlist(an)
	an <- an[!duplicated(an)]
	names(an) <- sub("[0-9]*$", "", names(an))
	info <- data.frame(visible = rep.int(TRUE, length(an)), from = names(an), 
	row.names = an)
	if (!is.character(generic.function)) {
		generic.function <- deparse(substitute(generic.function))
	} else if (!exists(generic.function, mode = "function", envir = parent.frame()) && !generic.function %in% c("Math", "Ops", "Complex", "Summary")){
		rtn<-FALSE
		attr(rtn,'msg')<-gettextf("no function '%s' is visible", generic.function)
	}
	if (!any(generic.function == knownGenerics)) {
		truegf <- utils:::findGeneric(generic.function, parent.frame())
		if (truegf == ""){ 
			rtn=FALSE
			attr(rtn,'msg')<-gettextf("function '%s' appears not to be generic", generic.function)
			return(rtn)
		} else if (nzchar(truegf) && truegf != generic.function) {
			rtn = FALSE
			attr(rtn,'msg')<-gettextf("generic function '%s' dispatches methods for generic '%s'", generic.function, truegf)
		}
	}
	rtn<-TRUE
	name <- paste("^", generic.function, ".", sep = "")
	name <- gsub("([.[$+*])", "\\\\\\1", name)
	info <- info[grep(name, row.names(info)), ]
	info <- info[!row.names(info) %in% S3MethodsStopList, ]
	if (nrow(info)) {
	  keep <- sapply(row.names(info), function(nm) exists(nm, mode = "function"))
	  info <- info[keep, ]
	}
	defenv <- if (!is.na(w <- .knownS3Generics[generic.function])) asNamespace(w) else {
		genfun <- get(generic.function, mode = "function", envir = parent.frame())
		if (.isMethodsDispatchOn() && methods::is(genfun, "genericFunction")) 
			genfun <- methods::slot(genfun, "default")@methods$ANY
		if (typeof(genfun) == "closure") environment(genfun)
		else .BaseNamespaceEnv
	}
	S3reg <- ls(get(".__S3MethodsTable__.", envir = defenv), pattern = name)
	rbindSome <- function(df, nms, msg) {
        n2 <- length(nms)
        dnew <- data.frame(visible = rep.int(FALSE, n2), from = rep.int(msg, 
            n2), row.names = nms)
        n <- nrow(df)
        if (n == 0) 
            return(dnew)
        keep <- !duplicated(c(rownames(df), rownames(dnew)))
        rbind(df[keep[1:n], ], dnew[keep[(n + 1):(n + n2)], ])
    }
	if (length(S3reg)) info <- rbindSome(info, S3reg, msg = paste("registered S3method for", generic.function))
	if (generic.function == "all") info <- info[-grep("^all\\.equal", row.names(info)),]
	info <- info[sort.list(row.names(info)), ]
	res <- row.names(info)
	class(res) <- "MethodsFunction"
	attr(res, "info") <- info
	attr(rtn,'methods')<-res
	rtn
}
S3GENERICRCODE
