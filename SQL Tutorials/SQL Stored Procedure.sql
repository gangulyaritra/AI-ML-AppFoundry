CREATE PROCEDURE `GetCallTrend`(
  IN P_FromDate DATE,
  IN P_ToDate DATE,
  IN P_Interval VARCHAR(1000),
  IN P_Queue VARCHAR(1000)
)
BEGIN
IF length(P_Queue)>0 THEN

IF (P_Interval="daily") THEN
SELECT
  date_format(a.fromTime, "%d-%b-%Y") AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
  AND FIND_IN_SET(b.queueName, P_Queue)
GROUP BY
  date_format(a.fromTime, "%d-%b-%Y"),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  date_format(a.fromTime, "%d-%b-%Y");
END IF;

IF (P_Interval="weekly") THEN
SELECT
  week(a.fromTime) AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
  AND FIND_IN_SET(b.queueName, P_Queue)
GROUP BY
  week(a.fromTime),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  week(a.fromTime);
END IF;

IF (P_Interval="monthly") THEN
SELECT
  date_format(a.fromTime, "%M") AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
  AND FIND_IN_SET(b.queueName, P_Queue)
GROUP BY
  date_format(a.fromTime, "%M"),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  date_format(a.fromTime, "%M");
END IF;

IF (P_Interval="quarterly") THEN
SELECT
  quarter(a.fromTime) AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
  AND FIND_IN_SET(b.queueName, P_Queue)
GROUP BY
  quarter(a.fromTime),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  quarter(a.fromTime);
END IF;

IF (P_Interval="yearly") THEN
SELECT
  YEAR(a.fromTime) AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
  AND FIND_IN_SET(b.queueName, P_Queue)
GROUP BY
  YEAR(a.fromTime),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  YEAR(a.fromTime);
END IF;

IF (P_Interval="hourly") THEN
SELECT
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00")) AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
  AND FIND_IN_SET(b.queueName, P_Queue)
GROUP BY
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00")),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00"));
END IF;

IF (P_Interval="quarterhour") THEN
SELECT
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:%i")) AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
  AND FIND_IN_SET(b.queueName, P_Queue)
GROUP BY
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:%i")),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:%i"));
END IF;

IF (P_Interval="halfhour") THEN
SELECT
  CASE
    WHEN MINUTE(a.fromTime)>=30 THEN concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:30"))
    ELSE concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00"))
  END AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
  AND FIND_IN_SET(b.queueName, P_Queue)
GROUP BY
  CASE
    WHEN MINUTE(a.fromTime)>=30 THEN concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:30"))
    ELSE concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00"))
  END,
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  CASE
    WHEN MINUTE(a.fromTime)>=30 THEN concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:30"))
    ELSE concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00"))
  END;
END IF;
END IF;

IF length(P_Queue)<=0 THEN

IF (P_Interval="daily") THEN
SELECT
  date_format(a.fromTime, "%d-%b-%Y") AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
GROUP BY
  date_format(a.fromTime, "%d-%b-%Y"),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  date_format(a.fromTime, "%d-%b-%Y");
END IF;

IF (P_Interval="weekly") THEN
SELECT
  week(a.fromTime) AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
GROUP BY
  week(a.fromTime),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  week(a.fromTime);
END IF;

IF (P_Interval="monthly") THEN
SELECT
  date_format(a.fromTime, "%M") AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
GROUP BY
  date_format(a.fromTime, "%M"),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  date_format(a.fromTime, "%M");
END IF;

IF (P_Interval="quarterly") THEN
SELECT
  quarter(a.fromTime) AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
GROUP BY
  quarter(a.fromTime),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  quarter(a.fromTime);
END IF;

IF (P_Interval="yearly") THEN
SELECT
  YEAR(a.fromTime) AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
GROUP BY
  YEAR(a.fromTime),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  YEAR(a.fromTime);
END IF;

IF (P_Interval="hourly") THEN
SELECT
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00")) AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
GROUP BY
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00")),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00"));
END IF;

IF (P_Interval="quarterhour") THEN
SELECT
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:%i")) AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
GROUP BY
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:%i")),
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:%i"));
END IF;

IF (P_Interval="halfhour") THEN
SELECT
  CASE
    WHEN MINUTE(a.fromTime)>=30 THEN concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:30"))
    ELSE concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00"))
  END AS `Interval`,
  COALESCE(b.queueName, '-') AS queue,
  COALESCE(SUM(a.tTalkCompleteCount), 0) AS talks,
  COALESCE(SUM(a.nOfferedCount), 0) AS offered,
  COALESCE(SUM(a.tAnsweredCount), 0) AS answered,
  COALESCE(SUM(a.tAbandonCount), 0) AS abandon,
  COALESCE(SUM(a.tFlowOutCount), 0) AS flownout,
  COALESCE(SUM(a.nErrorCount), 0) AS error
FROM
  queue_aggregate a LEFT JOIN dim_queue b ON a.queue=b.queueId
WHERE
  DATE(a.fromTime) BETWEEN P_FromDate AND P_ToDate
  AND mediaType="voice"
GROUP BY
  CASE
    WHEN MINUTE(a.fromTime)>=30 THEN concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:30"))
    ELSE concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00"))
  END,
  COALESCE(b.queueName, '-')
ORDER BY
  COALESCE(b.queueName, '-'),
  CASE
    WHEN MINUTE(a.fromTime)>=30 THEN concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:30"))
    ELSE concat(date_format(a.fromTime, "%d-%b-%Y"), ' ', date_format(a.fromTime, "%H:00"))
  END;
END IF;
END IF;

END