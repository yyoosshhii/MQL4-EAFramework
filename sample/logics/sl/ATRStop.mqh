#ifndef ATRStop_
#define ATRStop_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <EAFramework/EAFramework.mqh>

/**
 * ATRを損切り値幅として利用する。
 */
class ATRStop : public Stop {

private:

	int periods;

	double mult;
	
public:
	ATRStop( int periods_, double mult_ ): periods( periods_ ), mult( mult_ ) {};
	~ATRStop(){};

	virtual double calc( OrderRequest* request ){

		//
		if( request.isBuy() ) {
            return request.price - mult * iATR( symbol(), timeframe(), periods, 0 );
        } else {
            return request.price + mult * iATR( symbol(), timeframe(), periods, 0 ) + spread();
		}
	}

	virtual string toString(){ return "ATRS_"+periods+"_"+mult; };
};

#endif // ATRStop_