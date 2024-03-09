-- PART TABLE.
CREATE OR REPLACE TABLE part (
  p_partkey INTEGER PRIMARY KEY,
  p_name VARCHAR(55) NOT NULL,
  p_mfgr VARCHAR(25) NOT NULL,
  p_brand VARCHAR(10) NOT NULL,
  p_type VARCHAR(25) NOT NULL,
  p_size INTEGER NOT NULL,
  p_container VARCHAR(10) NOT NULL,
  p_retailprice DECIMAL(10, 2) NOT NULL,
  p_comment VARCHAR(255) NOT NULL
);

-- REGION TABLE.
CREATE OR REPLACE TABLE region (
  r_regionkey INTEGER PRIMARY KEY,
  r_name VARCHAR(25) NOT NULL,
  r_comment VARCHAR(255) NOT NULL
);

-- NATION TABLE.
CREATE OR REPLACE TABLE nation (
  n_nationkey INTEGER PRIMARY KEY,
  n_name VARCHAR(25) NOT NULL,
  n_regionkey INTEGER NOT NULL REFERENCES region(r_regionkey),
  n_comment VARCHAR(255) NOT NULL
);

-- SUPPLIER TABLE.
CREATE OR REPLACE TABLE supplier (
  s_suppkey INTEGER PRIMARY KEY,
  s_name VARCHAR(50) NOT NULL,
  s_address VARCHAR(40) NOT NULL,
  s_nationkey INTEGER NOT NULL REFERENCES nation(n_nationkey),
  s_phone CHAR(15) NOT NULL,
  s_acctbal DOUBLE PRECISION NOT NULL,
  s_comment VARCHAR(255) NOT NULL
);

-- CUSTOMER TABLE.
CREATE OR REPLACE TABLE customer (
  c_custkey INTEGER PRIMARY KEY,
  c_name VARCHAR(25) NOT NULL,
  c_address VARCHAR(40) NOT NULL,
  c_nationkey INTEGER NOT NULL REFERENCES nation(n_nationkey),
  c_phone CHAR(15) NOT NULL,
  c_acctbal DOUBLE PRECISION NOT NULL,
  c_mktsegment VARCHAR(10) NOT NULL,
  c_comment VARCHAR(255) NOT NULL
);

-- PARTSUPP TABLE.
CREATE OR REPLACE TABLE partsupp (
  ps_partkey INTEGER NOT NULL REFERENCES part(p_partkey),
  ps_suppkey INTEGER NOT NULL REFERENCES supplier(s_suppkey),
  ps_availqty INTEGER NOT NULL,
  ps_supplycost DECIMAL(10, 2) NOT NULL,
  ps_comment VARCHAR(255) NOT NULL
);

-- LINEITEM TABLE.
CREATE OR REPLACE TABLE lineitem (
  l_orderkey INTEGER NOT NULL REFERENCES orders(o_orderkey),
  l_partkey INTEGER NOT NULL REFERENCES part(p_partkey),
  l_suppkey INTEGER NOT NULL REFERENCES supplier(s_suppkey),
  l_linenumber INTEGER PRIMARY KEY,
  l_quantity INTEGER NOT NULL,
  l_extendedprice DECIMAL(10, 4) NOT NULL,
  l_discount DECIMAL(10, 4) NOT NULL,
  l_tax DECIMAL(10, 4) NOT NULL,
  l_returnflag CHAR(1) NOT NULL,
  l_linestatus VARCHAR(2) NOT NULL,
  l_shipdate DATE NOT NULL,
  l_commitdate DATE NOT NULL,
  l_receiptdate DATE NOT NULL,
  l_shipinstruct VARCHAR(25) NOT NULL,
  l_shipmode VARCHAR(10) NOT NULL,
  l_comment VARCHAR(44) NOT NULL
);

-- ORDERS TABLE.
CREATE OR REPLACE TABLE orders (
  o_orderkey INTEGER PRIMARY KEY,
  o_custkey INTEGER NOT NULL REFERENCES customer(c_custkey),
  o_orderstatus CHAR(1) NOT NULL,
  o_totalprice DECIMAL(15, 2) NOT NULL,
  o_orderdate DATE NOT NULL,
  o_orderpriority VARCHAR(15) NOT NULL,
  o_clerk VARCHAR(15) NOT NULL,
  o_shippriority INTEGER NOT NULL,
  o_comment VARCHAR(255) NOT NULL
);


INSERT INTO region (R_REGIONKEY, R_NAME, R_COMMENT)
VALUES (1, 'EUROPE', 'Old continent with rich history'),
       (2, 'AMERICA', 'Land of opportunity and diversity'),
       (3, 'ASIA', 'Most populous continent with ancient cultures'),
       (4, 'AFRICA', 'Diverse continent with rich cultural heritage'),
       (5, 'OCEANIA', 'Island continent with unique flora and fauna');

INSERT INTO nation (N_NATIONKEY, N_NAME, N_REGIONKEY, N_COMMENT)
VALUES  (1, 'France', 1, 'Land of wine and romance'),
        (2, 'Germany', 1, 'Land of engineering and beer'),
        (3, 'China', 3, 'Most populous nation with rich history'),
        (4, 'Japan', 3, 'Land of technology and innovation'),
        (5, 'United States', 2, 'Land of opportunity and diversity'),
        (6, 'Canada', 2, 'Land of maple syrup and friendly people'),
        (7, 'India', 3, 'Ancient civilization with diverse cultures'),
        (8, 'Brazil', 2, 'Vibrant culture with stunning landscapes'),
        (9, 'Australia', 5, 'Land of unique wildlife and natural beauty'),
        (10, 'Egypt', 4, 'Land of pyramids and ancient wonders');