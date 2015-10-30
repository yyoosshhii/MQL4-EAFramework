#ifndef Portfolio_
#define Portfolio_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


#include <Object.mqh>

#include <Arrays/ArrayObj.mqh>

#include "./System.mqh"

/**
 * contain multiple systems
 */
class Portfolio: public CObject {

//
private:
	CArrayObj* systems;
	int barsD1;

// Name
private:
    string name;
public:
	string getName(){ return name; }
	void setName( string value ){ name = value; }

// RiskCoeff
private:
    string riskCoeff;
public:
	string getRiskCoeff(){ return riskCoeff; }
	void setRiskCoeff( double value ){
	    riskCoeff = value;
	    // sync systems
		for( int i=0, len=systems.Total(); i<len; i++ ){
			System* sys = systems.At( i );
			sys.setRiskCoeff( value );
		}
    }

// Logger
private:
	bool logEnabled;
	datetime startAt;

	void outputLog() {
		if( !logEnabled ) return;
		int i,len;
		// systemのlogを使って生成する

        // marge samples
        System* sys = systems.At(0);
        int sysLen = systems.Total();
        CArrayObj* errors = new CArrayObj();
        CArrayInt* requests = new CArrayInt();
        for( i = 0, len = sys.timeline.Total(); i < len; i++ ) {
            CArrayInt* err = new CArrayInt();
            int req = 0;
            // sys loop TODO エラーにSystem判別情報入れたい。index?
            for( int k=0;k<sysLen;k++ ) {
                sys = systems.At(k);
                err.AddArray( (CArrayInt*) sys.errors.At(i) );
                req += sys.requests[i];
            }
            errors.Add(err);
            requests.Add(req);
        }

        // totals
        int errorTotal = 0;
        int requestTotal = 0;

        // timeseries data CSV
        sys = systems.At( systems.Total()-1 );
        CArrayInt* timeline = sys.timeline;
        CArrayFloat* values = sys.values;

        datetime end = TimeCurrent();
        string csvStr = "time,equity,request,error";
        for( i=0,len=timeline.Total();i<len;i++ ) {
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
        if( title == NULL ) title = "Portfolio";

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
	Portfolio* enableLog(){ logEnabled = true; return GetPointer(this); };

public:
    bool debugEnabled;
	Portfolio* enableDebug(){
	    debugEnabled = true;
		for( int i=0, len=systems.Total(); i<len; i++ ){
			System* sys = systems.At( i );
			sys.enableDebug();
        }
	    return GetPointer(this);
    };

public:

	Portfolio():
	name( NULL ), riskCoeff( 1.0 ), systems( new CArrayObj() ),barsD1(-1)
    {
		startAt = TimeCurrent();
	};

	~Portfolio(){

		outputLog();

		for( int i=0, len=systems.Total(); i<len; i++ ){
			System* sys = systems.At( i );
			delete sys;
		}
		delete systems;

	};

	System* putSystem( System* system ){
		systems.Add( system );
		// riskCoeff
		system.setRiskCoeff( riskCoeff );
		// debug
		if( debugEnabled ) system.enableDebug();

		return system;
	};

	void tick(){
		for( int i=0, len=systems.Total(); i<len; i++ ){
			System* sys = systems.At( i );
			sys.tick();
		}
	};
	void onTimer(){
		for( int i=0, len=systems.Total(); i<len; i++ ){
			System* sys = systems.At( i );
			sys.onTimer();
		}
	}

};

#endif // Portfolio_