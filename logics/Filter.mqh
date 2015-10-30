#ifndef Filter_
#define Filter_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "../Logic.mqh"
#include "../OrderRequest.mqh"


/**
 * 
 */
class Filter: public Logic {

protected:

	bool _reversed;

public:
	Filter(): Logic(), _reversed(false) {};
	~Filter(){};

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

	virtual bool test( OrderRequest* request ){ 
		Print( "TODO impl test()" );
		return true; 
	};

	Filter* reverse(){
	    _reversed = true;
    	return GetPointer( this );
	}

	bool doTest( OrderRequest* request ) {
	    return test( request ) ? !_reversed : _reversed ;
	}

	virtual void onTick(){};

	virtual void onTimeframe(){};

};

#endif // Filter_