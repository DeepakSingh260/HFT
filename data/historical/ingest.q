// Define schema for historical stock data
stockData:([] Date:`date$(); Open:`float$(); High:`float$(); Low:`float$(); Close:`float$(); Adj_Close:`float$(); Volume:`int$(); Sym:`symbol$()) 
loadCSV:{[file; sym]
    / Read the CSV file
    rawData: read0 file;
    header: first rawData;
    data: ("DFFFFFI"; enlist ",") 0: rawData;
    data: update Sym:sym from data;
    data: update Volume:`int$Volume from data
    `stockData insert data
 }

// Example usage
stock_list: `AAPL`MSFT
{
    file_path: raze string x, ".csv";
    file: `$file_path;
    / read0 file;
    loadCSV[file; x]
 } each stock_list

// Save the table to disk for persistence
/ save `stockData
