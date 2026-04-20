# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Development:**
- `bin/setup` — install dependencies, compile assets, prepare database
- `bin/dev` — start all services (Rails, Sidekiq, JS bundler, CSS watcher) via Foreman

**Testing:**
- `bin/test` — run Minitest suite
- `bin/playwright` — run Playwright E2E tests (add `--ui` for interactive mode)
- E2E tests run against a separate server on port 3001

**Code quality:**
- `bundle exec rubocop` — Ruby linting (Rails Omakase config)
- `bundle exec srb tc` — Sorbet type checking
- `bin/types` — regenerate Sorbet RBI files (run after adding gems or DSL changes)
- `bundle exec brakeman` — security scanning

**Database:**
- `bin/reset` — drop, recreate, and seed database

## Architecture

Rails 8 e-commerce app showcasing Espago payment gateway integration. Uses Hotwire (Turbo + Stimulus) for real-time frontend updates without a JS framework.

**Core domain:**
- `User` → Cart → `Order` (with `OrderItem`s) → `Payment`
- `User` → `Subscription` → `Payment`
- `User` → `SavedPaymentMethod` (CIT/MIT stored authorizations)
- Payments are polymorphic — they belong to either an Order or a Subscription

**Payment processing flow:**
1. Controller creates a Payment record and enqueues a job
2. `app/services/espago_client.rb` wraps the Espago HTTP API (uses the Sofia gem with a Soren HTTP adapter)
3. `app/services/payment_processor/` contains modular classes: `Charge`, `Refund`, `Reverse`, `Check`, `StateManager`, and builders under `request/`
4. `app/services/client_processor/` handles saving/deleting payment methods
5. `BackRequestsProcessor` handles async Espago webhook callbacks
6. Background jobs (`app/jobs/`) poll for status updates and handle subscription renewal/expiry via Sidekiq

**Real-time updates:** Models call `broadcasts_refreshes` (turbo-rails), so UI updates automatically when payment state changes.

**Type safety:** Sorbet strict mode is enforced throughout. Every new class/method needs Sorbet signatures. Run `bin/types` after gem changes.

**Testing patterns:**
- Integration tests use VCR cassettes (`test/cassettes/`) to record/replay Espago HTTP interactions
- Factories are in `test/factories/` (FactoryBot)
- System tests use Cuprite (headless Chrome via Ferrum)

**Background jobs (Sidekiq):**
- `UpdatePaymentStatusJob` — polls Espago for async payment results
- `FinalizePaymentJob` — completes payment lifecycle
- `RenewSubscriptionJob` / `ExpireSubscriptionJob` — scheduled via `config/recurring.yml`

**Credentials:** Espago API credentials (username/password for Basic Auth) live in `config/credentials.yml.enc`. Access with `bin/rails credentials:edit`.

**CI:** GitHub Actions runs RuboCop → Sorbet → Minitest → Playwright on every push/PR. Requires `RAILS_MASTER_KEY` and `ESPAGO_PUBLIC_KEY` secrets.
