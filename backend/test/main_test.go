package main

import (
	"testing"
	"web-work-request-backend/config"
)

func TestConfigLoad(t *testing.T) {
	cfg := config.Load()

	if cfg.ServerPort == "" {
		t.Error("ServerPort should not be empty")
	}

	if cfg.DBHost == "" {
		t.Error("DBHost should not be empty")
	}

	if cfg.JWTSecret == "" {
		t.Error("JWTSecret should not be empty")
	}
}

func TestConfigDefaultValues(t *testing.T) {
	cfg := config.Load()

	if cfg.ServerPort != "8080" {
		t.Errorf("Expected ServerPort to be 8080, got %s", cfg.ServerPort)
	}

	if cfg.DBHost != "localhost" {
		t.Errorf("Expected DBHost to be localhost, got %s", cfg.DBHost)
	}

	if cfg.DBPort != 5432 {
		t.Errorf("Expected DBPort to be 5432, got %d", cfg.DBPort)
	}
}
