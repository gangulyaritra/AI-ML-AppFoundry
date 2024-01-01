# Import Library.
import re
import pickle
import nltk
import pandas as pd
import numpy as np
import tensorflow as tf
from textblob import TextBlob, Word
from sklearn.model_selection import train_test_split
import warnings

warnings.filterwarnings("ignore")
nltk.download("wordnet")

"""
--------------------------------------------------
GloVe: https://nlp.stanford.edu/projects/glove/
--------------------------------------------------
!wget http://nlp.stanford.edu/data/glove.6B.zip
!unzip glove.6B.zip
--------------------------------------------------
"""

# Model Configuration.
MAX_SEQUENCE_LENGTH = 32
GLOVE_EMB = "glove.6B.300d.txt"
EMBEDDING_DIM = 300
BATCH_SIZE = 8
EPOCHS = 10


if __name__ == "__main__":
    # Load the `spam.csv` file from the directory.
    data = pd.read_csv(r"spam.csv")
    print(data)

    # Shuffle the dataset rows and Reset the column index.
    data = data.sample(frac=1).reset_index(drop=True)

    # Text Cleaning and Preprocessing.
    data["Message"] = data["Message"].apply(
        lambda x: re.sub("[^a-zA-Z]", " ", x).lower()
    )
    data["Message"] = data["Message"].apply(
        lambda x: " ".join([Word(word).lemmatize() for word in x.split()])
    )
    data["Message"] = data["Message"].apply(lambda x: str(TextBlob(x).correct()))

    data["Category"] = data["Category"].apply(lambda x: 1 if x == "spam" else 0)

    # Split Dataset into Features and Target Set.
    X_train, X_test, y_train, y_test = train_test_split(
        data["Message"],
        data["Category"],
        test_size=0.2,
        random_state=42,
        stratify=data["Category"],
    )

    # Tensorflow Tokenization and Padding.
    tokenizer = tf.keras.preprocessing.text.Tokenizer()
    tokenizer.fit_on_texts(X_train)

    vocab_size = len(tokenizer.word_index) + 1

    # Save the Tokenizer Object.
    pickle.dump(tokenizer, open("tokenizer.pkl", "wb"))

    X_train = tf.keras.preprocessing.sequence.pad_sequences(
        tokenizer.texts_to_sequences(X_train),
        padding="post",
        truncating="post",
        maxlen=MAX_SEQUENCE_LENGTH,
    )

    X_test = tf.keras.preprocessing.sequence.pad_sequences(
        tokenizer.texts_to_sequences(X_test),
        padding="post",
        truncating="post",
        maxlen=MAX_SEQUENCE_LENGTH,
    )

    """
    ------------------------------
    WORD EMBEDDINGS.
    ------------------------------
    """
    embeddings_index = {}

    with open(GLOVE_EMB, encoding="utf8") as f:
        for line in f:
            values = line.split()
            word = value = values[0]
            coefs = np.asarray(values[1:], dtype="float32")
            embeddings_index[word] = coefs
    embedding_matrix = np.zeros((vocab_size, EMBEDDING_DIM))

    for word, i in tokenizer.word_index.items():
        embedding_vector = embeddings_index.get(word)
        if embedding_vector is not None:
            embedding_matrix[i] = embedding_vector

    # Embedding Layer.
    embedding_layer = tf.keras.layers.Embedding(
        vocab_size,
        EMBEDDING_DIM,
        weights=[embedding_matrix],
        input_length=MAX_SEQUENCE_LENGTH,
        trainable=False,
    )

    """
    ------------------------------
    MODEL BUILDING & TRAINING.
    ------------------------------
    """
    sequence_input = tf.keras.layers.Input(shape=(MAX_SEQUENCE_LENGTH,), dtype="int32")
    embedding_sequences = embedding_layer(sequence_input)

    # Build the Model.
    x = tf.keras.layers.SpatialDropout1D(0.3)(embedding_sequences)
    x = tf.keras.layers.Conv1D(64, 4, activation="relu", kernel_regularizer="l2")(x)
    x = tf.keras.layers.Bidirectional(
        tf.keras.layers.LSTM(64, dropout=0.2, recurrent_dropout=0.2)
    )(x)
    x = tf.keras.layers.Dense(512, activation="relu", kernel_regularizer="l2")(x)
    x = tf.keras.layers.Dropout(0.4)(x)
    x = tf.keras.layers.Dense(512, activation="relu", kernel_regularizer="l2")(x)
    outputs = tf.keras.layers.Dense(1, activation="sigmoid")(x)
    model = tf.keras.Model(sequence_input, outputs)

    # Compile the Model.
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4),
        loss="binary_crossentropy",
        metrics=["AUC"],
    )

    # Model Summary.
    print(model.summary())

    callbacks = [
        tf.keras.callbacks.EarlyStopping(patience=3, verbose=1),
        tf.keras.callbacks.ReduceLROnPlateau(
            factor=0.1, patience=3, min_lr=0.00001, monitor="val_loss", verbose=1
        ),
        tf.keras.callbacks.ModelCheckpoint("model.h5", verbose=1, save_best_only=True),
    ]

    # Fit the Model.
    history = model.fit(
        X_train,
        y_train,
        batch_size=BATCH_SIZE,
        epochs=EPOCHS,
        validation_data=(X_test, y_test),
        callbacks=callbacks,
    )
