import psycopg2
import pandas as pd
from sqlalchemy import create_engine, String, Integer, Date
from src.constants import POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD, SCHEMA_NAME
from src.etl_dim_location import extract_location
from src.etl_rig_count import clean_dataframe, prepare_dataframe


def main():
    # Use pandas ExcelFile and parse multiple sheets.
    xlsx = pd.ExcelFile("data/BH_data.xlsx")

    # Get a list of all Excel sheet names.
    sheet_names = xlsx.sheet_names

    # Read all the Excel DataFrames.
    df1 = pd.read_excel(xlsx, sheet_names[0], header=None)
    df2 = pd.read_excel(xlsx, sheet_names[1], header=None)

    # dim_location: Concatenate both DataFrames and Reset the DataFrame Index.
    dim_location = pd.concat(
        [extract_location(df1), extract_location(df2)]
    ).reset_index(drop=True)

    # rig_count: Concatenate both DataFrames and Reset the DataFrame Index.
    df1 = clean_dataframe(df1)
    df2 = clean_dataframe(df2)

    rig_count = pd.concat(
        [prepare_dataframe(df1), prepare_dataframe(df2)], keys=["x", "y"]
    ).reset_index(drop=True)

    try:
        # Create the PostgreSQL Connection Engine.
        engine = create_engine(
            f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@0.0.0.0:5432/{POSTGRES_DB}"
        )

        # Use the PostgreSQL Database URL to create a connection.
        conn = psycopg2.connect(
            database=POSTGRES_DB,
            host="0.0.0.0",
            port=5432,
            user=POSTGRES_USER,
            password=POSTGRES_PASSWORD,
        )

        # Get the cursor object from the connection.
        cur = conn.cursor()

        # Check if the SCHEMA already exists.
        cur.execute(
            f"""
                SELECT schema_name 
                FROM information_schema.schemata 
                WHERE schema_name = '{SCHEMA_NAME}'
            """
        )
        schema_exists = cur.fetchone() is not None

        # Insert Data into PostgreSQL Database.
        if not schema_exists:
            raise Exception("SCHEMA doesn't exist.")
        else:
            dim_location.to_sql(
                "dim_location",
                engine,
                schema=SCHEMA_NAME,
                if_exists="append",
                index=False,
                dtype={
                    "country_iso_code": String(3),
                    "country_name": String(45),
                    "state_name": String(45),
                },
                method="multi",
            )

            rig_count.to_sql(
                "rig_count",
                engine,
                schema=SCHEMA_NAME,
                if_exists="append",
                index=False,
                dtype={
                    "date": Date,
                    "land": Integer,
                    "offshore": Integer,
                    "state": String(45),
                },
                method="multi",
            )

            print("Data Inserted Successfully into PostgreSQL Database.")

        # Close the DB connections.
        cur.close()
        conn.close()

    except Exception as e:
        print(e)


if __name__ == "__main__":
    main()
