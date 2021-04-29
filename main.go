package main

import (
	"crypto/rand"

	_ "github.com/influxdata/flux/parser"
)

func init() {
	var buf [12]byte
	rand.Read(buf[:])
}

func main() {
	println("ok")
}
