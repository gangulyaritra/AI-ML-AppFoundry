import os
import json
import yaml
import joblib
from typing import Any
from pathlib import Path
from box import ConfigBox
from box.exceptions import BoxValueError
from ensure import ensure_annotations


@ensure_annotations
def read_yaml(path_to_yaml: Path) -> ConfigBox:
    try:
        with open(path_to_yaml) as yaml_file:
            content = yaml.safe_load(yaml_file)
            return ConfigBox(content)
    except BoxValueError as e:
        raise ValueError("The YAML file is empty.") from e


@ensure_annotations
def create_directories(path_to_directories: list):
    for path in path_to_directories:
        os.makedirs(path, exist_ok=True)


@ensure_annotations
def save_json(path: Path, data: dict):
    with open(path, "w") as f:
        json.dump(data, f, indent=4)


@ensure_annotations
def load_json(path: Path) -> ConfigBox:
    with open(path) as f:
        content = json.load(f)
    return ConfigBox(content)


@ensure_annotations
def save_bin(data: Any, path: Path):
    joblib.dump(value=data, filename=path)


@ensure_annotations
def load_bin(path: Path) -> Any:
    return joblib.load(path)


@ensure_annotations
def get_size(path: Path) -> str:
    size_in_kb = round(os.path.getsize(path) / 1024)
    return f"~ {size_in_kb} KB"
