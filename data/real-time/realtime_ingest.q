// Define schema for real-time stock data
realTimeData: ([] time:(); sym:(); high:(); low:(); open:(); close: ();volume:())
// Function to ingest real-time data into KDB+
.ingestRealTimeData: {[time; sym; open; high; low; close; volume] stockData insert (time; sym; open; high; low; close; volume)}
x:`time`sym`high`low`open`close`volume!10 "AAPL" 10 9 8 10 234
// Example to check the data
select from realTimeData


.ingestRealTimeData: {[time; sym; open; high; low; close; volume] time: `long$ time; sym: `symbol$ sym; open: `float$ open; high: `float$ high; low: `float$ low;close: `float$ close;volume: `int$ volume; `realTimeData insert (time; sym; open; high; low; close; volume);}