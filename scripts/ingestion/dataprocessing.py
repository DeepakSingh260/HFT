import qpython.qconnection as qconn
import pandas as pd
import matplotlib.pyplot as plt

# Connect to the KDB+ instance
q = qconn.QConnection(host='localhost', port=5000)
q.open()
columns = ["Date", "Open" , "High", "Low", "Close",  "Adj_Close", "Volume", "Sym"]
# Function to load data from KDB+ table into a Pandas DataFrame
def load_data_from_kdb(table_name):
    query = f"select from {table_name}"
    result = q.sendSync(query)
    # print(result)
    df = pd.DataFrame(result, columns= columns)
    return df

# Load historical stock data from KDB+ table into a Pandas DataFrame
historical_data = load_data_from_kdb('stockData')

historical_data['Sym'] = historical_data['Sym'].str.decode('utf-8')
historical_data['Date'] = pd.to_datetime(historical_data['Date'], unit='D', origin='2000-01-01')

# Data Exploration
summary_statistics = historical_data.describe()
# print(summary_statistics)

# Visualization
plt.figure(figsize=(10, 6))
for sym in historical_data['Sym'].unique():
    sym_data = historical_data[historical_data['Sym'] == sym]
    print(sym_data['Close'].values)
    plt.plot(sym_data['Date'].values, sym_data['Close'].values, label=f'{sym} Close Price')
plt.xlabel('Date')
plt.ylabel('Price')
plt.title('Historical Stock Prices')
plt.legend()
plt.show()


# Feature Engineering: Adding Moving Averages and Volatility
historical_data['SMA_20'] = historical_data.groupby('Sym')['Close'].transform(lambda x: x.rolling(window=20).mean())
historical_data['SMA_50'] = historical_data.groupby('Sym')['Close'].transform(lambda x: x.rolling(window=50).mean())
historical_data['EMA_20'] = historical_data.groupby('Sym')['Close'].transform(lambda x: x.ewm(span=20, adjust=False).mean())
historical_data['Volatility'] = historical_data.groupby('Sym')['Close'].transform(lambda x: x.pct_change().rolling(window=20).std())




# Close the connection to the KDB+ instance
q.close()
