// so, first we define a number of bars
// then fill with quarters
// then group triplets, not to be touched anymore
// then we split into eights
// then we group eights into events
// then we delete events --> rest
(
~timeTape = () ;

~timeTape.makeTriplets = {|me, tripletsNum = 3, seed|
	var tr = [] ;
	if (seed.notNil){thisThread.randSeed = seed} ;
	tripletsNum.do {
		var type = [\e, \q].wchoose([0.8, 0.2]) ;
		if (type == \e){
			tr = tr.add(Array.fill(3, {1/3}))} {
			tr = tr.add(Array.fill(3, {2/3}))
		}
	} ;
	tr
} ;

~timeTape.makeQuarters = {|me, measuresNum, triplets|
	var dur = triplets.flat.sum ;
	var rhy4 = Array.fill(measuresNum * 4 - dur, {1}) ;
	rhy4 ;
} ;

~timeTape.split8 = {|me, rhy4|
	rhy4.collect{|i|
		if(i.class == Array){[i]}{[0.5, 0.5]}
	}.flatten
} ;

~timeTape.group8 = {|me, rhy8, min = 1, max = 5 |
	var p = Pseq(rhy8).asStream ;
	var grp = [], next = p.next ;
	var ev ;
	while {next.notNil}{
		ev = 0 ;
		rrand(min, max).do{
			if(next.notNil){
				if(grp.sum <= rhy8.sum){
					ev = ev+next
				}
				};
			next = p.next ;
		} ;
		grp = grp.add(ev) ;
		grp
	} ;
	//grp = grp.add(ev)
	grp
} ;

~timeTape.makeTape = {|me, measuresNum, tripletsNum, minDur, maxDur|
	var t  = me.makeTriplets(tripletsNum) ;
	var q  = me.makeQuarters(measuresNum, t) ;
	var e = me.split8(q) ;
	var g = me.group8(e, minDur, maxDur) ;
	var index  = [] ;
	var time = 0;
	var copy = [], n = 0;
	g.do{|u,i|
		if ((time+u) == (time+u).floor) {
			index = index.add(i+1) ;
		} ;
		time = time + u
	} ;
	index = index.scramble[..(tripletsNum-1)] ;
	g.do{|ev, i|
		if(index.includes(i)){
			copy = copy.add(t[n]) ;
			n = n+1
		} ;
		copy = copy.add(ev)
	} ;
	copy;
} ;

~timeTape.delete = {|me, tape, delProb = 0.2, seed|
	if (seed.notNil){thisThread.randSeed = seed} ;
	tape.collect{|e|
		if(1.0.rand >= delProb){
			[\n, e]
		}{ [\r, e]}
	}
} ;

~timeTape.rhyConv = {|me, tape, measOffset = 0|
	var rhy = [] ;
	var t = measOffset*4 ;
	tape.do{|e, i|
		if(e[0] == \n){
			if(e[1].class == Array){
				e[1].do{|it, ind|
					rhy = rhy.add([\n, t+(it*ind), it])
				}
			}{
				rhy = rhy.add([\n, t, e[1]]) }
		};
		t = t+[e[1]].flat.sum
	} ;
	rhy
}  ;
)
/*
t = ~timeTape.makeTape(8, 2, 1, 3) ;
d  =~timeTape.delete(t, 0.2) ;
~rhy = ~timeTape.rhyConv(d) ;
~mel = ~brownMel.(~rhy, 72, 60, 84, 5) ;
~makeMidi.(~mel, 150, "/home/andrea/musica/scores/unrealBook/test.mid")
)
t  = ~timeTape.makeTriplets
q  = ~timeTape.makeQuarters(t)
e = ~timeTape.split8(q)
e.sum
g = ~timeTape.group8(e)
g.sum
*/