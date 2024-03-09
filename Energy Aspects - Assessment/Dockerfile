FROM python:3.10-slim-bullseye
RUN apt update -y && apt-get install libpq-dev -y
WORKDIR /app
COPY . /app
RUN pip install --upgrade pip && pip install -r requirements.txt
CMD ["python3", "load_data.py"]