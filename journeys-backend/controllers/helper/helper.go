package helper

import (
	"fmt"
	"math"
)

func CalculateRank(totalXP int) string {
	level := calculateLevel(totalXP)

	// Newbie
	if level == 0 {
		return "Newbie"
	}

	var rank string
	switch {
	case level >= 1 && level <= 5:
		rank = "Adventurer"
	case level >= 6 && level <= 10:
		rank = "Traveller"
	case level >= 11 && level <= 15:
		rank = "Backpacker"

	case level >= 16 && level <= 20:
		rank = "Adventurer Bronze"
	case level >= 21 && level <= 25:
		rank = "Traveller Bronze"
	case level >= 26 && level <= 30:
		rank = "Backpacker Bronze"

	case level >= 31 && level <= 35:
		rank = "Adventurer Silver"
	case level >= 36 && level <= 40:
		rank = "Traveller Silver"
	case level >= 41 && level <= 45:
		rank = "Backpacker Silver"

	case level >= 46 && level <= 50:
		rank = "Adventurer Gold"
	case level >= 51 && level <= 55:
		rank = "Traveller Gold"
	default:
		rank = "Backpacker Gold"
	}

	return fmt.Sprintf("%s lvl %d", rank, level)
}

func calculateLevel(totalXP int) int {
	if totalXP < 100 {
		return 0
	}
	return totalXP / 100
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
