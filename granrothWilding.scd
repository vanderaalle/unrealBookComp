// Mark Granroth-Wilding
// Cfr. http://jazzparser.granroth-wilding.co.uk/Thesis.html
// Harmonic Analysis of Music Using Combinatory Categorial Grammar

(
f = File("/home/andrea/musica/scores/unrealBook/varia/jazzParser/chord_corpus.txt", "r") ;

t = f.readAllString; f.close ;
~stream = Pseq(t.split($\n)).asStream ;

c = [] ;
n = ~stream.next ;
while{n.notNil}{
	var cn, ch ;
	if(n.contains("sequence-")){
		cn = ~stream.next ;
		~stream.next ;
		ch = ~stream.next ;
		c = c.add([cn, ch]) ;
		n = ~stream.next
	}{n = ~stream.next}
} ;
)
c = c.collect{|i| [i[0].replace("Main key:    ", ""), i[1].split($ ).select{|k| k.size>0}.collect{|k| k.replace(",","")}]}

~short = c.select{|i| i[1].size <= 32}
~short.do{|i| i[1].size.postln}