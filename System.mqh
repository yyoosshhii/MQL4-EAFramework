#ifndef System_
#define System_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "./Context.mqh"
#include "./CustomError.mqh"

#include "./logics/Close.mqh"
#include "./logics/Filter.mqh"
#include "./logics/Sizing.mqh"
#include "./logics/Stop.mqh"
#include "./logics/TakeProfit.mqh"
#include "./logics/Trigger.mqh"
#include "./logics/Open.mqh"
#include "./logics/Plugin.mqh"

#include "./OrderInfo.mqh"

#include <Files/FileTxt.mqh>
#include <Arrays/ArrayInt.mqh>
#include <Arrays/ArrayFloat.mqh>


/**
 * 許容エラー数
 */
int ALLOWABLE_NUM_ERROR = 100;

/**
 *
 * @class
 */
class System: public Context {

// Close Logics
private:
	CArrayObj* closes;
public:
	Close* getClose(){ return closes.Total() > 0 ? closes.At(0) : NULL; }

	CArrayObj* getCloses(){ return closes; }

	System* setClose( Close* value ){
		putClose( value );
		return GetPointer(this);
	}
	System* putClose( Close* value ){
		closes.Add( value ); 
		value.setContext( GetPointer(this) );
		return GetPointer(this);
	}
//
// Filter Logics
private:
	CArrayObj* filters;
public:

	CArrayObj* getFilters(){ return filters; }

	System* putFilter( Filter* value ){
		filters.Add( value ); 
		value.setContext( GetPointer(this) );
		return GetPointer(this);
	}


// Sizing Logic
private:
	Sizing* sizing;
public:
	Sizing* getSizing(){ return sizing; }
	System* setSizing( Sizing* value ){
	    sizing = value;
	    value.setContext( GetPointer(this) );
		return GetPointer(this);
    }

// Stop Logic
private:
	Stop* stop;
public:
	Stop* getStop(){ return stop; }
	System* setStop( Stop* value ){
	    stop = value;
	    value.setContext( GetPointer(this) );
		return GetPointer(this);
    }

// TakeProfit Logic
private:
	TakeProfit* takeProfit;
public:
	TakeProfit* getTakeProfit(){ return takeProfit; }
	System* setTakeProfit( TakeProfit* value ){
	    takeProfit = value;
	    value.setContext( GetPointer(this) );
		return GetPointer(this);
    }

// Trigger Logic
private:
	Trigger* trigger;
public:
	Trigger* getTrigger(){ return trigger; }
	System* setTrigger( Trigger* value ){
	    trigger = value;
	    value.setContext( GetPointer(this) );
		return GetPointer(this);
    }

// Open Logic
private:
	Open* open;
public:
	Open* getOpen(){ return open; }
	System* setOpen( Open* value ){
	    open = value;
	    value.setContext( GetPointer(this) );
		return GetPointer(this);
    }


// Filter Logics
private:
	CArrayObj* plugins;
public:

	CArrayObj* getPlugins(){ return filters; }

	System* putPlugin( Plugin* value ){
		plugins.Add( value );
		value.setContext( GetPointer(this) );
		return GetPointer(this);
	}

///////////////////////////////////////////////////////////////////////////////////

// name
private:
    string name;
public:
	string getName(){ return name; }
	void setName( string value ){ name = value; }

// Logger
private:
	bool logEnabled;
	datetime startAt;
	int numRequest;
	CArrayInt* errorList;

	int totalSystemError;
public:
	CArrayInt* timeline;
	CArrayFloat* values;

	CArrayObj* errors;

	CArrayInt* requests;
private:

	void updateLogs() {
	    // サンプリングは飛ばさない。ポートフォリオでマージするかも。
        //if( !logEnabled ) return;

        // log
        timeline.Add( StrToTime( TimeToString( TimeCurrent(), TIME_DATE ) ) );
        values.Add( MathRound( AccountEquity() * 100 ) / 100 );
        errors.Add( errorList );
        errorList = new CArrayInt();
        requests.Add( numRequest );
        numRequest = 0;
	}

	void outputLog() {

	    //
		if( !logEnabled ) return;

        // totals
        int errorTotal = 0;
        int requestTotal = 0;

        // timeseries data CSV
        datetime end = TimeCurrent();
        string csvStr = "time,equity,request,error";
        for( int i=0,len=timeline.Total();i<len;i++ ) {
            CArrayInt* errList = errors.At(i);
            string errStr = "";
            for( int ei=0,elen=errList.Total();ei<elen;ei++ )
                errStr += ""+errList[ei]+" ";
            csvStr += "\n"+ timeline[i] +","+ values[i] +","+ requests[i] +","+ StringTrimRight(errStr);
            errorTotal += errList.Total();
            requestTotal += requests[i];
        }

        //
        string title = name;
        if( title == NULL ) title = toString();

        // レポート key=value
        string reportStr = "";
        reportStr += "system="+ title +"\n";
        reportStr += "eaName="+ WindowExpertName() +"\n";
        reportStr += "symbol="+ Symbol() +"\n";
        reportStr += "period="+ Period() +"\n";
        reportStr += "totalTrade="+ OrdersHistoryTotal() +"\n";
        reportStr += "accountCurrency="+ AccountCurrency() +"\n";
        reportStr += "totalError="+ errorTotal +"\n";
        reportStr += "totalRequest="+ requestTotal +"";

        // ファイル出力
        string fileName = title +"__"+ TimeToString( startAt, TIME_DATE ) +"_"+ TimeToString( end, TIME_DATE );
        while( FileIsExist( fileName+".csv" ) ) fileName += "_";
        CFileTxt* file;
        // CSV
        file = new CFileTxt();
        file.Open( fileName +".csv", FILE_WRITE );
        file.WriteString( csvStr );
        delete file;
        // REPORT
        file = new CFileTxt();
        file.Open( fileName +".report", FILE_WRITE );
        file.WriteString( reportStr );
        delete file;
    }

public:
	System* enableLog(){ logEnabled = true; return GetPointer(this); };


private:
    // 各足の更新判別用
	int barsCurrentTimeframe;
	int barsM1;
	int barsM5;
	int barsM15;
	int barsM30;
	int barsH1;
	int barsH4;
	int barsD1;
	int barsW1;
	int barsMN1;


public:
    /**
     * constructor
     */
	System( string symbol_ = NULL, int timeframe_ = PERIOD_CURRENT ):
	Context( symbol_, timeframe_ ),
	name( NULL ),
	// ロジック
	closes( new CArrayObj() ), filters( new CArrayObj() ), sizing(NULL), stop(NULL), trigger(NULL), open(NULL), plugins( new CArrayObj() ),
	// 足の進捗状態
	barsCurrentTimeframe( -1 ),
	barsM1(-1), barsM5(-1), barsM15(-1), barsM30(-1), barsH1(-1), barsH4(-1), barsD1(-1), barsW1(-1), barsMN1(-1),
	errorList(new CArrayInt()), numRequest(0), timeline(new CArrayInt()), values(new CArrayFloat()), errors(new CArrayObj()), requests(new CArrayInt()),
	totalSystemError(0)
	{
		startAt = TimeCurrent();
		Print("new System");

	    debugEnabled = false;
	};

	/**
	 * destructor
	 */
	~System(){
	    outputLog();
	};

public:

    /**
     * triggerのリクエストを捌く
     * generate a new order.
     * @return Order*
     */
	virtual OrderInfo* order( OrderRequest* request ) {
	    log( "-- order ------------------------------" );
	    log( "-- " + toString() );
        numRequest++;

        int i, len;

        // 開始値を設定
		if( request.price == -1 && open != NULL ) open.setup( request );
		// 指定がない場合は成り行き
		if( request.price == -1 ) {
			switch( request.operation ) {
				case BUY: case BUYLIMIT: case BUYSTOP:
					request.price = Ask;
					break;
				case SELL: case SELLLIMIT: case SELLSTOP:
					request.price = Bid;
					break;
			}
		}
		// 値を丸める
		request.price = round( request.price / Point() ) * Point();

		// フィルターをかます
		for( i=0, len=filters.Total(); i < len; i++ ) {
			Filter* filter = filters.At(i);
			if( filter.doTest( request ) != true ) {
				log( "--  filterd : " + filter.toString() );
				return NULL;
			}
		}

		// 手仕舞いロジックの反映
		for( i=0, len=closes.Total(); i < len; i++ ) {
			Close* close = closes.At(i);
			close.setup( request );
		}

		// 損切りロジックの反映
		if( stop != NULL ) request.stoploss = stop.calc( request );

		// 利食いロジックの反映
		if( takeProfit != NULL ) request.takeprofit = takeProfit.calc( request );

		// ポジションサイジングロジックの反映
		if( sizing != NULL ) request.volume = sizing.calc( request );

        // オーダー
		OrderInfo* order = sendOrderRequest( request );
		if( order == NULL ){
            log( "--  OrderRequest failed" );

			// エラーの取り回し
			//  エラーコードを溜めてレポートとして出力する。
			int errorCode = GetLastError();
			errorList.Add( errorCode );
			//  エラー件数の加算
			totalSystemError++;
			if( totalSystemError > ALLOWABLE_NUM_ERROR ) {
			    CustomError::SYSTEM_DOWN_BY_ERRORS();
			    errorCode = GetLastError();
                errorList.Add( errorCode );
			}

			switch( errorCode ) {
			    case 130: // ERR_INVALID_STOPS
			        Print("order ERROR 130.", request.isBuy() ? "BUY": "SELL" ," price:", request.price, " stop:", request.stoploss );
			        break;
			    case 131: // ERR_INVALID_TRADE_VOLUME
			        Print("order ERROR 131. volume:", request.volume );
			        break;
                case ERROR_OUT_OF_RANGE_TRADE_VOLUME:
			        Print("order ERROR TRADE_VOLUME. volume:", request.volume, " rounded:", roundLot( request.volume ) );
			        break;
                default:
			        Print("order ERROR ", errorCode, ". @see : http://docs.mql4.com/constants/errorswarnings/enum_trade_return_codes" );
			}

			return NULL;
		}

		//
		getOrders().Add( order );

		return order;
	}

    /**
     * processing of every tick.
     * TODO high-load
     */
	void tick() {

	    // down... ログ出力だけ行う
        if( totalSystemError > ALLOWABLE_NUM_ERROR ) {
            // D1
            int tmp = iBars( getSymbol(), PERIOD_D1 );
            if( barsD1 != tmp ){
                barsD1=tmp;
                updateLogs();
            }
            return;
        }

        // TODO 未約定オーダーの状況把握と更新

        // TODO ⇡とマージ
//		checkClosedOrders();

        //
		onTick();

        // Periods
        tryNotifyUpdatedPeriodBars();

        //
		onTickAfter();
	};

	void onTimer(){

		UseEvent( TIMER );
		notify( TIMER );
	}

private:

    /**
     * remove closed orders.
     * TODO realtime
     */
	void checkClosedOrders(){

		CArrayObj* orders = getOrders();
		for( int i = 0; i < orders.Total(); i++ ) {
			OrderInfo* order = orders.At( i );
			if( order.isClosed() ) {
				Print( "Closed!! id:", order.getTicketId() );
				orders.Detach( i );
				i--;
			}
		}
	}


    /**
     * 各足のバー更新をチェックし、更新があれば通知する。
     */
    void tryNotifyUpdatedPeriodBars() {

		int bars;

		// CurrentTimeframe
		bars = iBars( getSymbol(), getTimeframe() );
		if( barsCurrentTimeframe != bars ){
		    barsCurrentTimeframe=bars;
		    onTimeframe();
        }

		checkClosedOrders();

		// M1
		bars = iBars( getSymbol(), PERIOD_M1 );
		if( barsM1 == bars ) return;
		barsM1=bars;
		onM1();

		// M5
		bars = iBars( getSymbol(), PERIOD_M5 );
		if( barsM5 == bars ) return;
		barsM5=bars;
		onM5();

		// M15
		bars = iBars( getSymbol(), PERIOD_M15 );
		if( barsM15 == bars ) return;
		barsM15=bars;
		onM15();

		// M30
		bars = iBars( getSymbol(), PERIOD_M30 );
		if( barsM30 == bars ) return;
		barsM30=bars;
		onM30();

		// H1
		bars = iBars( getSymbol(), PERIOD_H1 );
		if( barsH1 == bars ) return;
		barsH1=bars;
		onH1();

		// H4
		bars = iBars( getSymbol(), PERIOD_H4 );
		if( barsH4 == bars ) return;
		barsH4=bars;
		onH4();

		// D1
		bars = iBars( getSymbol(), PERIOD_D1 );
		if( barsD1 == bars ) return;
        barsD1=bars;
        onD1();
        //
        updateLogs();

		// W1
		bars = iBars( getSymbol(), PERIOD_W1 );
		if( barsW1 == bars ) return;
		barsW1=bars;
		onW1();

		// MN1
		bars = iBars( getSymbol(), PERIOD_MN1 );
		if( barsMN1 == bars ) return;
		barsMN1=bars;
		onMN1();
    }

	virtual void onTick(){

//        Print( "System.onTick now:", TimeCurrent() );
		UseEvent( TICK );
		notify( TICK );
	}

	virtual void onTickAfter(){
//        Print( "System.onTickAfter now:", TimeCurrent() );
		UseEvent( TICK_AFTER );
		notify( TICK_AFTER );
	}

	virtual void onTimeframe(){
		UseEvent( TIMEFRAME );
		notify( TIMEFRAME );
	}
	virtual void onM1(){
		UseEvent( M1 );
		notify( M1 );
	}
	virtual void onM5(){
		UseEvent( M5 );
		notify( M5 );
	}
	virtual void onM15(){
		UseEvent( M15 );
		notify( M15 );
	}
	virtual void onM30(){
		UseEvent( M30 );
		notify( M30 );
	}
	virtual void onH1(){
		UseEvent( H1 );
		notify( H1 );
	}
	virtual void onH4(){
		UseEvent( H4 );
		notify( H4 );
	}
	virtual void onD1(){
		UseEvent( D1 );
		notify( D1 );
	}
	virtual void onW1(){
		UseEvent( W1 );
		notify( W1 );
	}
	virtual void onMN1(){
		UseEvent( MN1 );
		notify( MN1 );
	}


	virtual string toString(){
	    string str = "System";
		if( trigger!=NULL ) str += "_"+ trigger.toString();

		int i, len;
		for( i=0, len=closes.Total(); i < len; i++ ) {
			Close* close = closes.At(i);
			str += "_"+ close.toString();		
		}
		if( stop!=NULL ) str += "_"+ stop.toString();
		if( takeProfit!=NULL ) str += "_"+ takeProfit.toString();
		for( i=0, len=filters.Total(); i < len; i++ ) {
			Filter* filter = filters.At(i);
			str += "_"+ filter.toString();		
		}
		for( i=0, len=plugins.Total(); i < len; i++ ) {
			Plugin* plugin = plugins.At(i);
			str += "_"+ plugin.toString();
		}
		return str; 
	};
};

#endif // System_