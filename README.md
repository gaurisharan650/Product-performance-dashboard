# 📊 Product Performance & User Journey Analysis Dashboard

> Analyzed 5,000+ records to evaluate user behavior, funnel drop-offs, and product engagement using SQL, Power BI, and interactive HTML dashboards.

![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=flat)
![Last Updated](https://img.shields.io/badge/Last%20Updated-March%202026-blue?style=flat)
![SQL](https://img.shields.io/badge/SQL-MySQL-blue?style=flat&logo=mysql)
![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-yellow?style=flat&logo=powerbi)
![Excel](https://img.shields.io/badge/Excel-Data%20Source-green?style=flat&logo=microsoftexcel)
![HTML](https://img.shields.io/badge/HTML-Chart.js-orange?style=flat&logo=html5)

---

##  Project Overview

| Detail | Info |
|--------|------|
| **Dataset** | `user_funnel_data_2.xlsx` |
| **Records** | 674 events · 200 unique users |
| **Period** | January 2024 |
| **Products** | 10 (P1 – P10) |
| **Funnel Stages** | 5 (Visit → Signup → Add to Cart → Checkout → Purchase) |

---

## 📈 Key Findings

### 🔻 Funnel Drop-off

| Stage | Users | Drop-off |
|-------|-------|----------|
| Visit | 200 | — |
| Signup | 163 | ↓ 18.5% |
| Add to Cart | 134 | ↓ 17.8% |
| Checkout | 100 | ↓ **25.4% ⚠️ Highest** |
| Purchase | 77 | ↓ 23.0% |

> **Key Insight:** Biggest drop-off at **Add to Cart → Checkout (25.4%)** — primary area for optimization.

**Overall conversion: 38.5%** (Visit → Purchase)

###  Top Products by Interactions

| Rank | Product | Interactions |
|------|---------|-------------|
| 1 | P1 | 83 |
| 2 | P2 | 72 |
| 3 | P4 | 69 |
| 4 | P7 | 69 |
| 5 | P6 | 68 |

---

## 📁 Repository Structure

```
Product-performance-dashboard/
│
├── 📄 README.md
├── 📊 user_funnel_data_2.xlsx          ← Raw dataset
├── 🗃️ analysis_queries.sql             ← SQL scripts (7 sections)
├── 📋 PowerBI_DAX_Guide.docx           ← DAX formulas & report layout
├── 🌐 product_performance_dashboard.html ← Interactive HTML dashboard
├── 🖼️ prodcut.performance1.jpeg        ← Power BI screenshot 1
└── 🖼️ product.performance2.jpeg        ← Power BI screenshot 2
```

---

## 🚀 Quick Start

**SQL**
1. Open MySQL Workbench and run `analysis_queries.sql`
2. Import `user_funnel_data_2.xlsx` into the `user_funnel` table

**Power BI**
1. Load `user_funnel_data_2.xlsx` into Power BI Desktop
2. Follow the DAX guide in `PowerBI_DAX_Guide.docx`

**HTML Dashboard**
1. Download `product_performance_dashboard.html`
2. Open in any browser ✅ — no installation needed

---

## 👩‍💻 Author

Gauri Sharan** 
