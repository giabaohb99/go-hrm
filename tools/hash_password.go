package main

import (
	"fmt"
	"log"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	password := "admin123"
	
	// Generate hash
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	if err != nil {
		log.Fatal(err)
	}
	
	fmt.Println("Password:", password)
	fmt.Println("Bcrypt hash:", string(hash))
	
	// Verify it works
	err = bcrypt.CompareHashAndPassword(hash, []byte(password))
	if err != nil {
		fmt.Println("Verification FAILED!")
	} else {
		fmt.Println("Verification SUCCESS!")
	}
}
