/*
Modal pieces:
4 bars mininum for a mode
chords and melody generated from the mode

2-4 blocks for 8 bars (16 up to 32 bars)



*/

(
~path = thisProcess.nowExecutingPath.dirname ; ["melody", "midi", "measuresFromMidi", "harmony", "cabala"].do{|n| (~path++"/"++n++".scd").load } ;


// from melody.scd

~modes = [
	~dorian, ~phrygian, ~lydian, ~lydianAugmented,
	~diminished, ~wholeTone,
	~mixolydian, ~locrian] ;

~modeNames = [
	\dorian, \phrygian, \lydian, \lydianAugmented,
	\diminished, \wholeTone,
	\mixolydian, \locrian] ;

~dict = ~symbolsTo9.keys.collect{|i| [i, ~symbolsTo9[i].asSymbol]}.asArray.flop ;

~makeStruct = {
	var numMod = rrand(3,5) ;
	//var id = (..~modes.size-1).scramble[..numMod] ;
	var id = Array.fill(numMod, {~modes.size.rand}) ;
	var mds = id.collect{|i| ~modes[i]} ;
	var nms = id.collect{|i| ~modeNames[i]} ;
	var root = 12.rand ;
	var rootMode = (mds.first+root)%12 ;
	var nRoot, roots = [root] ;
	mds[1..].do{|md|
		nRoot = rootMode.choose ;
		roots = roots.add(nRoot) ;
		rootMode = (md+nRoot)%12
	} ;
	[roots, nms, mds].flop
} ;


~createChordFromMode = {|base, mode, degree, num = 4|
	var ch = [] ;
	var root = mode[degree];
	num.do{|i|
		ch = ch.add(mode[(degree+(2*i))%mode.size])
	} ;
	// base, actual root pitch, abstract chord
	[base, (root+base)%12, ((ch-root)%12).asSet.asArray.sort]
} ;


~nicepostCh = {|ch|
	ch.do{|i|
		"C Db D Eb E F Gb G Ab A Bb B".split($ )[i[1]].post ;
		~dict[0][~dict[1].indexOf(i[2].asSymbol)].post; " mode:".post;
		"C Db D Eb E F Gb G Ab A Bb B".split($ )[i[0]].post ;
		" ".post ; i.last.postln ;
	}
} ;


~logHarmony = {|ch, path|
	var f = File(path, "w") ;
	var t = "" ;
	ch.do{|i|
		t = t++
		"C Db D Eb E F Gb G Ab A Bb B".split($ )[i[1]]++
		~dict[0][~dict[1].indexOf(i[2].asSymbol)]+ " mode:"+
		"C Db D Eb E F Gb G Ab A Bb B".split($ )[i[0]] +
		i.last++"\n" ;
	} ;
	f.write(t); f.close
} ;

~paths = ["CliffordBrown_Daahoud", "EricDolphy_Les", "FreddieHubbard_DolphinDance", "FreddieHubbard_DownUnder", "FreddieHubbard_SocietyRed", "JoeHenderson_In'NOut-1", "LeeMorgan_JustOneOfThoseThings"].collect{|i| "/home/andrea/musica/scores/unrealBook/varia/fromJazzomat/"++i++"_FINAL.mid"} ;

// container for all measure melodic blocks
~all = [] ;
~all =  ~makeMeasuresFromMidis.(~paths)
~all = ~all.select{|e| e.size>2} ;

/*
(

~struct = ~makeStruct.() ;
//~createChordFromMode.(2, ~major, 4, 4)

~ch = ~struct.collect{|i| ~createChordFromMode.(i[0], i[2], i[2].size.rand, 4).add(i[1])} ;


~nicepostCh.(~ch) ;

~meass = [] ;
~cnt = 0;

// here we are stretching meas to 2
// and comprressing
~measSrc =  ~all.choose ;
~struct.do{|block|
	var mode = block[2] ;
	var root = block[0] ;
	var md = 10.collect{|i| mode+((i-3)*12)}.flatten+root ;
	var meas ;
	//var measSrc = ~all.choose ;
	2.do{|n|
		~measSrc = [~measSrc, ~all.choose].choose.postln;
		meas = ~measSrc.collect{|i| [i[0].nearestInList(md), i[1]*2+~cnt, i[2]*2]} ;
		~meass = ~meass.add(meas) ;
		~cnt = ~cnt+8 ;
	} ;
} ;
// easy rangwe
~melSrc = ~meass.flatten.collect{|e|
	var p = if(e[0]<57){e[0]+12}{e[0]} ;
	p = if(p>84){p-12}{p};
	[p, e[1], e[2]]
} ;

// clean up those damn' durs

~mel = [] ;
(~melSrc.size-1).do{|j|
	if((~melSrc[j][1]+~melSrc[j][2]) > ~melSrc[j+1][1]){
		~mel = ~mel.add([~melSrc[j][0], ~melSrc[j][1], ~melSrc[j+1][1]-~melSrc[j][1]])
	}{ ~mel = ~mel.add(~melSrc[j]) }
} ;
~mel = ~mel.add([~melSrc.last[0], ~melSrc.last[1],
	min(~struct.size*2*8-~melSrc.last[1], ~melSrc.last[2])]) ;


~makeMidi.(~mel, 180, "/home/andrea/musica/scores/unrealBook/test.mid") ;
)*/


~makeForm = {|noteFragm|
	var struct = ~makeStruct.() ;
	var ch = struct.collect{|i|
		~createChordFromMode.(i[0], i[2], i[2].size.rand, 4).add(i[1])} ;
	//~nicepostCh.(~ch) ;
	var meass = [] ;
	var cnt = 0;
	var melSrc, mel ;
	// here we are stretching meas to 2
	// and comprressing
	var measSrc =  noteFragm.choose ;
	struct.do{|block|
		var mode = block[2] ;
		var root = block[0] ;
		var md = 10.collect{|i| mode+((i-3)*12)}.flatten+root ;
		var meas ;
		//var measSrc = ~all.choose ;
		2.do{|n|
			measSrc = [measSrc, noteFragm.choose].choose.postln;
			meas = measSrc
			.collect{|i| [i[0].nearestInList(md), i[1]*2+cnt, i[2]*2]} ;
			meass = meass.add(meas) ;
			cnt = cnt+8 ;
		} ;
	} ;
	// easy range
	melSrc = meass.flatten.collect{|e|
		var p = if(e[0]<57){e[0]+12}{e[0]} ;
		p = if(p>84){p-12}{p};
		[p, e[1], e[2]]
	} ;
	// clean up those damn' durs
	mel = [] ;
	(melSrc.size-1).do{|j|
		if((melSrc[j][1]+melSrc[j][2]) > melSrc[j+1][1]){
			mel = mel.add([melSrc[j][0], melSrc[j][1], melSrc[j+1][1]-melSrc[j][1]])
		}{ mel = mel.add(melSrc[j]) }
	} ;
	mel = mel.add([melSrc.last[0], melSrc.last[1],
		min(struct.size*2*8-melSrc.last[1], melSrc.last[2])]) ;
	[mel, ch]
} ;

)

(
~composers = [] ;
thisThread.randSeed = 1971 ;
10.do{
	var comp = ~getName.(~names, ~surnames);
	var wk = Array.fill(10, {~titler.(1, 3).postln}) ;
	~composers = ~composers.add([comp, wk])
} ;



~composers.do{|i, j|
	var comp = i[0] ;
	i[1].do{|w|
		var tempo = rrand(150, 210) ;
		var stuff = ~makeForm.(~all) ;
		var mel = stuff[0] ;
		var ch = stuff[1] ;
		var key	= ~getKey.(mel);
		i.postln ; w.postln ;
		~logHarmony.(ch, "/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".harm") ;
		~makeMidi.(mel, tempo, "/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".mid") ;

	}
} ;
)