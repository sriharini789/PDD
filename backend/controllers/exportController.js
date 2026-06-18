const prisma = require('../config/prisma');
const PDFDocument = require('pdfkit');
const docx = require('docx');

exports.exportPdf = async (req, res) => {
  try {
    const paper = await prisma.paper.findUnique({ where: { id: parseInt(req.params.id) } });
    if (!paper || paper.userId !== req.user.id) return res.status(404).send('Paper not found');

    const doc = new PDFDocument({ margin: 50 });
    res.setHeader('Content-disposition', `attachment; filename="${paper.title.replace(/[^a-z0-9]/gi, '_')}.pdf"`);
    res.setHeader('Content-type', 'application/pdf');
    doc.pipe(res);

    // Document Title
    doc.fontSize(20).fillColor('#4E148C').text(paper.title, { align: 'center' });
    doc.moveDown(0.5);
    doc.fontSize(12).fillColor('#333333').text(`Authors: ${paper.authors || 'Unknown'}`, { align: 'center' });
    doc.moveDown(1);

    // Verification Header
    const isVerified = paper.verification?.isResearchPaper;
    const score = paper.verification?.confidenceScore || 0;
    doc.fontSize(12).fillColor(isVerified ? '#2E7D32' : '#E65100')
       .text(isVerified ? `Verified Research Paper (Confidence: ${score}%)` : `Not firmly verified as a research paper (Score: ${score}%)`, { align: 'center' });
    doc.moveDown(2);

    // Section helper
    const drawSectionHeader = (title) => {
      doc.fontSize(14).fillColor('#4E148C').text(title.toUpperCase(), { underline: true });
      doc.moveDown(0.5);
    };

    // 1. EXTRACTED METADATA & CONTENT
    drawSectionHeader('Extracted Metadata & Content');
    doc.fontSize(10).fillColor('#222222');
    doc.text(`Abstract: ${paper.extractedContent?.abstract || 'N/A'}`);
    doc.moveDown(0.5);
    doc.text(`Keywords: ${paper.extractedContent?.keywords || 'N/A'}`);
    doc.moveDown(1);

    const contentSections = ['introduction', 'methodology', 'results', 'conclusion'];
    contentSections.forEach(sec => {
      const val = paper.extractedContent?.[sec];
      if (val) {
        doc.fontSize(11).fillColor('#4E148C').text(sec.charAt(0).toUpperCase() + sec.slice(1));
        doc.fontSize(10).fillColor('#222222').text(val.toString());
        doc.moveDown(0.8);
      }
    });
    doc.moveDown(1);

    // 2. SUMMARIES
    drawSectionHeader('Summaries');
    doc.fontSize(11).fillColor('#4E148C').text('Short Summary (Key Highlights):');
    doc.fontSize(10).fillColor('#222222').text(paper.summaries?.short || 'N/A');
    doc.moveDown(0.8);

    doc.fontSize(11).fillColor('#4E148C').text('Medium Summary (Overview):');
    doc.fontSize(10).fillColor('#222222').text(paper.summaries?.medium || 'N/A');
    doc.moveDown(0.8);

    doc.fontSize(11).fillColor('#4E148C').text('Detailed Summary:');
    doc.fontSize(10).fillColor('#222222').text(paper.summaries?.detailed || paper.summary || 'N/A');
    doc.moveDown(2);

    // 3. KEY INSIGHTS
    if (paper.insights) {
      drawSectionHeader('Key Research Insights');
      const keys = [
        'researchProblem', 'objective', 'datasetUsed', 'algorithmsUsed',
        'experimentalResults', 'performanceMetrics', 'findings', 'limitations', 'futureScope'
      ];
      keys.forEach(k => {
        const val = paper.insights[k];
        if (val) {
          const displayKey = k.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase());
          doc.fontSize(11).fillColor('#4E148C').text(displayKey);
          doc.fontSize(10).fillColor('#222222').text(val.toString());
          doc.moveDown(0.6);
        }
      });
      doc.moveDown(1.5);
    }

    // 4. CITATIONS
    if (paper.citations) {
      drawSectionHeader('Citations');
      Object.entries(paper.citations).forEach(([key, val]) => {
        doc.fontSize(11).fillColor('#4E148C').text(key.toUpperCase());
        doc.fontSize(10).fillColor('#222222').text(val.toString());
        doc.moveDown(0.6);
      });
      doc.moveDown(1.5);
    }

    // 5. REFERENCES
    if (paper.references && paper.references.length > 0) {
      doc.addPage();
      drawSectionHeader('References');
      paper.references.forEach((ref, i) => {
        let refText = `${i + 1}. ${ref.authors || 'Unknown'} (${ref.year || ''}). ${ref.title || 'Unknown Title'}.`;
        if (ref.journal) refText += ` ${ref.journal}.`;
        if (ref.doi && ref.doi !== 'N/A') refText += ` DOI: ${ref.doi}`;
        if (ref.url) refText += ` URL: ${ref.url}`;
        doc.fontSize(9).fillColor('#222222').text(refText);
        doc.moveDown(0.4);
      });
    }

    doc.end();
  } catch (error) {
    console.error(error);
    res.status(500).send('Error generating PDF');
  }
};

exports.exportDocx = async (req, res) => {
  try {
    const paper = await prisma.paper.findUnique({ where: { id: parseInt(req.params.id) } });
    if (!paper || paper.userId !== req.user.id) return res.status(404).send('Paper not found');

    const isVerified = paper.verification?.isResearchPaper;
    const score = paper.verification?.confidenceScore || 0;

    const children = [
      new docx.Paragraph({ text: paper.title, heading: docx.HeadingLevel.HEADING_1, alignment: docx.AlignmentType.CENTER }),
      new docx.Paragraph({ text: `Authors: ${paper.authors || 'Unknown'}`, alignment: docx.AlignmentType.CENTER }),
      new docx.Paragraph({ text: isVerified ? `Verified Research Paper (Confidence: ${score}%)` : `Not firmly verified as a research paper (Score: ${score}%)`, alignment: docx.AlignmentType.CENTER }),
      new docx.Paragraph({ text: "" }),

      new docx.Paragraph({ text: "EXTRACTED METADATA & CONTENT", heading: docx.HeadingLevel.HEADING_2 }),
      new docx.Paragraph({ text: `Abstract: ${paper.extractedContent?.abstract || 'N/A'}` }),
      new docx.Paragraph({ text: `Keywords: ${paper.extractedContent?.keywords || 'N/A'}` }),
    ];

    const contentSections = ['introduction', 'methodology', 'results', 'conclusion'];
    contentSections.forEach(sec => {
      const val = paper.extractedContent?.[sec];
      if (val) {
        children.push(new docx.Paragraph({ text: sec.toUpperCase(), heading: docx.HeadingLevel.HEADING_3 }));
        children.push(new docx.Paragraph({ text: val.toString() }));
      }
    });

    children.push(new docx.Paragraph({ text: "" }));
    children.push(new docx.Paragraph({ text: "SUMMARIES", heading: docx.HeadingLevel.HEADING_2 }));
    children.push(new docx.Paragraph({ text: "Short Summary:", heading: docx.HeadingLevel.HEADING_3 }));
    children.push(new docx.Paragraph({ text: paper.summaries?.short || 'N/A' }));
    children.push(new docx.Paragraph({ text: "Medium Summary:", heading: docx.HeadingLevel.HEADING_3 }));
    children.push(new docx.Paragraph({ text: paper.summaries?.medium || 'N/A' }));
    children.push(new docx.Paragraph({ text: "Detailed Summary:", heading: docx.HeadingLevel.HEADING_3 }));
    children.push(new docx.Paragraph({ text: paper.summaries?.detailed || paper.summary || 'N/A' }));

    if (paper.insights) {
      children.push(new docx.Paragraph({ text: "" }));
      children.push(new docx.Paragraph({ text: "KEY INSIGHTS", heading: docx.HeadingLevel.HEADING_2 }));
      const keys = [
        'researchProblem', 'objective', 'datasetUsed', 'algorithmsUsed',
        'experimentalResults', 'performanceMetrics', 'findings', 'limitations', 'futureScope'
      ];
      keys.forEach(k => {
        const val = paper.insights[k];
        if (val) {
          const displayKey = k.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase());
          children.push(new docx.Paragraph({ text: displayKey, heading: docx.HeadingLevel.HEADING_3 }));
          children.push(new docx.Paragraph({ text: val.toString() }));
        }
      });
    }

    if (paper.citations) {
      children.push(new docx.Paragraph({ text: "" }));
      children.push(new docx.Paragraph({ text: "CITATIONS", heading: docx.HeadingLevel.HEADING_2 }));
      Object.entries(paper.citations).forEach(([key, val]) => {
        children.push(new docx.Paragraph({ text: `${key.toUpperCase()}: ${val}` }));
      });
    }

    if (paper.references && paper.references.length > 0) {
      children.push(new docx.Paragraph({ text: "" }));
      children.push(new docx.Paragraph({ text: "REFERENCES", heading: docx.HeadingLevel.HEADING_2 }));
      paper.references.forEach((ref, i) => {
        let refText = `${i + 1}. ${ref.authors || 'Unknown'} (${ref.year || ''}). ${ref.title || 'Unknown Title'}.`;
        if (ref.journal) refText += ` ${ref.journal}.`;
        if (ref.doi && ref.doi !== 'N/A') refText += ` DOI: ${ref.doi}`;
        if (ref.url) refText += ` URL: ${ref.url}`;
        children.push(new docx.Paragraph({ text: refText }));
      });
    }

    const doc = new docx.Document({ sections: [{ children }] });
    const buffer = await docx.Packer.toBuffer(doc);
    res.setHeader('Content-disposition', `attachment; filename="${paper.title.replace(/[^a-z0-9]/gi, '_')}.docx"`);
    res.setHeader('Content-type', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    res.send(buffer);
  } catch (error) {
    console.error(error);
    res.status(500).send('Error generating DOCX');
  }
};

exports.exportTxt = async (req, res) => {
  try {
    const paper = await prisma.paper.findUnique({ where: { id: parseInt(req.params.id) } });
    if (!paper || paper.userId !== req.user.id) return res.status(404).send('Paper not found');

    const isVerified = paper.verification?.isResearchPaper;
    const score = paper.verification?.confidenceScore || 0;

    let text = `PAPER ANALYSIS: ${paper.title}\n`;
    text += `AUTHORS: ${paper.authors}\n`;
    text += `VERIFICATION: ${isVerified ? 'Verified Research Paper' : 'Not firmly verified'} (Score: ${score}%)\n\n`;

    text += `=========================================\n`;
    text += `EXTRACTED METADATA & CONTENT\n`;
    text += `=========================================\n`;
    text += `Abstract:\n${paper.extractedContent?.abstract || 'N/A'}\n\n`;
    text += `Keywords: ${paper.extractedContent?.keywords || 'N/A'}\n\n`;

    const contentSections = ['introduction', 'methodology', 'results', 'conclusion'];
    contentSections.forEach(sec => {
      const val = paper.extractedContent?.[sec];
      if (val) {
        text += `${sec.toUpperCase()}:\n${val}\n\n`;
      }
    });

    text += `=========================================\n`;
    text += `SUMMARIES\n`;
    text += `=========================================\n`;
    text += `Short Summary:\n${paper.summaries?.short || 'N/A'}\n\n`;
    text += `Medium Summary:\n${paper.summaries?.medium || 'N/A'}\n\n`;
    text += `Detailed Summary:\n${paper.summaries?.detailed || paper.summary || 'N/A'}\n\n`;

    if (paper.insights) {
      text += `=========================================\n`;
      text += `KEY INSIGHTS\n`;
      text += `=========================================\n`;
      const keys = [
        'researchProblem', 'objective', 'datasetUsed', 'algorithmsUsed',
        'experimentalResults', 'performanceMetrics', 'findings', 'limitations', 'futureScope'
      ];
      keys.forEach(k => {
        const val = paper.insights[k];
        if (val) {
          const displayKey = k.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase());
          text += `${displayKey}:\n${val}\n\n`;
        }
      });
    }

    if (paper.citations) {
      text += `=========================================\n`;
      text += `CITATIONS\n`;
      text += `=========================================\n`;
      Object.entries(paper.citations).forEach(([k, v]) => {
        text += `${k.toUpperCase()}: ${v}\n`;
      });
      text += `\n`;
    }

    if (paper.references && paper.references.length > 0) {
      text += `=========================================\n`;
      text += `REFERENCES\n`;
      text += `=========================================\n`;
      paper.references.forEach((ref, i) => {
        let refText = `${i + 1}. ${ref.authors || 'Unknown'} (${ref.year || ''}). ${ref.title || 'Unknown Title'}.`;
        if (ref.journal) refText += ` ${ref.journal}.`;
        if (ref.doi && ref.doi !== 'N/A') refText += ` DOI: ${ref.doi}`;
        if (ref.url) refText += ` URL: ${ref.url}`;
        text += `${refText}\n`;
      });
    }

    res.setHeader('Content-disposition', `attachment; filename="${paper.title.replace(/[^a-z0-9]/gi, '_')}.txt"`);
    res.setHeader('Content-type', 'text/plain');
    res.send(text);
  } catch (error) {
    res.status(500).send('Error generating TXT');
  }
};

exports.exportMarkdown = async (req, res) => {
  try {
    const paper = await prisma.paper.findUnique({ where: { id: parseInt(req.params.id) } });
    if (!paper || paper.userId !== req.user.id) return res.status(404).send('Paper not found');

    const isVerified = paper.verification?.isResearchPaper;
    const score = paper.verification?.confidenceScore || 0;

    let md = `# ${paper.title}\n`;
    md += `**Authors:** ${paper.authors}\n`;
    md += `**Verification:** ${isVerified ? 'Verified Research Paper' : 'Not firmly verified'} (Confidence: ${score}%)\n\n`;

    md += `## Extracted Metadata & Content\n`;
    md += `### Abstract\n${paper.extractedContent?.abstract || 'N/A'}\n\n`;
    md += `**Keywords:** ${paper.extractedContent?.keywords || 'N/A'}\n\n`;

    const contentSections = ['introduction', 'methodology', 'results', 'conclusion'];
    contentSections.forEach(sec => {
      const val = paper.extractedContent?.[sec];
      if (val) {
        md += `### ${sec.charAt(0).toUpperCase() + sec.slice(1)}\n${val}\n\n`;
      }
    });

    md += `## Summaries\n`;
    md += `### Short Summary (Key Highlights)\n${paper.summaries?.short || 'N/A'}\n\n`;
    md += `### Medium Summary\n${paper.summaries?.medium || 'N/A'}\n\n`;
    md += `### Detailed Summary\n${paper.summaries?.detailed || paper.summary || 'N/A'}\n\n`;

    if (paper.insights) {
      md += `## Key Insights\n`;
      const keys = [
        'researchProblem', 'objective', 'datasetUsed', 'algorithmsUsed',
        'experimentalResults', 'performanceMetrics', 'findings', 'limitations', 'futureScope'
      ];
      keys.forEach(k => {
        const val = paper.insights[k];
        if (val) {
          const displayKey = k.replace(/([A-Z])/g, ' $1').replace(/^./, str => str.toUpperCase());
          md += `### ${displayKey}\n${val}\n\n`;
        }
      });
    }

    if (paper.citations) {
      md += `## Citations\n`;
      Object.entries(paper.citations).forEach(([k, v]) => {
        md += `* **${k.toUpperCase()}:** ${v}\n`;
      });
      md += `\n`;
    }

    if (paper.references && paper.references.length > 0) {
      md += `## References\n`;
      paper.references.forEach((ref, i) => {
        let refText = `${i + 1}. ${ref.authors || 'Unknown'} (${ref.year || ''}). *${ref.title || 'Unknown Title'}*.`;
        if (ref.journal) refText += ` ${ref.journal}.`;
        if (ref.doi && ref.doi !== 'N/A') refText += ` DOI: ${ref.doi}`;
        if (ref.url) refText += ` [Link](${ref.url})`;
        md += `${refText}\n\n`;
      });
    }

    res.setHeader('Content-disposition', `attachment; filename="${paper.title.replace(/[^a-z0-9]/gi, '_')}.md"`);
    res.setHeader('Content-type', 'text/markdown');
    res.send(md);
  } catch (error) {
    res.status(500).send('Error generating Markdown');
  }
};
