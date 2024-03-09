CREATE SCHEMA web_scrapes;

-- Table Name: dim_location
CREATE TABLE IF NOT EXISTS web_scrapes.dim_location (
  country_iso_code char(3) NOT NULL, 
  country_name varchar(45) NOT NULL, 
  state_name varchar(45) UNIQUE NOT NULL, 
  PRIMARY KEY (state_name)
);

-- Table Name: rig_count
CREATE TABLE IF NOT EXISTS web_scrapes.rig_count (
  rig_id SERIAL PRIMARY KEY, 
  "date" date NOT NULL, 
  land int, 
  offshore int, 
  state varchar(45) NOT NULL, 
  FOREIGN KEY (state) REFERENCES web_scrapes.dim_location(state_name)
);
