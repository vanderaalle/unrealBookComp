// bebopper was the classic drummer
// bebopper is aimed at non legato style

(
// modifying good ole drummer to host just a 1 voice rhythm, EASY
~bebopper = () ;

// setting tempo, meter, density
~bebopper.setEnv = {|me|
	me.tempo = rrand(110, 160) ;
	me.meterBase = [4, 8].choose ;
	me.meterNum = rrand(2, 10) ;
	me.density = 3/4  ; // density for subdivions
	me.dur = 0.1 ; // duration for evs
	me.struct = Array.fill(1, {[]}) ; // general container for 1 voice struct
	me.voices = Array.fill(1, {[]}) ; // container for routines
} ;

~bebopper.density = 3/4 ; // hard coded

~bebopper.setMeter = {|me, frac|
	me.meterNum = frac[0] ;
	me.meterBase = frac[1] ;
} ;


// here we create the data structure to lily and playback
~bebopper.fillVoice = {|me, which = 0, prob|
	var quarters, eightRest ;
	var voice = [] ;
	quarters = (me.meterNum*(8/me.meterBase)).div(2) ;// quarters
	eightRest = (me.meterNum*(8/me.meterBase)) - (quarters*2) ;
	quarters.do {|ev|
		// this is crucial
		var sub = [1,2,3,4].wchoose(prob) ;
		var evArr = [] ;
		sub.do{|i|
			if (me.density.coin){
				evArr = evArr.add([\n, 1/sub])
				}{ evArr = evArr.add([\r, 1/sub]) }
		} ;
		voice = voice.add(evArr)
	};

	if (eightRest > 0) {
	eightRest.asInteger.do {|ev|
		var evArr = [] ;
		if (me.density.coin){
			evArr = evArr.add([\n, 1/2])
			}{ evArr = evArr.add([\r, 1/2]) };
		voice = voice.add(evArr)
		}
	} ;
	me.struct[which] = voice;
} ;

// here we create the data structure and playback
~bebopper.fill = {|me, seed, prob|
	if (prob.isNil) {prob = [0.35,0.45,0.1, 0.1]} ;
	if (seed.notNil){thisThread.randSeed = seed} ;
	1.do{|i| me.fillVoice(i, prob)}
} ;

~bebopper.rate = 1 ;

~bebopper.runVoice = {|me, which = 0|
	var ev ;
	me.voices[which] = {inf.do{|i|
		ev = me.struct[which].flatten[i%me.struct[which].flatten.size] ;
		if (ev[0] == \n){
			Synth(\player, [\buf,
				[~crash, ~snare, ~kick][which].choose, \out, which, \amp, -10.dbamp, \rate, me.rate])
		} ;
		(ev[1]*(60/me.tempo)).wait ;
	}}.fork
};

~bebopper.run = {|me|
	// protection
	me.voices.do{|i|
		if (i.notNil) { i.stop }
	} ;
	1.do{|i|
		me.runVoice(i)
	}

} ;

~bebopper.exit = {|me|
	me.voices.do{|r| r.stop}
} ;

~bebopper.setEnv ;
//~bebopper.fillVoice; ~bebopper.runVoice
//~bebopper.fill ; // you just run and refill

// we need a generic format for rhythm,
// independently from rhythm generator
// and a melody format, independenty from melody generator
// so that we can define siglato

// csound style
/*
note attack dur
where:
  note: midinote
  attack and dur: 1.0 is 1 quarter
*/

// here we have the right format
~bebopRhyConv = {|struct, measOffset = 0|
	var rhy = [] ;
	var t = measOffset*4 ;
	struct.flatten.do{|e, i|
		if(e[0] == \n){
			rhy = rhy.add([\n, t, e[1]])
		} ;
		t = t+e[1]
	} ;
	rhy
} ;

~bebopper.makeMeasures = {|me, measures, meter, tempo, densities, seeds, prob|
	var stru = [] ;
	measures.do{|i|
		//tempo = tempos[i%tempos.size] ;
		me.tempo = tempo ;
		//meter = meters[i%meters.size] ;
		me.setMeter(meter) ;
		me.density = densities[i%densities.size] ;
		me.fill(seeds[i%seeds.size], prob) ;
		//me.struct.postln ;
		stru = stru++me.struct.flatten
	} ;
	stru
} ;


/*
~meters = [[4,4]]; ~tempos = [140]; ~densities = [6/7]; ~seeds = [100, 101, 102, 103]; ~prob = [0.3,0.5,0.1, 0.1] ;

a = ~bebopper.makeMeasures(8, ~meters, ~tempos, ~densities, ~seeds, ~prob)
b = ~bebopper.makeMeasures(8, ~meters, ~tempos, ~densities, ~seeds, ~prob)
c = a++b ;
~rhy = ~bebopRhyConv.(c) ;
~mel = ~brownMel.(~rhy, 72, 60, 84, 7)

// vel
a = ~bebopper.makeMeasures(8, ~meters, ~tempos, ~densities, ~seeds, ~prob) ;
~rhy = ~bebopRhyConv.(a) ;
~mel1 = ~mel = ~brownMel.(~rhy, 72, 60, 84, 7, seed:1) ;
b = ~bebopper.makeMeasures(8, ~meters, ~tempos, ~densities, ~seeds, ~prob) ;
~rhy = ~bebopRhyConv.(b, 8) ;
// same rhy same mel
~mel2 = ~brownMel.(~rhy, 72, 60, 84, 7, seed:1) ;
~mel = ~mel1++~mel2 ;
~makeMidi.(~mel, ~tempos[0], "/home/andrea/musica/scores/unrealBook/sandbox/test.mid") ;

// Golden Age
// AAB, AABA, ABAC, ABA, ABAb

//
// // so, here we are filling, maybe playing back not necessary
// (
// // we stick to 1 meter and 1 tempo
// ~meters = [[4,4]]; ~tempos = [140]; ~densities = [5/7]; ~seeds = [1914, 1974, 1959]; ~prob = [0.35,0.45,0.1, 0.1] ;
// ~struct = [] ; // generic collector
// // rather than a routine we need a cycle
// //~dr = Routine{
// 8.do{|i|
// 	~tempo = ~tempos[i%~tempos.size] ;
// 	~bebopper.tempo = ~tempo.postln ;
// 	~meter = ~meters[i%~meters.size] ;
// 	~bebopper.setMeter(~meter.postln) ;
// 	~bebopper.density = ~densities[i%~densities.size] ;
// 	//~bebopper.dur = 0.1;
// 	~bebopper.fill(~seeds[i%~seeds.size], ~prob) ; // you just run and refill
// 	~bebopper.struct.postln ;
// 	~struct = ~struct++~bebopper.struct.flatten
// }
// //} ;
// )
*/

~makeForm = {|name, title, tempo|
	var meter = [4,4] ;
	var struct = [] ;
	var mel = [] ;
	var prob =  [0.45,0.45,0.05, 0.05] ;
	var b, rhy, off = 0 ;
	var pitches = Array.series(12,  64, 1).scramble ;
	var form = [\AAB, \AABA, \ABAC, \ABA].choose ;
	var frm = [] ;
	var formDur, formDens, formSeeds ;
	formDur = () ;
	[\A, \B, \C].do{|i| formDur[i] = [4, 6, 8, 12].wchoose([0.3, 0.05, 0.6, 0.05])} ;
	formDens = () ;
	[\A, \B, \C].do{|i| formDens[i]= [4,5,6].wchoose([0.45, 0.45, 0.1])/7} ;
	formSeeds = () ;
	[\A, \B, \C].do{|i|
		formSeeds[i] = Array.fill([2,3,4,6].choose, {rrand(0,1000)})};
	form.asString.do{|i| frm = frm.add(i.asString.asSymbol)};
	frm.postln.do{|sec|
		var se = formSeeds[sec] ;
		var density = formDens[sec] ;
		//sec.postln; formDur[sec].postln ;
		b = ~bebopper.makeMeasures(formDur[sec], meter, tempo, [density], se, prob) ;
		rhy = ~bebopRhyConv.(b, off) ;
		mel = mel++~brownMel.(rhy, pitches[frm.indexOf(sec)], 60, 84, 7, seed:se[0]) ;
		off = off+formDur[sec] ;
	} ;
	thisThread.randSeed = rrand(0, 100000) ;
	[mel, frm, formDur, frm.collect{|i| formDur[i]}.sum]
} ;
)


//~struct.flatten.do{|i| i.postln}
//~rhy = ~bebopRhyConv.(~struct) ;

// here we load melody and midi

//~mel = ~randModeMel.(~rhy, ~locrian, 1, 60)
// rhy, mode, ref = 0, range = 3
//~mel = ~brownModeMel.(~rhy, ~locrian, 0, 5)
