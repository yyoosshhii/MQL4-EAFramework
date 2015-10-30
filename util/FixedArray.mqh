#ifndef FixedArray_
#define FixedArray_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <Object.mqh>

/**
 *
 */
class FixedArray : public CObject {

private:

    CObject* data[];
    int _length;


public:
	FixedArray( int length_ = 10 ): CObject(), _length(0) {
        length( length_ );
	};
	~FixedArray(){};


private:

public:

	int length( void ) const { return _length; }
	void length( const int value ){
	    if( _length == value ) return;
	    int prev = _length;
        ArrayResize( data, value );
        for( int i=prev; i<value; i++ ) data[i] = NULL;
        _length = value;
    }

    CObject* get( int index ) {
        if( index < 0 || _length <= index ) return NULL;
        return data[index];
    }
    void set( int index, CObject* object ) {
        if( index < 0 || _length <= index ) return;
        data[index] = object;
    }



	virtual string toString(){ return "FixedArray"; };
};

#endif // FixedArray_