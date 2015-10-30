#ifndef CircularBuffer_
#define CircularBuffer_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/**
 *
 */
class CircularBuffer {

private:
    int size;
    int index;
    double data[];

public:
	CircularBuffer( int size_ ): size( size_ ), index(0) {
        ArrayResize( data, size );
        ArrayInitialize( data, -1 );
	};
	~CircularBuffer(){};

public:

    int getSize() { return size; }

    double at( int offset ) {
        int index = ( (index + offset) % size + size ) % size;
//        Print( "CircularBuffer.at "+ offset +", "+ index );
        return data[ index ];
    }

    void put( double value ) {
        index = (index+1) % size;
        data[index] = value;
    }

	virtual string toString(){ return "CircularBuffer"; };
};

#endif // CircularBuffer_