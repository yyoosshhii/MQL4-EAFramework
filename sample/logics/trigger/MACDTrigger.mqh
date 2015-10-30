#ifndef MACDTrigger_
#define MACDTrigger_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <EAFramework/EAFramework.mqh>

/**
 * MACDによる仕掛けトリガー
 */
class MACDTrigger : public Trigger {

private:
	int fastPeriods;
	int slowPeriods;
	int signalPeriods;

public:
	MACDTrigger( int fastPeriods_, int slowPeriods_ = -1, int signalPeriods_ = -1 ): fastPeriods( fastPeriods_ ) {
	    slowPeriods = slowPeriods_ != -1 ? slowPeriods_ : MathCeil( (double)fastPeriods/12 * 26 );
	    signalPeriods = signalPeriods_ != -1 ? signalPeriods_ : MathCeil( (double)fastPeriods/12 * 9 );
	};
	~MACDTrigger(){};

	virtual void onTimeframe(){

		double macd1 = iMACD( symbol(), timeframe(), fastPeriods, slowPeriods, signalPeriods, PRICE_MEDIAN, 0, 1 );
		double signal1 = iMACD( symbol(), timeframe(), fastPeriods, slowPeriods, signalPeriods, PRICE_MEDIAN, 1, 1 );
		double macd2 = iMACD( symbol(), timeframe(), fastPeriods, slowPeriods, signalPeriods, PRICE_MEDIAN, 0, 2 );
		double signal2 = iMACD( symbol(), timeframe(), fastPeriods, slowPeriods, signalPeriods, PRICE_MEDIAN, 1, 2 );

        if( macd2 < signal2 && macd1 > signal1 )
            getContext().order( new OrderRequest( BUY ) );
        if( macd2 > signal2 && macd1 < signal1 )
            getContext().order( new OrderRequest( SELL ) );
	};
	
	virtual string toString(){ return "MACDT_"+fastPeriods; };

};

#endif // MACDTrigger_