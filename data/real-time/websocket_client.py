import websocket
import json
import qpython.qconnection as qconn
import time
import sys
import logging
import datetime

# Configure logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s %(message)s')
logger = logging.getLogger()

# Authentication token for Polygon.io (replace with your actual token)
api_key= ''
dataset = 'sip_non_pro'
tickers = ['AAPL','GOOGL','MSFT','AMZN','META']


def on_message(ws, message):
    try:
        data = json.loads(message)
        
        # Handle incoming status messages (such as connection, authentication, etc.)
        if isinstance(data, list) and 'ev' in data[0] and data[0]['ev'] == 'status':
            logger.info(f"Received status message: {data}")
            return
        logger.debug(f"all data: {data}")
        # Assuming data contains time, symbol, price, and volume
        if isinstance(data, dict):
            q_data = {
                'time': data.get('t') ,
                'sym': data.get('s'),
                'high': data.get('h'),
                'low': data.get('l'),
                'open': data.get('o'),
                'close': data.get('c'),
                'volume': data.get('v')
            }
            
            # Send data to KDB+
            logger.debug(f"Ingesting data: {q_data}")
            q.sendSync('.ingestRealTimeData', q_data['time'], q_data['sym'], q_data['high'], q_data['low'], q_data['open'], q_data['close'], q_data['volume'])

    except Exception as e:
        logger.error(f"Error in on_message: {e}")

def on_error(ws, error):
    logger.error(f"Error: {error}")

def on_close(ws, close_status_code, close_msg):
    logger.info(f"### closed ### Code: {close_status_code}, Reason: {close_msg}")
    
def subscribe(wsapp, dataset, tickers):
    sub_request = {
        'event': 'subscribe',
        'dataset': dataset,
        'tickers': tickers,
        'channel': 'bars',
        'frequency': '10s',
        'aggregation': '1m'
    }
    wsapp.send(json.dumps(sub_request))

def on_open(ws):
    logger.info("### opened ###")
    try:
        print('Connection is opened')
        subscribe(ws, dataset, tickers)
    except Exception as e:
        logger.error(f"Error in on_open: {e}")

if __name__ == "__main__":
    websocket.enableTrace(True)
    
    logger.info("start")

    # Initialize and open connection to KDB+
    try:
        q = qconn.QConnection(host='localhost', port=5000)
        q.open()
        logger.info("Connected to KDB+")
    except Exception as e:
        logger.error(f"Error connecting to KDB+: {e}")
        sys.exit(1)

    ws = websocket.WebSocketApp(f'wss://ws.finazon.io/v1?apikey={api_key}',
                                on_open=on_open,
                                on_message=on_message,
                                on_error=on_error)
    ws.on_open = on_open
    logger.info("connection setup")
    ws.run_forever()
