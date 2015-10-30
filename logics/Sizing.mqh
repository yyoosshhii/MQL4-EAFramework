#ifndef Sizing_
#define Sizing_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "../Logic.mqh"
#include "../OrderRequest.mqh"

/**
 * 
 */
class Sizing : public Logic {

private:
	
public:
	Sizing(): Logic() {};
	~Sizing(){};

public:

	virtual double calc( OrderRequest* request ){
		return -1.0;
	};
};

#endif // Sizing_