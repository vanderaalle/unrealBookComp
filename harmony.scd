// This a harmonizator that starts from melody and tries to
// match the notes in the melody by finding a chord
// it does not assume any key
(
// see Haruspex list
// we skip 9, 11 and 13
~symbolsTo7 = () ;
"C	{0,4,7}
Cm	{0,3,7}
C+	{0, 4, 8}
Co	{0, 3, 6}
C7	{0, 4, 7, 10}
CM7	{0, 4, 7, 11}
CmM7	{0, 3, 7, 11}
Cm7	{0, 3, 7, 10}
C+M7	{0, 4, 8, 11}
C+7	{0, 4, 8, 10}
C0	{0, 3, 6, 10}
Co7	{0, 3, 6, 9}
C7b5	{0, 4, 6, 10}
Csus4	{0, 5, 7}
Csus2	{0, 2, 7}
Cadd2	{0, 2, 4, 7}
Cadd4	{0, 4, 5, 7}
Cmadd2	{0, 2, 3, 7}
Cmadd4	{0, 3, 5, 7}"
		.split($\n)
		.collect{|i| i.split($\t)}.collect{|i|
			[
				i[0].split($\ ).collect{|j| j.replace("C", "").asSymbol},
				i[1].replace("{", "[").replace("}", "]").interpret

			]
		}.collect{|ch|
			ch[0].do{|key|
				~symbolsTo7[key] = ch[1]
			}
		};

// up to 9
~symbolsTo9 = () ;
"C	{0,4,7}
Cm	{0,3,7}
C+	{0, 4, 8}
Co	{0, 3, 6}
C7	{0, 4, 7, 10}
CM7	{0, 4, 7, 11}
CmM7	{0, 3, 7, 11}
Cm7	{0, 3, 7, 10}
C+M7	{0, 4, 8, 11}
C+7	{0, 4, 8, 10}
C0	{0, 3, 6, 10}
Co7	{0, 3, 6, 9}
C7b5	{0, 4, 6, 10}
Csus4	{0, 5, 7}
Csus2	{0, 2, 7}
Cadd2	{0, 2, 4, 7}
Cadd4	{0, 4, 5, 7}
Cmadd2	{0, 2, 3, 7}
Cmadd4	{0, 3, 5, 7}
CM9	{0, 4, 7, 11, 14}
C9	{0, 4, 7, 10, 14}
CmM9	{0, 3, 7, 11, 14}
Cm9	{0, 3, 7, 10, 14}
C+M9	{0, 4, 8, 11, 14}
C+9	{0, 4, 8, 10, 14}
CØ9	{0, 3, 6, 10, 14}
CØb9	{0, 3, 6, 10, 13}
Co9	{0, 3, 6, 9, 14}
Cob9	{0, 3, 6, 9, 13}
C11	{0, 4, 7, 10, 14, 17}"
		.split($\n).postln
		.collect{|i| i.split($\t)}.collect{|i|
			[
				i[0].split($\ ).collect{|j| j.replace("C", "").asSymbol},
				i[1].replace("{", "[").replace("}", "]").interpret

			].postln
		}.collect{|ch|
			ch[0].do{|key|
				~symbolsTo9[key] = ch[1]
			}
		};


~extractFormsFromMeasure = {|mel,meas|
	// shitty dec is not posted so we round
	var stru = mel.select{|i,j|
		(i[1].round(0.1)>=(4.0*meas))
		&&
		(i[1].round(0.1) < (4.0*(meas+1)))
	}.collect{|i| i[0]} ;
	var conc = stru.dup(stru.size).flat ;
	var forms = [] ;
	stru.size.do{|i|
		var co = conc[i..(i+stru.size-1)] ;
		var base = (co[0]%12);
		var com = (co%12) ;
		var form = ((com)-(com[0])) ;
		form = form.collect{|i| if(i<0){i+12}{i}}.asSet.asArray.sort ;
		forms = forms.add([base, form])
	}	;
	forms
} ;


// rewritten as a recursive func
~chordMatch = {|forms, symbols, matched, cnt = 0|
	var fm, ch ;
	var dict = () ;
	if (matched.isNil){matched = forms.size} ;
	forms.do{|ann|
		var form = ann[1] ;
		var p ;
		p = symbols.select{|i|
		(i.asSet&form.asSet).size == matched
		} ;
		fm = ann ;
		ch = p;
		dict[fm.asSymbol] = ch.keys.asArray ;
	} ;
	if((ch.size == 0)&&(cnt < 100)){
		//"AGAIN".postln;
		cnt = cnt+1;  ~chordMatch.(forms, symbols, matched-1, cnt)}
	{
		fm ;
		ch;
		dict
	} ;

} ;

// priority for choosing chord, max to min
~priority =['', 'm', '7', 'm7', 'M7', '+', 'mM7', '+7', '+M7', '7b5','o', 'o7', '0', 'sus4', 'sus2', 'add4', 'add2', 'madd4', 'madd2' ] ;
~priority2 =['', 'm', 'M9', '9', 'm9', 'mM9', '7', 'm7', 'M7', '+', 'mM7', '+7', '+M7', '7b5','o', 'o7', '0', 'sus4', 'sus2', 'add4', 'add2', 'madd4', 'madd2', '+M9', '+9', 'Ø9', 'Øb9', 'o9', 'ob9'] ;


~creditAssign = {|dict, priority|
	var cr = [], best ;
	dict = dict.collect{|i|
		var id = i.collect{|ch| priority.indexOf(ch)}.sort.first ;
		id
	} ;
	best = dict.values.asArray.sort.first ;
	dict.keys.asArray.do{|i|
		if (dict[i] == best){cr = cr.add(
			[i.asString.interpret[0], priority[best]]
		)}
	} ;
	cr.collect{|k|
		(k[0].midinote.reverse[1..].reverse.toUpper++k[1].asString)
		.replace(" ", "")}
} ;

~harmonizeMel = {|mel, measures, symbols, priority|
	var harm = [] ;
	var forms, k, c ;
	measures.do{|i|
		forms = ~extractFormsFromMeasure.(mel, i) ;
		k = ~chordMatch.(forms, symbols) ;
		c  = ~creditAssign.(k, priority) ;
		harm = harm.add(c)
	} ;
	harm.postln;
} ;

~nicePost = {|harm|
	harm.do{|i,j|
		("meas."+(j+1).asString+": ").post ;
		i.do{|c| c.post++" ".post} ; "".postln
	}
} ;

~logHarmony = {|harm, form, dur, tot, key, path|
	var f = File(path, "w"), block ;
	var sharp = ["C#","D#","F#","G#","A#"] ;
	var flat  = ["Db","Eb","Gb","Ab","Bb"] ;
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
	case
	{ key == 0 } {txt = txt}
	{ sign == 1.neg} {sharp.do{|s|
		txt = txt.replace(s, flat[sharp.indexOf(s)])
	}}
	{ sign == 1 } {txt = txt};
	txt.postln ;
	f.write(txt) ;
	f.close ;
} ;
)

//~nicePost.(~harmonizeMel.(~mel, 16, ~symbolsTo9, ~priority2))

