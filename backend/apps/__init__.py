# Created by guxu at 10/19/24
from flask import Flask
import os
from flask_cors import CORS

# create a Flask application
app = Flask(__name__)


# app.debug = True


CORS(app)

import apps.router