const prisma = require('../config/prisma');
const PDFDocument = require('pdfkit');
const docx = require('docx');

exports.exportPdf = async (req, res) => {
  try {
    const paper = await prisma.paper.findUnique({ where: { id: parseInt(req.params.id) } });
    if (!paper || paper.userId !== req.user.id) return res.status(404).send('Paper not found');

    const doc = new PDFDocument();
    res.setHeader('Content-disposition', `attachment; filename="${paper.title.replace(/[^a-z0-9]/gi, '_')}.pdf"`);
    res.setHeader('Content-type', 'application/pdf');
    doc.pipe(res);

    // Title & Authors
    doc.fontSize(22).text(paper.title, { align: 'center' });
    doc.moveDown();
    doc.fontSize(14).text(`Authors: ${paper.authors || 'Unknown'}`, { align: 'center' });
    doc.moveDown();

    // Verification
    const isVerified = paper.verification?.isResearchPaper;
    const score = paper.verification?.confidenceScore || 0;
    doc.fontSize(12).fillColor(isVerified ? 'green' : 'orange')
       .text(isVerified ? `Verified Research Paper (Confidence: ${score}%)` : `Not firmly verified as a research paper (Score: ${score}%)`, { align: 'center' });
    doc.fillColor('black').moveDown(2);

    // Abstract & Summaries
    doc.fontSize(16).text('Abstract', { underline: true });
    doc.fontSize(11).text(paper.extractedContent?.abstract || 'N/A');
    doc.moveDown();

    doc.fontSize(16).text('AI Detailed Summary', { underline: true });
    doc.fontSize(11).text(paper.summaries?.detailed || paper.summary || 'N/A');
    doc.moveDown();

    // Key Insights
    if (paper.insights) {
      doc.fontSize(16).text('Key Research Insights', { underline: true });
      Object.entries(paper.insights).forEach(([key, val]) => {
        if (val) {
          doc.fontSize(12).text(key.charAt(0).toUpperCase() + key.slice(1), { bold: true });
          doc.fontSize(11).text(val.toString());
          doc.moveDown(0.5);
        }
      });
      doc.moveDown();
    }

    // Methodology & Results
    doc.fontSize(16).text('Methodology & Results', { underline: true });
    doc.fontSize(11).text(`Methodology: ${paper.extractedContent?.methodology || 'N/A'}`);
    doc.moveDown(0.5);
    doc.fontSize(11).text(`Results: ${paper.extractedContent?.results || 'N/A'}`);
    doc.moveDown();

    // Citations
    if (paper.citations) {
      doc.fontSize(16).text('Citations', { underline: true });
      Object.entries(paper.citations).forEach(([key, val]) => {
        doc.fontSize(11).text(`${key.toUpperCase()}: ${val}`);
        doc.moveDown(0.5);
      });
      doc.moveDown();
    }

    // References
    if (paper.references && paper.references.length > 0) {
      doc.addPage();
      doc.fontSize(16).text('References', { underline: true });
      paper.references.forEach((ref, i) => {
        doc.fontSize(10).text(`${i + 1}. ${ref.authors || 'Unknown'} (${ref.year || ''}). ${ref.title || 'Unknown Title'}. ${ref.journal || ''}`);
        doc.moveDown(0.3);
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

    const children = [
      new docx.Paragraph({ text: paper.title, heading: docx.HeadingLevel.HEADING_1, alignment: docx.AlignmentType.CENTER }),
      new docx.Paragraph({ text: `Authors: ${paper.authors || 'Unknown'}`, alignment: docx.AlignmentType.CENTER }),
      new docx.Paragraph({ text: "" }),
      new docx.Paragraph({ text: "Abstract", heading: docx.HeadingLevel.HEADING_2 }),
      new docx.Paragraph({ text: paper.extractedContent?.abstract || 'N/A' }),
      new docx.Paragraph({ text: "Detailed Summary", heading: docx.HeadingLevel.HEADING_2 }),
      new docx.Paragraph({ text: paper.summaries?.detailed || paper.summary || 'N/A' }),
    ];

    if (paper.insights) {
      children.push(new docx.Paragraph({ text: "Key Insights", heading: docx.HeadingLevel.HEADING_2 }));
      Object.entries(paper.insights).forEach(([key, val]) => {
        if (val) {
          children.push(new docx.Paragraph({ text: key.toUpperCase(), bold: true }));
          children.push(new docx.Paragraph({ text: val.toString() }));
        }
      });
    }

    if (paper.citations) {
      children.push(new docx.Paragraph({ text: "Citations", heading: docx.HeadingLevel.HEADING_2 }));
      Object.entries(paper.citations).forEach(([key, val]) => {
        children.push(new docx.Paragraph({ text: `${key.toUpperCase()}: ${val}` }));
      });
    }

    const doc = new docx.Document({ sections: [{ children }] });
    const buffer = await docx.Packer.toBuffer(doc);
    res.setHeader('Content-disposition', `attachment; filename="${paper.title.replace(/[^a-z0-9]/gi, '_')}.docx"`);
    res.setHeader('Content-type', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document');
    res.send(buffer);
  } catch (error) {
    res.status(500).send('Error generating DOCX');
  }
};

exports.exportTxt = async (req, res) => {
  try {
    const paper = await prisma.paper.findUnique({ where: { id: parseInt(req.params.id) } });
    if (!paper || paper.userId !== req.user.id) return res.status(404).send('Paper not found');

    let text = `PAPER ANALYSIS: ${paper.title}\n`;
    text += `AUTHORS: ${paper.authors}\n\n`;
    text += `ABSTRACT:\n${paper.extractedContent?.abstract || 'N/A'}\n\n`;
    text += `SUMMARY:\n${paper.summaries?.detailed || paper.summary || 'N/A'}\n\n`;

    if (paper.insights) {
      text += `KEY INSIGHTS:\n`;
      Object.entries(paper.insights).forEach(([k, v]) => text += `- ${k}: ${v}\n`);
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

    let md = `# ${paper.title}\n**Authors:** ${paper.authors}\n\n`;
    md += `## Abstract\n${paper.extractedContent?.abstract || 'N/A'}\n\n`;
    md += `## Summary\n${paper.summaries?.detailed || paper.summary || 'N/A'}\n\n`;

    if (paper.insights) {
      md += `## Key Insights\n`;
      Object.entries(paper.insights).forEach(([k, v]) => md += `### ${k}\n${v}\n\n`);
    }

    res.setHeader('Content-disposition', `attachment; filename="${paper.title.replace(/[^a-z0-9]/gi, '_')}.md"`);
    res.setHeader('Content-type', 'text/markdown');
    res.send(md);
  } catch (error) {
    res.status(500).send('Error generating Markdown');
  }
};
