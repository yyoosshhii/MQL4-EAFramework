#ifndef TakeProfit_
#define TakeProfit_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "../Logic.mqh"
#include "../OrderRequest.mqh"

/**
 * 
 */
class TakeProfit : public Logic {

private:
	
public:
	TakeProfit(): Logic() {};
	~TakeProfit(){};

public:

	virtual double calc( OrderRequest* request ){
		//
		switch( request.operation ) {
			case BUY:
			case BUYLIMIT:
			case BUYSTOP:
				//
				break;

			case SELL:
			case SELLLIMIT:
			case SELLSTOP:
				//
				break;
		}
		return -1.0;
	};
};

#endif // TakeProfit_