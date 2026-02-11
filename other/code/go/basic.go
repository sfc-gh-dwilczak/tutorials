package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/snowflakedb/gosnowflake"
)

func main() {
	dsn := "service_go:<PASSWORD GOES HERE>@ggb82720/raw/aws?warehouse=developer"
	db, err := sql.Open("snowflake", dsn)
	if err != nil {
		log.Fatalf("Failed to open a DB connection: %v", err)
	}
	defer db.Close()

	var result string
	err = db.QueryRow("SELECT 1").Scan(&result)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(result)
}
