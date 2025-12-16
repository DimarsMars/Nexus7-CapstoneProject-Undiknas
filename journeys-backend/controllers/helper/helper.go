package helper

import (
	"fmt"
	"math"
)

func CalculateRank(xp int) string {
	switch {
	case xp >= 300:
		return "Master"
	case xp >= 200:
		return "Pro"
	case xp >= 100:
		return "Adventurer"
	default:
		return "Newbie"
	}
}

func CalculateDistance(lat1, lon1, lat2, lon2 float64) float64 {
	const R = 6371 // Earth radius in KM

	dLat := (lat2 - lat1) * math.Pi / 180.0
	dLon := (lon2 - lon1) * math.Pi / 180.0

	lat1 = lat1 * math.Pi / 180.0
	lat2 = lat2 * math.Pi / 180.0

	a := math.Sin(dLat/2)*math.Sin(dLat/2) +
		math.Sin(dLon/2)*math.Sin(dLon/2)*math.Cos(lat1)*math.Cos(lat2)
	c := 2 * math.Atan2(math.Sqrt(a), math.Sqrt(1-a))
	d := R * c

	return d
}

func StringToUint(s string) uint {
	var id uint
	fmt.Sscanf(s, "%d", &id)
	return id
}
