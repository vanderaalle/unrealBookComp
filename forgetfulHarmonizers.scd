/*
1. create names and titles, and store them into an archive
for n
2. select name and title
3. make form
4. call bebopper routine and melody model
5. write midi
6. harmonize and write harm and form in an annotation file
*/

~path = thisProcess.nowExecutingPath.dirname ; ["melody", "midi", "harmonyMarkov", "cabala", "timeTape"].do{|n| (~path++"/"++n++".scd").load } ;


~makeForm = {
	var mel = [] ;
	var t, d, rhy, ch, off = 0 ;
	var form = [\AAB, \AABA, \ABAC, \ABA].choose ;
	var frm = [], harm = [] ;
	var formDur = () ;
	var formSeeds ;
	var pitches = Array.series(12), quality ;
	[\A, \B, \C].do{|i| formDur[i] = [4, 6, 8, 12].wchoose([0.3, 0.05, 0.6, 0.05])} ;
	form.asString.do{|i| frm = frm.add(i.asString.asSymbol)};
	formSeeds = () ;
	[\A, \B, \C].do{|i|
		formSeeds[i] = rrand(0,1000)};
	frm.postln.do{|sec|
		thisThread.randSeed = formSeeds[sec] ;
		t = ~timeTape.makeTape(formDur[sec], 2, 1, Array.series(4,2).wchoose([0.1,0.4, 0.3, 0.2])) ;
		d = ~timeTape.delete(t, rrand(0.15,0.35)) ;
		rhy = ~timeTape.rhyConv(d, 0) ;
		ch = ~makeChordSeq.(
			(pitches.choose.asString++"_"++~harm.keys.choose.asString).asSymbol,
			~harm, formDur[sec]) ;
		harm = harm ++ ch ;
		mel = mel++~fromMarkovHarmony.(rhy, ch).collect{|i| [i[0], i[1]+off, i[2]]} ;
		off = off+(formDur[sec]*4) ; //4/4
	} ;
	[mel, frm, formDur, frm.collect{|i| formDur[i]}.sum, harm]
} ;


~composers = [] ;
thisThread.randSeed = 1955 ;
5.do{
	var comp = ~getName.(~names, ~surnames);
	var wk = Array.fill(10, {~titler.(1, 3).postln}) ;
	~composers = ~composers.add([comp, wk])
} ;



~composers.do{|i, j|
	var comp = i[0] ;
	i[1].do{|w|
		var tempo = rrand(130, 180) ;
		var stuff = ~makeForm.() ;
		var mel = stuff[0] ;
		var form = stuff[1] ;
		var dur = form.collect{|i| stuff[2][i]} ;
		var tot = stuff[3] ;
		var key	= ~getKey.(mel);
		var harm = stuff[4] ;
		i.postln ; w.postln ;
		~logHarmony.(harm, form, dur, tot, key, "/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".harm") ;
		~makeMidi.(mel, tempo, "/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".mid") ;

	}
} ;

