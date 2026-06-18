const pdfParseModule = require('pdf-parse');

exports.extractTextFromPDF = async (fileBuffer) => {
  try {
    if (typeof pdfParseModule === 'function') {
      const data = await pdfParseModule(fileBuffer);
      return { text: data.text, numpages: data.numpages || 1 };
    }
    if (pdfParseModule && typeof pdfParseModule.PDFParse === 'function') {
      const parser = new pdfParseModule.PDFParse(new Uint8Array(fileBuffer));
      const res = await parser.getText();
      return { text: res.text, numpages: 1 }; // PDFParse fallback doesn't reliably expose numpages
    }
    throw new Error('Unsupported pdf-parse module format');
  } catch (error) {
    throw new Error('Failed to parse PDF: ' + error.message);
  }
};
