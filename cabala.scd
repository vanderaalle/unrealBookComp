// 2016 most popular names
// https://www.babynamewizard.com/the-top-1000-baby-names-of-2016-united-states-of-america
f = File("/home/andrea/musica/scores/unrealBook/lang/firstNames", "r") ;
t = f.readAllString ; f.close ;
~names = t.split($\n).select{|i| i.size>1}.collect{|i| i.split($\t)[1]} ;

// 1990 census first 1000
//https://namecensus.com/most_common_surnames.htm
f = File("/home/andrea/musica/scores/unrealBook/lang/surnames", "r") ;
t = f.readAllString ; f.close ;
~surnames = t.split($\n).select{|i| i.size>1}.collect{|i| i.split($\t)[0]}.collect{|i| i.toLower.capitalizeFirst} ;

~getName = {|first, sur| first.choose+sur.choose} ;

//~getName.(~names, ~surnames)

~cleaner = {|wordList|
	if (wordList != []){
		if ([\a, \of, \and, \for, \the, \from, \that, \but, \which,\who,\at,\a, \an,
			\by,\still,\despite,\in, \my, \will,\to,\his,\as,\still,\with,
			\is, \are, \would // more problematic
		].includes(wordList.last.toLower.asSymbol))
		{
			//"delete: ".post ; wordList.postln ;
			wordList = wordList.reverse[1..].reverse ;
			wordList = ~cleaner.(wordList)
		};
	} ;
	if (wordList != []){
		if ([\are, \is, \was, \of, \am, \were, \and, \will, \would ]
			.includes(wordList.first.toLower.asSymbol))
		{
			//"delete: ".post ; wordList.postln ;
			wordList = wordList[1..] ;
			wordList = ~cleaner.(wordList)
		} ;
	} ;
	if ( wordList.collect{|i| i.asSymbol}.includes(\film) )
		{ wordList = [] } ;
	if( wordList.collect{|i| i.asSymbol}.includes(\movie) )
		{ wordList = [] } ;
	wordList
} ;

~titler ={|min, max, path = "/home/andrea/musica/scores/unrealBook/lang/unsup/"|
	var n = rrand(0, 49999) ;
	var name = n.asString++"_0.txt";
	var f,t, b, d, st, str = "" ;
	name = path++name ;
	f = File(name, "r") ;
	t = f.readAllString ;
	f.close ;
	t = t.replace("<br />", "").replace("<br />", "").replace("&", "and") ;
	b = t.split($ ) ;
	d = rrand(min, max);
	st = rrand(0, b.size-d) ;
	b = b[st..(st+d)] ;
	// this should be recursive pruning
	// deleting undesired words from ends
	b = ~cleaner.(b) ;
	if (b == []){~titler.(min, max)}{
		b.do{|i| str = str+i} ;
		// avoid punctuation inside title
		str = str.split($.)[0] ;
		str = str.split($,)[0] ;
		str = str.split($;)[0] ;
		str = str.split($!)[0] ;
		str = str.split($?)[0] ;
		str = str.split($-)[0] ;
		str = str.split($:)[0] ;
		["\"", "(", ")", "[", "]", "\/"].do{|i|
			str = str.replace(i, "")
		} ;
		str = str.replace(" i ", " I ");
		str = str[1..].capitalizeFirst ;
		str}
} ;

//100.do{~titler.(1, 9).postln}
//
// thisThread.randSeed = 1951 ;
// 5.do{
// 	~getName.(~names, ~surnames).post; ": ".postln;
// 	10.do{~titler.(1, 3).postln} ;
// 	"".postln
// }


//~cleaner.(["still", "a"])