# -*- coding: utf-8 -*-
"""
-------------------------------------------------
   File Name：     fitness_service
   Description :
   Author :       guxu
   date：          6/22/24
-------------------------------------------------
   Change Activity:
                   6/22/24:
-------------------------------------------------
"""
import os.path
import time

import google.generativeai as genai
from ..utils.util import video_to_webp, make_image_path
import json
from ..enums.response_status import ResponseStatus
from apps.constants import LOCAL_UPLOAD_DIRECTORY
from dotenv import load_dotenv
from ..knowledgebase.local_file_knowledge import LocalFileKnowledge


load_dotenv()

class FitnessService:
    def __init__(self):
        # Create a Bedrock Runtime client in the AWS Region of your choice.
        self.model_id = "gemini-1.5-flash"
        self.response_format = {
            "rating": 80,
            "overall_evaluation": ["point1", "point2", "..."],
            "potential_improvement": [
                {"problem": "p1", "improvement": "i1"},
                {"problem": "p2", "improvement": "i2"},
                "..."
            ]
        }
        self.local_file_knowledge = LocalFileKnowledge("text")
        genai.configure(api_key=os.environ.get("GOOGLE_API_KEY"))

    def get_feedback(self, input_path):
        input_path = os.path.join(LOCAL_UPLOAD_DIRECTORY, input_path)
        print("input_path: ", input_path)
        webp_path = make_image_path(input_path)
        print("webp_path", webp_path)

        start_time = time.time()
        video_to_webp(input_path, webp_path)
        end_time = time.time()
        print("convert to webp: ", end_time - start_time)

        gemini_file = genai.upload_file(path=webp_path, display_name="webp")
        file = genai.get_file(name=gemini_file.name)

        documents = self.local_file_knowledge.search_with_fitness_type("quant")
        if isinstance(documents, list):
            documents_text = "\n\n".join(documents)
        else:
            documents_text = documents
        # 获取模型对象
        system_instruction = (
            "You are a senior fitness instructor who masters all fitness movements and excels at helping students correct improper techniques.\n\n"
            f"Reference information:\n{documents_text}"
        )
        model = genai.GenerativeModel(
            model_name=self.model_id,
            system_instruction=system_instruction
        )
        # 构造 Prompt
        prompt = (
            "Evaluate the fitness movement in the provided file, give a rating of the movement out of 100, "
            "and provide an overall evaluation. Point out any problems with the movement and how to improve it. "
            "Your answer must be in JSON format as described: "
            f"{self.response_format}"
        )
        resp = {}
        try:
            response = model.generate_content(
                [file, prompt],
                generation_config=genai.GenerationConfig(response_mime_type="application/json")
            )

            # 尝试将 response 解析为 JSON
            try:
                response_json = json.loads(response.text)
                resp.update(FitnessResponse.SUCCESS)
                resp.update({"data": response_json})
                print(resp)
            except json.JSONDecodeError as json_err:
                print(f"ERROR: Response is not a valid JSON. Reason: {json_err}")
                resp.update(FitnessResponse.FAIL)
                resp.update({"error": "Invalid JSON format in response"})

        except Exception as e:
            print(f"ERROR: Can't invoke '{self.model_id}'. Reason: {e}")
            resp.update(FitnessResponse.FAIL)
        return resp

class FitnessResponse(ResponseStatus):
    pass

if __name__ == '__main__':
    fitness_service = FitnessService()
    fitness_service.get_feedback("IMG_3723.MOV")