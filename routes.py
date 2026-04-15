from bottle import template, static_file

def setup_routes(app):
    
    @app.route('/')
    def index():
        return template('index')
    
    @app.route('/direct_lp', method=['GET', 'POST'])
    def direct_lp():
        from controllers.direct_lp import direct_lp_handler
        return direct_lp_handler()
    
    @app.route('/transport')
    def transport():
        return template('transport')
    
    @app.route('/assignment')
    def assignment():
        return template('assignment')
    
    @app.route('/video')
    def video():
        return template('video')
    
    @app.route('/authors')
    def authors():
        return template('authors')
    
    @app.route('/contact')
    def contact():
        return template('contact')
    
    @app.route('/static/<filepath:path>')
    def serve_static(filepath):
        return static_file(filepath, root='static')