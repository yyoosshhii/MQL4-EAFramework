#ifndef ATRTakeProfit_
#define ATRTakeProfit_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <EAFramework/EAFramework.mqh>

/**
 * ATRを利食い値幅として利用する。
 */
class ATRTakeProfit : public TakeProfit {

private:

	int periods;

	double mult;
	
public:
	ATRTakeProfit( int periods_, double mult_ ): periods( periods_ ), mult( mult_ ) {};
	~ATRTakeProfit(){};

	virtual double calc( OrderRequest* request ){
		//
		if( request.isBuy() ) {
            return request.price + mult * iATR( symbol(), timeframe(), periods, 0 );
        } else {
            return request.price - mult * iATR( symbol(), timeframe(), periods, 0 ) + spread();
		}
	}

	virtual string toString(){ return "ATRTP_"+periods+"_"+mult; };
};

#endif // ATRTakeProfit_