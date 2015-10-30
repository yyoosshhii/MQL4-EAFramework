#ifndef FixedRiskSizing_
#define FixedRiskSizing_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <EAFramework/EAFramework.mqh>

/**
 * 損失確定(StopLoss)時に失う額を、資産のn%に固定する。
 */
class FixedRiskSizing : public Sizing {

private:
	
	double risk;

public:
	FixedRiskSizing( double risk_ ): risk( risk_ ) {};
	~FixedRiskSizing(){};


	virtual double calc( OrderRequest* request ){
		if( request.stoploss == 0 ) return -1.0;

		double diff = fabs( request.stoploss - request.price );
		if( diff == 0 ) return -1.0;

//		double balance = AccountBalance();
		double equity = AccountEquity();
		double amountOfRisk = equity * risk * riskCoeff();// リスク係数対応

		double lotSize = MarketInfo( symbol(), MODE_LOTSIZE );
		//Print( "lotSize:", lotSize );
		double lots = ( amountOfRisk / getContext().symbolToAccountCurrency(diff) ) / lotSize;

		getContext().log( "diff:"+diff+", equity:"+equity+", amountOfRisk:"+amountOfRisk+", lots:"+lots );

		return lots;
	};

	virtual string toString(){ return "FixedRisk_"+risk; };
};

#endif // FixedRiskSizing_