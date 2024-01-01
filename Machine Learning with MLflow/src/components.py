import os
import joblib
import zipfile
from pathlib import Path
import pandas as pd
import numpy as np
import urllib.request as request
from urllib.parse import urlparse
from sklearn.model_selection import train_test_split
from sklearn.linear_model import ElasticNet
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
from src.utils import get_size, save_json
from src.config_entity import (
    DataIngestionConfig,
    DataValidationConfig,
    DataTransformationConfig,
    ModelTrainerConfig,
    ModelEvaluationConfig,
)
import mlflow
import mlflow.sklearn


class DataIngestion:
    def __init__(self, config: DataIngestionConfig):
        self.config = config

    def download_file(self) -> None:
        if not os.path.exists(self.config.local_data_file):
            filename, headers = request.urlretrieve(
                url=self.config.source_URL, filename=self.config.local_data_file
            )
            print(f"{filename} downloaded with the following info: \n{headers}")
        else:
            print(
                f"File already exists of size: {get_size(Path(self.config.local_data_file))}"
            )

    def extract_zip_file(self) -> None:
        unzip_path = self.config.unzip_dir
        os.makedirs(unzip_path, exist_ok=True)
        with zipfile.ZipFile(self.config.local_data_file, "r") as zip_ref:
            zip_ref.extractall(unzip_path)


class DataValidation:
    def __init__(self, config: DataValidationConfig):
        self.config = config

    def validate_all_columns(self) -> bool:
        try:
            validation_status = None
            data = pd.read_csv(self.config.unzip_data_dir, sep=";")
            all_cols = list(data.columns)
            all_schema = self.config.all_schema.keys()

            for col in all_cols:
                validation_status = col in all_schema

                with open(self.config.STATUS_FILE, "w") as f:
                    f.write(f"Validation Status: {validation_status}")

            return validation_status

        except Exception as e:
            raise e


class DataTransformation:
    def __init__(self, config: DataTransformationConfig):
        self.config = config

    def split_dataset(self) -> None:
        data = pd.read_csv(self.config.data_path, sep=";")

        train, test = train_test_split(data)

        train.to_csv(os.path.join(self.config.root_dir, "train.csv"), index=False)
        test.to_csv(os.path.join(self.config.root_dir, "test.csv"), index=False)


class ModelTrainer:
    def __init__(self, config: ModelTrainerConfig):
        self.config = config

    def train_model(self) -> None:
        train_data = pd.read_csv(self.config.train_data_path)
        test_data = pd.read_csv(self.config.test_data_path)

        train_x = train_data.drop([self.config.target_column], axis=1)
        test_x = test_data.drop([self.config.target_column], axis=1)
        train_y = train_data[[self.config.target_column]]
        test_y = test_data[[self.config.target_column]]

        lr = ElasticNet(
            alpha=self.config.alpha,
            l1_ratio=self.config.l1_ratio,
            max_iter=self.config.max_iter,
            tol=self.config.tol,
            random_state=42,
            selection=self.config.selection,
        )
        lr.fit(train_x, train_y)

        joblib.dump(lr, os.path.join(self.config.root_dir, self.config.model_name))


class ModelEvaluation:
    def __init__(self, config: ModelEvaluationConfig):
        self.config = config

    def eval_metrics(self, actual, pred) -> None:
        rmse = np.sqrt(mean_squared_error(actual, pred))
        mae = mean_absolute_error(actual, pred)
        r2 = r2_score(actual, pred)
        return rmse, mae, r2

    def log_into_mlflow(self) -> None:
        test_data = pd.read_csv(self.config.test_data_path)
        model = joblib.load(self.config.model_path)

        test_x = test_data.drop([self.config.target_column], axis=1)
        test_y = test_data[[self.config.target_column]]

        mlflow.set_registry_uri(self.config.mlflow_uri)
        tracking_url_type_store = urlparse(mlflow.get_tracking_uri()).scheme

        with mlflow.start_run():
            predicted_qualities = model.predict(test_x)

            (rmse, mae, r2) = self.eval_metrics(test_y, predicted_qualities)
            scores = {"rmse": rmse, "mae": mae, "r2": r2}
            save_json(path=Path(self.config.metric_file_name), data=scores)

            mlflow.log_params(self.config.all_params)

            mlflow.log_metric("rmse", rmse)
            mlflow.log_metric("r2", r2)
            mlflow.log_metric("mae", mae)

            if tracking_url_type_store != "file":
                mlflow.sklearn.log_model(
                    model, "model", registered_model_name="ElasticNet"
                )
            else:
                mlflow.sklearn.log_model(model, "model")
