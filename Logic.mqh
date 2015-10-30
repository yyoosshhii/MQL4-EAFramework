#ifndef Logic_
#define Logic_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "./Context.mqh"

#include "./util/Notifier.mqh"
//class System;

/**
 * 
 */
class Logic: public Notifier {

protected:
	Context* context;
public:

    /**
     * コンテキスト参照
     * @aliase ctx
     */
	Context* getContext(){ return context; }
    Context* ctx(){ return context; }
    /**
     * コンテキスト設定
     */
	virtual void setContext( Context* value ){
		context = value;
		initWithContext();
	}


	double riskCoeff(){ return context.getRiskCoeff(); }

	string symbol(){ return context.getSymbol(); };

	int timeframe(){ return context.getTimeframe(); };

	double point(){ return context.getPoint(); }

	double roundPoint( double value ){ return context.roundPoint( value ); }

	double spread(){ return context.getSpread(); }

	double stoplevel(){ return context.getStopLevel(); };

protected:
    /**
     * コンテキストが設定された状態での初期化処理
     */
    virtual void initWithContext(){}

private:
	
public:
	Logic(): Notifier() {};
	~Logic(){};

	virtual void onTick(){};

	virtual void onTimeframe(){};

	virtual void onM1(){};
	
	virtual void onM5(){};
	
	virtual void onM15(){};
	
	virtual void onM30(){};
	
	virtual void onH1(){};
	
	virtual void onH4(){};
	
	virtual void onD1(){};
	
	virtual void onW1(){};
	
	virtual void onMN1(){};

	virtual string toString(){ return "Logic"; };

};

#endif // Logic_