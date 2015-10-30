#property copyright "Copyright 2015 yyoosshhii"
#property version   "0.0.0"
#property strict

/* Frameworkを導入 */
#include <EAFramework/EAFramework.mqh>

/* トリガーロジック */
#include "logics/trigger/MACDTrigger.mqh"
// params
input int MACDTrigger_fastPeriods = 12;
input int MACDTrigger_slowPeriods = 26;
input int MACDTrigger_signalPeriods = 9;

/* 値段ロジック */
#include "logics/open/MarketOrderOpen.mqh"

/* 手仕舞いロジック */
#include "logics/close/TimeoutClose.mqh"
// params
input int TimeoutClose_periods = 5;

/* 損切りロジック */
#include "logics/sl/ATRStop.mqh"
// params
input int ATRStop_periods = 120;
input double ATRStop_mult = 2.0;

/* 利食いロジック */
#include "logics/tp/ATRTakeProfit.mqh"
// params
input int ATRTakeProfit_periods = 120;
input double ATRTakeProfit_mult = 2.0;

/* フィルターロジック */
#include "logics/filter/RSIFilter.mqh"
// params
input int RSIFilter_periods = 7;
input double RSIFilter_threshold = 30.0;

/* ポジションサイジングロジック */
#include "logics/sizing/FixedRiskSizing.mqh"
// params
input double FixedRiskSizing_risk = 0.01;

// システム
System* sys = NULL;


int OnInit() {

    /* システムを構築する */
    sys = new System()
        /* トリガー設定 */
        .setTrigger( new MACDTrigger(
            MACDTrigger_fastPeriods,
            MACDTrigger_slowPeriods,
            MACDTrigger_signalPeriods
        ))
        /* 値段設定 */
        .setOpen( new MarketOrderOpen() )
        /* 手仕舞い設定 */
        .putClose( new TimeoutClose(
            TimeoutClose_periods
        ))
        /* 損切り設定 */
        .setStop( new ATRStop(
            ATRStop_periods,
            ATRStop_mult
        ))
        /* 利食い設定 */
        .setTakeProfit( new ATRTakeProfit(
            ATRTakeProfit_periods,
            ATRTakeProfit_mult
        ))
        /* フィルター設定 */
        .putFilter( new RSIFilter(
            RSIFilter_periods,
            RSIFilter_threshold
        ))
        /* ポジションサイジング設定 */
        .setSizing( new FixedRiskSizing(
            FixedRiskSizing_risk
        ))
        /* ログ出力を許可 */
        .enableDebug();

    //
    return INIT_SUCCEEDED;
}

void OnTick() {
    /* ティック更新をシステムへ伝える */
    sys.tick();
}

void OnDeinit( const int reason ) {
    /* システムを破棄する */
    delete sys;
    sys = NULL;
}

double OnTester() { return 0.0; }
