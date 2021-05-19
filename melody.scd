// Melodic generators

// the melodic generators are abstract, that is,
// they all need a rhy in csound style
/*
note attack dur
where:
  note: midinote
  attack and dur: 1.0 is 1 quarter
*/
(
// Generators map events on pitches

// pitches randomly selected in a range
~randMel = {|rhy, min = 60, max = 84, seed|
	var mel = [], next ;
	rhy.collect{|e,i|
		[rrand(min, max), e[1], e[2]]
	} ;
} ;
//~mel = ~randMel.(~rhy) ;

// brownian motion in range
~brownMel = {|rhy, start, min, max, range, seed|
	var mel = [], next ;
	if (seed.notNil){thisThread.randSeed = seed} ;
	rhy.do{|e,i|
		next = start + (range.rand*[-1,1].choose) ;
		if (next > max) {next = max - (next-max) } ;
		if (next < min) {next = min + (min-next) } ;
		mel = mel.add([next, e[1], e[2]]) ;
		start = next
	} ;
	mel
} ;
//~mel = ~brownMel.(~rhy, 72, 60, 84, 5) ;

~major = [0,2,4,5,7,9,11];
~minor = [0,2,3,5,7,8,10];
~melodicMinor = [0,2,3,5,7,9,11] ;
~harmonicMinor = [0,2,3,5,7,8,11] ;
~dorian = [0,2,3,5,7,9,10];
~phrygian = [0,1,3,5,7,8,10];
~lydian = [0,2,4,6,7,9,11];
~lydianAugmented = [0,2,4,6,7,9,10] ;
~diminished = [0,2,3,5,6,8,9,11] ;
~halfWholeDimished = [0,1,3,4,6,7,9,10] ;
~wholeTone = [0,2,4,6,8,10] ;
~mixolydian = [0,2,4,5,7,9,10];
~locrian = [0,1,3,5,6,8,10];
~superlocrian = [0,1,3,4,6,8,10] ;
~bluesMinor = [0,3,5,6,7,10] ;
~bebopDominant = [0,2,4,5,7,9,10,11];
// pitches randomly selected from a normalized mode, then transposed

~randModeMel = {|rhy, mode, octaveNum = 1, transp  = 60, seed|
	var md ;
	if (seed.notNil){thisThread.randSeed = seed} ;
	md = octaveNum.collect{|i| mode+(i*12)}.flatten ;
	rhy.collect{|e,i|
		[md.choose+transp, e[1], e[2]]
	} ;
} ;
//~mel = ~randModeMel.(~rhy, ~major, 2, 60)
// ref is the mode root
~brownModeMel = {|rhy, mode, ref = 0, range = 3, min = 60, max = 84, seed|
	var md, mel, start, st, next ;
	if (seed.notNil){thisThread.randSeed = seed} ;
	md = 10.collect{|i| mode+(i*12)}.flatten+ref ;
	mel = [] ;
	start = md.select{|i| (i >= min).and(i <= max)}.choose ;
	st = start ;
	rhy.do{|e,i|
		next = md[md.indexOf(start)+(range.rand*[-1,1].choose)] ;
		// reset to root
		if (next > max) {next = st } ;
		if (next < min) {next = st } ;
		mel = mel.add([next, e[1], e[2]]) ;
		start = next
	} ;
	mel
} ;


~fromMarkovHarmony = {|rhy, harmony, range = 3, min = 60, max = 81, seed, res = 4|
	var modes = (
		\maj7: [~major, ~lydian, ~lydianAugmented],
		\min7: [~minor, ~phrygian, ~dorian],
		\7: [~mixolydian, ~lydian, ~superlocrian],
		\min7b5: [~locrian],
		\11: [~minor, ~phrygian, ~dorian],
		\o7: [~diminished]
	) ;
	var mel = [], md, start ;
	if (seed.notNil){thisThread.randSeed = seed} ;
	start = rrand(min, max);
	rhy.do{|ev, i|
		// get harmony for note
		var harm = harmony[(ev[1]/res).asInteger].asString ;
		var ref = harm.split($_)[0].asInteger ;
		var quality = harm.split($_)[1].asSymbol;
		var mode = modes[quality].choose;
		var nmode ;
		var p ;
		md = 10.collect{|i| mode+(i*12)}.flatten+ref ;
		if (((ev[1]+ev[2])/res).asInteger <= (((ev[1]+ev[2])/res).asInteger+1)){
			p = rrand(start-range, start+range).nearestInList(md)
		}{
			var harm2 = harmony[(rhy[i+1][1]/res).asInteger].asString ;
			var ref2 = harm2.split($_)[0].asInteger ;
			var quality2 = harm2.split($_)[1].asSymbol;
			var mode2 = modes[quality2].choose;
			var md2 = 10.collect{|i| mode2+(i*12)}.flatten+ref ;
			var inter = md.asSet.sect(md2).asArray.sort ;
			p = rrand(start-range, start+range).nearestInList(inter)
		} ;
		if (p > max){ p = p-12 } ;
		if (p < min){ p = p+12 } ;
		mel = mel.add([p, ev[1], ev[2]]) ;
		start = p
		// get mode
		// get pitch brown style
	} ;
	mel
} ;



~fromBluesHarmony = {|rhy, harmony, range = 3, min = 60, max = 81, seed = 0|
	var modes = (
//		\maj7: [~major, ~lydian, ~lydianAugmented],
		\min7: [~bluesMinor, ~dorian],
		\minb9: [~bluesMinor, ~phrygian],
		\7: [~bebopDominant, ~bluesMinor],
//		\min7b5: [~locrian],
//		\11: [~minor, ~phrygian, ~dorian],
		\o7: [~diminished, ~bluesMinor],
		\maj7:[~bluesMinor, ~dorian],
		\min7b5:[~bluesMinor]
	) ;
	var mel = [], md, start, cnt = 16 ;
	thisThread.randSeed = seed ;
	start = rrand(min, max);
	rhy.do{|ev, i|
		// get harmony for note
		// assumes double harmony for measure
		var harm = harmony[(ev[1]/2).asInteger].asString ;
		var ref = harm.split($_)[0].asInteger ;
		var quality = harm.split($_)[1].asSymbol;
		var mode ;
		var nmode ;
		var p ;
		if(ev[1] >= cnt){
			thisThread.randSeed = seed;
			start = rrand(min, max);
			if(cnt == 16){start = start+5} ;
			cnt = cnt + 16 } ;
		mode = modes[quality].choose;
		//if (i%inverter == 0){sign = sign.neg} ;
		md = 10.collect{|i| mode+(i*12)}.flatten+ref ;
		if (((ev[1]+ev[2])/2).asInteger <= (((ev[1]+ev[2])/2).asInteger+1)){
			p = rrand(start-range, start+range).nearestInList(md)
		}{
			var harm2 = harmony[(rhy[i+1][1]/2).asInteger].asString ;
			var ref2 = harm2.split($_)[0].asInteger ;
			var quality2 = harm2.split($_)[1].asSymbol;
			var mode2 = modes[quality2].choose;
			var md2 = 10.collect{|i| mode2+(i*12)}.flatten+ref ;
			var inter = md.asSet.sect(md2).asArray.sort ;
			p = rrand(start-range, start+range).nearestInList(inter)
		} ;
		if (p > max){ p = p-12 } ;
		if (p < min){ p = p+12 } ;
		mel = mel.add([p, ev[1], ev[2]]) ;
		start = p
		// get mode
		// get pitch brown style
	} ;
	mel
} ;
)
/*
(
t = ~timeTape.makeTape(8, 2, 1, 3) ;
d  =~timeTape.delete(t, 0.2) ;
~rhy = ~timeTape.rhyConv(d) ;
~ch = ~makeChordSeq.('0_maj7', ~harm) ;
~mel = ~fromMarkovHarmony.(~rhy, ~ch) ;
~makeMidi.(~mel, 150, "/home/andrea/musica/scores/unrealBook/test.mid") ;
~prettySeq.(~ch)
)
*/