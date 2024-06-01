import yfinance as yf
import pandas as pd

# Download historical data for a specific stock
def download_data(symbol, start_date, end_date):
    data = yf.download(symbol, start=start_date, end=end_date)
    data.reset_index(inplace=True)
    return data

# Example usage
stock_list = [
    "AAPL",
    "MSFT",
    "GOOGL",
    "AMZN",
    "META"  
]
for symbol in stock_list:
    # symbol = "AAPL"
    start_date = "2023-01-01"
    end_date = "2024-05-27"
    data = download_data(symbol, start_date, end_date)

    # Save the data to a CSV file
    data.to_csv(f"data/historical/{symbol}.csv", index=False)
