# -*- coding: utf-8 -*-
"""
-------------------------------------------------
   File Name：     router
   Description :
   Author :       guxu
   date：          6/22/24
-------------------------------------------------
   Change Activity:
                   6/22/24:
-------------------------------------------------
"""
from . import app
from .services.file_upload_service import FileUploadService
from .services.fitness_service import FitnessService
from flask import request, jsonify
from uagents import Model
from uagents.query import query
import json

file_upload_service = FileUploadService()
fitness_service = FitnessService()

user_agent = "agent1qtc6nzpxmhj9za3unpusd692netap02aujs825086yz4musk88rjwrq6l5g"
@app.route('/')
def index():
    return "OK"

@app.route('/api/upload', methods=['POST'])
def upload():
    img = request.files["file"]
    response = file_upload_service.upload_img(img)
    return jsonify(response)

class QueryRequest(Model):
    url: str
async def agent_query(req):
    response = await query(destination=user_agent, message=req, timeout=30)
    data = json.loads(response.decode_payload())
    return data
@app.route('/api/evaluate', methods=['POST'])
async def evaluate():
    data = request.get_json()
    url = data["url"]
    req = QueryRequest(url=url)
    res = await agent_query(req)
    return jsonify(res)