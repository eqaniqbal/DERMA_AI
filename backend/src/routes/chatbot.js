const express = require('express');
const router = express.Router();
const ChatSession = require('../models/ChatSession');

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const GEMINI_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`;

const SYSTEM_PROMPT = `You are DermaBot, an expert AI dermatology first-aid assistant for the Derma AI app. 

Your role:
- Provide step-by-step first-aid guidance for skin problems like rashes, wounds, insect bites, acne, and allergies
- Ask follow-up questions to better understand the user's symptoms
- Give personalized skincare advice based on the user's skin type and lifestyle
- Suggest when the user should see a real dermatologist
- Answer real-time skin care queries clearly and simply
- Update your recommendations based on user feedback and recovery progress

Rules:
- Always be friendly, clear, and easy to understand
- Never diagnose serious medical conditions — always recommend a doctor for serious cases
- Ask one follow-up question at a time to collect more symptoms
- Keep responses concise and actionable
- Always end with a follow-up question or suggestion chip options

After every response, provide 2-3 quick reply suggestions in this exact format:
SUGGESTIONS: ["option 1", "option 2", "option 3"]`;

// POST /api/chatbot/message
router.post('/message', async (req, res) => {
  try {
    const { message, sessionId, userId = 'guest' } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    // Find or create chat session
    let session;
    if (sessionId) {
      session = await ChatSession.findById(sessionId);
    }
    if (!session) {
      session = new ChatSession({ userId, messages: [] });
    }

    // Add user message to session
    session.messages.push({ role: 'user', content: message });

    // Build conversation history for Gemini
    const conversationHistory = session.messages.map((msg) => ({
      role: msg.role === 'assistant' ? 'model' : 'user',
      parts: [{ text: msg.content }],
    }));

    // Call Gemini API
    const geminiResponse = await fetch(GEMINI_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        system_instruction: {
          parts: [{ text: SYSTEM_PROMPT }],
        },
        contents: conversationHistory,
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 500,
        },
      }),
    });

    const geminiData = await geminiResponse.json();

    if (!geminiData.candidates || geminiData.candidates.length === 0) {
      return res.status(500).json({ error: 'No response from Gemini' });
    }

    const fullResponse =
      geminiData.candidates[0].content.parts[0].text;

    // Extract suggestions from response
    let aiMessage = fullResponse;
    let suggestions = [];

    const suggestionMatch = fullResponse.match(/SUGGESTIONS:\s*(\[.*?\])/s);
    if (suggestionMatch) {
      try {
        suggestions = JSON.parse(suggestionMatch[1]);
        aiMessage = fullResponse.replace(/SUGGESTIONS:\s*(\[.*?\])/s, '').trim();
      } catch (e) {
        suggestions = [];
      }
    }

    // Save assistant response to session
    session.messages.push({ role: 'assistant', content: aiMessage });
    await session.save();

    res.json({
      sessionId: session._id,
      message: aiMessage,
      suggestions,
    });
  } catch (error) {
    console.error('Chatbot error:', error);
    res.status(500).json({ error: 'Something went wrong' });
  }
});

// GET /api/chatbot/history/:sessionId
router.get('/history/:sessionId', async (req, res) => {
  try {
    const session = await ChatSession.findById(req.params.sessionId);
    if (!session) return res.status(404).json({ error: 'Session not found' });
    res.json({ messages: session.messages });
  } catch (error) {
    res.status(500).json({ error: 'Something went wrong' });
  }
});

module.exports = router;
