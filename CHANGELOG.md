# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2025-06-03

### Added
- `PromptScrub::Middleware` — Faraday middleware for request redaction + response rehydration
- Built-in detectors: email, SSN, credit card (Luhn-validated), US phone number
- `PromptScrub::Vault` — per-request thread-safe token↔value store
- `PromptScrub::StreamRehydrator` — streaming helper with partial-token buffer
- `PromptScrub.configure` block for global configuration
- `Configuration#add_detector` — register custom regex detectors
- `Configuration#disable_detector` — opt out of specific built-in detectors
