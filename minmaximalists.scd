
~transposer = {|ser, num|
	ser
	.collect{|p| if(p!=\r){p+num}{\r}}
	.collect{|p| if(p!=\r){
		if(p > 81){p = p-12}{p};
		if(p < 59){p = p+12}{p}
	}{\r}};
} ;

~makeBlock = {|numq = 64, top = 70, res = 0.3333333|
	var num, numRest, rest, ser, rh, numTransp, transp ;
	var mel, att, dur, tr ;
	num = rrand(3, 9) ;
	numRest = rrand(1, 3) ;
	rest = Array.fill(numRest, {\r}) ;
	// range = blue sevent
	ser = ((60..top).scramble[..num-1]++rest).scramble +rrand(0, 12);
	rh = Array.series(num+numRest, 1, res).asInteger.scramble ;
	numTransp = rrand(3, 6) ;
	transp = Pseq(Array.fill(numTransp, {rrand(1, 6)}), inf).asStream ;

	mel = [] ;
	att = 0 ;
	dur = 0 ; // 4q*8m = 32
	tr = ser.copy ;
	while {dur <= numq} {
		tr.do{|p, i|
			mel = mel.add([p, att, rh[i]/2]) ;
			att = att+ (rh[i]/2)
		};
		dur = dur + (rh.sum/2) ;
		tr = ~transposer.(tr, transp.next) ;
	} ;

	// cleanup
	mel = mel.select{|e| e[0] != \r}
	.select{|e| e[1] < numq }.collect{|e|
		if(e[1]+e[2] > numq){e[2] = numq-e[1]} ;
		[e[0], e[1], e[2]]
	} ;
	mel
//~mel.last
} ;

//~mel = ~makeBlock.(32, 65)


~path = thisProcess.nowExecutingPath.dirname ; ["melody", "midi", "cabala", "harmony"].do{|n| (~path++"/"++n++".scd").load } ;

//~makeMidi.(~mel, 180, "/home/andrea/musica/scores/unrealBook/test.mid", cKey:0) ;
//~nicePost.(~harmonizeMel.(~mel, 16, ~symbolsTo9, ~priority2))

// rewritten from nicepost, easy
~logHarmony = {|harm, path|
	var f = File(path, "w") ;
	var txt = "" ;
	harm.do{|i,j|
		txt = txt++("meas."+(j+1).asString+": ") ;
		i.do{|c|
			txt = txt+c++" "} ;
		txt = txt ++"\n"
	} ;
	f.write(txt) ;
	f.close ;
} ;

(
~composers = [] ;
thisThread.randSeed = 1969 ;
5.do{
	var comp = ~getName.(~names, ~surnames);
	var wk = Array.fill(10, {~titler.(1, 3).postln}) ;
	~composers = ~composers.add([comp, wk])
} ;
~composers.do{|i, j|
	var comp = i[0] ;
	i[1].do{|w|
		var harm, mel ;
		var tempo = rrand(120, 180) ;
		var durA = [32, 64].choose ;
		var melA = ~makeBlock.(durA, 70) ;
		var melB = ~makeBlock.(32, rrand(64, 67)) ;
		var melA1 = melA.select{|e| e[1]<32};
		melB = melB.collect{|i| [i[0], i[1]+durA, i[2]]} ;
		melA1 = melA1.collect{|i| [i[0], i[1]+durA+32, i[2]]} ;
		mel = melA++melB++melA1 ;
		harm = ~harmonizeMel.(mel, durA/4+16, ~symbolsTo9, ~priority2) ;
		~logHarmony.(harm, "/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".harm") ;
		~makeMidi.(mel, tempo, "/home/andrea/musica/scores/unrealBook/sandbox/"++i[0]++"_"++w++".mid", cKey:0) ;
	}
} ;
)
