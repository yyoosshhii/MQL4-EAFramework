#ifndef Stop_
#define Stop_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "../Logic.mqh"
#include "../OrderRequest.mqh"

/**
 * 
 */
class Stop : public Logic {

private:
	
public:
	Stop(): Logic(){};
	~Stop(){};

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

#endif // Stop_