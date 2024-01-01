# Import Library.
import re, pickle
import tensorflow as tf
from textblob import Word
from flask import Flask, request, render_template

# Load the Saved Objects.
tokenizer = pickle.load(open("tokenizer.pkl", "rb"))
model = tf.keras.models.load_model("model.h5")

app = Flask(__name__)


# Text Cleaning and Preprocessing.
def cleanText(text):
    text = re.sub("[^a-zA-Z]", " ", text).lower()
    text = " ".join([Word(word).lemmatize() for word in text.split()])
    return text


@app.route("/")
def home():
    return render_template("home.html")


@app.route("/predict", methods=["POST"])
def predict():
    if request.method == "POST":
        text = request.form["text"]
        text = cleanText(text)
        text_enc = tf.keras.preprocessing.sequence.pad_sequences(
            tokenizer.texts_to_sequences([text]),
            padding="post",
            truncating="post",
            maxlen=32,
        )
        prediction = model.predict(text_enc)
        category = "SPAM MESSAGE" if prediction[0][0] >= 0.5 else "HAM MESSAGE"
    return render_template("home.html", pred=category)


if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
