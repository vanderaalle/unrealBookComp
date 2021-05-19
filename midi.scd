// midi file generator
// this one should be abstract, that is
// it is generally capable of converting a mel

~getKey = {|mel|
	var score = 0, newScore, scale, in, out, pitchClass = 0 ;
	var major = [0,2,4,5,7,9,11] ;
	var m = mel.collect{|i| i[0]}%12 ;
	12.do{|p|
		scale = ((major+p)%12).sort ;
		in = 0 ; out = 0 ;
		m.asSet.do{|i|
			//i.post; ":".post;
			if(scale.includes(i)){
				in = in+(m.occurrencesOf(i))
			}{
				out = out+(m.occurrencesOf(i)) ;
			};
			newScore =  in - out ;
			if (newScore > score) {score = newScore; pitchClass = i}
		};
	} ;
	//[pitchClass, newScore].postln ;
	[0, -5, 2, -3, 4, -1, -6, 1, -4, 3, -2, 5][pitchClass]
} ;


~makeMidi = {|mel, bpm, path, ckeyOn = true, cKey| // we need to keep track of meter
	var m = SimpleMIDIFile(path); // create empty file
	var t = 0 ;
	m.init1(2, bpm, "4/4" );
	mel.do{|e, i|
		m.addNote(e[0], 127, e[1]*m.division, e[2]*m.division, 127, track:1, channel:1) ;
	} ;
	if(ckeyOn){
		cKey = if (cKey.isNil){~getKey.(mel).postln}{cKey};
		// only first item of array is relevant; 0 is, range -n to n
		m.addMetaEvent([1, 0, \keySignature, [cKey,0] ] ) ;
	} ;
	m.write; // write down
} ;
