#ifndef Plugin_
#define Plugin_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "../Logic.mqh"
#include "../OrderRequest.mqh"


/**
 * 
 */
class Plugin: public Logic {

public:
	Plugin(): Logic() {};
	~Plugin(){};

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

	virtual void onTick(){};

	virtual void onTimeframe(){};

};

#endif // Plugin_