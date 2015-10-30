#ifndef OrderInfo_
#define OrderInfo_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include "./OrderOperation.mqh"
#include "./OrderRequest.mqh"
#include <Object.mqh>

#include <Hash.mqh>

/**
 * OrderInfo
 */
class OrderInfo : public CObject {

private:

	// static OrderInfo* selected;

public:
	/**
	 * TODO ticket != order !
	 */
//	static OrderInfo* getByTicketId( int ticketId ){
//		return new OrderInfo( ticketId );
//	};
	/**
	 * TODO ticket != order !
	 */
//	static OrderInfo* getByIndex( int index ){
//		if( OrderSelect( index, SELECT_BY_POS, MODE_TRADES ) )
//			return new OrderInfo( OrderTicket() );
//		return NULL;
//	};

private:

	int ticketId;

    OrderRequest* request;

private:
	double commonValue;
public:
    double getCommonValue(){ return commonValue; }
    void setCommonValue( double v ){ commonValue = v; }


private:
    Hash* data;
public:

    /**  */
    bool has( string keyName ) { return data.hContainsKey( keyName ); }

    /** get props */
    /** */
    string getString( string keyName ) { return data.hGetString( keyName ); }
    /** */
    double getDouble( string keyName ) { return data.hGetDouble( keyName ); }
    /** */
    int getInt( string keyName ) { return data.hGetInt( keyName ); }
    /** */
    long getLong( string keyName ) { return data.hGetLong( keyName ); }
    /** */
    datetime getDatetime( string keyName ) { return data.hGetDatetime( keyName ); }

    /** put props */
    /** */
    bool putString( string keyName, string s ) { return !!data.hPutString( keyName, s ); }
    /** */
    bool putDouble( string keyName, double d ) { return !!data.hPutDouble( keyName, d ); }
    /** */
    bool putInt( string keyName, int i ) { return !!data.hPutInt( keyName, i ); }
    /** */
    bool putLong( string keyName, long i ) { return !!data.hPutLong( keyName, i ); }
    /** */
    bool putDatetime( string keyName, datetime i ) { return !!data.hPutDatetime( keyName, i ); }

    /** delete props */
    bool del( string keyName ) { return data.hDel( keyName ); }


public:
	OrderInfo( OrderRequest* request_, int initialTicketId_ ): request( request_ ), ticketId( initialTicketId_ ) {
	    commonValue = -1;
        data = new Hash();
	};
	~OrderInfo(){
        delete data;
	};

	/**
	 * オーダーによっては複数のticketにまたがる可能性があるので・・
	 *   ex) ポジションの半分を手仕舞う場合、残りの半分が新たなticketとして扱われる
	 */
	void updateTicketId() {
        // magicを手がかりに新たなTicketを探す
        for( int i = 0; i < OrdersTotal(); i++ ) {
            if( !OrderSelect( i, SELECT_BY_POS, MODE_TRADES ) ) continue;
            if( OrderMagicNumber() != request.magic ) continue;

            ticketId = OrderTicket();
            return;
        }
	}

	bool select(){
		return OrderSelect( ticketId, SELECT_BY_TICKET, MODE_TRADES );
	}

	bool isOpened(){
		return getProfit() != 0.0;
	}
	bool isClosed(){ 
		return getCloseTime() > 0;
	}

	double getClosePrice(){
		if( !select() ) return -1;
		return OrderClosePrice();
	};

	datetime getCloseTime(){
		if( !select() ) return -1;
		return OrderCloseTime();
	};
	
	string getComment(){
		if( !select() ) return NULL;
		return OrderComment();
	};
	
	double getCommission(){
		if( !select() ) return -1;
		return OrderCommission();
	};
	
	datetime getExpiration(){
		if( !select() ) return -1;
		return OrderExpiration();
	};
	
	double getLots(){
		if( !select() ) return -1;
		return OrderLots();
	};
	
	int getMagicNumber(){
		if( !select() ) return -1;
		return OrderMagicNumber();
	};
	
	double getOpenPrice(){
		if( !select() ) return -1;
		return OrderOpenPrice();
	};
	
	datetime getOpenTime(){
		if( !select() ) return -1;
		return OrderOpenTime();
	};
	
	void print(){
		if( !select() ) return;
		OrderPrint();
	};
	
	double getProfit(){
		if( !select() ) return -1;
		return OrderProfit();
	};
	
	double getStopLoss(){
		if( !select() ) return -1;
		return OrderStopLoss();
	};
	
	double getSwap(){
		if( !select() ) return -1;
		return OrderSwap();
	};
	
	string getSymbol(){
		if( !select() ) return NULL;
		return OrderSymbol();
	};
	
	double getTakeProfit(){
		if( !select() ) return -1;// TODO 機能していない close後じゃないと取れない
		return OrderTakeProfit();
	};
	
	int getTicketId(){
		return ticketId;
	};
	
	OrderOperation getType(){
		if( !select() ) return -1;
		return OrderType();
	};

	bool isBuy(){
		switch( getType() ){
			case BUY: case BUYLIMIT: case BUYSTOP:
				return true;
				break; 
		}
		return false;
	}
};


#endif // OrderInfo_