import { NextResponse } from "next/server"
import { getTelosContext } from "@/lib/telos-data"

const OLLAMA_BASE = process.env.OLLAMA_BASE_URL || "http://localhost:11434"
const OLLAMA_MODEL = process.env.OLLAMA_MODEL || "deepseek-r1:1.5b"

export async function POST(request: Request) {
  try {
    const { message } = await request.json()

    if (!message) {
      return NextResponse.json(
        { error: "Message is required" },
        { status: 400 }
      )
    }

    // Load all TELOS context
    const telosContext = getTelosContext()

    const systemPrompt = `You are a helpful AI assistant with access to the user's complete Personal TELOS (Life Operating System).

${telosContext}

When answering questions:
- Reference specific information from the TELOS files above
- Be conversational and helpful
- If asked about goals, projects, beliefs, wisdom, etc., use the exact information from the relevant sections
- If information isn't in the TELOS data, say so clearly
- Keep responses concise but informative`

    // Call local Ollama API directly
    const ollamaResponse = await fetch(`${OLLAMA_BASE}/api/chat`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: OLLAMA_MODEL,
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: message },
        ],
        stream: false,
      }),
    })

    if (!ollamaResponse.ok) {
      const errorText = await ollamaResponse.text()
      throw new Error(`Ollama API error ${ollamaResponse.status}: ${errorText}`)
    }

    const data = await ollamaResponse.json()
    const assistantMessage = data.message?.content || ""

    if (!assistantMessage) {
      throw new Error("No response from Ollama")
    }

    return NextResponse.json({ response: assistantMessage })
  } catch (error) {
    console.error("Error in chat API:", error)
    return NextResponse.json(
      { error: "Failed to process request" },
      { status: 500 }
    )
  }
}
