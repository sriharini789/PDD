/**
 * Local Analysis Engine (Replacement for Gemini API dependency)
 * Extracts metadata, sections, and generates citations locally.
 */

exports.analyzeLocal = async (text, numpages) => {
  const lines = text.split('\n').map(l => l.trim()).filter(l => l.length > 0);
  const wordCount = text.split(/\s+/).length;

  // 1. Title Extraction
  let title = "Unknown Title";
  for (let i = 0; i < Math.min(lines.length, 20); i++) {
    const line = lines[i];
    // Heuristic: First long line that doesn't look like meta info
    if (line.length > 25 && !line.match(/vol\.|issue|http|doi|issn|abstract/i)) {
      title = line;
      break;
    }
  }

  // 2. Author Extraction
  let authors = "Unknown Authors";
  if (lines.length > 5) {
    authors = lines.slice(1, 6).find(l => l.length > 10 && l.length < 150 && !l.includes(title)) || lines[1];
  }

  // 3. Section Extraction (More robust regex)
  const sections = {
    abstract: extractSection(text, /(?:abstract|summary|background)\b/i, /(?:introduction|keywords|index|1\.|materials)/i),
    introduction: extractSection(text, /(?:introduction|objective|aims)\b/i, /(?:method|background|literature|2\.|related)/i),
    methodology: extractSection(text, /(?:methodology|materials|methods|experimental|implementation)\b/i, /(?:results|evaluation|3\.|discussion)/i),
    results: extractSection(text, /(?:results|findings|experiments|evaluation)\b/i, /(?:discussion|conclusion|4\.|analysis)/i),
    discussion: extractSection(text, /(?:discussion|interpretation)\b/i, /(?:conclusion|summary|5\.|recommendations)/i),
    conclusion: extractSection(text, /(?:conclusion|concluding|final remarks)\b/i, /(?:references|bibliography|acknowledgments|appendix)/i),
    references: extractSection(text, /(?:references|bibliography|works cited)\b/i, /$/i)
  };

  // Fallback for Abstract if not found
  if (sections.abstract.length < 50) {
    sections.abstract = text.substring(0, 1500).split(/\n\s*\n/)[0]; // Just take first paragraph
  }

  // 4. Citation Generation
  const yearMatch = text.match(/\b(19|20)\d{2}\b/);
  const year = yearMatch ? yearMatch[0] : new Date().getFullYear();

  const citations = {
    apa: `${authors} (${year}). ${title}.`,
    mla: `${authors}. "${title}." ${year}.`,
    ieee: `[1] ${authors}, "${title}," ${year}.`,
    chicago: `${authors}. "${title}." ${year}.`,
    harvard: `${authors} (${year}) '${title}'.`,
    bibtex: `@article{paper_${Date.now()},\n  author = {${authors}},\n  title = {${title}},\n  year = {${year}}\n}`
  };

  // 5. Verification
  const hasAbstract = sections.abstract.length > 100;
  const hasRefs = sections.references.length > 100;
  const isResearch = hasAbstract || hasRefs;

  // 6. Clean and Format matter (ensure paragraphs have spacing)
  Object.keys(sections).forEach(k => {
    sections[k] = sections[k]
      .replace(/([.?!])\s*\n\s*/g, '$1\n\n') // Ensure spacing after sentences ending lines
      .replace(/\s+/g, ' ') // Remove double spaces
      .replace(/\n\s*\n/g, '\n\n') // Normalize double newlines
      .trim();
  });

  return {
    verification: {
      isResearchPaper: isResearch,
      confidenceScore: isResearch ? 92 : 35
    },
    extractedContent: {
      title,
      authors,
      ...sections
    },
    summaries: {
      short: sections.abstract.substring(0, 300) + (sections.abstract.length > 300 ? "..." : ""),
      medium: (sections.abstract + "\n\n" + sections.introduction).substring(0, 800) + "...",
      detailed: sections.abstract + "\n\n" + sections.introduction + "\n\n" + sections.results.substring(0, 500)
    },
    insights: {
      researchProblem: sections.introduction.substring(0, 300) + "...",
      researchObjective: "Primary investigation into " + title,
      methodology: sections.methodology.substring(0, 400) + "...",
      findings: sections.results.substring(0, 400) + "...",
      limitations: sections.discussion.substring(0, 300) + "..."
    },
    topicsExt: {
      main: ["Research Analysis", "Academic Data", "Extracted Sections"],
      sub: ["PDF Analysis"]
    },
    citations,
    references: parseReferences(sections.references),
    metrics: {
      totalPages: numpages,
      totalWords: wordCount,
      readingTime: Math.ceil(wordCount / 200) + ' min',
      totalReferences: sections.references.split('\n').filter(l => l.length > 30).length
    }
  };
};

function extractSection(text, startRegex, endRegex) {
  const startMatch = text.match(startRegex);
  if (!startMatch) return "";
  const startIndex = startMatch.index + startMatch[0].length;
  const rest = text.substring(startIndex);

  // Find the end by looking for the next section title
  const endMatch = rest.match(endRegex);
  const endIndex = endMatch ? endMatch.index : rest.length;

  let content = rest.substring(0, endIndex).trim();

  // Clean up common OCR/PDF artifacts
  content = content.replace(/^[:\-\s\.]+/g, '');

  return content;
}

function parseReferences(refText) {
  if (!refText || refText.length < 20) return [];

  // Split by line or by standard reference numbering
  let refLines = refText.split(/\n|(?=\[\d+\])|(?=\d+\.\s+[A-Z])/);

  return refLines
    .map(line => line.trim())
    .filter(line => line.length > 30) // Heuristic: reference must be long enough
    .map(line => {
      // Basic extraction of year/title from line
      const yearMatch = line.match(/\((19|20)\d{2}\)/) || line.match(/\b(19|20)\d{2}\b/);
      return {
        title: line,
        authors: "Extracted Reference",
        year: yearMatch ? yearMatch[0].replace(/[()]/g, '') : ""
      };
    });
}
