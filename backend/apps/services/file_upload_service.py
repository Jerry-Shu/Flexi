# -*- coding: utf-8 -*-
"""
-------------------------------------------------
   File Name：     upload_file
   Description :
   Author :       guxu
   date：          6/22/24
-------------------------------------------------
   Change Activity:
                   6/22/24:
-------------------------------------------------
"""
import os
from ..utils.util import gen_random_string
from ..enums.response_status import ResponseStatus
from apps.constants import LOCAL_UPLOAD_DIRECTORY

class FileUploadService():

    def __init__(self):
        self.upload_directory = LOCAL_UPLOAD_DIRECTORY
        if not os.path.exists(self.upload_directory):
            os.mkdir(self.upload_directory)


    def upload_img(self, file):
        response = {}
        try:
            if file:
                # Ensure the upload directory exists
                if not os.path.exists(self.upload_directory):
                    os.makedirs(self.upload_directory)

                # Convert file to bytearray and generate a unique filename
                deduplicated_filename = gen_random_string(5) + file.filename
                file_path = os.path.join(self.upload_directory, deduplicated_filename)

                # Save the file to the local directory
                with open(file_path, 'wb') as f:
                    f.write(file.read())

                # Construct the file URL (assuming the local server serves files from this directory)
                file_url = deduplicated_filename
                response.update(UploadResponseStatus.SUCCESS)
                response.update({"data": {"file_path": file_url}})
        except Exception as e:
            print(e)
            response.update(UploadResponseStatus.FAIL)
        return response

class UploadResponseStatus(ResponseStatus):
    pass