import os
from dotenv import dotenv_values
from src.train_pipeline import (
    DataIngestionTrainingPipeline,
    DataValidationTrainingPipeline,
    DataTransformationTrainingPipeline,
    ModelTrainerTrainingPipeline,
    ModelEvaluationTrainingPipeline,
)

config = dotenv_values(".env")

"""
DagsHub Environment Variables.
"""
os.environ["MLFLOW_TRACKING_URI"] = config["MLFLOW_TRACKING_URI"]
os.environ["MLFLOW_TRACKING_USERNAME"] = config["MLFLOW_TRACKING_USERNAME"]
os.environ["MLFLOW_TRACKING_PASSWORD"] = config["MLFLOW_TRACKING_PASSWORD"]


if __name__ == "__main__":
    try:
        data_ingestion = DataIngestionTrainingPipeline()
        data_ingestion.main()
    except Exception as e:
        raise e

    try:
        data_validation = DataValidationTrainingPipeline()
        data_validation.main()
    except Exception as e:
        raise e

    try:
        data_transformation = DataTransformationTrainingPipeline()
        data_transformation.main()
    except Exception as e:
        raise e

    try:
        model_trainer = ModelTrainerTrainingPipeline()
        model_trainer.main()
    except Exception as e:
        raise e

    try:
        model_evaluation = ModelEvaluationTrainingPipeline()
        model_evaluation.main()
    except Exception as e:
        raise e
