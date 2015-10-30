#ifndef CustomError_
#define CustomError_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

/**
 *
 */
class CustomError {

public:
    /**
     * トレードロット数を丸めた結果、指定値とかけ離れた場合
     * error core: 65537
     */
	static void OUT_OF_RANGE_TRADE_VOLUME(){ SetUserError(1); };

    /**
     * エラー多発のため、システムを停止
     * error core: 65538
     */
	static void SYSTEM_DOWN_BY_ERRORS(){ SetUserError(2); };

};
#define ERROR_OUT_OF_RANGE_TRADE_VOLUME 65537


#endif // CustomError_