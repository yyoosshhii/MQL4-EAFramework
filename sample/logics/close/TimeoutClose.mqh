#ifndef TimeoutClose_
#define TimeoutClose_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <EAFramework/EAFramework.mqh>
#include <Arrays/ArrayObj.mqh>

/**
 * 任意のbar数経過後にクローズする。
 */
class TimeoutClose : public Close {

private:

	double periods;
	int timeframe;

public:
	TimeoutClose( double periods_, int timeframe_ = PERIOD_CURRENT ): periods( periods_ ), timeframe( timeframe_ ) {
	    if( timeframe == PERIOD_CURRENT ) timeframe = Period();
	};
	~TimeoutClose(){};

	virtual void setup( OrderRequest* request ){};

	virtual void onTick(){
	    checkOrders();
	};

	virtual void onTimeframe(){};

private:

	void checkOrders() {

		int now = TimeCurrent();

		CArrayObj* orders = getContext().getOrders();
		for( int i = 0; i < orders.Total(); i++ ) {

			OrderInfo* order = orders.At( i );

			if( !order.isOpened() ) continue;

			if( order.getOpenTime() > ( TimeCurrent() - periods*timeframe* 60 ) ) continue;

			// close
			bool result = getContext().closeOpenedOrder( order );
			if( result ) {
				orders.Delete( i ); 
				i--;
			}
		}

	}

	virtual string toString(){ return "TimeoutC_"+periods; };

};

#endif // TimeoutClose_