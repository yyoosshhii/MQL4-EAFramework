#ifndef MarketOrderOpen_
#define MarketOrderOpen_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <EAFramework/EAFramework.mqh>

/**
 * 成り行き注文
 */
class MarketOrderOpen : public Open {

private:


public:
	MarketOrderOpen(): Open() {};
	~MarketOrderOpen(){};


private:

public:

	virtual void setup( OrderRequest* request ) {

        if( request.isBuy() )
            request.price = Ask;
        else
            request.price = Bid;
	}


	virtual string toString(){ return "MarketOrderOpen"; };
};

#endif // MarketOrderOpen_