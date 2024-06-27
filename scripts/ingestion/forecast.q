stockData: get `:stockData;
close_price: stockData.Close;
sma_20: 20 mavg close_price;
ema_20: (2 % 1+20) ema close_price;

/Calculate Volume Weighted Average
/  select Volume wavg Close by Sym from stockData

ema_50: (2 % 1+50) ema close_price;

/ buy_signal:  ema_20 > ema_50 by sym from stockData

select emfDiff:ema[2%21; Close] - ema[2%51; Close]  by Sym from stockData 

date : select date where Sym = `AAPL from stockData 
date: data.x



ProcessAAPL: ([] Date:date; MovingAverage20:MVA_20 ; ExpoAverage20: EMA_20 ; ExpoAverage50: EMA_50  );

