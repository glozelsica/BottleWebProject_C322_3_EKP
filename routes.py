from bottle import static_file, template

def setup_routes(app):
    
    @app.route('/')
    def index():
        return template('index')
    
    @app.route('/direct_lp', method=['GET', 'POST'])
    def direct_lp():
        from controllers.direct_lp import solve_direct_lp
        return solve_direct_lp()
    
    @app.route('/video')
    def video():
        return template('video')
    
    @app.route('/static/<filepath:path>')
    def static(filepath):
        return static_file(filepath, root='static')
    
    # заглушки для страниц других участников
    @app.route('/transport')
    def transport():
        return template('base', content_template='transport_content')
    
    @app.route('/assignment')
    def assignment():
        return template('base', content_template='assignment_content')
    
    @app.route('/authors')
    def authors():
        return template('base', content_template='authors_content')
    
    @app.route('/contact')
    def contact():
        return template('base', content_template='contact_content')