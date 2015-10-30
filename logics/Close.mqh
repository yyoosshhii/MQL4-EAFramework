#ifndef Close_
#define Close_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "../Logic.mqh"
#include "../OrderRequest.mqh"

/**
 * 
 */
class Close: public Logic {

private:
	
public:
	Close(): Logic() {};
	~Close(){};

protected:

    virtual void initWithContext(){
        UseEvent( TICK );
        UseEvent( TIMEFRAME )
		UseEvent( TICK_AFTER );

        ctx().on( TICK, self() );
        ctx().on( TIMEFRAME, self() );
        ctx().on( TICK_AFTER, self() );
    }

    virtual void onNotify( int eventType, Notifier* notifier, Hash* data = NULL ){
        UseEvent( TICK );
        UseEvent( TIMEFRAME );
		UseEvent( TICK_AFTER );

        if( eventType == TICK ) onTick();
        else if( eventType == TIMEFRAME ) onTimeframe();
        else if( eventType == TICK_AFTER ) onTickAfter();
    }

public:

	virtual void onTick(){};

	virtual void onTimeframe(){};

	virtual void onTickAfter(){};

	virtual void setup( OrderRequest* request ){};
};

#endif // Close_