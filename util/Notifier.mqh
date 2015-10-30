#ifndef Notifier_
#define Notifier_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <Object.mqh>
#include <Hash.mqh>
#include <Arrays/ArrayObj.mqh>
#include "./FixedArray.mqh"

/**
 *
 */
class Notifier: public CObject {

private:
    FixedArray* eventListenersList;


public:
	Notifier(): CObject() {
	    eventListenersList = new FixedArray( 10 );
	};
	~Notifier(){};

protected:
    Notifier* self(){ return GetPointer(this); }

    virtual void onNotify( int eventType, Notifier* notifier, Hash* data = NULL ) {}

private:

    CArrayObj* getListeners( int eventType ) {

        CObject* result = eventListenersList.get( eventType );

        if( !result ) {
            result = new CArrayObj();
            //
            if( eventListenersList.length() < (eventType+1) )
                eventListenersList.length( eventType+10 );
            //
            eventListenersList.set( eventType, result );
        }
        return (CArrayObj*) result;
    }

public:

	virtual void on( int eventType, Notifier* listener ){
	    CArrayObj* listeners = getListeners( eventType );
	    int index = listeners.Search( listener );
	    if( index != -1 ) return;
	    listeners.Add( listener );
//	    listeners.Sort(0);
	};

	virtual void off( int eventType, Notifier* listener ) {
	    CArrayObj* listeners = getListeners( eventType );
	    int index = listeners.Search( listener );
	    if( index == -1 ) return;
	    listeners.Delete( index );
//	    listeners.Sort(0);
	}

	void notify( int eventType, Hash* data = NULL ) {
        CArrayObj* listeners = eventListenersList.get( eventType );
        if( !listeners ) return;
	    for( int i=0, len=listeners.Total(); i<len; i++ )
	        ((Notifier*) listeners.At(i) ).onNotify( eventType, self(), data );
	}


	virtual string toString(){ return "Notifier"; };
};


#include <Hash.mqh>
#include <Arrays/ArrayString.mqh>

#define UseEvent( key ) static const int key = Event::type( #key );
/**
 *
 */
class Event {

// STATIC
private:
    static CArrayString* list;

public:
    static int type( string key ) {
        int index = list.SearchLinear( key );
        if( index != -1 ) {
            return index;
        }
        index = list.Total();
        list.Add( key );
        return index;
    }

////
//private:
//    int _type;
//    Hash* _data;
//    Notifier* _notifier;
//
//public:
//    Event( int type_, Hash* data_ = NULL, Notifier* notifier_ ):
//    _type( type_ ), _data( data_ ), _notifier( notifier_ ) {}
//
//    int type() { return _type; }
//
//    bool is( int type_ ) { return _type == type_; }
//
//    Hash* data() { return _data; }
//
//    Notifier* notifier(){ return _notifier; }

};
CArrayString* Event::list = new CArrayString();


#endif // Notifier_