import os
import numpy as np
from pydantic import BaseModel
from fastapi import FastAPI, status
from fastapi.responses import Response
from fastapi.middleware.cors import CORSMiddleware
from starlette.responses import JSONResponse, RedirectResponse
from uvicorn import run as app_run
from src.prediction_pipeline import PredictionPipeline


app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class DataModel(BaseModel):
    fixed_acidity: float
    volatile_acidity: float
    citric_acid: float
    residual_sugar: float
    chlorides: float
    free_sulfur_dioxide: float
    total_sulfur_dioxide: float
    density: float
    pH: float
    sulphates: float
    alcohol: float


@app.get("/", tags=["authentication"])
async def index():
    return RedirectResponse(url="/docs")


@app.post("/predict", response_description="Prediction EndPoint.")
async def test_point_prediction(data: DataModel):
    try:
        test_point = [
            data.fixed_acidity,
            data.volatile_acidity,
            data.citric_acid,
            data.residual_sugar,
            data.chlorides,
            data.free_sulfur_dioxide,
            data.total_sulfur_dioxide,
            data.density,
            data.pH,
            data.sulphates,
            data.alcohol,
        ]
        data = np.array(test_point).reshape(1, 11)

        os.system("python train.py")

        obj = PredictionPipeline()
        predict = obj.predict(data)

        return JSONResponse(
            status_code=status.HTTP_200_OK,
            content={"message": f"Wine Quality: {round(predict[0], 0)}"},
        )
    except Exception as e:
        return Response(f"Error Occurred! {e}")


if __name__ == "__main__":
    app_run(app, host="0.0.0.0", port=8080)
