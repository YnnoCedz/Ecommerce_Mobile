from flask import Flask
from config import Config
from extensions import mail
from forgot_password import forgot_password_bp

app = Flask(__name__)
app.config.from_object(Config)

mail.init_app(app)

app.register_blueprint(forgot_password_bp)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
