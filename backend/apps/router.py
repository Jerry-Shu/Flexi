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
from pydub import AudioSegment
import io
import os
import base64

file_upload_service = FileUploadService()
fitness_service = FitnessService()

gemini_agent = "agent1qtc6nzpxmhj9za3unpusd692netap02aujs825086yz4musk88rjwrq6l5g"
deepgram_agent = "agent1qg6tklqzs43xscskfctxgw6h9zgt8p33k38jlptge58ajr75xfpmw379h8s"
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

class Text2AudioRequest(Model):
    text: str
def load_audio_to_memory(audio_path, format=None):
    if not audio_path:
        return None

    if format is None:
        format = os.path.splitext(audio_path)[1][1:]
    # 读取音频文件，保持原始格式
    audio = AudioSegment.from_file(audio_path, format=format)

    # 将音频文件转换为字节流并存储到内存中，保持原始格式
    audio_bytes_io = io.BytesIO()
    audio.export(audio_bytes_io, format=format)  # 保持原始格式导出
    # 返回内存中的音频数据
    return audio_bytes_io.getvalue()
async def agent_query(gemini_req):
    response = await query(destination=gemini_agent, message=gemini_req, timeout=60)
    data = json.loads(response.decode_payload())
    print("data", data)
    text = str(data["data"])
    deepgram_req = Text2AudioRequest(text=text)
    audio_path = await query(destination=deepgram_agent, message=deepgram_req, timeout=60)
    audio_path = json.loads(audio_path.decode_payload())
    audio_file = load_audio_to_memory(audio_path["audio_path"])
    audio_base64 = base64.b64encode(audio_file).decode('utf-8')
    data["data"]["audio"] = audio_base64
    return data
@app.route('/api/evaluate', methods=['POST'])
async def evaluate():
    data = request.get_json()
    url = data["url"]
    gemini_req = QueryRequest(url=url)
    res = await agent_query(gemini_req)
    return jsonify(res)