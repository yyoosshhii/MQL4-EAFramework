#ifndef Env_
#define Env_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/**
 * 
 */
class Env {

private:
	string symbol_;
	
public:
	Env( string symbol__ = NULL ):
	symbol_( symbol__ )
	{

	};
	~Env(){

	};

private:
	static Env* scope;
public:
	static string symbol(){ return scope==NULL? NULL: scope.symbol_; };

};

Env* Env::scope = NULL;

#endif // Env_