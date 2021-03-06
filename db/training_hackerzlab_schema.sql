DROP TABLE IF EXISTS user;
CREATE TABLE user (                                     -- ユーザー
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    login_id        TEXT,                               -- ログインID名 (例: 'hackerz@gmail.com')
    password        TEXT,                               -- ログインパスワード (例: 'hackerz')
    name            TEXT,                               -- 名前 (例: 'おそまつ')
    approved        INTEGER,                            -- 承認フラグ (例: 0: 承認していない, 1: 承認済み)
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS question;
CREATE TABLE question (                                 -- 問題
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    title           TEXT,                               -- タイトル (例: '文字列を解読せよ')
    question        TEXT,                               -- 問題文 (例: '以下の暗号を解読し、元の文字列を解読せよ。')
    answer          TEXT,                               -- 問題の答え (例: 'Stay Hungry')
    score           INTEGER,                            -- 得点 (例 10)
    level           INTEGER,                            -- 難易度 (例: 1)
    pattern         INTEGER,                            -- 問題パターン (例: 10: form, 20: choice, ...)
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS collected;
CREATE TABLE collected (                                -- 問題集
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    title           TEXT,                               -- タイトル (例: '第１回 2016-01-31')
    description     TEXT,                               -- 問題集の説明 (例: '簡単なものから難しいものまで')
    passcode        TEXT,                               -- 問題集の解くための認証 (例: 'hackerz999')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS collected_sort;
CREATE TABLE collected_sort (                           -- 問題集と問題の順番
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    collected_id    INTEGER,                            -- 問題集ID (例 1)
    question_id     INTEGER,                            -- 問題ID (例: 1)
    sort_id         INTEGER,                            -- 問題集の中での問題の順番 (例: 1)
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS choice;
CREATE TABLE choice (                                   -- 問題の答え選択
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    question_id     INTEGER,                            -- 問題ID (例: 5)
    answer_text     TEXT,                               -- 答えの文 (例: '孫 正義')
    answer_val      INTEGER,                            -- 答えの値 (例: 1)
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS survey;
CREATE TABLE survey (                                   -- 調査するページ
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    question_id     INTEGER,                            -- 問題ID (例: 5)
    secret_id       TEXT,                               -- 隠されているID (例: 'Daniel')
    secret_password TEXT,                               -- 隠されているパスワード (例: 'SsrpCujI')
    page_url        TEXT,                               -- 調査用ページへのURL (例: '/cracking_from_list')
    page_title      TEXT,                               -- 調査用ページのタイトル (例: 'クラッキング用ページ')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS hint;
CREATE TABLE hint (                                     -- 問題のヒント
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    question_id     INTEGER,                            -- 問題ID (例: 5)
    level           INTEGER,                            -- ヒントレベル (例: 3 )
    hint            TEXT,                               -- ヒント文面 (例: '問題をよく読んでみよう')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS hint_opened;
CREATE TABLE hint_opened (                              -- 問題のヒント開封履歴
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    user_id         INTEGER,                            -- ユーザーID (例: 5)
    collected_id    INTEGER,                            -- 問題集ID (例: 5)
    hint_id         INTEGER,                            -- 問題のヒントID (例: 5)
    opened          INTEGER,                            -- 開封記録 (例: 0: 開封していない, 1: 開封済み )
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS answer;
CREATE TABLE answer (                                   -- 入力された解答
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    question_id     INTEGER,                            -- 問題ID (例: 5)
    collected_id    INTEGER,                            -- 問題集ID (例: 5)
    user_id         INTEGER,                            -- ユーザーID (例: 5)
    user_answer     TEXT,                               -- 入力した答え (例: 'Stay Hungry')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS answer_time;
CREATE TABLE answer_time (                              -- 入力された時間
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    answer_id       INTEGER,                            -- 入力された解答ID (例: 5)
    remaining_sec   INTEGER,                            -- 残り時間 (例: 600) 秒で入力
    entered_ts      TEXT,                               -- 入力した日時 (例: '2016-01-08 12:24:12')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
DROP TABLE IF EXISTS question_opened;
CREATE TABLE question_opened (                          -- 問題の開封履歴
    id              INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID (例: 5)
    user_id         INTEGER,                            -- ユーザーID (例: 5)
    question_id     INTEGER,                            -- 問題ID (例: 5)
    collected_id    INTEGER,                            -- 問題集ID (例: 5)
    opened          INTEGER,                            -- 開封記録 (例: 0: 開封していない, 1: 開封済み )
    opened_ts       TEXT,                               -- 開封日時 (例: '2016-01-08 12:24:12')
    deleted         INTEGER,                            -- 削除フラグ (例: 0: 削除していない, 1: 削除済み)
    created_ts      TEXT,                               -- 登録日時 (例: '2016-01-08 12:24:12')
    modified_ts     TEXT                                -- 修正日時 (例: '2016-01-08 12:24:12')
);
