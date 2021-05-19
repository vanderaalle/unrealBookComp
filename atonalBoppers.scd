/*
1. create names and titles, and store them into an archive
for n
2. select name and title
3. make form
4. call bebopper routine and melody model
5. write midi
6. harmonize and write harm and form in an annotation file
*/


~path = thisProcess.nowExecutingPath.dirname ; ["melody", "midi", "bebopper", "cabala", "harmony"].do{|n| (~path++"/"++n++".scd").load } ;


~composers = [] ;
thisThread.randSeed = 1951 ;
5.do{
	var comp = ~getName.(~names, ~surnames);
	var wk = Array.fill(10, {~titler.(1, 3).postln}) ;
	~composers = ~composers.add([comp, wk])
} ;

~composers.do{|i, j|
	var comp = i[0] ;
	i[1].do{|w|
		var tempo = rrand(120, 170) ;
		var stuff = ~makeForm.(tempo: ~tempo ) ;
		var mel = stuff[0] ;
		var form = stuff[1] ;
		var dur = form.collect{|i| stuff[2][i]} ;
		var tot = stuff[3].postln ;
		var key	= ~getKey.(mel);
		var harm = ~harmonizeMel.(mel, tot, ~symbolsTo7, ~priority) ;
		~logHarmony.(harm, form, dur, tot, key, "/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".harm") ;
		~makeMidi.(mel, tempo, "/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".mid") ;

	}
} ;

