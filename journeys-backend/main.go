package main

import (
	"be_journeys/config"
	"be_journeys/routes"
	"fmt"
)

func main() {
	config.ConnectDB()
	config.InitFirebase()

	r := routes.SetupRouter()

	routes.AuthRoutes(r)
	routes.UserRoutes(r)
	routes.ProfileRoutes(r)
	routes.CategoryRoutes(r)

	fmt.Println("Server running on :8080")
	r.Run(":8080")
}
