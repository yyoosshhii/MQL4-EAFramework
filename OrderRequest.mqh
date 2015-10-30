#ifndef OrderRequest_
#define OrderRequest_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "./OrderOperation.mqh"

int OrderRequest_Magic_Incrementor = 1000;

class OrderRequest {
public:
    /**
     * market symbol
     */
    string   symbol;

    /**
     * BUY,SELL,,,
     */
    OrderOperation operation;

    /**
     * position size
     */
    double   volume;

    /**
     * price
     */
    double   price;

    /**
     * limit points of slippage
     */
    int      slippage;

    /**
     *
     */
    double   stoploss;

    double   takeprofit;

    string   comment;

    int      magic;

    /**
     *
     */
    datetime expiration;

public:
	OrderRequest( OrderOperation op_, 
		double volume_ = 1.0,
		string symbol_ = NULL, 
		double price_ = -1, 
		int slippage_ = 10, 
		double stoploss_ = 0, 
		double takeprofit_ = 0, 
		string comment_ = NULL, 
		int magic_ = 0, 
		datetime expiration_ = 0 
	): 
		symbol( symbol_ ), 
		operation( op_ ), 
		volume( volume_ ), 
		price( price_ ), 
		slippage( slippage_ ), 
		stoploss( stoploss_ ),
		takeprofit( takeprofit_ ),
		comment( comment_ ),
		magic( magic_ != 0 ? magic : OrderRequest_Magic_Incrementor++ ),
		expiration( expiration_ )
	{};
	~OrderRequest(){};

	bool isBuy() {
		switch( operation ) {
			case BUY:
			case BUYLIMIT:
			case BUYSTOP:
				return true;
				break;
		}
		return false;	
	}
};

#endif // OrderRequest_