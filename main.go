package main

import (
	"crypto/rand"

	_ "github.com/influxdata/flux/libflux/go/libflux"
)

func init() {
	var buf [12]byte
	rand.Read(buf[:])
}

func main() {
	println("ok")
}
