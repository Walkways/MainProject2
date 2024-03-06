from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from os import path
from flask_login import LoginManager
import os



db = SQLAlchemy()
# DB_NAME = "database.db"
DB_NAME = "test"


def create_app():
    app = Flask(__name__)

    # app.config["MYSQL_DATABASE_USER"] = "root"
    # app.config["MYSQL_DATABASE_PASSWORD"] = "test"
    # app.config["MYSQL_DATABASE_DB"] = "test"
    # app.config["MYSQL_DATABASE_HOST"] = "localhost"
    # app.config["MYSQL_DATABASE_PORT"] = 3306
    
    app.config['SECRET_KEY'] = "helloworld"
    # app.config['SQLALCHEMY_DATABASE_URI'] = f'sqlite:///{DB_NAME}'
    # app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql://username:password@00.00.00.00/dbname'
    # app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://root:@localhost/test"
    # app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://root:@localhost/" + "database.db"
    # app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://root:@localhost/test"    
    # app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://root:@127.0.0.1:3306/test"
    # app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://root:@localhost:3306/test"
    # app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://root:test@localhost/test"
    # app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://root:test@127.0.0.1:3306/test"

    # app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://root:@127.0.0.1:3306/test3"
    ip = os.environ.get('BDD_IP', 'valeur_par_defaut')
    mdp = os.environ.get('BDD_MDP', 'valeur_par_defaut')
    chaine = "mysql+pymysql://mansour:" + mdp + "@" + ip + ":3306/test"
    # ma_variable = os.environ.get('MA_VARIABLE', 'valeur_par_defaut')
    app.config['SQLALCHEMY_DATABASE_URI'] = chaine
    # app.config['SQLALCHEMY_DATABASE_URI'] = "mysql+pymysql://mansour:mdp00@00.00.000.000:3306/test"

    db.init_app(app)

    from .views import views
    from .auth import auth

    app.register_blueprint(views, url_prefix="/")
    app.register_blueprint(auth, url_prefix="/")

    from .models import User, Post, Comment, Likes

    create_database(app)

    login_manager = LoginManager()
    login_manager.login_view = "auth.login"
    login_manager.init_app(app)

    @login_manager.user_loader
    def load_user(id):
        return User.query.get(int(id))

    return app


def create_database(app):
    if not path.exists("website/" + DB_NAME):
        db.create_all(app=app)
        print("Created database!")
