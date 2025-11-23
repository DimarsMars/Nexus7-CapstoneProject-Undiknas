package main

import (
	"be_journeys/config"
	"be_journeys/routes"
	"fmt"
)

func main() {
	config.ConnectDB()
	r := routes.SetupRouter()
	fmt.Println("🚀 BE Journeys berjalan di http://localhost:8080 🚀")
	r.Run(":8080")
}
