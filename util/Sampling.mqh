#ifndef Sampling_
#define Sampling_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "../Context.mqh"

#include <Files/FileTxt.mqh>
#include <Arrays/ArrayInt.mqh>
#include <Arrays/ArrayFloat.mqh>

/**
 *
 * @class
 */
class Sampling: public Context {

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
public:
	CArrayInt* timeline;

	CArrayFloat* prices;

	CArrayFloat* samples;

protected:
    int numIndicators;
	virtual void doSampling( CArrayFloat* samples ){
	    samples.Add( 1.0 );
	}

private:

	void updateLogs() {
	    // サンプリングは飛ばさない。ポートフォリオでマージするかも。
        //if( !logEnabled ) return;

        // log
        timeline.Add( StrToTime( TimeToString( TimeCurrent(), TIME_DATE ) ) );
        prices.Add( Bid );

        doSampling( samples );
	}

	void outputLog() {

	    //
		if( !logEnabled ) return;

        // totals
        int errorTotal = 0;
        int requestTotal = 0;

        int i;

        // timeseries data CSV
        datetime end = TimeCurrent();

        // header
        string csvStr = "time,price";
        for( i=0; i<numIndicators; i++ )
            csvStr += ",i"+i;

        // body
        for( int index=0,len=timeline.Total(); index<len; index++ ) {
            csvStr += "\n"+ timeline[index] +","+ prices[index] +"";
            for( i=0; i<numIndicators; i++ )
                csvStr += ","+ samples[ index * numIndicators + i ];
        }

        //
        string title = name;
        if( title == NULL ) title = toString();

        // ファイル出力
        string fileName = title +"__"+ TimeToString( startAt, TIME_DATE ) +"_"+ TimeToString( end, TIME_DATE );
        while( FileIsExist( fileName+".csv" ) ) fileName += "_";
        CFileTxt* file;
        // CSV
        file = new CFileTxt();
        file.Open( fileName +".csv", FILE_WRITE );
        file.WriteString( csvStr );
        delete file;
    }

public:
	Sampling* enableLog(){ logEnabled = true; return GetPointer(this); };


private:
    // 各足の更新判別用
	int barsCurrentTimeframe;
	int barsD1;


public:
    /**
     * constructor
     */
	Sampling( string symbol_ = NULL, int timeframe_ = PERIOD_CURRENT ):
	Context( symbol_, timeframe_ ),
	name( NULL ),
	numIndicators( 0 ),
	// 足の進捗状態
	barsCurrentTimeframe( -1 ), barsD1(-1),
	timeline( new CArrayInt() ), prices(new CArrayFloat()), samples(new CArrayFloat())
	{
		startAt = TimeCurrent();
		Print("new Sampling");
	};

	/**
	 * destructor
	 */
	~Sampling(){
	    outputLog();
	};

public:

    /**
     * processing of every tick.
     * TODO high-load
     */
	void tick() {
	    // down... ログ出力だけ行う
            // D1
        int tmp = iBars( getSymbol(), PERIOD_D1 );
        if( barsD1 != tmp ){
            barsD1=tmp;
            updateLogs();
        }

		onTick();

		datetime time = TimeCurrent();
		int bars;

		// CurrentTimeframe
		bars = iBars( getSymbol(), getTimeframe() );
		if( barsCurrentTimeframe != bars ){
		    barsCurrentTimeframe=bars;
		    onTimeframe();
		}
	};

private:

	virtual void onTick(){

	}
	virtual void onTimeframe(){

	}

	virtual string toString(){
	    string str = "Sampling";
		return str; 
	};
};

#endif // Sampling_