import React, { useState } from "react";

export default function App() {
  const [question, setQuestion] = useState("");
  const [answer, setAnswer] = useState("");
  const [advice, setAdvice] = useState("");
  const [loading, setLoading] = useState(false);

  async function onSubmit(e) {
    e.preventDefault();
    setAdvice("");
    setLoading(true);
    try {
      const res = await fetch("/api/advice", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({ question, answer })
      });
      const data = await res.json();
      setAdvice(data.advice || data.error || "No response");
    } catch (e) {
      setAdvice(String(e));
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="font-ui min-h-screen">
      <header className="border-b">
        <div className="mx-auto max-w-5xl px-6 py-6 flex items-center justify-between">
          <div className="text-2xl font-semibold">InterviewCoach</div>
          <div className="text-sm text-neutral-500">by Christine • simple, clean</div>
        </div>
      </header>

      <main className="mx-auto max-w-5xl px-6 py-10">
        <section className="text-center mb-10">
          <h1 className="text-4xl md:text-5xl font-semibold tracking-tight">Answer better. Get hired.</h1>
          <p className="mt-4 text-neutral-600 text-lg">Paste a question and your draft. Get precise improvements and a sharpened version.</p>
        </section>

        <form onSubmit={onSubmit} className="grid md:grid-cols-2 gap-6">
          <div className="p-5 rounded-2xl border shadow-sm">
            <label className="block text-sm mb-2 text-neutral-700">Interview question</label>
            <textarea value={question} onChange={e=>setQuestion(e.target.value)}
              placeholder="Tell me about a time you led without authority..."
              className="w-full h-28 p-3 bg-neutral-50 rounded-lg outline-none" />
            <label className="block text-sm mt-4 mb-2 text-neutral-700">Your draft answer</label>
            <textarea value={answer} onChange={e=>setAnswer(e.target.value)}
              placeholder="Your draft answer here..."
              className="w-full h-48 p-3 bg-neutral-50 rounded-lg outline-none" />
            <button disabled={loading} className="mt-4 w-full rounded-xl py-3 text-white bg-black">
              {loading ? "Thinking…" : "Get advice"}
            </button>
          </div>

          <div className="p-5 rounded-2xl border shadow-sm">
            <div className="text-sm mb-2 text-neutral-700">Coach output</div>
            <div className="prose max-w-none whitespace-pre-wrap text-sm leading-6">
              {advice || "Your tailored advice will appear here."}
            </div>
          </div>
        </form>
      </main>

      <footer className="border-t">
        <div className="mx-auto max-w-5xl px-6 py-6 text-sm text-neutral-500">
          Built for learning: React • FastAPI • OpenAI • Docker • Helm • EKS • Harness
        </div>
      </footer>
    </div>
  );
}
