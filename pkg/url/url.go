package url

import "strings"

const characterMap = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

func mapReverse(original string) map[rune]int64 {
	storedMap := map[rune]int64{}
	for pos, cha := range original {
		storedMap[cha] = int64(pos)
	}
	return storedMap
}
func reverse(s string) string {
	var b strings.Builder
	b.Grow(len(s))
	for i := len(s) - 1; i >= 0; i-- {
		b.WriteByte(s[i])
	}
	return b.String()
}

// DecodeSlug decode a slug back into numbers

// Shortener class to handle url shorten and decode
type Shortener struct {
	AvaliableMap string
	ReverseMap   map[rune]int64
}

// ShortenURL compute slug for given id
func (e Shortener) ShortenURL(n int64) string {
	var str strings.Builder
	for i := 0; i < 9; i++ {
		str.WriteByte(e.AvaliableMap[n%62])
		n = n / 62
	}
	return str.String()
}

// DecodeSlug decode given slug to id
func (e Shortener) DecodeSlug(n string) int64 {
	var output int64 = 0
	for _, cha := range reverse(n) {
		output = output*62 + e.ReverseMap[cha]
	}
	return output
}

// New instance creation
func New() Shortener {
	runeMap := characterMap
	reversed := mapReverse(runeMap)
	s := Shortener{runeMap, reversed}
	return s
}
