package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/snowflakedb/gosnowflake"
	_ "github.com/snowflakedb/gosnowflake"
)

func main() {
	// Set up environment variables
	os.Setenv("SNOWFLAKE_ACCOUNT", "ggb82720")
	os.Setenv("SNOWFLAKE_USER", "daniel.wilczak@snowflake.com")
	// Specify that you want to use external browser authentication
	os.Setenv("SNOWFLAKE_AUTHENTICATOR", "externalbrowser")

	// Build the DSN (Data Source Name)
	dsn, err := gosnowflake.DSN(&gosnowflake.Config{
		Account:       os.Getenv("SNOWFLAKE_ACCOUNT"),
		User:          os.Getenv("SNOWFLAKE_USER"),
		Authenticator: gosnowflake.AuthTypeExternalBrowser,
	})

	if err != nil {
		log.Fatalf("Failed to build DSN: %v", err)
	}

	// Open a database connection
	db, err := sql.Open("snowflake", dsn)
	if err != nil {
		log.Fatalf("Failed to open database: %v", err)
	}
	defer db.Close()

	// Test the connection
	err = db.Ping()
	if err != nil {
		log.Fatalf("Failed to connect to Snowflake: %v", err)
	}

	fmt.Println("Successfully connected to Snowflake!")
	// Now you can execute queries using db.Query or db.Exec
}
