// Define schema for real-time stock data
// Function to ingest real-time data into KDB+
//.ingestRealTimeData: {[time; sym; open; high; low; close; volume] stockData insert (time; sym; open; high; low; close; volume)}
//x:`time`sym`high`low`open`close`volume!10 "AAPL" 10 9 8 10 234 //This won't work as you cannot have different type in same array
// Example to check the data


//The true code
realTimeData: ([] time:(); sym:(); high:(); low:(); open:(); close: ();volume:())
select from realTimeData

/ diff : 10957 * 24 * 60 * 60; time_zone_diff: 4*60*60; diff: diff+time_zone_diff; diff: diff*1e9;diff:"j"$diff;
/ .ingestRealTimeData: {[time; sym; open; high; low; close; volume] time: "j"$time*1e9;  time: "p"$time-diff ; sym: `$ sym; open: `float$ open; high: `float$ high; low: `float$ low;close: `float$ close;volume: `int$ volume; `realTimeData insert (time; sym; open; high; low; close; volume);}

.ingestRealTimeData: {[time; sym; open; high; low; close; volume] time: .z.p ; sym: `$ sym; open: `float$ open; high: `float$ high; low: `float$ low;close: `float$ close;volume: `int$ volume; `realTimeData insert (time; sym; open; high; low; close; volume);}

/ analyzeData:{[data] ma: select sym, avg price by 5 xbar time.minute from data ;ma}
    select close by sym  from ( select avg close by 5 xbar time.minute, sym  from realTimeData)

processRealTimeData: ([] time:(); sym:(); high:(); low:(); open:(); close: ();volume:(); moving_average_20: (); expo_average_20 : (); expo_average_50 : ()  )


//connect to ticker plant 
h:neg hopen `:localhost:5000 /

.calculateMovingAverage: {
    [data]
    ma20: select time,sym,high,low,open,close,volume ,moving_average_20: mavg[ 20; close ] from data;
    ema20: select sym,time, expo_average_20: ema[ 2%21; close ]   from data;
    ema50: select sym,time, expo_average_50: ema[ 2%51; close ]   from data;
    ema20: ( [sym:ema20`sym; time:ema20`time] expo_average_20: ema20`expo_average_20 );
    ema50: ( [sym:ema50`sym; time:ema50`time] expo_average_50: ema50`expo_average_50 );
    ema_table: lj[ema20;ema50];
    combined: ma20 lj ema_table;
    :last combined
 }

.calculateMovingAverage: { [data] ma20: select time,sym,high,low,open,close,volume ,moving_average_20: mavg[ 20; close ] from data; ema20: select sym,time, expo_average_20: ema[ 2%21; close ]   from data; ema50: select sym,time, expo_average_50: ema[ 2%51; close ]   from data; ema20: ( [sym:ema20`sym; time:ema20`time] expo_average_20: ema20`expo_average_20 ); ema50: ( [sym:ema50`sym; time:ema50`time] expo_average_50: ema50`expo_average_50 ); ema_table: lj[ema20;ema50]; combined: ma20 lj ema_table; :last combined }
.z.ts:{ data1 : .calculateMovingAverage[ select from realTimeData where sym=`MSFT ]; data2 : .calculateMovingAverage[ select from realTimeData where sym=`AAPL ] ; h({[trade;x] `trade insert x};`trade; data1 );  h({[trade;x] `trade insert x};`trade; data2); }
/trigger timer every 100ms
\t 100

trade: ([] time: `timestamp$(); sym: `symbol$(); high: `float$(); low: `float$();  open: `float$(); close: `float$(); volume: `int$();moving_average_20: `float$(); expo_average_20: `float$();expo_average_50: `float$())

.h({[trade;x] `trade insert x}; `trade; (( last data1`time; last data1`sym; last data1`high; last data1`low; last data1`open; last data1`close; last data1`volume; last data1`moving_average_20; last data1`expo_average_20; last data1`expo_average_50)));