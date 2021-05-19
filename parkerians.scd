(
// data written in Python
f = File("/home/andrea/musica/scores/unrealBook/varia/Omnibook/harmodict", "r") ;
~harmoDict = f.readAllString.interpret; f.close ;
f = File("/home/andrea/musica/scores/unrealBook/varia/Omnibook/meldict", "r") ;
~melDict = f.readAllString.interpret; f.close ;


// from Python
~makeChain = {|harmoDict, lenght = 8|
    var start = harmoDict.keys.choose ;
    var seq = [start] ;
	var next ;
    Array.series(lenght-1).do{
        next = harmoDict[start].choose ;
		seq = seq.add(next) ;
        start = next
	} ;
    seq
} ;


~makeMel = {|seq, off = 0|
	seq.collect{|ch,i|
		~melDict[ch].choose
		.collect{|e| [e[0], e[1]+(i*4)+off, e[2].clip(0,4-(e[1]))]}}.flatten ;
} ;

//~seq = ~makeChain.(~harmoDict, 8) ;
//~mel = ~seq.collect{|ch,i| ~melDict[ch].choose.collect{|e| [e[0], e[1]+(i*4), e[2].clip(0,4-(e[1]))]}}.flatten ;
//~makeMidi.(~mel, 150, "/home/andrea/musica/scores/unrealBook/test.mid")


~logHarmony = {|harm, form, dur, tot, key, path|
	var f = File(path, "w"), block ;
	var sharp =	["C","C#","D","D#","E","F","F#","G","G#","A","A#", "B"];
	var flat  = ["C","Db","D","Eb","E","F","Gb","G","Ab","A","Bb", "B"] ;
	var keys = ["Gb","Db","Ab","Eb","Bb","F","C","G","D","A","E","B","F#"] ;
	var sign = key.sign ;
	var txt = "" ;
	var in = ["dominant", "half-diminished", "diminished", "minor", "major", "major-sixth" ] ;
	var out = ["7", "m7b5", "0", "m", "", "6"] ;
	f.write(form.asString.replace("[", "").replace("]", "")++"\n") ;
	f.write(dur.asString.replace("[", "").replace("]", "")++"\n") ;
	f.write("key: "++keys[key+6]++"\n") ;
	f.write("no. measures: "++tot.asString++"\n\n") ;
	dur = Pseq(dur.integrate, 1).asStream ;
	block = dur.next ;
	harm.do{|i,j|
		i = i.asString.replace("_", "") ;
		in.do{|nmi, id|
			i = i.replace(nmi, out[id])
		} ;
		txt = txt++("m."+(j+1).asString+": ") ;
		txt = txt++(i++" ") ;
		txt = txt+"\n" ;
		if((j+1) == block){txt = txt++"\n"; block = dur.next} ;
	} ;
	txt.postln ;
	f.write(txt) ;
	f.close ;
} ;


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
		formSeeds[i] = rrand(0,100000)};
	frm.postln.do{|sec|
		thisThread.randSeed = formSeeds[sec] ;
		ch = ~makeChain.(~harmoDict, formDur[sec]) ;
		harm = harm ++ ch ;
		mel = mel ++ ~makeMel.(ch, off) ;
		off = off+(formDur[sec]*4) ; //4/4
	} ;
	[mel, frm, formDur, frm.collect{|i| formDur[i]}.sum, harm]
} ;

~composers = [] ;
thisThread.randSeed = 2981920 ;
5.do{
	var comp = ~getName.(~names, ~surnames);
	var wk = Array.fill(20, {~titler.(1, 3).postln}) ;
	~composers = ~composers.add([comp, wk])
} ;

~path = thisProcess.nowExecutingPath.dirname ; ["midi", "cabala"].do{|n| (~path++"/"++n++".scd").load } ;

)

~composers.do{|i, j|
	var comp = i[0] ;
	i[1].do{|w|
		var tempo = rrand(100, 200) ;
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
