package main

import (
	"flag"
	"fmt"
	"log"
	"web-work-request-backend/utils"
)

func main() {
	var (
		password = flag.String("password", "", "Password to hash")
		generate = flag.Bool("generate", false, "Generate a random password")
		length   = flag.Int("length", 12, "Length of generated password (when using -generate)")
		verify   = flag.String("verify", "", "Password to verify against hash")
		hash     = flag.String("hash", "", "Hash to verify password against (use with -verify)")
	)
	flag.Parse()

	if *generate {
		// Generate a random password and its hash
		password, hash, err := utils.GenerateSecurePassword(*length)
		if err != nil {
			log.Fatalf("Error generating password: %v", err)
		}
		fmt.Printf("Generated Password: %s\n", password)
		fmt.Printf("Password Hash: %s\n", hash)
		return
	}

	if *verify != "" && *hash != "" {
		// Verify password against hash
		if utils.CheckPasswordHash(*verify, *hash) {
			fmt.Println("✅ Password matches hash!")
		} else {
			fmt.Println("❌ Password does not match hash!")
		}
		return
	}

	if *password != "" {
		// Hash the provided password
		hash, err := utils.GeneratePasswordHash(*password)
		if err != nil {
			log.Fatalf("Error hashing password: %v", err)
		}
		fmt.Printf("Password: %s\n", *password)
		fmt.Printf("Hash: %s\n", hash)
		return
	}

	// Show usage if no valid flags provided
	fmt.Println("Password Hash Generator for Web Work Request Backend")
	fmt.Println("")
	fmt.Println("Usage:")
	fmt.Println("  Generate hash for a password:")
	fmt.Println("    go run cmd/password/main.go -password=\"yourpassword\"")
	fmt.Println("")
	fmt.Println("  Generate a random password with hash:")
	fmt.Println("    go run cmd/password/main.go -generate -length=16")
	fmt.Println("")
	fmt.Println("  Verify a password against a hash:")
	fmt.Println("    go run cmd/password/main.go -verify=\"password\" -hash=\"hashstring\"")
	fmt.Println("")
	fmt.Println("Examples:")
	fmt.Println("  go run cmd/password/main.go -password=\"admin123\"")
	fmt.Println("  go run cmd/password/main.go -generate -length=20")
	fmt.Println("  go run cmd/password/main.go -verify=\"admin123\" -hash=\"$2a$10$...\"")
}
