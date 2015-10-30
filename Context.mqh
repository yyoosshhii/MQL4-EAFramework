#ifndef Context_
#define Context_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <Arrays/ArrayObj.mqh>
#include "./OrderRequest.mqh"
#include "./OrderInfo.mqh"
#include "./CustomError.mqh"

#include "./util/Notifier.mqh"
#include <Object.mqh>
#include <yyoolib.mqh>

/**
 * 
 */
class Context: public Notifier {

// Debug
public:
    bool debugEnabled;
    void log( string value ){
        if( debugEnabled ) Print( "// ", value );
    }
    Context* enableDebug(){ debugEnabled = true; return GetPointer(this); }

private: // Orders
	CArrayObj* orders;
public:
	CArrayObj* getOrders(){ return orders; };

private: // Symbol
	string symbol;
public:
	string getSymbol(){ 
		//Print("Context.getSymbol", symbol ); 
		return symbol; 
	};
	Context* setSymbol( string value ){ 
		symbol = value;
		if( value != NULL ) {
			if( !SymbolSelect( value, true ) ) Print("SymbolSelect( ", value, " ); failure!");
		}
		return GetPointer( this ); 
	};

private: // Timeframe
	int timeframe;
public:
	int getTimeframe(){ return timeframe; }
	Context* setTimeframe( int value ){ 
		timeframe = value;
		return GetPointer( this ); 
	};

private: // RiskCoeff
    double riskCoeff;
public:
    double getRiskCoeff(){ return riskCoeff; }
	Context* setRiskCoeff( double value ){
		riskCoeff = value;
		return GetPointer( this );
	};


public: // 環境変数取得系

    double getPoint(){
        return MarketInfo( symbol, MODE_POINT );
    }
    double roundPoint( double value ){
        return MathRound( value / getPoint() ) * getPoint();
    }
	double getSpread(){
		return MarketInfo( symbol ,MODE_SPREAD ) * MarketInfo( symbol, MODE_POINT );
	}
	double getStopLevel() {
		return (MarketInfo( symbol ,MODE_STOPLEVEL )+1) * MarketInfo( symbol, MODE_POINT );
	}
	double symbolToAccountCurrency( double value ) {
	    return SymbolToAccountCurrency( value, getSymbol() );
	}
    double getLotStep(){
        return MarketInfo( symbol, MODE_LOTSTEP );
    }
    double getLotMax(){
        return MarketInfo( symbol, MODE_MAXLOT );
    }
    double getLotMin(){
        // TODO 最小がMINLOTではない？errorになるのでstepでみる
        return MarketInfo( symbol, MODE_LOTSTEP );
    }
    double roundLot( double lot ){
        double step = getLotStep();
		lot = MathMin( lot, getLotMax() );
		lot = MathMax( lot, getLotMin() );
		lot = MathRound( lot / step ) * step;
		return lot;
    }

public:
	Context( string symbol_, int timeframe_ = PERIOD_CURRENT ): Notifier(),
	symbol( NULL ), timeframe( timeframe_ ), orders( new CArrayObj() ){
		setSymbol( symbol_ );
		debugEnabled = false;
	};
	~Context(){};

    /**
     * リクエスト内容をオーダー
     * @abstract
     */
	virtual OrderInfo* order( OrderRequest* request ){ return NULL; };


	/**
	 * 指定リクエストを実際に送信し、OrderInfo化して返す
	 */
	OrderInfo* sendOrderRequest( OrderRequest* request ){
		OrderRequest* req = request;
		// TODO 成り行き対応 Sleep(100); RefreshRates() Ask or Bid

		if( req.price == -1 ) {
			switch( req.operation ){
				case BUY: case BUYLIMIT: case BUYSTOP:
					req.price = Ask;
					break;
				case SELL: case SELLLIMIT: case SELLSTOP:
					req.price = Bid;
					break;
			}
		}

        // 値とStop値が所定の値幅より狭い場合
        double value, stopLevel = getStopLevel();
		if( req.isBuy() ) {
		    // sellする
            value = req.price - req.stoploss - getSpread();
            if( value < stopLevel ) value = stopLevel;
            req.stoploss = req.price - value - getSpread();
		} else {
		    // buyする
            value = req.stoploss - req.price - getSpread();
            if( value < stopLevel ) value = stopLevel;
            req.stoploss = req.price + value + getSpread();
		}
		// 損切り値を丸める
		req.stoploss = roundPoint( req.stoploss );

        // ロット数を丸める
        double lots = roundLot( req.volume );
        //  実際のロット数とかけ離れている場合はエラーにする lotStepの半分以上のズレをエラーとする
        if( fabs( req.volume - lots ) > getLotStep()*0.5 ) {
            CustomError::OUT_OF_RANGE_TRADE_VOLUME();
		    // ERROR
    		return NULL;
        }
        req.volume = lots;

		//
		//Print("Order.send op:", req.operation, " price:", req.price, " stop:", req.stoploss );

		int ticketId = OrderSend(
			req.symbol != NULL ? req.symbol : Symbol(),
			req.operation,
			req.volume,
			req.price,
			req.slippage,
			req.stoploss,
			req.takeprofit,
			req.comment,
			req.magic,
			req.expiration,
			req.operation % 2 == 0 ? Blue : Red
		);
		if( ticketId == -1 ) {
		    // ERROR
    		return NULL;
		}
		return new OrderInfo( req, ticketId );
	};


	/**
	 *  Only opened order
	 */
	bool closeOpenedOrder( OrderInfo* order, double lots = -1, double price = -1, int slippage = 3 ){
//		if( !select() ) return -1;
        bool isSeparate = true;
		if( lots == -1 ) {
		    lots = order.getLots();
		    isSeparate = false;
		}
		if( price == -1 ) {
			switch( order.getType() ){
				case BUY: case BUYLIMIT: case BUYSTOP:
					price = Bid;
					break;
				case SELL: case SELLLIMIT: case SELLSTOP:
					price = Ask;
					break;
			}
		}

		color col = order.isBuy() ? Blue : Red;
		double open = order.getOpenPrice();

		if( order.isBuy() && open < price || !order.isBuy() && open > price  ) {
		    col = Yellow;
		}

		bool result = OrderClose( order.getTicketId(), lots, price, slippage, col );

		if( !result ) return false;
		if( isSeparate )
		    order.updateTicketId();
		return true;
	};

	/**
	 *  Only pending order
	 */
	bool deletePendingOrder( OrderInfo* order ){
		if( !order.select() ) return -1;
		return OrderDelete( order.getTicketId() );
	};

	/**
	 * 既存オーダーの内容修正
	 */
	bool modifyOrder( OrderInfo* order, double price = NULL, double stoploss = NULL, double takeprofit = NULL, datetime expiration = NULL ){
		if( price == NULL ) price = order.getOpenPrice();
		if( stoploss == NULL ) stoploss = order.getStopLoss();
		if( takeprofit == NULL ) takeprofit = order.getTakeProfit();
		if( expiration == NULL ) expiration = order.getExpiration();

		return OrderModify( order.getTicketId(), price, stoploss, takeprofit, expiration, order.isBuy() ? Blue : Red );
	};



	virtual string toString(){ return "Context"; };
};

#endif // Context_