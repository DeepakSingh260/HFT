// data loading code
stockData: get `:stockData;
stockData.Close
stockData;
.loadData:{[]  stockData: get `:stockData;  stockData.Volume }
.loadProcessAAPL:{[] ProcessAAPL:get `:ProcessAAPL};
//Preprocessing code 

vol:.loadData[]
ProcessAAPL : .loadProcessAAPL[];
ProcessAAPL;
.Macd : { [stockData;sym] 
    macd: { [x] ema[ 2%13 ; x ] - ema[ 2% 27; x ] } ;
    signal : { ema[ 2%10 ; x]};
    res: select Date, Sym, Close,
        EMA_12: ema[2%13; Close],
        EMA_26: ema[2%27; Close],
        MACD: macd[Close]
        
        from stockData where Sym = sym;
    res: update Signal: signal[MACD] from res;
    :select from res;
        
 };

table: .Macd[stockData;`AAPL];

show table.Close

//data ploting code
.plot:{[x]
  .qp.go[500;500]
    .qp.title["MCDA"]
    .qp.theme[.gg.theme.clean]
      .qp.stack(
        .qp.line[x; `Date; `EMA_12]
          .qp.s.geom[enlist[`fill]!enlist .gg.colour.Blue]
          ,.qp.s.legend["";
            `EMA_12`EMA_26`Close!(.gg.colour.Blue;.gg.colour.Red;.gg.colour.Green)]
          ,.qp.s.labels[`x`y!("Date";"Price")];
        .qp.line[x; `Date; `EMA_26]
          .qp.s.geom[enlist[`fill]!enlist .gg.colour.Red]
            ,.qp.s.labels[`x`y!("Date";"Price")];
        .qp.line[x; `Date; `Close]
          .qp.s.geom[enlist[`fill]!enlist .gg.colour.Green]
          ,.qp.s.labels[`x`y!("Date";"Price")])}

.plot[ select from table  ];

//forecast close using linear regression

.forecast : { [table]
    dates : table.Date;
    dateNum : "i"$dates;
    model : .ml.online.sgd.linearRegression.fit[ dateNum; table.Close ; 1b; `maxIter`alpha!(1000;0.01) ] ;
    show model;
    

 };

.forecast[ table ]
\l C:/Users/alexm/Downloads/w64/ml/ml.q

.ml.loadfile`:util/init.q
.ml.loadfile`:timeseries/init.q

\l utils/graphics.q


 