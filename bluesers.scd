// Bluesers uses 32 bar changes encoded into a file
// uses tape as a basic time stamp
// finally exploits a markov blues melody

(
~path = thisProcess.nowExecutingPath.dirname ; ["melody", "midi", "harmonyMarkov", "cabala", "timeTape"].do{|n| (~path++"/"++n++".scd").load } ;

~readChordDef = {|path = "/home/andrea/musica/scores/unrealBook/code/bluesForms"|
	var f = File(path, "r") ;
	var txt = f.readAllString ;
	f.close ;
	txt = txt.split($\n).select{|i|
		i.contains("//").not
	}.select{|i| i.size>0}
	.collect{|i| i.split($ ).select{|i| i.size>0}.collect{|i| i.asSymbol}}
} ;

~makeDoubleChordsFromSeq = {|seq|
	var nseq = [] ;
	seq.do{|ch|
		if(ch.asString.contains("@")){
			nseq = nseq++ch.asString.split($@)[0].asSymbol ;
			nseq = nseq++ch.asString.split($@)[1].asSymbol ;
		}{
			nseq = nseq++ch;
			nseq = nseq++ch;
		}
	} ;
		nseq
} ;


~transposeSeq = {|seq, off|
	seq.collect{|i|
		(((i.asString.split($_)[0].asInteger+off)%12).asString
			++"_"++(i.asString.split($_)[1].asString)).asSymbol
	} ;
} ;

~prettySeq = {|seq|
	var sq = "" ;
	var names = "C C#/Db D D#/Eb E F F#/Gb G G#/Ab A A#/Bb B".split($ ) ;
	var actual ;
	var next ;
	seq.do{|ch,i|
		if(i%8 == 0){"".postln} ;
		if(i%2==0){("m."++(i/2+1)++ ": ").post };
		next = (names[ch.asString.split($_)[0].asInteger] ++
			ch.asString.split($_)[1].asString ++ " " ) ;
		if (next != actual){ next.post } ;
		actual = next ;
		if(i%2==1){"".postln; actual = ""} ;
	}
} ;

~logHarmony = {|seq, key, path|
	var f = File(path, "w"), block ;
	var sq = "" ;
	var sharp =	["C","C#","D","D#","E","F","F#","G","G#","A","A#", "B"];
	var flat  = ["C","Db","D","Eb","E","F","Gb","G","Ab","A","Bb", "B"] ;
	var names ;
	var actual ;
	var next ;
	var sign = key.sign ;
	var keys = ["Gb","Db","Ab","Eb","Bb","F","C","G","D","A","E","B","F#"] ;
	var txt = "";
	f.write("key: "++keys[key+6]++"\n") ;
	names = if (sign == 1.neg){ flat }{ sharp } ;
	seq.do{|ch,i|
		if(i%8 == 0){txt = txt ++"\n"} ;
		if(i%2==0){txt = txt++("m."++(i/2+1)++ ": ") };
		next = (names[ch.asString.split($_)[0].asInteger] ++
			ch.asString.split($_)[1].asString ++ " " ) ;
		if (next != actual){ txt = txt ++ next } ;
		actual = next ;
		if(i%2==1){txt = txt ++"\n"; actual = ""} ;
	} ;
	f.write(txt) ;
	f.close ;
} ;

~makeForm = {|seed = 100|
	var mel = [] ;
	var t, d, rhy = [], ch ;
	var harm  ;
	var pitches = Array.series(12), quality ;
	//thisThread.randSeed = formSeeds[sec] ;
//	t = ~timeTape.makeTape(12, 0, 1, Array.series(4,2).wchoose([0.5,0.3, 0.1, 0.1])) ;
	3.do{|k|
	//t = (~timeTape.makeTape(4, 0, 1, Array.series(4,2).wchoose([0.5,0.3, 0.1, 0.1]))!3).flatten ;
		t = ~timeTape.makeTape(4, 1, 1, Array.series(4,2).wchoose([0.5,0.3, 0.1, 0.1])) ;
		d = ~timeTape.delete(t, 0.2, seed) ;
		rhy = rhy++~timeTape.rhyConv(d, k*4)
	};
	harm = ~bluesChords.choose ;
	ch = ~transposeSeq.(~makeDoubleChordsFromSeq.(harm), pitches.choose) ;
	mel = ~fromBluesHarmony.(rhy, ch, rrand(3,5), seed:1000.rand).collect{|i| [i[0], i[1], i[2]]} ;
	[mel, ch, harm]
} ;

)

(
~bluesChords = ~readChordDef.() ;
~composers = [] ;
thisThread.randSeed = 1965 ;
10.do{
	var comp = ~getName.(~names, ~surnames);
	var wk = Array.fill(10, {
		var tit = ~titler.(1, 3);
		if (tit.split($ ).size <=2){tit = tit + "Blues"}{tit} ;
		tit.postln
	}) ;
	~composers = ~composers.add([comp, wk])
} ;


~composers.do{|i, j|
	var comp = i[0] ;
	i[1].do{|w|
		var tempo = rrand(90, 180) ;
		var stuff = ~makeForm.(1000.rand) ;
		var mel = stuff[0] ;
		var ch = stuff[1] ;
		var key	= ~getKey.(mel);
		i.postln ; w.postln ;
		~logHarmony.(ch, key, "/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".harm") ;
		~makeMidi.(mel, tempo, "/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".mid") ;

	}
} ;

)

~bluesChords = ~readChordDef.() ;
~log = ~makeForm.(1000.rand) ;
~mel =  ~log[0] ;
~ch = ~log[1] ;
~makeMidi.(~mel, 150, "/home/andrea/musica/scores/unrealBook/test.mid") ;
~prettySeq.(~ch) ;
