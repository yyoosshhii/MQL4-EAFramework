#ifndef MACDTrigger_
#define MACDTrigger_

/* フレームワーク */
#include <EAFramework/EAFramework.mqh>

/**
 * MACDによる仕掛け
 */
class MACDTrigger : public Trigger {

private:
    /* 短期MA期間 */
    int fastPeriods;
    /* 長期MA期間 */
    int slowPeriods;
    /* シグナル算出期間 */
    int signalPeriods;

public:
    /**
     * @param {int} fastPeriods_    短期MA期間
     * @param {int} [slowPeriods_]  長期MA期間 [オプション]
     * @param {int} [signalPeriods_]シグナル算出期間 [オプション]
     */
    MACDTrigger( int fastPeriods_, int slowPeriods_ = -1, int signalPeriods_ = -1 ): fastPeriods( fastPeriods_ ) {
        slowPeriods = slowPeriods_ != -1 ? slowPeriods_ : MathCeil( (double)fastPeriods/12 * 26 );
        signalPeriods = signalPeriods_ != -1 ? signalPeriods_ : MathCeil( (double)fastPeriods/12 * 9 );
    };
    ~MACDTrigger(){};

    /* 毎足Open時 */
    virtual void onTimeframe(){

        /* 1日前のMACD&Signal */
        double macd1 = iMACD( symbol(), timeframe(), fastPeriods, slowPeriods, signalPeriods, PRICE_MEDIAN, 0, 1 );
        double signal1 = iMACD( symbol(), timeframe(), fastPeriods, slowPeriods, signalPeriods, PRICE_MEDIAN, 1, 1 );

        /* 2日前のMACD&Signal */
        double macd2 = iMACD( symbol(), timeframe(), fastPeriods, slowPeriods, signalPeriods, PRICE_MEDIAN, 0, 2 );
        double signal2 = iMACD( symbol(), timeframe(), fastPeriods, slowPeriods, signalPeriods, PRICE_MEDIAN, 1, 2 );

        /* MACDがSignalを上回れば 買い */
        if( macd2 < signal2 && macd1 > signal1 )
            getContext().order( new OrderRequest( BUY ) );

        /* MACDがSignalを下回れば 売り */
        if( macd2 > signal2 && macd1 < signal1 )
            getContext().order( new OrderRequest( SELL ) );
    };

    /* デバッグ用途 ロジック名出力 */
    virtual string toString(){ return "MACDT_"+fastPeriods; };
};

#endif // MACDTrigger_