import spacy
import pandas as pd
from pycountry import countries

spacy.cli.download("en_core_web_sm")
nlp = spacy.load("en_core_web_sm")


# Function to Extract ISO 3166-1 alpha-3 Country Codes.
def extract_country_code(country_name: str) -> list:
    return [
        (
            countries.get(alpha_2=country_name).alpha_3
            if len(country_name) == 2
            else countries.get(name=country_name).alpha_3
        )
    ]


# ETL Function for SQL Table `dim_location`.
def extract_location(df: pd.DataFrame) -> pd.DataFrame:
    locations = df.iloc[5].dropna().tolist()

    # Extract State/Province Information.
    state_names = locations[:-1]

    # Extract Country Name.
    country_name = [
        ent.text.upper() for ent in nlp(locations[-1]).ents if ent.label_ == "GPE"
    ]

    # Compute Country Code.
    country_code = extract_country_code("".join(country_name))

    # Create DataFrame with repeated values.
    return pd.DataFrame(
        [
            [item[0], item[1], item[2]]
            for item in zip(
                country_code * len(state_names),
                country_name * len(state_names),
                state_names,
            )
        ],
        columns=["country_iso_code", "country_name", "state_name"],
    )
