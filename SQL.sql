
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


＃06:ユーザーの年齢を計算をしよう

プレイ期間
SELECT
	userID AS ユーザーID,
	MIN(startTime) AS 開始日,
	MAX(endTime) AS 終了日,
	DATE(MAX(endTime)) - DATE(MIN(startTime)) + 1 AS プレイ期間
FROM
	eventlog
GROUP BY userID;

年齢
SELECT
	userID AS ユーザーID,
	YEAR(CURRENT_DATE()) AS 現在年,
	birth AS 生年月日,
	YEAR(CURRENT_DATE()) - YEAR(birth) AS 数え年,
	TIMESTAMPDIFF(YEAR, birth, CURRENT_DATE()) AS 満年齢
FROM
	users;

演習問題
-- ユーザーの平均年齢を求める
SELECT
	AVG(TIMESTAMPDIFF(YEAR, birth, '2016-12-01')) AS '平均年齢'
FROM
	users;

TIPS
DATE() 同士を直接比較していたプレイ期間の算出について
1月をまたいでしまう場合に上記と同じように想定外の数値が表示されていることが判明いたしました。


これに対して、MySQLでは日付や時刻同士を計算するための関数がいくつも用意されています。
同TIPS内にございます TIMESTANPDIFF() を用いる方法や、
0年0月0日からの起算日数を数値で返却する TO_DAYS() を用いる方法など
複数手段がございますので詳細はMySQL公式ドキュメントをご確認ください。

以下はTO_DAYS()を用いる例です。


  TO_DAYS(MAX(endTime)) - TO_DAYS(MIN(startTime)) + 1  AS プレイ期間,
  -- それぞれ0年0月0日からの日数であるため直接比較しても正しく日数差を求められます


現在の日時を求める
CURRENT_DATE()) AS 現在日時

2つの日時の間の期間を整数で求める
TIMESTAMPDIFF(YEAR, (誕生日), (現在の日時))

参考になるWebサイト
逆引きSQL構文集 - 四則演算を行う
http://www.sql-reference.com/math/operatore.html

【MySQL】日付時刻関数を使用して、日付や時刻の差分を取得する | バシャログ。
http://bashalog.c-brains.jp/14/02/28-150000.php

mysqlで年齢計算 - Qiita
http://qiita.com/kabayama/items/b5775e6904c7a4d627a8

MySQL :: MySQL 5.6 リファレンスマニュアル :: 12.7 日付および時間関数
https://dev.mysql.com/doc/refman/5.6/ja/date-and-time-functions.html


＃07:テキストを検索しよう
SELECT
	userID,
	startTime,
	events.event_summary
FROM
	eventlog
	INNER JOIN events ON events.eventID = eventlog.eventID
WHERE userID = 2;

-- テキスト検索
SELECT
	userID,
	startTime,
	events.event_summary
FROM
	eventlog
	INNER JOIN events ON events.eventID = eventlog.eventID
WHERE events.event_stage <> 0
    AND events.event_summary LIKE '%との闘い'
ORDER BY
    userID, startTime;

URLで検索
SELECT
	userID,
	startTime,
	events.event_summary,
	events.event_url
FROM
	eventlog
	INNER JOIN events ON events.eventID = eventlog.eventID
WHERE events.event_stage <> 0
    AND events.event_url LIKE '%dungeon%'
ORDER BY
    userID, startTime;

演習問題
-- 特定の都道府県を絞り込む
SELECT *
FROM area
WHERE area_name LIKE '%山%';


＃08:サブクエリでアクティブユーザー数を求めよう
日付ごとに重複しないアクティブユーザーを取り出す
SELECT DISTINCT
	DATE(startTime) AS day,
	eventlog.userID AS user
FROM eventlog
	INNER JOIN users ON users.userID = eventlog.userID
WHERE deleted_at IS NULL;
↓

-- サブクエリで、アクティブユーザー数を求める
SELECT *
FROM (SELECT DISTINCT
	DATE(startTime) AS day,
	eventlog.userID AS user
FROM eventlog
	INNER JOIN users ON users.userID = eventlog.userID
WHERE deleted_at IS NULL) AS ActiveUsers;
↓

SELECT day, COUNT(user)
FROM (SELECT DISTINCT
	DATE(startTime) AS day,
	eventlog.userID AS user
FROM eventlog
	INNER JOIN users ON users.userID = eventlog.userID
WHERE deleted_at IS NULL) AS ActiveUsers
GROUP BY day;

演習課題「月次のアクティブユーザー数を求める」
SELECT DISTINCT
	DATE_FORMAT(startTime, '%Y-%m') AS yearMonth,
	eventlog.userID AS user
FROM eventlog
	INNER JOIN users ON users.userID = eventlog.userID
WHERE deleted_at IS NULL;
↓

-- 月次アクティブユーザー数を求める
SELECT yearMonth, COUNT(user)
FROM (SELECT DISTINCT
	DATE_FORMAT(startTime, '%Y-%m') AS yearMonth,
	eventlog.userID AS user
FROM eventlog
	INNER JOIN users ON users.userID = eventlog.userID
WHERE deleted_at IS NULL) AS ActiveUsers
GROUP BY yearMonth;


＃09:グループ分けしよう
SELECT
	userID,
	level,
	CASE
		WHEN level >= 4 THEN '上級'
		WHEN level >= 2 THEN '中級'
		ElSE '初級'
	END AS クラス
FROM
	users;

※条件式の順番に注意

クラスごとのユーザー数
SELECT
    CASE
		WHEN level >= 4 THEN '上級'
		WHEN level >= 2 THEN '中級'
		ElSE '初級'
	END AS クラス,
	COUNT(*) AS ユーザー数
FROM
	users
GROUP BY クラス;


演習課題「ユーザーの財務状況を調べる」
SELECT userID, gold
FROM users;
↓

-- 所持金で、お金持ちか分類する
SELECT
    userID,
    gold,
    CASE
		WHEN gold >= 3000 THEN '大金持ち'
		WHEN gold >= 1000 THEN '小金持ち'
		ElSE '発展途上'
	END AS finance
FROM users;



CASEの基本形
-- データを分類し直す
SELECT
	userID,
	level,
	CASE
		WHEN (条件式1) THEN (出力1)
		WHEN (条件式2) THEN (出力2)
		ElSE (出力3)
	END
FROM
	users

参考になるWebサイト
便利なCASE文 - Qiita
http://qiita.com/wcareer/items/c5645058cd89b18c9f21

CASE式のススメ
http://www.geocities.jp/mickindex/database/db_case.html

MySQL :: MySQL 5.6 リファレンスマニュアル :: 13.6.5.1 CASE 構文
https://dev.mysql.com/doc/refman/5.6/ja/case.html


＃10:クロス集計してみよう
SELECT
	startTime,
	eventlog.userID,
	users.level
FROM eventlog
	INNER JOIN users ON users.userID = eventlog.userID;
↓

-- クロス集計
SELECT
	DATE_FORMAT(startTime, '%Y-%m') AS 日付,
	eventlog.userID AS ユーザー,
	CASE
	    WHEN users.level >= 4 THEN '上級'
        WHEN users.level >= 2 THEN '中級'
        ELSE '初級'
    END AS クラス
FROM eventlog
	INNER JOIN users ON users.userID = eventlog.userID;

↓　重複を削除

SELECT DISTINCT
	DATE_FORMAT(startTime, '%Y-%m') AS 日付,
	eventlog.userID AS ユーザー,
	CASE
	    WHEN users.level >= 4 THEN '上級'
        WHEN users.level >= 2 THEN '中級'
        ELSE '初級'
    END AS クラス
FROM eventlog
	INNER JOIN users ON users.userID = eventlog.userID;

↓　サブクエリ化

SELECT *
FROM (SELECT DISTINCT
	DATE_FORMAT(startTime, '%Y-%m') AS 日付,
	eventlog.userID AS ユーザー,
	CASE
	    WHEN users.level >= 4 THEN '上級'
        WHEN users.level >= 2 THEN '中級'
        ELSE '初級'
    END AS クラス
FROM eventlog
	INNER JOIN users ON users.userID = eventlog.userID
) AS クラス分け;

↓　パネルデータ化

SELECT
    日付,
    ユーザー,
    クラス,
    CASE WHEN クラス = '初級' THEN 1 ELSE 0 END AS 初級,
    CASE WHEN クラス = '中級' THEN 1 ELSE 0 END AS 中級,
    CASE WHEN クラス = '上級' THEN 1 ELSE 0 END AS 上級
FROM (SELECT DISTINCT
	DATE_FORMAT(startTime, '%Y-%m') AS 日付,
	eventlog.userID AS ユーザー,
	CASE
	    WHEN users.level >= 4 THEN '上級'
        WHEN users.level >= 2 THEN '中級'
        ELSE '初級'
    END AS クラス
FROM eventlog
	INNER JOIN users ON users.userID = eventlog.userID
) AS クラス分け;

↓　月ごとに集計

SELECT
    日付,
    SUM(CASE WHEN クラス = '初級' THEN 1 ELSE 0 END) AS 初級,
    SUM(CASE WHEN クラス = '中級' THEN 1 ELSE 0 END) AS 中級,
    SUM(CASE WHEN クラス = '上級' THEN 1 ELSE 0 END) AS 上級
FROM (SELECT DISTINCT
    	DATE_FORMAT(startTime, '%Y-%m') AS 日付,
    	eventlog.userID AS ユーザー,
    	CASE
    	    WHEN users.level >= 4 THEN '上級'
            WHEN users.level >= 2 THEN '中級'
            ELSE '初級'
        END AS クラス
    FROM eventlog
    	INNER JOIN users ON users.userID = eventlog.userID
    ) AS クラス分け
GROUP BY 日付;

演習課題「ユーザーの財務状況をクロス集計する」
SELECT
	日付,
		SUM(CASE WHEN finance = '大金持ち' THEN 1 ELSE 0 END) AS 大金持ち,
	SUM(CASE WHEN finance = '小金持ち' THEN 1 ELSE 0 END) AS 小金持ち,
	SUM(CASE WHEN finance = '発展途上' THEN 1 ELSE 0 END) AS 発展途上
FROM ( SELECT DISTINCT
    	DATE_FORMAT(startTime, '%Y%m') AS 日付,
    	eventlog.userID,
    	CASE
    		WHEN gold >= 3000 THEN "大金持ち"
    		WHEN gold >= 1000 THEN "小金持ち"
    		ELSE "発展途上"
    	END AS finance
	FROM eventlog
		INNER JOIN users ON users.userID = eventlog.userID
	) AS クラス分け
GROUP BY 日付;

クロス集計表を作る手順
1. クロス集計の元になるデータを用意する
2. サブクエリとして読み込む
3. CASEで、特定の値だったら1にする。このとき別名を、特定の値と同じにする

CASE WHEN クラス = "初級" THEN 1 ELSE NULL END AS "初級",
CASE WHEN クラス = "中級" THEN 1 ELSE NULL END AS "中級",
CASE WHEN クラス = "上級" THEN 1 ELSE NULL END AS "上級"

4. SUM関数とGROUP BYで集計する

参考になるWebサイト
MySQLでクロス集計してみた | トーハム紀行
http://torhamzedd.blogspot.jp/2010/06/mysql.html


＃11:サブクエリで、平均や割合を求めよう
平均
SELECT AVG(level) AS 平均レベル FROM users;

平均以上のユーザー
SELECT userID, name, level
FROM users
WHERE level >= (SELECT AVG(level) AS 平均レベル FROM users);

平均以上のユーザー数
SELECT COUNT(userID) AS 平均以上のユーザー数
FROM users
WHERE level >= (SELECT AVG(level) AS 平均レベル FROM users);

-- サブクエリで、平均レベル以上の割合を求める
SELECT
    COUNT(userID) AS 平均以上のユーザー数,
    (SELECT COUNT(*) FROM users) AS 全体のユーザー数,
    COUNT(userID) / (SELECT COUNT(*) FROM users) * 100 AS 割合
FROM users
WHERE level >= (SELECT AVG(level) AS 平均レベル FROM users);


演習課題「平均以上の所持金を持つユーザーだけ表示する」
-- 平均以上の所持金を持つユーザーを表示する
SELECT userID, name, gold
FROM users
WHERE gold >= (SELECT AVG(gold) AS 平均レベル FROM users);


SELECT
	TIMESTAMPDIFF(YEAR, birth, '2017-01-01') AS '年齢'
FROM
	users;


-- ユーザーの平均年齢を求める
サブクエリを使って平均年齢を求めてください。
SELECT
    SUM(TIMESTAMPDIFF(YEAR, birth, '2017-01-01') ) AS 年齢の合計,
	COUNT(userID) AS ユーザー数,
    (SELECT AVG(TIMESTAMPDIFF(YEAR, birth, '2017-01-01')) FROM users) AS 平均年齢
FROM
	users;

*
SELECT
	SUM(TIMESTAMPDIFF(YEAR, birth, '2017-01-01') ) AS 年齢の合計,
	COUNT(userID) AS ユーザー数,
    AVG(TIMESTAMPDIFF(YEAR, birth, '2017-01-01')) AS '平均年齢'
FROM
	users;

 サブクエリの基本形
FROM句に書く場合


-- FROM句に書く場合
SELECT *
FROM (サブクエリ) AS (サブクエリ名);


WHERE句に書く場合

-- WHERE句に書く場合
SELECT *
FROM users
WHERE level = ((サブクエリ));


SELECT句に書く場合

-- SELECT句に書く場合
SELECT (サブクエリ) AS (サブクエリ名)
FROM users;

参考になるWebサイト
逆引きSQL構文集 - 副問合せ(サブクエリ)を行う
http://www.sql-reference.com/select/subquery.html

SQL 副問い合わせの基本を理解する
http://omachizura.com/sql/%E5%89%AF%E5%95%8F%E3%81%84%E5%90%88%E3%82%8F%E3%81%9B%E3%82%92%E7%90%86%E8%A7%A3%E3%81%99%E3%82%8B.html
