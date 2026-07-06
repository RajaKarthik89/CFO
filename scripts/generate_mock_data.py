#!/usr/bin/env python3
"""
Generate realistic synthetic financial data for CFO app demo.
User: Karthik, 22-year-old student/freelancer in Hyderabad, India.
Outputs JSON files to assets/mock_data/
"""

import json
import random
import os
from datetime import datetime, timedelta
from pathlib import Path

random.seed(42)  # Reproducible data

OUTPUT_DIR = Path(__file__).parent.parent / "assets" / "mock_data"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Date range: Jan 1 2026 – Jun 30 2026 (6 months)
START_DATE = datetime(2026, 1, 1)
END_DATE = datetime(2026, 6, 30)
TODAY = datetime(2026, 7, 4)  # "today" for demo purposes


# ── User Profile ──────────────────────────────────────────────
def generate_user_profile():
    profile = {
        "name": "Karthik",
        "age": 22,
        "occupation": "Student & Freelance Developer",
        "monthly_income_avg": 28000,
        "income_type": "irregular_freelance",
        "salary_credit_day": None,
        "primary_bank": "HDFC Bank",
        "cards": [
            {
                "name": "HDFC Millennia",
                "type": "credit",
                "reward_rate": "5% cashback on Amazon & Flipkart, 1% on others",
                "limit": 75000,
            },
            {
                "name": "UPI - HDFC",
                "type": "upi",
                "reward_rate": "0%",
            },
        ],
        "location": "Hyderabad, India",
        "currency": "INR",
    }
    return profile


# ── Transactions ──────────────────────────────────────────────

FOOD_MERCHANTS = [
    ("Swiggy", "Food & Dining"),
    ("Zomato", "Food & Dining"),
    ("Dominos Pizza", "Food & Dining"),
    ("McDonald's", "Food & Dining"),
    ("Chai Point", "Food & Dining"),
    ("Cafe Coffee Day", "Food & Dining"),
    ("Paradise Biryani", "Food & Dining"),
    ("Barbeque Nation", "Food & Dining"),
    ("Meghana Foods", "Food & Dining"),
    ("Local Mess - Ameerpet", "Food & Dining"),
]

SHOPPING_MERCHANTS = [
    ("Amazon India", "Shopping"),
    ("Flipkart", "Shopping"),
    ("Myntra", "Shopping"),
    ("Reliance Digital", "Shopping"),
    ("Decathlon", "Shopping"),
    ("Croma", "Shopping"),
]

TRANSPORT_MERCHANTS = [
    ("Uber India", "Transport"),
    ("Ola Cabs", "Transport"),
    ("Rapido", "Transport"),
    ("Indian Oil Petrol", "Transport"),
    ("HP Petrol Pump", "Transport"),
    ("TSRTC Bus Pass", "Transport"),
]

ENTERTAINMENT_MERCHANTS = [
    ("BookMyShow", "Entertainment"),
    ("PVR Cinemas", "Entertainment"),
    ("INOX Movies", "Entertainment"),
    ("Steam Games", "Entertainment"),
]

BILL_MERCHANTS = [
    ("TSSPDCL Electricity", "Bills & Utilities"),
    ("ACT Fibernet", "Bills & Utilities"),
    ("Jio Recharge", "Bills & Utilities"),
    ("Airtel Recharge", "Bills & Utilities"),
]

SUBSCRIPTION_MERCHANTS = [
    ("Netflix", "Subscriptions"),
    ("Spotify Premium", "Subscriptions"),
    ("Amazon Prime", "Subscriptions"),
    ("Google One 100GB", "Subscriptions"),
    ("YouTube Premium", "Subscriptions"),
]

INVESTMENT_MERCHANTS = [
    ("Groww SIP - Nifty 50", "Investments"),
    ("Groww SIP - Small Cap", "Investments"),
]

PAYMENT_METHODS = ["UPI - HDFC", "HDFC Millennia", "UPI - HDFC", "UPI - HDFC"]  # Weighted toward UPI


def random_date_in_month(year, month):
    if month == 12:
        max_day = 31
    else:
        next_month = datetime(year, month + 1, 1)
        max_day = (next_month - timedelta(days=1)).day
    day = random.randint(1, max_day)
    hour = random.randint(7, 23)
    minute = random.randint(0, 59)
    return datetime(year, month, day, hour, minute, 0)


def generate_transactions():
    transactions = []
    tx_id = 1000

    months = [(2026, m) for m in range(1, 7)]  # Jan-Jun 2026

    for month_idx, (year, month) in enumerate(months):
        # ── Freelance Income (irregular, 2-4 credits per month, avg ~28k/mo) ──
        num_income = random.choice([2, 2, 3, 3, 4])
        for _ in range(num_income):
            amount = random.choice([8000, 10000, 12000, 12000, 15000, 15000, 18000, 20000, 25000, 30000])
            tx_id += 1
            transactions.append({
                "id": f"TXN{tx_id}",
                "date": random_date_in_month(year, month).strftime("%Y-%m-%dT%H:%M:%S"),
                "merchant": random.choice(["Upwork Freelance Payment", "Fiverr Payment", "Client - Direct Transfer", "Freelance Project Payment", "Toptal Payment"]),
                "category": "Income",
                "amount": amount,
                "type": "credit",
                "payment_method": "Bank Transfer",
                "description": "Freelance development work",
            })

        # Family transfer (occasional, ~every other month)
        if month_idx % 2 == 0:
            tx_id += 1
            transactions.append({
                "id": f"TXN{tx_id}",
                "date": random_date_in_month(year, month).strftime("%Y-%m-%dT%H:%M:%S"),
                "merchant": "Family - NEFT Transfer",
                "category": "Income",
                "amount": random.choice([8000, 10000, 10000, 12000, 15000]),
                "type": "credit",
                "payment_method": "Bank Transfer",
                "description": "Family support",
            })

        # ── Food & Dining (higher on weekends, increasing trend) ──
        base_food_count = 8 + month_idx * 2  # Gradually increases
        for _ in range(base_food_count):
            merchant, category = random.choice(FOOD_MERCHANTS)
            # Swiggy/Zomato orders are typically ₹200-600, restaurants higher
            if merchant in ("Swiggy", "Zomato"):
                amount = random.randint(180, 650)
            elif merchant in ("Barbeque Nation",):
                amount = random.randint(800, 2000)
            elif merchant in ("Paradise Biryani", "Meghana Foods"):
                amount = random.randint(300, 700)
            else:
                amount = random.randint(80, 350)

            dt = random_date_in_month(year, month)
            # Weekend boost: increase amount slightly on weekends
            if dt.weekday() >= 5:
                amount = int(amount * random.uniform(1.1, 1.5))

            tx_id += 1
            transactions.append({
                "id": f"TXN{tx_id}",
                "date": dt.strftime("%Y-%m-%dT%H:%M:%S"),
                "merchant": merchant,
                "category": category,
                "amount": amount,
                "type": "debit",
                "payment_method": random.choice(PAYMENT_METHODS),
                "description": "",
            })

        # ── Shopping (2-5 per month, occasional big purchase) ──
        num_shopping = random.randint(2, 5)
        for _ in range(num_shopping):
            merchant, category = random.choice(SHOPPING_MERCHANTS)
            if merchant in ("Reliance Digital", "Croma"):
                # Occasional big electronics purchase
                amount = random.choice([1500, 2500, 3500, 5000, 8000, 15000])
            elif merchant in ("Amazon India", "Flipkart"):
                amount = random.choice([299, 499, 799, 999, 1499, 2499, 3999])
            else:
                amount = random.randint(500, 3000)

            tx_id += 1
            pm = "HDFC Millennia" if merchant in ("Amazon India", "Flipkart") else random.choice(PAYMENT_METHODS)
            transactions.append({
                "id": f"TXN{tx_id}",
                "date": random_date_in_month(year, month).strftime("%Y-%m-%dT%H:%M:%S"),
                "merchant": merchant,
                "category": category,
                "amount": amount,
                "type": "debit",
                "payment_method": pm,
                "description": "",
            })

        # Big one-off purchase in specific months
        if month == 2:  # Bought earbuds in Feb
            tx_id += 1
            transactions.append({
                "id": f"TXN{tx_id}",
                "date": datetime(2026, 2, 14, 15, 30).strftime("%Y-%m-%dT%H:%M:%S"),
                "merchant": "Amazon India",
                "category": "Shopping",
                "amount": 4999,
                "type": "debit",
                "payment_method": "HDFC Millennia",
                "description": "Sony WF-C700N Earbuds",
            })
        if month == 4:  # Bought a keyboard in April
            tx_id += 1
            transactions.append({
                "id": f"TXN{tx_id}",
                "date": datetime(2026, 4, 8, 11, 20).strftime("%Y-%m-%dT%H:%M:%S"),
                "merchant": "Amazon India",
                "category": "Shopping",
                "amount": 8499,
                "type": "debit",
                "payment_method": "HDFC Millennia",
                "description": "Keychron K2 Mechanical Keyboard",
            })

        # ── Transport (3-6 per month) ──
        num_transport = random.randint(3, 6)
        for _ in range(num_transport):
            merchant, category = random.choice(TRANSPORT_MERCHANTS)
            if "Petrol" in merchant:
                amount = random.choice([500, 800, 1000, 1200])
            elif merchant == "TSRTC Bus Pass":
                amount = 500
            else:
                amount = random.randint(80, 350)

            tx_id += 1
            transactions.append({
                "id": f"TXN{tx_id}",
                "date": random_date_in_month(year, month).strftime("%Y-%m-%dT%H:%M:%S"),
                "merchant": merchant,
                "category": category,
                "amount": amount,
                "type": "debit",
                "payment_method": "UPI - HDFC",
                "description": "",
            })

        # ── Entertainment (1-2 per month) ──
        num_entertainment = random.randint(1, 2)
        for _ in range(num_entertainment):
            merchant, category = random.choice(ENTERTAINMENT_MERCHANTS)
            if "Steam" in merchant:
                amount = random.choice([349, 499, 799, 1299])
            else:
                amount = random.randint(200, 500)

            tx_id += 1
            transactions.append({
                "id": f"TXN{tx_id}",
                "date": random_date_in_month(year, month).strftime("%Y-%m-%dT%H:%M:%S"),
                "merchant": merchant,
                "category": category,
                "amount": amount,
                "type": "debit",
                "payment_method": random.choice(PAYMENT_METHODS),
                "description": "",
            })

        # ── Bills (monthly) ──
        # Electricity
        tx_id += 1
        transactions.append({
            "id": f"TXN{tx_id}",
            "date": datetime(year, month, random.randint(5, 10), 10, 0).strftime("%Y-%m-%dT%H:%M:%S"),
            "merchant": "TSSPDCL Electricity",
            "category": "Bills & Utilities",
            "amount": random.randint(800, 1500),
            "type": "debit",
            "payment_method": "UPI - HDFC",
            "description": "Monthly electricity bill",
        })

        # WiFi
        tx_id += 1
        transactions.append({
            "id": f"TXN{tx_id}",
            "date": datetime(year, month, random.randint(1, 5), 10, 0).strftime("%Y-%m-%dT%H:%M:%S"),
            "merchant": "ACT Fibernet",
            "category": "Bills & Utilities",
            "amount": 999,
            "type": "debit",
            "payment_method": "UPI - HDFC",
            "description": "Monthly WiFi bill - 150 Mbps plan",
        })

        # Mobile recharge
        tx_id += 1
        transactions.append({
            "id": f"TXN{tx_id}",
            "date": datetime(year, month, random.randint(15, 25), 10, 0).strftime("%Y-%m-%dT%H:%M:%S"),
            "merchant": "Jio Recharge",
            "category": "Bills & Utilities",
            "amount": 299,
            "type": "debit",
            "payment_method": "UPI - HDFC",
            "description": "Monthly mobile recharge",
        })

        # ── Subscriptions (monthly) ──
        for merchant, category in SUBSCRIPTION_MERCHANTS:
            prices = {
                "Netflix": 649,
                "Spotify Premium": 119,
                "Amazon Prime": 149,
                "Google One 100GB": 130,
                "YouTube Premium": 149,
            }
            tx_id += 1
            transactions.append({
                "id": f"TXN{tx_id}",
                "date": datetime(year, month, random.randint(1, 5), 8, 0).strftime("%Y-%m-%dT%H:%M:%S"),
                "merchant": merchant,
                "category": category,
                "amount": prices[merchant],
                "type": "debit",
                "payment_method": "HDFC Millennia",
                "description": f"Monthly {merchant} subscription",
            })

        # ── Rent (monthly) ──
        tx_id += 1
        transactions.append({
            "id": f"TXN{tx_id}",
            "date": datetime(year, month, 1, 9, 0).strftime("%Y-%m-%dT%H:%M:%S"),
            "merchant": "Rent - PG Accommodation",
            "category": "Rent",
            "amount": 8000,
            "type": "debit",
            "payment_method": "Bank Transfer",
            "description": "Monthly PG rent - Madhapur",
        })

        # ── Investments (SIP - monthly) ──
        tx_id += 1
        transactions.append({
            "id": f"TXN{tx_id}",
            "date": datetime(year, month, 5, 9, 30).strftime("%Y-%m-%dT%H:%M:%S"),
            "merchant": "Groww SIP - Nifty 50",
            "category": "Investments",
            "amount": 500,
            "type": "debit",
            "payment_method": "Bank Transfer",
            "description": "Monthly SIP - Nifty 50 Index Fund",
        })

        # ── Goal contributions (sporadic savings transfers) ──
        if random.random() > 0.3:  # ~70% chance each month
            tx_id += 1
            amount = random.choice([2000, 3000, 5000, 5000, 7000, 8000])
            transactions.append({
                "id": f"TXN{tx_id}",
                "date": random_date_in_month(year, month).strftime("%Y-%m-%dT%H:%M:%S"),
                "merchant": "Savings Transfer - MacBook Fund",
                "category": "Savings",
                "amount": amount,
                "type": "debit",
                "payment_method": "Bank Transfer",
                "description": "Savings for MacBook Air goal",
            })

        if random.random() > 0.5:  # ~50% chance
            tx_id += 1
            amount = random.choice([1000, 2000, 2000, 3000])
            transactions.append({
                "id": f"TXN{tx_id}",
                "date": random_date_in_month(year, month).strftime("%Y-%m-%dT%H:%M:%S"),
                "merchant": "Savings Transfer - Emergency Fund",
                "category": "Savings",
                "amount": amount,
                "type": "debit",
                "payment_method": "Bank Transfer",
                "description": "Savings for Emergency Fund goal",
            })

    # Sort by date
    transactions.sort(key=lambda t: t["date"])

    # Compute running balance (starting with an initial balance)
    initial_balance = 15000  # Starting balance Jan 1
    running_balance = initial_balance
    for tx in transactions:
        if tx["type"] == "credit":
            running_balance += tx["amount"]
        else:
            running_balance -= tx["amount"]
        tx["balance_after"] = running_balance

    return transactions, initial_balance


# ── Goals ─────────────────────────────────────────────────────
def generate_goals():
    goals = [
        {
            "id": "goal_1",
            "name": "MacBook Air M3",
            "target_amount": 110000,
            "saved_amount": 35000,
            "target_date": "2026-12-31",
            "created_date": "2026-01-15",
            "category": "Electronics",
            "priority": "high",
            "monthly_contribution_target": 7500,
            "icon": "laptop_mac",
        },
        {
            "id": "goal_2",
            "name": "Emergency Fund",
            "target_amount": 50000,
            "saved_amount": 12000,
            "target_date": "2027-06-30",
            "created_date": "2026-01-01",
            "category": "Safety Net",
            "priority": "high",
            "monthly_contribution_target": 3000,
            "icon": "shield",
        },
        {
            "id": "goal_3",
            "name": "Goa Trip with Friends",
            "target_amount": 25000,
            "saved_amount": 8000,
            "target_date": "2026-10-15",
            "created_date": "2026-03-01",
            "category": "Travel",
            "priority": "medium",
            "monthly_contribution_target": 4000,
            "icon": "flight",
        },
    ]
    return goals


# ── Subscriptions ─────────────────────────────────────────────
def generate_subscriptions():
    subscriptions = [
        {
            "id": "sub_1",
            "name": "Netflix",
            "monthly_cost": 649,
            "annual_cost": 7788,
            "category": "Entertainment",
            "billing_cycle": "monthly",
            "next_billing_date": "2026-07-05",
            "last_used": "2026-06-15",
            "usage_frequency": "low",
            "status": "underused",
            "notes": "Watched only 2 shows in the last 3 months",
        },
        {
            "id": "sub_2",
            "name": "Spotify Premium",
            "monthly_cost": 119,
            "annual_cost": 1428,
            "category": "Music",
            "billing_cycle": "monthly",
            "next_billing_date": "2026-07-03",
            "last_used": "2026-07-03",
            "usage_frequency": "daily",
            "status": "active",
            "notes": "Used daily for music and podcasts",
        },
        {
            "id": "sub_3",
            "name": "Amazon Prime",
            "monthly_cost": 149,
            "annual_cost": 1788,
            "category": "Shopping & Entertainment",
            "billing_cycle": "monthly",
            "next_billing_date": "2026-07-08",
            "last_used": "2026-07-01",
            "usage_frequency": "weekly",
            "status": "active",
            "notes": "Used for delivery and occasional Prime Video",
        },
        {
            "id": "sub_4",
            "name": "Google One 100GB",
            "monthly_cost": 130,
            "annual_cost": 1560,
            "category": "Cloud Storage",
            "billing_cycle": "monthly",
            "next_billing_date": "2026-07-10",
            "last_used": "2026-07-04",
            "usage_frequency": "daily",
            "status": "active",
            "notes": "Using 67GB of 100GB, needed for photos backup",
        },
        {
            "id": "sub_5",
            "name": "YouTube Premium",
            "monthly_cost": 149,
            "annual_cost": 1788,
            "category": "Entertainment",
            "billing_cycle": "monthly",
            "next_billing_date": "2026-07-12",
            "last_used": "2026-07-03",
            "usage_frequency": "daily",
            "status": "active",
            "notes": "Used daily, ad-free YouTube",
        },
    ]

    # Flag duplicates: Netflix + Amazon Prime Video overlap
    # Already handled via status field above (Netflix marked underused)

    return subscriptions


# ── Bills ─────────────────────────────────────────────────────
def generate_bills():
    # Bills with due dates relative to "today" (July 4, 2026)
    bills = [
        {
            "id": "bill_1",
            "name": "Electricity Bill",
            "merchant": "TSSPDCL Electricity",
            "amount": 1250,
            "due_date": "2026-07-07",  # 3 days from now - URGENT
            "category": "Bills & Utilities",
            "status": "pending",
            "is_recurring": True,
            "frequency": "monthly",
            "auto_pay": False,
        },
        {
            "id": "bill_2",
            "name": "WiFi Bill",
            "merchant": "ACT Fibernet",
            "amount": 999,
            "due_date": "2026-07-14",  # 10 days from now
            "category": "Bills & Utilities",
            "status": "pending",
            "is_recurring": True,
            "frequency": "monthly",
            "auto_pay": True,
        },
        {
            "id": "bill_3",
            "name": "Mobile Recharge",
            "merchant": "Jio Recharge",
            "amount": 299,
            "due_date": "2026-07-20",  # 16 days
            "category": "Bills & Utilities",
            "status": "pending",
            "is_recurring": True,
            "frequency": "monthly",
            "auto_pay": False,
        },
        {
            "id": "bill_4",
            "name": "PG Rent",
            "merchant": "PG Accommodation",
            "amount": 8000,
            "due_date": "2026-08-01",  # ~28 days
            "category": "Rent",
            "status": "pending",
            "is_recurring": True,
            "frequency": "monthly",
            "auto_pay": False,
        },
        {
            "id": "bill_5",
            "name": "HDFC Millennia Credit Card",
            "merchant": "HDFC Bank",
            "amount": 4520,
            "due_date": "2026-07-15",  # 11 days
            "category": "Credit Card",
            "status": "pending",
            "is_recurring": True,
            "frequency": "monthly",
            "auto_pay": False,
        },
    ]
    return bills


# ── Generate Everything ───────────────────────────────────────
def main():
    print("Generating CFO mock data...")

    # Generate
    user_profile = generate_user_profile()
    transactions, initial_balance = generate_transactions()
    goals = generate_goals()
    subscriptions = generate_subscriptions()
    bills = generate_bills()

    # Add metadata
    meta = {
        "initial_balance": initial_balance,
        "data_generated_at": datetime.now().isoformat(),
        "date_range": {
            "start": START_DATE.strftime("%Y-%m-%d"),
            "end": END_DATE.strftime("%Y-%m-%d"),
        },
        "demo_today": TODAY.strftime("%Y-%m-%d"),
    }

    # Write files
    def write_json(filename, data):
        filepath = OUTPUT_DIR / filename
        with open(filepath, "w") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        print(f"  ✓ {filepath} ({len(data) if isinstance(data, list) else 'object'})")

    write_json("user_profile.json", user_profile)
    write_json("transactions.json", transactions)
    write_json("goals.json", goals)
    write_json("subscriptions.json", subscriptions)
    write_json("bills.json", bills)
    write_json("metadata.json", meta)

    # Print summary
    print(f"\nSummary:")
    print(f"  Transactions: {len(transactions)}")
    print(f"  Initial balance: ₹{initial_balance:,}")
    final_balance = transactions[-1]["balance_after"] if transactions else initial_balance
    print(f"  Final balance: ₹{final_balance:,}")
    total_credits = sum(t["amount"] for t in transactions if t["type"] == "credit")
    total_debits = sum(t["amount"] for t in transactions if t["type"] == "debit")
    print(f"  Total credits: ₹{total_credits:,}")
    print(f"  Total debits: ₹{total_debits:,}")
    print(f"  Computed balance: ₹{initial_balance + total_credits - total_debits:,}")
    print(f"  Goals: {len(goals)}")
    print(f"  Subscriptions: {len(subscriptions)}")
    print(f"  Bills: {len(bills)}")

    # Category breakdown
    categories = {}
    for t in transactions:
        if t["type"] == "debit":
            cat = t["category"]
            categories[cat] = categories.get(cat, 0) + t["amount"]
    print(f"\nSpending by category:")
    for cat, amt in sorted(categories.items(), key=lambda x: -x[1]):
        print(f"  {cat}: ₹{amt:,}")


if __name__ == "__main__":
    main()
