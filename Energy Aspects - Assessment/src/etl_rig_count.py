import pandas as pd
import numpy as np
import warnings

warnings.filterwarnings("ignore")


# Function to clean DataFrame for further processing.
def clean_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    df = df.iloc[5:, :-3]
    df = df.fillna(method="ffill", axis=1)
    df = df.set_axis(df.iloc[0], axis=1, copy=False)
    df = df.iloc[1:].reset_index(drop=True)
    df = df.rename(columns={np.nan: "date"})
    return df


# Function to transform DataFrame to extract required output.
def transform_dataframe(df: pd.DataFrame, col_name: str) -> pd.DataFrame:
    if df[["date", col_name]].shape[1] == 2:
        df_temp = df[["date", col_name]]
        df_temp["offshore"] = np.nan
        df_temp["state"] = col_name
        df_temp.columns = ["date", "land", "offshore", "state"]
        return df_temp.iloc[1:, :]
    else:
        df_temp = df[["date", col_name]]
        df_temp["state"] = col_name
        df_temp.columns = ["date", "land", "offshore", "state"]
        return df_temp.iloc[1:, :]


# Function to prepare DataFrame for database insertion.
def prepare_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    df_list = [transform_dataframe(df, item) for item in set(df.columns.tolist()[1:])]
    df_concat = pd.concat(df_list, keys=[f"x{i}" for i in range(50)]).reset_index(
        drop=True
    )
    df_concat["date"] = pd.to_datetime(
        df_concat["date"], format="%Y-%m-%d %H:%M:%S"
    ).dt.date
    return df_concat
