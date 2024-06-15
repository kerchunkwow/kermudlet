# Destination Chat ID: 715565544
# 7118770481:AAEMvomEAOiCFjoCu_fSdxlBmUZ8GSYG4Hs

import requests
import sys

# Pass message to Telegram bot
def send_telegram_message( bot_token, chat_id, message ):
    url      = f'https://api.telegram.org/bot{bot_token}/sendMessage'
    data     = {'chat_id': chat_id, 'text': message}
    response = requests.post(url, data=data)
    print( response.text )

# With arguments from command line; send a message to a destination Telegram chat/bot
if __name__ == "__main__":
    bot_token = sys.argv[1]
    chat_id   = sys.argv[2]
    message   = sys.argv[3]
    send_telegram_message( bot_token, chat_id, message )
