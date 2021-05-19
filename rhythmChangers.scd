(
// Rhythm changes, original
~a0 = [
	[10, \M7],[7, \7],
	[0, \m7],[5, \7],
	[10, \M7],[7, \7],
	[0, \m7],[5, \7],
	[5, \m7], [10, \7],
	[3, \M7],[8, \7],
	[2, \m7], [7, \7],
	[0, \m7],[5, \7]
];


~b = [
	[2, \7],[2, \7],
	[2, \7],[2, \7],
	[7, \7],[7, \7],
	[7, \7],[7, \7],
	//
	[0, \7],[0, \7],
	[0, \7],[0, \7],
	[5, \7],[5, \7],
	[5, \7],[5, \7],
] ;


~a1 = [
	[10, \M7],[7, \7],
	[0, \m7],[5, \7],
	[10, \M7],[7, \7],
	[0, \m7],[5, \7],
	[5, \m7], [10, \7],
	[3, \M7],[8, \7],
	[0, \m7], [5, \7],
	[10, \M7],[10, \M7]
];

// we keep the harmony in the score siglato
// but change quality to minorized chords
// and omit second half bars chords
// so harmony is taken into account but not indicated in the score

// expanded
// first chords to minor
// added 9 and dim
~a0 = [
	[10, \m9],[7, \m9],
	[0, \m9],[5, \9],
	[10, \m9],[7, \0],
	[0, \m9],[5, \9],
	[5, \m9], [10, \9],
	[3, \M9],[8, \9],
	[2, \m9], [7, \9],
	[0, \m9],[5, \9]
];

// sort of Coltrane changes, by third
~b = [
	[2, \mM9],[2, \7],
	[11, \mM9],[11, \7],
	[7, \mM9],[7, \7],
	[4, \mM9],[4, \7],
	//
	[0, \11],[0, '7b5'],
	[9, \11],[9, '7b5'],
	[6, \11],[6, '7b5'],
	[5, \11],[5, '7b5'],
] ;


~a1 = [
	[10, \m9],[7, \m9],
	[0, \m9],[5, \9],
	[10, \m9],[7, \0],
	[0, \m9],[5, \9],
	[5, \m9], [10, \9],
	[3, \M9],[8, \9],
	[0, \m9], [5, \9],
	[10, \M9],[10, \M9]
];


~path = thisProcess.nowExecutingPath.dirname ; ["harmony", "melody", "midi", "cabala", "measuresFromMidi"].do{|n| (~path++"/"++n++".scd").load } ;

~extractChord = {|chordArr|
	(~symbolsTo9[chordArr[1]]+chordArr[0])%12
} ;

~transpSeq = {|seq, transp = 0|
	seq.collect{|i| [(i[0]+transp)%12, i[1]]}
} ;

//~transpSeq.(~a0, 2)

~makeModes = {|transp = 0|
	var md = [] ;
	~transpSeq.(~a0, transp).clump(2).collect{|i|
		(~extractChord.(i[0])++~extractChord.(i[1]))
	.asSet.asArray.sort
	}
	++
	~transpSeq.(~b, transp).clump(2).collect{|i|
		(~extractChord.(i[0])++~extractChord.(i[1]))
	.asSet.asArray.sort
	}
	++
	~transpSeq.(~a1, transp).clump(2).collect{|i|
		(~extractChord.(i[0])++~extractChord.(i[1]))
	.asSet.asArray.sort
	}
} ;

~processModes = {|transp = 0|
	~makeModes.(transp).collect{|m|
		Array.series(6, 36, 12).collect{|i|m+i}.flatten
	}
} ;


//~makeModes.()[0]
//~modes = ~processModes.() ;

~modalize = {|mel, modes|
	mel.collect{|e|
		var p = e[0] ;
		var att = e[1] ;
		var d = e[2] ;
		var md = modes[(att/4).trunc.asInteger] ;
		p = p.nearestInList(md) ;
		[p, att, d]
	}
} ;

// so here we get the melodic forms
~paths = ["BenWebster_MyIdeal", "BenWebster_NightAndDay", "CliffordBrown_Sandu", "SonnyRollins_Playin'InTheYard-2", "SonnyRollins_TheEverywhereCalypso-1"].collect{|i| "/home/andrea/musica/scores/unrealBook/varia/fromJazzomat/"++i++"_FINAL.mid"} ;

// container for all measure melodic blocks
~all = [] ;
~all =  ~makeMeasuresFromMidis.(~paths) ;
~all = ~all.select{|e| e.size>2} ;

//~all.choose


~makeMel = {|fragms, meas = 8, mul = 1|
	var mel = []  ;
	var sel = [fragms.choose] ;
	meas.do{|i|
		mel = mel.add(sel.choose.collect{|e| [e[0],(e[1]+(4*i)*mul), e[2]*mul]}) ;
		sel = sel.add(fragms.choose) ;
	} ;
	mel ;
} ;

~offMel = {|mel, offMeas = 0|
	mel.collect{|e| [e[0], e[1]+(offMeas*4), e[2]]}
} ;

~durClean = {|mel|
	var nMel = [] ;
	(mel.size-1).do{|j|
		if((mel[j][1]+mel[j][2]) > mel[j+1][1]){
			nMel = nMel.add([mel[j][0], mel[j][1], mel[j+1][1]-mel[j][1]])
		}{ nMel = nMel.add(mel[j]) }
	} ;
	nMel = nMel.add([mel.last[0], mel.last[1],
		min(32*4-mel.last[1], mel.last[2])]) ;
	nMel
} ;

~ranger = {|mel|
	mel.collect{|e|
		var p = if(e[0]<57){e[0]+12}{e[0]} ;
		p = if(p>84){p-12}{p};
		[p, e[1], e[2]]
	} ;
} ;

// supabasic
~logger = {|path, tone, key|
	var f = File(path, "w") ;
	var txt = "tonality: T --> transp: K".replace("T", tone).replace("K", key) ;
	f.write(txt); f.close
} ;

//~amel = ~makeMel.(~all, 4,2).flatten ;
//~bmel = ~makeMel.(~all, 4,2).flatten ;
// (
// ~amel = ~makeMel.(~all, 8).flatten ;
// ~bmel = ~makeMel.(~all, 8).flatten ;
//
// // we use da capo
// ~mel = ~amel++~offMel.(~bmel,8)++~offMel.(~amel, 16) ;
// ~mel = ~durClean.(~mel) ;
// ~transpose = 12.rand ;
// //~transpose = 10 ;
// ~modes = ~processModes.(~transpose) ;
// ~mel = ~ranger.(~mel) ;
// ~mel = ~modalize.(~mel, ~modes) ;
// // we need to:
// // - get the correct key automatically
// // - log transposition
// ~key = ([0, -5, 2, -3, 4, -1, -6, 1, -4, 3, -2, 5]-2)[~transpose] ;
// ~tone = "Bb B C Db D Eb E F Gb G Ab A".split($ )[~transpose] ;
// [~tone, ~transpose].postln ;
// ~makeMidi.(~mel, 150, "/home/andrea/musica/scores/unrealBook/test.mid", cKey:~key) ;
// )

//~logger.("/home/andrea/musica/scores/unrealBook/test.harm", [1,"ab"])

~makeForm = {|transpose|
	var modes ;
	var amel = ~makeMel.(~all, 8).flatten ;
	var bmel = ~makeMel.(~all, 8).flatten ;
	// we use da capo
	var mel = amel++~offMel.(bmel,8)++~offMel.(amel, 16) ;
	mel = ~durClean.(mel) ;
	//~transpose = 12.rand ;
	//~transpose = 10 ;
	modes = ~processModes.(transpose) ;
	mel = ~ranger.(mel) ;
	mel = ~modalize.(mel, modes) ;
	mel ;
} ;

)

(
~composers = [] ;
thisThread.randSeed = 1968 ;
10.do{
	var comp = ~getName.(~names, ~surnames);
	var wk = Array.fill(10, {~titler.(1, 3).postln}) ;
	~composers = ~composers.add([comp, wk])
} ;


~composers.do{|i, j|
	var comp = i[0] ;
	i[1].do{|w|
		var transpose = [2, 4, 5, 6, 7, 9, 10].choose ;
		var tempo = rrand(110, 180) ;
		var mel = ~makeForm.(transpose) ;
		var key = ([0, -5, 2, -3, 4, -1, -6, 1, -4, 3, -2, 5]-2)[transpose] ;
		var tone = "Bb B C Db D Eb E F Gb G Ab A".split($ )[transpose] ;
		~logger.("/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".harm", tone, key+2) ;
		~makeMidi.(mel, tempo, "/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".mid", cKey: key) ;
	}
} ;
)
