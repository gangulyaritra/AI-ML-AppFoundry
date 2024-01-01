# Import Library.
import re
import pickle
import uvicorn
import tensorflow as tf
from textblob import Word
from fastapi import FastAPI
from pydantic import BaseModel
from starlette import status
from starlette.responses import RedirectResponse

# Load the Saved Objects.
tokenizer = pickle.load(open("tokenizer.pkl", "rb"))
model = tf.keras.models.load_model("model.h5")

app = FastAPI()


class SpamRequest(BaseModel):
    text: str


class SpamResponse(BaseModel):
    spam: float
    ham: float
    sentence: str
    pred: str


# Text Cleaning and Preprocessing.
def cleanText(text):
    text = re.sub("[^a-zA-Z]", " ", text).lower()
    text = " ".join([Word(word).lemmatize() for word in text.split()])
    return text


@app.get("/")
def read_root():
    return RedirectResponse(url="/docs", status_code=status.HTTP_302_FOUND)


@app.post("/predict", response_model=SpamResponse)
def get_prediction(request: SpamRequest):
    sentence = cleanText(request.text)
    text_enc = tf.keras.preprocessing.sequence.pad_sequences(
        tokenizer.texts_to_sequences([sentence]),
        padding="post",
        truncating="post",
        maxlen=32,
    )

    prediction = model.predict(text_enc)
    category = "SPAM MESSAGE" if prediction[0][0] >= 0.5 else "HAM MESSAGE"
    return SpamResponse(
        spam=prediction[0][0],
        ham=1 - prediction[0][0],
        sentence=request.text,
        pred=category,
    )


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
