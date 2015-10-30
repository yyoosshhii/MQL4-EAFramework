#ifndef RSIFilter_
#define RSIFilter_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <EAFramework/EAFramework.mqh>

/**
 * RSIによる行き過ぎた値動きのフィルター
 */
class RSIFilter : public Filter {

private:
	int periods;


	double threshold;

public:
	RSIFilter( int periods_, double threshold_ = 30 ): periods( periods_ ), threshold( threshold_ ) {};
	~RSIFilter(){};

	virtual bool test( OrderRequest* request ) {

		bool result = true;

		double rsi = iRSI( symbol(), timeframe(), periods, PRICE_MEDIAN, 0 );

		if( request.isBuy() )
            result = ( rsi < (100-threshold) );
		else
            result = ( threshold < rsi );

		return result;
	};
	
	virtual string toString(){ return "RSIF_"+periods; };
};

#endif // RSIFilter_