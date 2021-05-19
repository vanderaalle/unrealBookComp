// allows to read midi files, segmenting measures


~makeMeasuresFromMidi = {|path|
	var m = SimpleMIDIFile.read(path);
	//var ev = m.realNoteOnEvents.select{|i| i[0] == 0}
	//.collect{|i| [i[4],i[1]/m.division]} ;
	var ev = m.noteSustainEvents.select{|i| i[0] == 0}
	.collect{|i| [i[4],i[1]/m.division,(i[6]/m.division)]} ;
	var meter = m.timeSignatures[0][1].asFloat ;
	var meass = [] ;
	var meas = [] ;
	var cnt = meter ;
	ev.do{|e, i|
		if(e[1] < cnt){
			meas = meas.add(e)
		}{
			meass = meass.add(meas) ;
			meas = [e] ;
			cnt = cnt+meter
		}
	} ;
	meass.collect{|meas|
		meas.collect{|e| [e[0], e[1]%meter, e[2]]}
	}
} ;


~makeMeasuresFromMidis = {|pathList|
	// container for all measure melodic blocks
	var all = [] ;
	pathList.do{|p| all = all++(~makeMeasuresFromMidi.(p))} ;
	all
} ;


//~meass = ~makeMeasuresFromMidi.("/home/andrea/musica/scores/unrealBook/varia/fromJazzomat/CliffordBrown_Sandu_FINAL.mid")

//~paths = ["CliffordBrown_Sandu", "CliffordBrown_Daahoud", "EricDolphy_Les", "FreddieHubbard_DolphinDance", "FreddieHubbard_DownUnder", "FreddieHubbard_SocietyRed", "JoeHenderson_In'NOut-1", "LeeMorgan_JustOneOfThoseThings"].collect{|i| "/home/andrea/musica/scores/unrealBook/varia/fromJazzomat/"++i++"_FINAL.mid"}

//~makeMeasuresFromMidis.(~paths)

// container for all measure melodic blocks
//~all = [] ;
//~all =  ~makeMeasuresFromMidis.(~paths)
