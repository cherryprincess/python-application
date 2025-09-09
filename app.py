from flask import Flask, jsonify
import logging
import os
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Configuration
app.config['DEBUG'] = os.getenv('DEBUG', 'False').lower() == 'true'
app.config['HOST'] = os.getenv('HOST', '0.0.0.0')
app.config['PORT'] = int(os.getenv('PORT', 8080))

def change(amount):
    """Calculate the resultant change and store the result (res)"""
    try:
        res = []
        coins = [1, 5, 10, 25]  # value of pennies, nickels, dimes, quarters
        coin_lookup = {25: "quarters", 10: "dimes", 5: "nickels", 1: "pennies"}

        # divide the amount*100 (the amount in cents) by a coin value
        # record the number of coins that evenly divide and the remainder
        coin = coins.pop()
        num, rem = divmod(int(amount * 100), coin)
        # append the coin type and number of coins that had no remainder
        if num > 0:  # Only add if there are coins
            res.append({num: coin_lookup[coin]})

        # while there is still some remainder, continue adding coins to the result
        while rem > 0:
            coin = coins.pop()
            num, rem = divmod(rem, coin)
            if num > 0:  # Only add if there are coins
                if coin in coin_lookup:
                    res.append({num: coin_lookup[coin]})
        
        logger.info(f"Change calculated for amount: {amount}, result: {res}")
        return res
    except Exception as e:
        logger.error(f"Error calculating change for amount {amount}: {str(e)}")
        raise


@app.route('/')
def hello():
    """Return a friendly HTTP greeting with health check info."""
    health_info = {
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'version': '1.0.0',
        'message': 'Hello World! Welcome to the python_flask demo website.'
    }
    logger.info("Health check endpoint accessed")
    return jsonify(health_info)


@app.route('/health')
def health():
    """Health check endpoint for monitoring."""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat()
    })


@app.route('/change/<dollar>/<cents>')
def changeroute(dollar, cents):
    """Calculate change for given dollar and cents amount."""
    try:
        logger.info(f"Make Change request for {dollar}.{cents}")
        amount = f"{dollar}.{cents}"
        result = change(float(amount))
        return jsonify({
            'input': f"${dollar}.{cents}",
            'change': result,
            'timestamp': datetime.utcnow().isoformat()
        })
    except ValueError as e:
        logger.error(f"Invalid input for change calculation: {dollar}.{cents}")
        return jsonify({
            'error': 'Invalid input. Please provide valid dollar and cents values.',
            'timestamp': datetime.utcnow().isoformat()
        }), 400
    except Exception as e:
        logger.error(f"Error processing change request: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'timestamp': datetime.utcnow().isoformat()
        }), 500


if __name__ == '__main__':
    logger.info(f"Starting Flask application on {app.config['HOST']}:{app.config['PORT']}")
    app.run(
        host=app.config['HOST'], 
        port=app.config['PORT'], 
        debug=app.config['DEBUG']
    )