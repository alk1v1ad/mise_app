# 🍳 Mise

### Smart Food & AI Recipe Assistant

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Node.js](https://img.shields.io/badge/Backend-Node.js-green?logo=node.js)
![AI](https://img.shields.io/badge/AI-Recipe%20Generation-orange)
![Status](https://img.shields.io/badge/Status-MVP-success)

---

## ✨ Overview

**Mise** is a mobile app that helps you manage food and instantly generate recipes using AI.

Instead of wondering *“what should I cook?”*, the app builds recipes based on what you already have.

---

## 🚀 Core Features

### 📦 Product Management

* Add products with expiration dates
* Smart color indicators:

    * 🔴 expired
    * 🟠 expiring soon
    * 🟢 fresh
* Edit & delete items

---

### 🤖 AI-Powered Recipes

* Generate recipes from available ingredients
* Structured output:

    * **Title**
    * **Ingredients**
    * **Steps**
* Backend-based AI (secure API usage)
* Fallback system (no crashes if API fails)

---

### 📚 Saved Recipes

* Save recipes locally
* View history
* Delete saved items

---

## 🧠 How It Works

```text
Flutter App → Backend (Node.js) → AI API → Backend → Flutter UI
```

* Flutter sends product list
* Backend handles AI request
* Response is structured and returned
* UI renders clean recipe blocks

---

## 🛠️ Tech Stack

| Layer    | Technology        |
| -------- | ----------------- |
| Frontend | Flutter           |
| Storage  | Hive              |
| Backend  | Node.js + Express |
| API      | AI (LLM)          |

---

## 🔥 Highlights

* Clean UI with structured recipe rendering
* AI integration via backend (secure & scalable)
* Stable UX with fallback recipes
* No login required (fully local storage)

---

## 🧩 Architecture Decisions

* **Backend required** → avoids exposing API keys
* **Structured AI output** → reliable UI parsing
* **Hive storage** → fast, offline-first

---



