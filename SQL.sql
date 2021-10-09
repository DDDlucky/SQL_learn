
SELECT * FROM users
INNER JOIN jobs ON jobs.jobID = users.jobID
INNER JOIN area ON area.areaID = users.areaID;


SELECT userID, name
FROM users
    INNER JOIN jobs ON jobs.jobID = users.jobID
    INNER JOIN area ON area.areaID = users.areaID;

SQLで間違いやすいポイント
- SELECTのカンマ忘れ、カンマ多すぎ
- テーブル連結時のテーブル名不足
- WHEREでAND忘れ

SELECT userID, name, area.areaID, area_name
FROM users
    INNER JOIN jobs ON jobs.jobID = users.jobID
    INNER JOIN area ON area.areaID = users.areaID
WHERE
    userID >= 10
    AND userID < 20;

演習問題
-- logIDが10以下のイベントログを表示
SELECT *
FROM eventlog
    INNER JOIN users on users.userID = eventlog.userID
WHERE logID <= 10;


＃03:ログ解析してみよう
https://dev.mysql.com/doc/refman/5.6/ja/date-and-time-functions.html
-- 日次のアクセス数を求める
SELECT DATE(startTime), COUNT(logID)
FROM eventlog
GROUP BY DATE(startTime);

-- 特定の範囲の日次のアクセス数を求める
SELECT DATE(startTime), COUNT(logID)
FROM eventlog
WHERE DATE(startTime) >= '2015-04-01'
GROUP BY DATE(startTime);

SELECT DATE(startTime), COUNT(logID)
FROM eventlog
WHERE DATE(startTime) BETWEEN "2015-04-01" AND "2015-04-30"
GROUP BY DATE(startTime);

-- 月次のアクセス数を求める
SELECT DATE_FORMAT(startTime, '%Y-%m'), COUNT(logID)
FROM eventlog
GROUP BY DATE_FORMAT(startTime, '%Y-%m');

演習問題
-- 日次のアクセス数を求める
SELECT DATE(startTime), COUNT(logID)
FROM eventlog
GROUP BY DATE(startTime);

-- 3月の日次アクセス数を求める
SELECT DATE(startTime), COUNT(logID)
FROM eventlog
WHERE DATE(startTime) BETWEEN '2015-03-01' and '2015-03-07'
GROUP BY DATE(startTime);

-- 月次のアクセス数を求める
SELECT DATE_FORMAT(startTime, '%Y-%m'), COUNT(logID)
FROM eventlog
GROUP BY DATE_FORMAT(startTime, '%Y-%m');


