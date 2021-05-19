SonaGraph.prepare ;

n = Buffer.read(s, "/home/andrea/Downloads/Oliver Nelson  - The Blues And The Abstract Truth -  01 -  Stolen Moments.wav") ;
b = Bus.audio(s, 1) ;
~rt = 107/60*4 ;
x = {Out.ar([0, b], Mix(PlayBuf.ar(2, n, BufRateScale.kr(n))))}.play
// an istance
a = SonaGraph.new ;
// now analyzing in real-time
a.analyzeRT(4,~rt, anBus:b) ; // rate depends on dur etc
x.free

a.stopAnalyzingRT

r = SonaGraphChromaGuiRT(a, thresh: -96, hStep: 3, vStep: 20, howManyBins: 300 ).makeGui

r.synthVol = -10

107/60*4
