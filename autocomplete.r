library(methods)


indent <- function(s){
    paste0("\t", gsub('\n', '\n\t', s))
}
escape_regex <- function(ex){
    gsub('([.\\^$*+?()[{\\\\])', '\\\\\\1', ex, perl=T)
}
escape_html <- function(string) {
    gsub("&", "&amp;" , fixed = TRUE, x=
    gsub("<", "&lt;"  , fixed = TRUE, x=
    gsub(">", "&gt;"  , fixed = TRUE, x=
    gsub('"', "&quot;", fixed = TRUE, x=
        string
    ))))
}

isS3Generic <- function(generic){
    knownGenerics <- utils:::getKnownS3generics()
    stopifnot(is.character(generic)) 
    if ( !exists(generic, mode = "function", envir = parent.frame())
      && !any(generic == c("Math", "Ops", "Complex", "Summary"))) 
        stop(gettextf("no function '%s' is visible", generic), domain = NA)
    if (any(generic == knownGenerics)) {
        TRUE
    } else {
        truegf <- utils:::findGeneric(generic, parent.frame())
        if (truegf == "") 
            FALSE
        else if (truegf == generic)
            TRUE
        else if (truegf != generic) {
            warning(gettextf("generic function '%s' dispatches methods for generic '%s'", 
              generic, truegf), domain = NA)
            TRUE
        }
    } 
    FALSE
}
isS4Generic <- function(generic) {
    stopifnot(is.character(generic)) 
    isGeneric(generic)
}
is_generic <- function( gname = deparse(substitute(g))
                      , g     = get(gname, env)
                      , env   = parent.frame()) {
    if(suppressWarnings( isS4Generic(gname))) return(4)
    if(suppressWarnings( isS3Generic(gname))) return(3)
    return(0)
}

is_s3_specialized <- function( fname = deparse(substitute(f))
                             , f     = get(fname, env)
                             , env   = parent.frame()) {
    if(!grepl('\\.', fname)) return(FALSE)
    if(is_generic(fname)) return(FALSE)
    parts <- strsplit(fname, "\\.")[[1]]
    if (length(parts) - 1) for(i in seq.int(length(parts)-1)) {
        gname <- paste(parts[1:i], collapse = '.')
        if ( ((exists(gname, envir=env, mode="function") && gname %in% getNamespaceExports(env))
           || exists(gname, mode="function"))
          && is_generic(gname) && fname %in% suppressWarnings(methods(gname))) {
            return(TRUE)
        }
    }
    FALSE
}

args2char <- function(args, max.string){
    arg.names <- names(args)
    has.default <- logical(length(args))
    for(i in seq_along(args)) {
        a <- args[[i]]
        has.default[[i]] <- !missing(a)
    }
    ifelse(has.default, paste(arg.names, limitedLabels(sQuote(args), 12), sep=' = '), arg.names)
}
args2params <- function( args ) {
    arg.strings <- args2char(args)
    paste(sprintf('<Param name="%s"/>', escape_html(arg.strings)), collapse='\n')
}
function2xml <- function( fname = deparse(substitute(f))
                        , f     = get(fname, env)
                        , env   = parent.frame()){
    stopifnot(is.function(f))
    stopifnot(is.character(fname))
    overload <- sprintf( '<Overload retVal="">\n%s\n</Overload>'
                       , indent(args2params(formals(f))))
    keyword  <- sprintf( '<KeyWord name="%s" func="yes">\n%s\n</KeyWord>'
                       , fname, indent(overload))
}
generic2xml <- function( fname = deparse(substitute(f))
                       , f     = get(fname, env)
                       , env = parent.frame()) {
    stopifnot(is.character(fname))
    g <- is_generic(fname)
    if(g == 4){
        overload <- sprintf('<Overload retVal="S4 Generic">\n%s\n</Overload>', indent(args2params(formals(f))))
        keyword <- sprintf('<KeyWord name="%s" func="yes">\n%s\n</KeyWord>', fname, indent(overload))
    } 
    else if(g == 3) {
        stopifnot(is.function(f))
        specifics <- methods(f)
        info <- attr(specifics, 'info')
        snames <- specifics[info$visible]
        sparams <- lapply(lapply(lapply(snames, get), formals), args2params)
        
        gparams <- args2params(formals(f))
        generic <- sprintf( '<Overload retVal="generic">\n%s\n</Overload>'
                          , indent(gparams))
        
        needs.special <- sparams != gparams
        classes <- gsub(escape_regex(paste0(fname, '.')), '', snames)

        overloads <- sprintf('<Overload retVal="(S3) %s">\n%s\n</Overload>'
                            , classes[needs.special]
                            , indent(sparams[needs.special]))
       
        keyword <- sprintf('<KeyWord name="%s" func="yes">\n%s\n%s\n</KeyWord>'
                          , fname, indent(generic)
                          , indent(paste(overloads, collapse='\n')))
    } else keyword <- NULL
    keyword
}

#' convert an object to Notepad ++ prompt XML
#' 
#' @param object character object
#' 
#' @export
object2xml <- function( oname = deparse(substitute(o))
                      , o     = get(oname, env)
                      , env   = parent.frame()
) {
    if (is.function(o)) {
        force(oname)
        if(is_generic(oname)) 
            return(generic2xml(fname=oname, f=o, env=env))
        if(!is_s3_specialized(fname=oname, f=o, env=env))
            return(function2xml(fname=oname, f=o, env=env))
        return(NULL)
    }
    else return(sprintf('<KeyWord name="%s"/>', oname))
}


valid_name <- function(name){
    grepl('^[.a-zA-Z][._a-zA-Z0-9]+$', name)
}
visible_name <- function(name){
    grepl('^[a-zA-Z][._a-zA-Z0-9]+$', name)
}

pkg <- 'base'
pkg2xml <- function(pkg, pb=NULL) {
    if(!is.null(pb)){
        setWinProgressBar(pb, label=pkg, getWinProgressBar(pb))
    }
    if(!(pkg %in% .packages())) 
        require(pkg, character.only=TRUE)
    ns <- asNamespace(pkg)
    all.names <- Filter(visible_name, getNamespaceExports(ns))
    isf <- sapply(all.names, function(x, ns){
        is.function(get(x, envir=ns))}
    , ns)
    if(length(isf)==0) isf <- logical(0)
    all.functions <- all.names[ isf]
    non.functions <- all.names[!isf]
    
    is.s3.special <- sapply(all.functions, is_s3_specialized, env=ns)    
    no.specials <- all.functions[!is.s3.special]

    if(!is.null(pb)){
        setWinProgressBar(pb, getWinProgressBar(pb)+1)
    }
    sapply(sort(c(non.functions, no.specials)), object2xml, env=ns)
}

xml_comment <- function(packages){
fstring <- sprintf("<!--
    R.xml Notepad++ Autocompletion file.
    Generated by NppToR on %s
    R Version: %s (%s)
    
    Packages: %s

-->"
, Sys.Date()
, R.version$version.string, R.version$nickname
, paste(packages, collapse=", "))
}

generate_autocomplete_xml <- 
function(..., packages=base.and.recommended()){
    others <- as.character(substitute(c(...)))[-1]
    packages <- unique(c(others, packages))
    
    pb <- winProgressBar("Extracting Keywords", packages[[1]], min=0, max=length(packages))
    on.exit(try(close(pb)))
    
    keywords <- unique(sort(unlist(lapply(packages, pkg2xml, pb))))
    close(pb)
    key.string <- paste(keywords, collapse='\n')
    
    estring <- '<Environment ignoreCase="no" startFunc="(" stopFunc=")" paramSeparator="," terminal=";" additionalWordChar = "."/>\n'
    aformat <- '<AutoComplete language="R">\n%s\n</AutoComplete>'
    autocomplete.string <- 
    sprintf(aformat, indent(paste(estring, key.string)))

    nformat <- '<?xml version="1.0" encoding="Windows-1252" ?>\n<NotepadPlus>\n%s\n%s\n</NotepadPlus>\n'
    sprintf(nformat, xml_comment(packages), indent(autocomplete.string))
}

base.and.recommended <- function() {
    ip <- suppressWarnings(data.frame(installed.packages(), stringsAsFactors=F))
    as.character(unique(subset(ip, Priority %in% c('base', 'recommended'))$Package))
}

#' Create the Notepad++ Autocompletion file. 
#' 
#' @param file where to save
#' @param ... extra packages to include
#' @param packages a character vector of packages.
#' 
#' Create the R.xml file for autocompletion in Notepad++ API format.
#' 
#' 
#' 
#' @export
write_autocomplete_xml <- 
function(file.xml='R.xml', ..., packages=base.and.recommended()){
    others <- as.character(substitute(c(...)))[-1]
    packages <- unique(c(others, packages))
    xml <- generate_autocomplete_xml(packages=packages)
    cat(xml, file=base::file(file.xml, encoding="Windows-1252"))
}

options(useFancyQuotes=FALSE)
write_autocomplete_xml()

