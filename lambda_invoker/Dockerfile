FROM --platform=$BUILDPLATFORM public.ecr.aws/lambda/python:3.14

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY lambda_function.py ./

CMD ["lambda_function.handler"]
