# Created by guxu at 10/19/24

from uagents import Agent, Context, Protocol, Model
from typing import Dict
from ..services.fitness_service import FitnessService

class QueryRequest(Model):
    url: str

class QueryResponse(Model):
    data: Dict
    statusCode: int
    statusMessage: str
class FitMovementRequest(Model):
    movement_file: str

class FitMovementResponse(Model):
    feedback: Dict


agent = Agent(
    name="user_agent",
    seed="user_agent",
    port=8001,
    endpoint=["http://localhost:8001/submit"],
)

print("uAgent address: ", agent.address)
summary_protocol = Protocol("Text Summarizer")

gemini_agent = "agent1qgvptfzsfqvtzt5yq72ucfyrv6vm9t5mq2ewvfc06axmtvdathllv7e87nf"

fitness_service = FitnessService()


@agent.on_message(model=FitMovementResponse)
async def send_response(ctx: Context, sender: str, msg: FitMovementResponse):
    ctx.logger.info(msg.feedback)

@agent.on_query(model=QueryRequest, replies={QueryResponse})
async def query_handler(ctx: Context, sender: str, _query: QueryRequest):
    ctx.logger.info("Query received")
    try:
        resp = fitness_service.get_feedback(_query.url)
        await ctx.send(sender, QueryResponse(data=resp["data"], statusCode=resp["statusCode"], statusMessage=resp["statusMessage"]))
    except Exception as e:
        print(e)
        await ctx.send(sender, QueryResponse(data={}, statusCode=900000, statusMessage="Internal Error"))

# agent.include(summary_protocol, publish_manifest=True)
agent.run()
