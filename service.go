package main

import (
	"database/sql"
	"time"

	"github.com/dreamrace/eaturl/pkg/url"
	"github.com/go-redis/redis"
)

var shortener url.Shortener
var db *sql.DB
var cache *redis.Client

var slugGetStatement *sql.Stmt
var slugSetStatement *sql.Stmt

func setUp(
	postgrConnStr string,
	redisHostName string,
	redisPassword string,
) error {

	var err error
	db, err = sql.Open("postgres", postgrConnStr)
	check(err)
	shortener = url.New()
	cache = redis.NewClient(&redis.Options{
		Addr:     redisHostName,
		Password: redisPassword,
		DB:       0,
	})
	_, err = cache.Ping().Result()
	check(err)
	slugGetStatement, err = db.Prepare("SELECT url FROM url WHERE id = $1")
	check(err)
	slugSetStatement, err = db.Prepare("INSERT INTO url (url) VALUES ($1) RETURNING id")
	check(err)

	return nil
}

func addURL(url string) (int64, error) {
	var id sql.NullInt64
	err := slugSetStatement.QueryRow(url).Scan(&id)
	if id.Valid {
		return id.Int64, nil
	} else {
		return -1, err
	}
}

func updateCache(slug string, url string) {
	cache.Set(slug, url, time.Duration(30)*time.Second)
}

func queryCache(slug string) (string, error) {
	var url string
	url, err := cache.Get(slug).Result()
	return url, err
}

func queryDatabase(slug string) (string, error) {
	var matchedURL sql.NullString
	decoded := shortener.DecodeSlug(slug)
	err := slugGetStatement.QueryRow(int(decoded)).Scan(&matchedURL)
	if matchedURL.Valid {
		return matchedURL.String, nil
	} else {
		return "", err
	}
}
