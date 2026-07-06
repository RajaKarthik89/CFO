# Finley — Your AI Financial Operating System

An AI personal CFO that understands your money instead of just displaying it.

Finley goes beyond traditional finance apps. While standard apps merely display numbers and record past transactions, Finley explains what those numbers mean and gives actionable, grounded advice on what to do about them. Built with a design language tailored for students, freelancers, and irregular-income earners in India, Finley acts as a personalized command center for net worth, forecasting, budgets, tax deductions, and savings optimization.

---

## 1. Problem & Solution

### The Problem
Managing money digitally today means juggling multiple fragmented apps—banking portals for balances, credit card apps for statements, UPI apps for quick payments, brokerage portfolios for investments, and separate budgeting trackers. The result is cognitive overload with no unified, forward-looking understanding of one's financial life.

### The Solution
Finley unifies your entire financial stack into a single, cohesive AI-native operating system. It aggregates account balances, investments, goals, tax options, credit limits, and subscriptions under one umbrella, using local generative AI to parse trends and provide clear, explainable recommendations.

---

## 2. Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (SDK version `^3.22.0` / Dart `>=3.2.0 <4.0.0`)
- **State Management**: [Riverpod](https://riverpod.dev/) (`flutter_riverpod` ^2.6.1 & `riverpod_annotation` ^2.6.1)
- **AI Engine**: [Google Generative AI SDK](https://pub.dev/packages/google_generative_ai) (^0.4.7) targeting the **`gemini-2.5-flash`** model on Google Beta endpoints
- **Data Layer**: Local asynchronous mock configuration provider loaded via `flutter_dotenv` (^5.2.1)
- **Charts & Visualizations**: [fl_chart](https://pub.dev/packages/fl_chart) (^0.70.2)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate) (^4.5.2) and custom hover-expandable state animations
- **Typography pairing**: Google Fonts (`google_fonts` ^6.2.1) including **Fraunces** (Serif), **Inter** (Sans-serif), and **IBM Plex Mono** (Monospace)

---

## 3. Feature Documentation

### AI Dashboard / Daily Briefing
- **What it does**: Displays a personalized morning briefing summarizing the user's financial day, current account balance, budget status, and urgent tasks.
- **How it works**: Reads profile and transaction databases via `mock_data_service.dart`. Renders the flat two-tone hero card above the metrics grid using the serif voice. Feeds the data structure to `ai_service.dart` which prompts Gemini to compile the natural language text.
- **Why it matters**: Replaces standard numeric tables with a readable newspaper-like summary that guides the user's financial focus every morning.

### AI Financial Chat ("Finley")
- **What it does**: A conversational assistant that answers user queries about cash flows, subscriptions, and spending metrics.
- **How it works**: Passes user questions in `chat_screen.dart` to the `AIService` along with structural account states (goals, budgets, balances) as contextual markers, returning explanations in the Serif Fraunces typeface.
- **Why it matters**: Replaces generic FAQ search systems with a context-aware personal accountant that actually remembers your account limits.

### Spending Intelligence
- **What it does**: Displays month-over-month category distributions in a flat interactive donut chart.
- **How it works**: Analyzes debit transactions in `finance_calculator.dart` to map category percentages. The chart is rendered in `spending_screen.dart` using the `PieChart` library.
- **Why it matters**: Connects raw account ledger logs to readable percentage visualizers that explain where the money went.

### Automatic Budget Creation
- **What it does**: Generates and monitors budget limits dynamically based on past expenditures.
- **How it works**: Computes a 3-month rolling average of category transactions in `finance_calculator.dart`. Renders visual progress bars that trigger warnings when usage crosses 80%.
- **Why it matters**: Eliminates the friction of manual bookkeeping by setting dynamic limits that match the user's real habits.

### Financial Health Score
- **What it does**: Combines various indices into a single composite wellness index (0-100).
- **How it works**: Computes a weighted score based on savings rate, budget adherence, and subscription efficiency in `finance_calculator.dart`.
- **Why it matters**: Gamifies responsible financial planning by condensing account data into a single health score.

### Savings Goals & Purchase Simulator
- **What it does**: Houses target goals and features a bottom sheet form to add goals with live progress previews.
- **How it works**: The `add_goal_sheet.dart` modal uses controllers to calculate progress percentages on every keystroke. Adds the resulting item to `GoalsNotifier` in `goals_controller.dart` to rebuild the list instantly.
- **Why it matters**: Simulates progress results in real time as the user types, highlighting target timelines before form submission.

### Subscription Manager
- **What it does**: Tracks active subscriptions, flags duplicate/underused ones, and supports adding new ones.
- **How it works**: Reads active subscriptions in `subscriptions_screen.dart`. Prompts Gemini via `ai_service.dart` to generate recommendations (keeping active plans, cancelling wasteful ones with annual savings calculations). Uses `add_subscription_sheet.dart` to append new items.
- **Why it matters**: Recovers wasted cash flow by presenting recurring leaks as concrete annual savings values.

### Savings Simulator
- **What it does**: Interactively forecasts future net worth growth based on lifestyle changes.
- **How it works**: Combines user sliders (adjusting food, travel, or subscription spending) in `simulator_screen.dart` and plots compound growth curves over 1, 5, or 10 years using `fl_chart`.
- **Why it matters**: Helps users visualize the compounding value of minor daily adjustments over a multi-year horizon.

### Natural Language Search
- **What it does**: Filters transaction history using conversational English.
- **How it works**: Accepts search text in `search_screen.dart`. Translates terms to query filters (e.g. date bounds, values) via `search_controller.dart` to query local tables.
- **Why it matters**: Removes complex dropdown forms by allowing users to search like they talk (e.g., "Swiggy above ₹500").

### Predictive Forecast & Cash Runway
- **What it does**: Visualizes projected cash runways and income-vs-expense timelines for the next 30, 60, or 90 days.
- **How it works**: Renders in `forecast_screen.dart`. Projects balances by matching recurring bills against average income, displaying smart notifications for projected deficits.
- **Why it matters**: Alerts users to potential cash flow deficits before they happen.

### Wealth & Net Worth Tracker
- **What it does**: Aggregates assets (Savings, Mutual Funds, Stocks, PF, Gold, Crypto) and liabilities (Loans, Cards) into a net worth index.
- **How it works**: Found in `wealth_screen.dart`. Summarizes balances and displays linked portfolio integrations.
- **Why it matters**: Encourages long-term balance sheet thinking instead of just checking monthly account balances.

### Tax Planning Section
- **What it does**: Recommends tax deductions under Sections 80C and 80D, and aggregates tax documents.
- **How it works**: Calculates current limits in `tax_planning_screen.dart` and recommends tax-saving investments (e.g. ELSS).
- **Why it matters**: Streamlines tax filing by organizing deductions and documents throughout the fiscal year.

### Credit Health Monitor
- **What it does**: Displays credit score dials and alerts when credit utilization crosses 30%.
- **How it works**: Located in `credit_health_screen.dart`. Renders a CIBIL dial and warns the user when utilization approaches high thresholds.
- **Why it matters**: Proactively protects the user's creditworthiness with early utilization alerts.

### Auto-Savings (Round-ups)
- **What it does**: Simulates saving UPI spare change by rounding transactions to the nearest ₹10 or ₹50.
- **How it works**: Enabled in `micro_savings_screen.dart`. Simulates spare change round-ups on everyday transactions.
- **Why it matters**: Makes saving effortless by auto-investing small amounts during daily transactions.

---

## 4. Design System: "Ledger & Ember"

We implement a cohesive dark design language matching financial premium aesthetics:

- **Canvas Background**: `#0B0E1A` (deep dark navy background canvas)
- **Cards Surface**: `#141A2E` (lifted card container surfaces)
- **Warm White**: `#F3F1EA` (primary texts and headers)
- **Muted Slate**: `#8B92A8` (supporting descriptions and labels)
- **Brass / Gold Accent**: `#C9A44C` (used for CTA elements, progress indicators, and highlight figures)
- **Warning Rust**: `#C1554D` (used for negative balances, overruns, and alarms)

### Typography Pairing
- **Serif (Fraunces)**: Reserved exclusively for AI briefing text blocks and quote sections to give a thoughtful, editorial feel.
- **Monospace (IBM Plex Mono)**: Used for all numeric financial balances, dates, and progress percentages to maintain clean tabular alignments.
- **Sans-Serif (Inter)**: Used for standard navigation menus, text field inputs, buttons, and app bars.

---

## 5. Data & Privacy Note

**Disclaimer**: This prototype is a demo created for hackathon evaluation. 
- All financial balances, transactions, and recurring accounts shown are **synthetic mock data** pre-loaded from JSON assets located under `assets/mock_data/`. 
- No real bank connections, SMS reading, or live PAN/UAN credentials are used. 
- In a production environment, Finley would integrate securely with the RBI-approved **Account Aggregator (AA) framework** to sync transactional statement logs with explicit user consent.

---

## 6. What's Not Built (Roadmap)

- **Real Account Sync**: Direct bank integration via Account Aggregator APIs.
- **Direct Investment Executions**: Mutual fund purchases or stock trades (requires SEBI Registered Investment Advisor (RIA) licensing).
- **Automated Tax Filing**: Direct e-filing pipeline with the Income Tax Department.
- **Autonomous Agent Transactions**: Booking tickets or auto-paying credit cards directly from the chat window.

---

## 7. Setup & Run Instructions

### Prerequisites
- Flutter SDK `^3.22.0`
- Dart SDK `^3.2.0`

### Step 1: Clone and Get Dependencies
```bash
git clone <repository_url>
cd CFO
flutter pub get
```

### Step 2: Set Up Environment Variables
Create a file named `.env` at the root of the project:
```env
GEMINI_API_KEY="YOUR_GOOGLE_GEMINI_API_KEY"
```

### Step 3: Run the Project
- **Web (Chrome)**:
  ```bash
  flutter run -d chrome --web-renderer canvaskit
  ```
- **Desktop (macOS)**:
  ```bash
  flutter run -d macos
  ```

---

## 8. Project Structure

```
CFO/
├── assets/                  # Pre-loaded mock JSON datasets and environment templates
│   ├── mock_data/           # Synthetic transactions, subscriptions, and profile info
│   └── .env                 # Environment config file
├── lib/
│   ├── app/                 # Global routers, themes, and font configurations
│   ├── core/
│   │   └── services/        # AI Service, Math calculators, and database mocks
│   ├── features/            # Feature directories (Dashboard, Chat, Budget, Wealth, etc.)
│   ├── models/              # Data structural model classes (Goal, Subscription, etc.)
│   ├── widgets/             # Reusable UI cards, amount visualizers, and banners
│   └── main.dart            # Application starting point
└── test/                    # Unit testing suite for financial algorithms
```
