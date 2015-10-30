#ifndef Util_
#define Util_

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Util {
private:

public:
	Util(){};
	~Util(){};

	static double random(){
		return MathRand() / 32767.0;
	}

	static int timeframeToSec( int timeframe ) {
		if( timeframe == 0 ) timeframe = Period();
		return timeframe * 60; // timeframeは分のint値なので
	}
};

#endif // Util_