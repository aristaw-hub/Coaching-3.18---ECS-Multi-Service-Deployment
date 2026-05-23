# Coaching-3.18---ECS-Multi-Service-Deployment
Mono repo: All applications &amp; IaC goes into a single repository. 
# Coaching 3.18 - ECS Multi-Service Deployment

Mono repo: All applications & IaC goes into a single repository.

## Architecture

- **Service 1 (S3 Upload)**: Flask app that allows users to upload files to S3 bucket
- **Service 2 (SQS Sender)**: Flask app that allows users to send messages to SQS queue
- **Infrastructure**: Terraform-managed ECS cluster with Fargate tasks

## Repository Structure

ecs-monorepo/
├── applications/
│   ├── s3-service/
│   │   ├── app.py
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   └── sqs-service/
│       ├── app.py
│       ├── requirements.txt
│       ├── Dockerfile
│       └── .dockerignore
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── ecs.tf
│   ├── iam.tf
│   ├── ecr.tf
│   ├── s3.tf
│   └── sqs.tf
├── .github/
│   └── workflows/
│       ├── terraform.yml
│       ├── s3-service.yml
│       └── sqs-service.yml
├── README.md
└── .gitignore

## Prerequisites

- AWS Account with appropriate permissions
- GitHub repository with the following secrets:
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY
- Terraform installed locally (for testing)

## Deployment Order

1. Deploy Infrastructure (Terraform) - Manual trigger
2. Deploy Applications - Automatic on push to main

## Accessing Services

After deployment, get the public IP from ECS tasks:

```bash
aws ecs list-tasks --cluster ecs-monorepo-cluster --service-name s3-upload-service
aws ecs describe-tasks --cluster ecs-monorepo-cluster --tasks <task-id>




Introduction	1
Requirements	1
Application Brief	2
Services	3
Service 1 (Flask app accessing S3)	3
Service 2 (Flask app accessing SQS)	4
Tips	6
Application Repository	6
IaC Repository	6
Introduction
Break yourselves up into pairs (3, if there’s an odd number). In this activity you would be creating ECS infra as well as deploying 2 independent applications  into it. Discuss among yourselves on how you would segregate your git repository / repositories to achieve this. Below are some examples: 

Mono repo: All applications & IaC goes into a single repository.
2 repositories : 1 repository to store your IaC and manage your IaC deployment. Another repository to manage your application code for both of your applications.
3 repositories: 1 repository to store your IaC and manage your IaC deployment. Individual repositories to store the application code for each of your 2 applications.

Note that each of the strategies above, would result in a slightly different GitHub action workflow.

1 of you will take the perspective of the App team/ Developer. Another will take the perspective of the cloud / devops team. Depending on your repository strategy, add the other person as collaborator (for the purpose of reviewing PR).
Requirements
All commits must go through a pull request before being merged to your main branch (either repo)
Set branch protection rules to enforce the above
Both your infra & application has to go through a proper CI & CD workflows (CD can be manual triggers)
You would only need to work with 1 environment (So pushes to main will do the application deployment)
(Optional) Include Snyk in your Github Actions CI workflow for your application/docker deployment
Application Brief
This would be a ECS cluster that would contain 3 services (application code in next section):

Service 1 -> User can upload a file which would then be uploaded to an S3 bucket.
Service 2 -> User can key in a message which would be input into a SQS Queue.

From IaC perspective: You would need to create an ECS cluster with 2 services, 2 ECR repositories, S3 bucket & SQS queue along with your IAM roles accordingly as part of your IaC. For VPC, you can use the default VPC. 

From application perspective: You would need to write a Dockerfile & build an image for each of the 2 services. 

Note: The requirements.txt file content will be the same for all the 2 services with a dependency on flask and boto3.


Services
Service 1 (Flask app accessing S3)

import os
import logging
import boto3
from flask import Flask, request, render_template_string
from werkzeug.utils import secure_filename

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s - %(message)s"
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

AWS_REGION = os.environ["AWS_REGION"]
BUCKET_NAME = os.environ["BUCKET_NAME"]
s3_client = boto3.client("s3", region_name=AWS_REGION)

# Simple HTML form for file upload
UPLOAD_FORM = """
<!DOCTYPE html>
<html>
  <body>
    <h1>Upload a File to S3</h1>
    <form method="POST" action="/upload" enctype="multipart/form-data">
      <label>Select file:</label>
      <input type="file" name="file" required/>
      <br/><br/>
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
    if not file_obj or file_obj.filename.strip() == "":
        logger.warning("No valid file provided.")
        return "No valid file provided.", 400

    filename = secure_filename(file_obj.filename)

    try:
        s3_client.upload_fileobj(file_obj, BUCKET_NAME, filename)
        logger.info("File '%s' uploaded to bucket '%s'.", filename, BUCKET_NAME)
        return f"File '{filename}' uploaded successfully to S3 bucket '{BUCKET_NAME}'!"
    except Exception as exc:
        logger.exception("Error uploading file to S3.")
        return f"Error uploading file: {str(exc)}", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)


Service 2 (Flask app accessing SQS)

import os
import logging
import boto3
from flask import Flask, request, render_template_string

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s - %(message)s"
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

AWS_REGION = os.environ["AWS_REGION"]
QUEUE_URL = os.environ["QUEUE_URL"]
sqs_client = boto3.client("sqs", region_name=AWS_REGION)

# Simple HTML form
SQS_FORM = """
<!DOCTYPE html>
<html>
  <body>
    <h1>Send a Message to SQS</h1>
    <form method="POST" action="/send">
      <label>Message:</label>
      <input type="text" name="message" required/>
      <br/><br/>
      <button type="submit">Send to SQS</button>
    </form>
  </body>
</html>
"""

@app.route("/send", methods=["GET", "POST"])
def send():
    if request.method == "GET":
        return render_template_string(SQS_FORM)

    message = request.form.get("message")
    if not message:
        logger.warning("No message provided.")
        return "No message provided.", 400

    try:
        response = sqs_client.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=message
        )
        message_id = response.get("MessageId", "N/A")
        logger.info("Message '%s' sent to '%s' (MessageId: %s).", message, QUEUE_URL, message_id)
        return f"Message sent to SQS! (MessageId: {message_id})"
    except Exception as exc:
        logger.exception("Error sending message to SQS.")
        return f"Error sending message to SQS: {str(exc)}", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)


Tips
Application Repository

If you are using the same repository for both of your applications, You can use different directories to store the Dockerfile, app.py & requirements.txt files for each service. And create separate workflow files to watch each directory.

Note: However using this method, you may need to refactor your workflows to use different variables from one another. E.g. (${{ var.SQS_ECS_SERVICE}} & ${{ var.S3_ECS_SERVICE}})



IaC Repository

You may also use the ECS public module where you can add each service into the “services” map. 

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 7.5.0"

  cluster_name = ""

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    s3-service = {
   
      

    }

    sqs-service = {
     
    }

  }
}



Alternatively you may also use the terraform resources in the terraform provider page (if you don't want to make use of community modules)
