import os
import boto3
from flask import Flask, request, render_template_string

app = Flask(__name__)

AWS_REGION = os.environ["AWS_REGION"]
QUEUE_URL = os.environ["QUEUE_URL"]

sqs_client = boto3.client("sqs", region_name=AWS_REGION)

SQS_FORM = """
<!DOCTYPE html>
<html>
<body>

<h1>Send Message to SQS</h1>

<form method="POST" action="/send">
  <input type="text" name="message"/>
  <button type="submit">Send</button>
</form>

</body>
</html>
"""

@app.route("/send", methods=["GET", "POST"])
def send():

    if request.method == "GET":
        return render_template_string(SQS_FORM)

    message = request.form.get("message")

    response = sqs_client.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=message
    )

    return f"Message Sent: {response['MessageId']}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)