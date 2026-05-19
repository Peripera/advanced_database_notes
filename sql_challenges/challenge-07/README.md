#  🔍 Lesson 02 — Oracle 23ai Vector Search
## Student Activity: Search a Wikipedia Article

In this activity you will:
1. **Choose** a Wikipedia article as your dataset
2. **Generate** vector embeddings for each paragraph (the "pre-load phase")
3. **Load** the vectors into Oracle 23ai on freesql.com
4. **Search** the article using natural language — no keyword matching needed.

> This is exactly how Netflix, Spotify, and AI assistants find relevant content at scale.

## 🎯 Activity — Your Turn


Try these three searches. For each one, run Step 7 with a new question, paste the SQL in freesql.com, and write down what you found.

---

**Search 1:** Ask something that IS in the article
> Question: `"How much force would requiere cow tipping?"`

What came back? Does it make sense?


---

**Search 2:** Ask something that is RELATED but not a direct quote
> Example: `"What is the main reason of the idea that cows sleep standing up is considered a myth?"`

Did it find relevant content even though those exact words aren't in the article?

---

**Search 3:** Ask something UNRELATED
> Example: `"What is the philosophy?"`

What score did you get? Is it high or low? Why?

---

> 💡 **Key insight:** Vector search finds *meaning*, not keywords.
> A score near **0.0** = very similar. A score near **1.0** = very different.