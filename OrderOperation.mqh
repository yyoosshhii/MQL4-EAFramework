#ifndef OrderOperation_
#define OrderOperation_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OrderOperation {
	BUY 		= 0, // Buy operation
	SELL 		= 1, // Sell operation
	BUYLIMIT 	= 2, // Buy limit pending order
	SELLLIMIT 	= 3, // Sell limit pending order
	BUYSTOP 	= 4, // Buy stop pending order
	SELLSTOP 	= 5  // Sell stop pending order
};

#endif // OrderOperation_