const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

console.log(
  "Gemini Key Loaded:",
  process.env.GEMINI_API_KEY ? "YES" : "NO"
);
exports.processAndStoreDocument = async (paperId, text) => {
  // Mock vector DB process for now
  return {
    success: true,
    chunks: 1,
  };
};

exports.analyzePaper = async (text) => {
  if (!process.env.GEMINI_API_KEY) {
    throw new Error("Gemini API key is not configured");
  }
  try {
    const model = genAI.getGenerativeModel({
      model: "gemini-2.0-flash",
    });

    // Strategy: Pass the beginning of the paper for metadata and the end for references
    const textLength = text.length;
    let paperContext = "";

    if (textLength <= 30000) {
      paperContext = text;
    } else {
      // Beginning (20k chars) + End (10k chars)
      paperContext = text.substring(0, 20000) + "\n...[CONTENT TRUNCATED]...\n" + text.substring(textLength - 10000);
    }

    const prompt = `
You are an expert academic research assistant. 
Analyze the provided research paper content and extract comprehensive structured information.
CRITICAL REQUIREMENT: NEVER generate generic summaries, generic citations, generic topics, placeholder content, dummy text, or hardcoded responses.
Everything generated MUST be based ONLY on the provided text. Never hallucinate.

Return your response strictly as a JSON object matching this structure:
{
  "verification": {
    "isResearchPaper": boolean, // True if the text resembles a real research paper/article
    "confidenceScore": number // 0-100 score of how confident you are
  },
  "extractedContent": {
    "title": "string",
    "authors": "string",
    "abstract": "string",
    "keywords": "string", // Comma-separated keywords
    "introduction": "string (strictly 3-5 concise bullet points, each starting with '- ')",
    "literatureReview": "string",
    "methodology": "string (strictly 3-5 concise bullet points, each starting with '- ')",
    "dataset": "string",
    "results": "string (strictly 3-5 concise bullet points, each starting with '- ')",
    "discussion": "string",
    "conclusion": "string (strictly 3-5 concise bullet points, each starting with '- ')"
  },
  "summaries": {
    "short": "string (strictly exactly 5 bullet points, each starting with '- ')",
    "medium": "string (strictly exactly 10 bullet points, each starting with '- ')",
    "detailed": "string (a detailed summary in concise prose of MAXIMUM 250 words)"
  },
  "insights": {
    "researchProblem": "string (concise bullet points starting with '- ')",
    "objective": "string (concise bullet points starting with '- ')",
    "datasetUsed": "string (concise bullet points starting with '- ')",
    "algorithmsUsed": "string (concise bullet points starting with '- ')",
    "experimentalResults": "string (concise bullet points starting with '- ')",
    "performanceMetrics": "string (concise bullet points starting with '- ')",
    "findings": "string (concise bullet points starting with '- ')",
    "limitations": "string (concise bullet points starting with '- ')",
    "futureScope": "string (concise bullet points starting with '- ')"
  },
  "topicsExt": {
    "main": ["string", "string"],
    "sub": ["string", "string"],
    "keywords": ["string", "string"],
    "researchArea": "string",
    "technicalConcepts": ["string", "string"]
  },
  "citations": {
    "apa": "string",
    "mla": "string",
    "ieee": "string",
    "chicago": "string",
    "harvard": "string",
    "bibtex": "string"
  },
  "references": [
    {
      "authors": "string",
      "title": "string",
      "journal": "string", // or conference name
      "year": "string",
      "doi": "string",
      "url": "string"
    }
  ]
}

Paper Content:
---
${paperContext}
---
`;

    const result = await model.generateContent({
      contents: [{ role: "user", parts: [{ text: prompt }] }],
      generationConfig: {
        responseMimeType: "application/json",
        temperature: 0.2, // Low temp for extraction
      }
    });

    const responseText = result.response.text();
    const parsedData = JSON.parse(responseText);

    return parsedData;

  } catch (error) {
    console.error("AI Analysis Error:", error);
    throw error;
  }
};

exports.chatWithPaper = async (paperId, content, query) => {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });
    const prompt = `
You are an AI assistant answering questions based solely on the provided research paper content.
Do NOT use outside knowledge. If the answer is not in the text, say "I cannot answer this based on the uploaded paper."

Paper Content:
${content.substring(0, 100000)}

User Question: ${query}
`;

    const result = await model.generateContent(prompt);
    return result.response.text();
  } catch (err) {
    console.error("Chat Error:", err);
    return "Failed to generate answer from AI.";
  }
};

exports.generateLiteratureReview = async (content) => {
  try {
    const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });
    const prompt = `
Generate a literature review based on this paper. Give 3 variants: 500 words, 1000 words, and 2000 words.
Structure the response as JSON:
{
  "review500": "...",
  "review1000": "...",
  "review2000": "..."
}

Paper Content:
${content.substring(0, 100000)}
`;

    const result = await model.generateContent({
      contents: [{ role: "user", parts: [{ text: prompt }] }],
      generationConfig: { responseMimeType: "application/json" }
    });
    return JSON.parse(result.response.text());
  } catch (err) {
    return null;
  }
};