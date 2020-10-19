package main

import "fmt"

type wh struct {
	w, h int
}

func main() {
	ppi := 150
	sizes := []wh{
		{40, 30},
		{30, 20},
		{36, 24},
		{48, 36}, // Vistaprint $31.77
		{28, 22}, // PrintFast $19.04
		{24, 18},
		{20, 16},
	}
	for _, size := range sizes {
		ratio := float32(size.w) / float32(size.h)
		fmt.Printf("%dx%d in = %dx%d pixels, %s\n", size.w, size.h, size.w*ppi, size.h*ppi, ratioStr(ratio))
	}
}

func ratioStr(ratio float32) string {
	if ratio == 1.25 {
		return "5:4"
	}
	if ratio >= 1.3 && ratio <= 1.335 {
		return "4:3"
	}
	if ratio == 1.6 {
		return "16:10"
	}
	if ratio == 1.7 {
		return "16:9"
	}
	return fmt.Sprintf("%g:1", ratio)
}
