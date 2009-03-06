#test_process_namespace.rb

load "process_namespace.rb"

keyword_loader=R_keywords.new()

puts keyword_loader.get_keywords('base').length
puts keyword_loader.get_keywords('stats').length
puts keyword_loader.get_keywords('tcltk').length
puts keyword_loader.get_keywords('KernSmooth')

begin
	puts keyword_loader.get_keywords("abcdef")
rescue
	puts "Error caught and handled"
end
begin
	puts keyword_loader.get_keywords("akima")
rescue RuntimeError, NameError => msg
	puts msg
end



