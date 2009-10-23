f<-function(n){
	n<-abs(as.integer(n))
	print(n)
	if(n-1)Recall(n-1) else "BLAST OFF!"
}
f(10)
x=1
x=2
