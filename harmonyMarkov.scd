// markovian harmony generator
// following Rawlins, Jazzology
// melody should follow
// basic idea: start from a formalized chord
// pitch class + quality
// for each quality determine a shift and a quality
// there should be many: so random pick among available
(
// this could be a container for memoryless chord generation
// all qualities should be acquanted for
~harm = (
	// ex. 2_m7 is Dm7
	// --> m7 as ii --> V7, that is, [5, 7]
	// where 5 is an offset, and 7 dominant (G7)
	// --> m7 as i --> IVmaj7, that i [5, maj7], Gmaj7
	// --> m7 as vi --> iimin7 [5, min7], Gmin7
	// --> change quality --> [0, maj7], Dmaj7
	// --> "dominated" --> [0, 7], D7
	\min7:['5_7', '5_maj7', '5_min7', '0_maj7', '0_7', '5_11', '9_o7'],
	// quality, fourth, next step, to 7, mod, substitution as doubling
	\maj7:['5_maj7', '2_7', '2_min7', '0_min7', '0_7', '5_11', '1_min7', '10_7', '8_maj7', '3_maj7', '2_min7b5', '9_min7', '4_min7'],
	// dominant7 resolves to its implied tonic [5_maj7],
	// to a minor chord [5_min7]
	// to another 7 [5_7]
	\7: ['5_maj7', '5_min7', '5_7', '2_min7', '2_maj7', '8_min7', '9_maj7',
		'3_maj7', '3_min7', '4_maj7', '4_min7', '6_maj7', '6_min7', ],
	\min7b5:['5_7', '10_maj7'],
	\11: ['8_maj7'],
	// diminished to half step up, 3 types
	\o7: ['1_maj7', '1_min7', '1_7']

) ;

//~ch = '2_min7' ;
~nextChord = {|chord, dict|
	var base = chord.asString.split($_)[0].asInteger ;
	var quality = chord.asString.split($_)[1].asSymbol ;
	var coded = dict[quality].choose ;
	var off = coded.asString.split($_)[0].asInteger ;
	var newQuality = coded.asString.split($_)[1].asString ;
	var pc = (base + off)%12 ;
	var next = (pc.asString++"_"++newQuality).asSymbol ;
	next
} ;
//~ch = '11_min7' ;
//~nextChord.(~ch, ~harm)

~makeChordSeq = {|start, harm, lenght = 8|
	var actual = if(start.isNil){ Array.series(12).choose}{start} ;
	var seq = [actual] ;
	(lenght-1).do{
		actual = ~nextChord.(actual, harm) ;
		seq = seq.add(actual)
	} ;
	seq
} ;
~prettySeq = {|seq|
	var sq = "" ;
	var names = "C C#/Db D D#/Eb E F F#/Gb G G#/Ab A A#/Bb B".split($ ) ;
	seq.do{|ch|
		(names[ch.asString.split($_)[0].asInteger] ++
			ch.asString.split($_)[1].asString ).postln;
	}
} ;

~logHarmony = {|harm, form, dur, tot, key, path|
	var f = File(path, "w"), block ;
	var sharp =	["C","C#","D","D#","E","F","F#","G","G#","A","A#", "B"];
	var flat  = ["C","Db","D","Eb","E","F","Gb","G","Ab","A","Bb", "B"] ;
	var keys = ["Gb","Db","Ab","Eb","Bb","F","C","G","D","A","E","B","F#"] ;
	var sign = key.sign ;
	var txt = "" ;
	f.write(form.asString.replace("[", "").replace("]", "")++"\n") ;
	f.write(dur.asString.replace("[", "").replace("]", "")++"\n") ;
	f.write("key: "++keys[key+6]++"\n") ;
	f.write("no. measures: "++tot.asString++"\n\n") ;
	dur = Pseq(dur.integrate, 1).asStream ;
	block = dur.next ;
	harm.do{|i,j|
		txt = txt++("m."+(j+1).asString+": ") ;
		i.do{|c|
			txt = txt++(c++" ") ;
		};
		txt = txt+"\n" ;
		if((j+1) == block){txt = txt++"\n"; block = dur.next} ;
	} ;
	if([0, 1.neg].includes(sign)) {
		flat.do{|s, i|
			txt = txt.replace(" "++i.asString++"_", s)
		}
	}
	{
		sharp.do{|s, i|
			txt = txt.replace(" "++i.asString++"_", s)
		}
	};
	txt.postln ;
	f.write(txt) ;
	f.close ;
} ;

//~prettySeq.(~makeChordSeq.('0_maj7', ~harm))

// substitution. Point is seq are already complex
// as they do not follow tonality
// so this layer might get simply cumbersome
/*
~sub = (
	\maj7: ['9_min7', '4_min7'],
	\7: ['3_7b5', '11_min7', '3_7', '11_7', '10_7'],
	\7b5: ['9_7'],
	\7: ['4_o7'],
	\min7: ['11_o7']
) ;
*/
)
// ii-V chains: requires a special rewriting (46)
// same for contiguous dominants (62)
// tritone (100)
// cfr 106