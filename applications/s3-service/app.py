import os
import logging
import boto3
from flask import Flask, request, render_template_string
from werkzeug.utils import secure_filename

logging.basicConfig(level=logging.INFO)

app = Flask(__name__)

AWS_REGION = os.environ["AWS_REGION"]
BUCKET_NAME = os.environ["BUCKET_NAME"]

s3_client = boto3.client("s3", region_name=AWS_REGION)

UPLOAD_FORM = """
<!DOCTYPE html>
<html>
<body>
<h1>Upload File to S3</h1>

<form method="POST" action="/upload" enctype="multipart/form-data">
  <input type="file" name="file"/>
  <button type="submit">Upload</button>
</form>

</body>
</html>
"""

@app.route("/upload", methods=["GET", "POST"])
def upload_file():

    if request.method == "GET":
        return render_template_string(UPLOAD_FORM)

    file_obj = request.files.get("file")

    if not file_obj:
        return "No file uploaded", 400

    filename = secure_filename(file_obj.filename)

    s3_client.upload_fileobj(
        file_obj,
        BUCKET_NAME,
        filename
    )

    return f"{filename} uploaded successfully"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)