#ifndef EAFramework_
#define EAFramework_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// core
#include "./Context.mqh"
#include "./System.mqh"
#include "./Portfolio.mqh"
#include "./OrderInfo.mqh"
#include "./OrderOperation.mqh"
#include "./OrderRequest.mqh"
#include "./Logic.mqh"

// logics
#include "./logics/Close.mqh"
#include "./logics/Filter.mqh"
#include "./logics/Plugin.mqh"
#include "./logics/Sizing.mqh"
#include "./logics/Stop.mqh"
#include "./logics/TakeProfit.mqh"
#include "./logics/Trigger.mqh"

// util
#include "./util/Util.mqh"
#include "./util/CircularBuffer.mqh"
#include "./util/Timer.mqh"
#include "./util/Sampling.mqh"

#endif // EAFramework_