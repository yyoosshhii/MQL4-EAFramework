#ifndef Open_
#define Open_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "../Logic.mqh"
#include "../OrderRequest.mqh"


/**
 * 
 */
class Open: public Logic {

public:
	Open(): Logic(){};
	~Open(){};

protected:

    virtual void initWithContext(){
        UseEvent( TICK );
		UseEvent( TIMEFRAME );

        ctx().on( TICK, self() );
        ctx().on( TIMEFRAME, self() );
    }

    virtual void onNotify( int eventType, Notifier* notifier, Hash* data = NULL ){
        UseEvent( TICK );
		UseEvent( TIMEFRAME );

        if( eventType == TICK ) onTick();
        else if( eventType == TIMEFRAME ) onTimeframe();
    }

public:

	virtual void setup( OrderRequest* request ){
		Print( "TODO impl setup()" );
	};

	virtual void onTick(){};

	virtual void onTimeframe(){};

};

#endif // Open_