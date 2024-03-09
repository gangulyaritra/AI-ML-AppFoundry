-- Question 1: Total sales by volume (number of orders) and amount.
CREATE OR REPLACE VIEW vw_sales_by_volume_and_amount 
    COMMENT='Total sales by volume and amount' 
    AS
    SELECT
      COUNT(*) AS "Total Sales",
      ROUND(SUM(volume), 0) AS "Total Volume",
      ROUND(SUM(amount*(1-discount)), 2) AS "Total Amount"
    FROM
      (
        SELECT
          l_orderkey,
          SUM(l_quantity) AS volume,
          SUM(l_extendedprice) AS amount,
          SUM(l_discount) AS discount
        FROM
          TEST_DB.TPCH_SF1.LINEITEM
        GROUP BY
          l_orderkey
      );


-- Question 2: Monthly sales trend by volume (number of orders) and amount.
CREATE OR REPLACE VIEW vw_monthly_sales_trend 
    COMMENT='Monthly sales trend by volume and amount' 
    AS
    SELECT
      MONTHNAME (o.o_orderdate) AS "Month",
      MONTH (o.o_orderdate) AS "MonthNo",
      YEAR (o.o_orderdate) AS "Year",
      COUNT(o.*) AS "Total Sales",
      ROUND(
        SUM(SUM(l.l_quantity)) OVER (
          PARTITION BY
            YEAR (o.o_orderdate)
          ORDER BY
            MONTHNAME (o.o_orderdate)
        ),
        0
      ) AS "Volume",
      ROUND(
        SUM(SUM(l.l_extendedprice*(1-l.l_discount))) OVER (
          PARTITION BY
            YEAR (o.o_orderdate)
          ORDER BY
            MONTHNAME (o.o_orderdate)
        ),
        2
      ) AS "Amount"
    FROM
      TEST_DB.TPCH_SF1.ORDERS o
      LEFT JOIN TEST_DB.TPCH_SF1.LINEITEM l ON o.o_orderkey=l.l_orderkey
    GROUP BY
      MONTHNAME (o.o_orderdate),
      MONTH (o.o_orderdate),
      YEAR (o.o_orderdate);


-- Question 3: Discount vs Price vs Volume.
CREATE OR REPLACE VIEW vw_discount_price_volume 
    COMMENT='Discount vs Price vs Volume' 
    AS
    SELECT
      ROUND(l_discount, 2) AS "Discount",
      ROUND(AVG(l_extendedprice), 2) AS "Avg. Price",
      ROUND(
        AVG(SUM(l_quantity)) OVER (PARTITION BY l_discount),
        0
      ) AS "Avg. Volume"
    FROM
      TEST_DB.TPCH_SF1.LINEITEM
    GROUP BY
      l_discount
    ORDER BY
      l_discount;


-- Question 4: Top 5 performing Clerks for each quarter (amount, volume, less return).
CREATE OR REPLACE VIEW vw_top5_clerks 
    COMMENT = 'Top 5 performing Clerks for each quarter' 
    AS 
    WITH clerk_sales AS (
      SELECT
        o.o_clerk AS clerk,
        o.o_orderdate AS orderdate,
        ROUND(SUM(l.l_extendedprice*(1-l.l_discount)*l.l_quantity), 2) AS sales,
        SUM(l.l_quantity) AS volume,
        SUM(CASE WHEN l.l_returnflag='R' THEN 0 ELSE l.l_quantity END) AS RETURNS
      FROM
        TEST_DB.TPCH_SF1.ORDERS o
        LEFT JOIN TEST_DB.TPCH_SF1.LINEITEM l ON o.o_orderkey=l.l_orderkey
      GROUP BY
        o.o_clerk,
        o.o_orderdate
    ),
    quarter_sales AS (
      SELECT
        QUARTER (orderdate) AS quarter,
        clerk,
        SUM(sales) AS qtr_sales,
        SUM(volume) AS qtr_volume,
        SUM(RETURNS) AS qtr_returns
      FROM
        clerk_sales
      GROUP BY
        QUARTER (orderdate),
        clerk
    )
    
    SELECT * FROM (SELECT *, RANK() OVER (PARTITION BY quarter ORDER BY qtr_sales DESC) AS rank FROM quarter_sales) x
    WHERE  rank <= 5 ORDER  BY quarter, rank;


SELECT * FROM VW_SALES_BY_VOLUME_AND_AMOUNT;
SELECT * FROM VW_MONTHLY_SALES_TREND;
SELECT * FROM VW_DISCOUNT_PRICE_VOLUME;
SELECT * FROM VW_TOP5_CLERKS;