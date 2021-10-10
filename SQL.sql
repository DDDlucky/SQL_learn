
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


＃04:アクティブユーザーを調べよう
逆引きSQL構文集 - 検索結果の列名を別名で表示する
http://www.sql-reference.com/select/as.html

逆引きSQL構文集 - 重複したレコードを省いて検索する
http://www.sql-reference.com/select/distinct.html

逆引きSQL構文集 - NULL値を持つデータを検索する
http://www.sql-reference.com/select/is_null.html

-- アクティブユーザーを求める
SELECT COUNT(*) AS アクティブユーザー数
FROM users;

空のカラムの行を表示する (IS NULL)
SELECT COUNT(*) AS アクティブユーザー数
FROM users
WHERE deleted_at IS NULL;

重複した行を省いて表示する (DISTINCT)
SELECT DISTINCT userID AS アクティブユーザー
FROM eventlog;

SELECT DISTINCT eventlog.userID AS アクティブユーザー
FROM eventlog
    INNER JOIN users ON users.userID = eventlog.userID
WHERE deleted_at IS NULL;

NG→カウントしてから重複を削除してしまう
SELECT DISTINCT COUNT(eventlog.userID) AS アクティブユーザー
FROM eventlog
    INNER JOIN users ON users.userID = eventlog.userID
WHERE deleted_at IS NULL;

OK→重複を除いてからカウントする
SELECT COUNT(DISTINCT eventlog.userID) AS アクティブユーザー
FROM eventlog
    INNER JOIN users ON users.userID = eventlog.userID
WHERE deleted_at IS NULL;

Daily Active Users（日別のユーザー数）
SELECT
    DATE(eventlog.startTime) AS 日付,
    COUNT(DISTINCT eventlog.userID) AS アクティブユーザー数
FROM eventlog
    INNER JOIN users ON users.userID = eventlog.userID
WHERE deleted_at IS NULL
GROUP BY DATE(eventlog.startTime);

演習問題
-- userIDが50番以降のアクティブユーザーを表示する
SELECT *
FROM
	users
WHERE
	userID >= 50
	AND deleted_at IS NULL;

-- 東京都のアクティブユーザーを表示する
SELECT *
FROM
	users
	INNER JOIN area ON area.areaID = users.areaID
WHERE
    area_name ='東京都'
    AND deleted_at IS NULL;


# 05:データを集計しよう
 SELECT文の処理順
- 1. FROM 対象テーブルからデータを取り出す
- 2. WHERE 条件に一致するレコードを絞り込み
- 3. GROUP BY グループ化
- 4. HAVING 集計結果から絞り込み
- 5. SELECT 指定したカラムだけを表示

逆引きSQL構文集 - 集計関数を使用する(基本)
http://www.sql-reference.com/summary/summary.html

逆引きSQL構文集 - 指定列の合計を求める
http://www.sql-reference.com/summary/sum.html

逆引きSQL構文集 - 指定列の平均を求める
http://www.sql-reference.com/summary/avg.html

逆引きSQL構文集 - 指定列の最大値や最小値を求める
http://www.sql-reference.com/summary/max_min.html

逆引きSQL構文集 - レコード数を取得する
http://www.sql-reference.com/summary/count.html

SQLの評価順 | The sky is the limit!
http://it.nog.raindrop.jp/?eid=350395

SELECT文の評価順序の話 - Qiita
http://qiita.com/suzukito/items/edcd00e680186f2930a8

SELECT
	eventlog.userID AS ユーザーID,
	SUM(events.increase_exp) AS 合計,
	AVG(events.increase_exp) AS 平均
FROM
	eventlog
	INNER JOIN events ON events.eventID = eventlog.eventID
GROUP BY eventlog.userID
HAVING SUM(events.increase_exp) >= 3000;

演習問題
-- ユーザーごとの合計獲得金額と平均獲得金額
SELECT
	eventlog.userID AS "ユーザーID",
	SUM(events.increase_gold) AS "合計",
	AVG(events.increase_gold) AS "平均"
FROM
	eventlog
	INNER JOIN events ON events.eventID = eventlog.eventID
GROUP BY eventlog.userID
HAVING SUM(events.increase_gold) >= 50
ORDER BY eventlog.userID;

-- レベルごとの平均経験値と平均ゴールド
SELECT level, AVG(exp), AVG(gold)
FROM users
GROUP BY level
ORDER BY level;
