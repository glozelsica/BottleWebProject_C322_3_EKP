from bottle import Bottle, run
from routes import setup_routes

app = Bottle()
setup_routes(app)

if __name__ == '__main__':
    run(app, host='localhost', port=8080, reloader=True)