#ifndef Timer_
#define Timer_
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include "../Logic.mqh"

/**
 * 曜日,時間タイマー
 * TODO 夏時間対応
 */
class Timer: public Logic {

private:

    int _dayOfWeek;
    int _hour;
    int _min;
    int _sec;
    bool _summerTime;

    static const int gosaSec;

    datetime fired;
    datetime next;

public:
    /**
     * day
     */
    int dayOfWeek(){ return _dayOfWeek; }
    Timer* dayOfWeek( int value ) { _dayOfWeek = value; return GetPointer(this); }
    /**
     * hour
     */
    int hour(){ return _hour; }
    Timer* hour( int value ) { _hour = value; return GetPointer(this); }
    /**
     * min
     */
    int min(){ return _min; }
    Timer* min( int value ) { _min = value; return GetPointer(this); }
    /**
     * seconds
     */
    int sec(){ return _sec; }
    Timer* sec( int value ) { _sec = value; return GetPointer(this); }

    /**
     * summerTime
     */
    bool summerTime(){ return _summerTime; }
    Timer* summerTime( bool value ) { _summerTime = value; return GetPointer(this); }

public:
	Timer(): Logic(), _dayOfWeek(-1), _hour(-1), _sec(-1), _summerTime(false), fired(0) {

	};
	~Timer(){};

protected:
    /**
     * コンテキストが設定された状態での初期化処理
     */
    virtual void initWithContext(){
        // initial timer

        UseEvent( TICK );
        ctx().on( TICK, self() );

        setTimer();
    }

    virtual void onNotify( int eventType, Notifier* notifier, Hash* data = NULL ){

        UseEvent( TICK );
        if( eventType != TICK ) return;

        // TIMER
        datetime now = TimeCurrent();

        // filter
        if( now < next ) return;

        datetime filter = next + gosaSec;

        // calc next
        setTimer();

        // filter
        if( now > filter ) return;

        fired = now;
        //
        UseEvent( TIMER );
        notify( TIMER );
    }

private:

    void setTimer() {

        int month;

        datetime now = TimeCurrent();
        next = now + 1;

        month = TimeMonth( next );
        if( _summerTime && 3 <= month && month < 11 ) {
            next += 1 * 60* 60;
        }

        int diff;
        if( _sec != -1 ) {
            diff = _sec - TimeSeconds( next );
            if( diff < 0 ) diff += 60;
            next += diff;
        }
        if( _min != -1 ) {
            diff = _min - TimeMinute( next );
            if( diff < 0 ) diff += 60;
            next += diff * 60;
        }
        if( _hour != -1 ) {
            diff = _hour - TimeHour( next );
            if( diff < 0 ) diff += 24;
            next += diff * 60 * 60;
        }
        if( _dayOfWeek != -1 ) {
            diff = _dayOfWeek - TimeDayOfWeek( next );
            if( diff < 0 ) diff += 7;
            next += diff * 24 * 60 * 60;
        }

        // summer-time
        month = TimeMonth( next );
        if( _summerTime && 3 <= month && month < 11 ) {
            next -= 1 * 60* 60;
        }
    }


public:


	virtual string toString(){ return "Timer"; };
};
const int Timer::gosaSec = 10;

#endif // Timer_