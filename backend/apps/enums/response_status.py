# -*- coding: utf-8 -*-
"""
-------------------------------------------------
   File Name：     response_status
   Description :
   Author :       guxu
   date：          6/22/24
-------------------------------------------------
   Change Activity:
                   6/22/24:
-------------------------------------------------
"""

class ResponseStatus:
    SUCCESS = {"statusCode": 0, "statusMessage": "Success"}
    FAIL = {"statusCode": 900000, "statusMessage": "Internal Server Error"}