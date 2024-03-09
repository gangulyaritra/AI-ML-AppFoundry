import psycopg2
from sqlalchemy import create_engine, Column, String, Integer, Date, ForeignKey
from sqlalchemy.orm import declarative_base
from src.constants import POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD, SCHEMA_NAME


try:
    # Use the PostgreSQL Database URL to create a connection.
    conn = psycopg2.connect(
        database=POSTGRES_DB,
        host="0.0.0.0",
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

    # Create the SCHEMA if it doesn't exist.
    if not schema_exists:
        cur.execute(f"CREATE SCHEMA IF NOT EXISTS {SCHEMA_NAME}")
        conn.commit()
        print("SCHEMA created successfully!")
    else:
        raise Exception("SCHEMA already exists.")

    # Create the PostgreSQL Connection Engine.
    engine = create_engine(
        f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@0.0.0.0:5432/{POSTGRES_DB}"
    )

    # Database Tables Creation.
    Base = declarative_base()

    class DimLocation(Base):
        __tablename__ = "dim_location"
        __table_args__ = {"schema": SCHEMA_NAME}

        country_iso_code = Column(String(3), nullable=False)
        country_name = Column(String(45), nullable=False)
        state_name = Column(String(45), primary_key=True)

    class RigCount(Base):
        __tablename__ = "rig_count"
        __table_args__ = {"schema": SCHEMA_NAME}

        rig_id = Column(Integer, primary_key=True, autoincrement=True)
        date = Column(Date, nullable=False)
        land = Column(Integer)
        offshore = Column(Integer)
        state = Column(String(45), ForeignKey(f"{SCHEMA_NAME}.dim_location.state_name"))

    Base.metadata.create_all(engine)
    print("TABLES created successfully!")

    # Close the DB connections.
    cur.close()
    conn.close()

except Exception as e:
    print(e)
