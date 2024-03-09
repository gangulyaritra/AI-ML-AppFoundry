-- Question 1: Total sales by volume (number of orders) and amount.
CREATE OR REPLACE PROCEDURE TEST_DB.TPCH_SF1.TOTAL_SALES_VOLUME_AMOUNT() 
RETURNS TABLE (
  "Total Sales" NUMBER(38, 0),
  "Total Volume" NUMBER(38, 0),
  "Total Amount" NUMBER(12, 2)
) 
LANGUAGE SQL 
EXECUTE AS OWNER 
AS 
$$ 
DECLARE 
    res RESULTSET DEFAULT (
        SELECT
            COUNT(*) AS "Total Sales",
            ROUND(SUM(volume), 0) AS "Total Volume",
            ROUND(SUM(amount *(1 - discount)), 2) AS "Total Amount"
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
            )
    );
BEGIN RETURN TABLE(res);
END;
$$;

CALL TEST_DB.TPCH_SF1.TOTAL_SALES_VOLUME_AMOUNT();


-- Question 4: Top 5 performing Clerks for each quarter (amount, volume, less return).
CREATE OR REPLACE PROCEDURE TEST_DB.TPCH_SF1.TOP5_CLERKS() 
RETURNS TABLE (
  "quarter" NUMBER(1, 0),
  "clerk" VARCHAR(255),
  "qtr_sales" NUMBER(12, 2),
  "qtr_volume" NUMBER(12, 0),
  "qtr_returns" NUMBER(12, 0),
  "rank" NUMBER(1, 0)
) 
LANGUAGE SQL 
EXECUTE AS OWNER 
AS 
' 
DECLARE 
    res RESULTSET DEFAULT (
        WITH clerk_sales AS (
            SELECT o.o_clerk AS clerk, o.o_orderdate AS orderdate,
            ROUND(SUM(l.l_extendedprice*(1-l.l_discount)*l.l_quantity), 2) AS sales,
            SUM(l.l_quantity) AS volume,
            SUM(CASE WHEN l.l_returnflag = ''R'' THEN 0 ELSE l.l_quantity END) AS returns
            FROM TEST_DB.TPCH_SF1.ORDERS o 
            LEFT JOIN TEST_DB.TPCH_SF1.LINEITEM l ON o.o_orderkey=l.l_orderkey
            GROUP BY o.o_clerk, o.o_orderdate
        ),
        quarter_sales AS (
            SELECT QUARTER(orderdate) AS quarter, clerk, 
            SUM(sales) AS qtr_sales, SUM(volume) AS qtr_volume, SUM(returns) AS qtr_returns
            FROM clerk_sales GROUP BY QUARTER(orderdate), clerk
        )

        SELECT * FROM (SELECT *, RANK() OVER (PARTITION BY quarter ORDER BY qtr_sales DESC) AS rank FROM quarter_sales) x
        WHERE  rank <= 5 ORDER  BY quarter, rank
    );
BEGIN RETURN TABLE(res);
END;
';

CALL TEST_DB.TPCH_SF1.TOP5_CLERKS();