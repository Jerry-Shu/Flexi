# Created by guxu at 10/19/24
import os
import random
import time

from uagents import Agent, Context, Protocol, Model
import requests
from dotenv import load_dotenv
from . import AUDIO_PATH

load_dotenv()

class Text2AudioRequest(Model):
    text: str

class Text2AudioResponse(Model):
    audio_path: str

url = "https://api.deepgram.com/v1/speak?model=aura-asteria-en"
headers = {
    "Authorization": f"Token {os.getenv('DEEPGRAM_API_KEY')}",
    "Content-Type": "application/json"
}
deepgram_agent = Agent(
    name="deepgram_agent",
    seed="deepgram_agent",
    port=8002,
    endpoint=["http://localhost:8002/submit"],
)
print("uAgent address: ", deepgram_agent.address)
summary_protocol = Protocol("Text to Audio")

def make_audio_file_name():
    random_number = str(random.randint(10000, 20000))
    return random_number + ".mp3"
@deepgram_agent.on_query(model=Text2AudioRequest, replies={Text2AudioResponse})
async def query_handler(ctx: Context, sender: str, _query: Text2AudioRequest):
    ctx.logger.info("Text to Audio Request received")
    pay_load = {
        "text": _query.text
    }
    try:
        response = requests.post(url, headers=headers, json=pay_load)
        if response.status_code == 200:
            audio_path = os.path.join(AUDIO_PATH, make_audio_file_name())
            with open(audio_path, "wb") as f:
                f.write(response.content)
            print("File saved successfully.")
            await ctx.send(sender, Text2AudioResponse(audio_path=audio_path))
        else:
            print(f"Error: {response.status_code} - {response.text}")
    except Exception as e:
        print(e)
        await ctx.send(sender, Text2AudioResponse(audio_path=""))

deepgram_agent.include(summary_protocol, publish_manifest=True)
deepgram_agent.run()