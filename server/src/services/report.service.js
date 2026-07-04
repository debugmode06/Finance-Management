const PDFDocument = require('pdfkit');
const ExcelJS = require('exceljs');
const path = require('path');
const fs = require('fs');

const { PROPOSAL_STATUSES, PROPOSAL_PRIORITIES } = require('../utils/constants');

const ensureReportsDir = () => {
  const dir = path.join(process.cwd(), 'uploads', 'reports');
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
  return dir;
};

const formatCurrency = (amount) =>
  amount != null ? `RM ${parseFloat(amount).toFixed(2)}` : 'N/A';

const formatDate = (date) =>
  date ? new Date(date).toLocaleDateString('en-MY', { year: 'numeric', month: 'short', day: 'numeric' }) : 'N/A';

/**
 * Generate PDF report
 */
const generatePDF = async (proposals, filters) => {
  const dir = ensureReportsDir();
  const filename = `report_${Date.now()}.pdf`;
  const filePath = path.join(dir, filename);

  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ margin: 50, size: 'A4' });
    const stream = fs.createWriteStream(filePath);
    doc.pipe(stream);

    // Header
    doc.fontSize(20).font('Helvetica-Bold').text('CSEA Finance Proposal Report', { align: 'center' });
    doc.moveDown(0.5);
    doc.fontSize(10).font('Helvetica').text(`Generated: ${new Date().toLocaleString()}`, { align: 'center' });
    doc.moveDown(0.5);

    // Filters summary
    if (filters) {
      doc.fontSize(9).fillColor('#666666');
      const filterText = Object.entries(filters)
        .filter(([, v]) => v)
        .map(([k, v]) => `${k}: ${v}`)
        .join(' | ');
      if (filterText) doc.text(`Filters: ${filterText}`, { align: 'center' });
      doc.fillColor('#000000');
    }

    doc.moveDown(1);
    doc.moveTo(50, doc.y).lineTo(545, doc.y).stroke();
    doc.moveDown(0.5);

    // Stats summary
    doc.fontSize(11).font('Helvetica-Bold').text('Summary');
    doc.moveDown(0.3);
    doc.fontSize(9).font('Helvetica');
    doc.text(`Total Proposals: ${proposals.length}`);

    const totalBudget = proposals.reduce((s, p) => s + (p.requestedBudget || 0), 0);
    const totalApproved = proposals.filter((p) => p.status === PROPOSAL_STATUSES.APPROVED || p.status === PROPOSAL_STATUSES.COMPLETED).length;
    doc.text(`Total Requested Budget: ${formatCurrency(totalBudget)}`);
    doc.text(`Approved: ${totalApproved}  |  Pending: ${proposals.filter(p => p.status === PROPOSAL_STATUSES.SUBMITTED || p.status === PROPOSAL_STATUSES.UNDER_REVIEW).length}  |  Completed: ${proposals.filter(p => p.status === PROPOSAL_STATUSES.COMPLETED).length}`);

    doc.moveDown(1);
    doc.moveTo(50, doc.y).lineTo(545, doc.y).stroke();
    doc.moveDown(0.5);

    // Table header
    const cols = { num: 50, title: 70, dept: 220, status: 320, budget: 400, date: 470 };
    doc.fontSize(9).font('Helvetica-Bold');
    doc.text('#', cols.num, doc.y, { width: 20 });
    doc.text('Title', cols.title, doc.y - doc.currentLineHeight(), { width: 145 });
    doc.text('Department', cols.dept, doc.y - doc.currentLineHeight(), { width: 95 });
    doc.text('Status', cols.status, doc.y - doc.currentLineHeight(), { width: 75 });
    doc.text('Budget', cols.budget, doc.y - doc.currentLineHeight(), { width: 65 });
    doc.text('Date', cols.date, doc.y - doc.currentLineHeight(), { width: 80 });
    doc.moveDown(0.5);
    doc.moveTo(50, doc.y).lineTo(545, doc.y).stroke('#cccccc');
    doc.moveDown(0.3);

    // Table rows
    proposals.forEach((p, i) => {
      const y = doc.y;
      if (y > 720) {
        doc.addPage();
        doc.y = 50;
      }
      doc.fontSize(8).font('Helvetica');
      const rowY = doc.y;
      doc.text(String(i + 1), cols.num, rowY, { width: 20 });
      doc.text(p.title || '', cols.title, rowY, { width: 145, ellipsis: true });
      doc.text(p.department || '', cols.dept, rowY, { width: 95 });
      doc.text(p.status || '', cols.status, rowY, { width: 75 });
      doc.text(formatCurrency(p.requestedBudget), cols.budget, rowY, { width: 65 });
      doc.text(formatDate(p.requiredDate), cols.date, rowY, { width: 80 });
      doc.moveDown(0.8);
    });

    doc.end();
    stream.on('finish', () => resolve({ filePath, filename }));
    stream.on('error', reject);
  });
};

/**
 * Generate Excel report
 */
const generateExcel = async (proposals, filters) => {
  const dir = ensureReportsDir();
  const filename = `report_${Date.now()}.xlsx`;
  const filePath = path.join(dir, filename);

  const workbook = new ExcelJS.Workbook();
  workbook.creator = 'CSEA Finance System';
  workbook.created = new Date();

  const sheet = workbook.addWorksheet('Proposals', {
    pageSetup: { paperSize: 9, orientation: 'landscape' },
  });

  // Header styling
  const headerFill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF0A5FFF' } };
  const headerFont = { bold: true, color: { argb: 'FFFFFFFF' }, size: 11 };

  sheet.columns = [
    { header: '#', key: 'num', width: 5 },
    { header: 'Title', key: 'title', width: 35 },
    { header: 'Department', key: 'department', width: 22 },
    { header: 'Event Name', key: 'eventName', width: 25 },
    { header: 'Priority', key: 'priority', width: 12 },
    { header: 'Status', key: 'status', width: 18 },
    { header: 'Requested Budget (RM)', key: 'requestedBudget', width: 22 },
    { header: 'Approved Budget (RM)', key: 'approvedBudget', width: 22 },
    { header: 'Actual Expense (RM)', key: 'actualExpense', width: 22 },
    { header: 'Required Date', key: 'requiredDate', width: 15 },
    { header: 'Submitted At', key: 'submittedAt', width: 18 },
    { header: 'Created By', key: 'createdBy', width: 20 },
    { header: 'Rejection Reason', key: 'rejectionReason', width: 30 },
  ];

  // Style header row
  sheet.getRow(1).eachCell((cell) => {
    cell.fill = headerFill;
    cell.font = headerFont;
    cell.alignment = { vertical: 'middle', horizontal: 'center', wrapText: true };
    cell.border = {
      bottom: { style: 'thin', color: { argb: 'FFffffff' } },
    };
  });

  // Data rows
  proposals.forEach((p, i) => {
    const row = sheet.addRow({
      num: i + 1,
      title: p.title || '',
      department: p.department || '',
      eventName: p.eventName || '',
      priority: p.priority || '',
      status: p.status || '',
      requestedBudget: p.requestedBudget || 0,
      approvedBudget: p.approvedBudget || '',
      actualExpense: p.actualExpense || 0,
      requiredDate: p.requiredDate ? new Date(p.requiredDate).toLocaleDateString() : '',
      submittedAt: p.submittedAt ? new Date(p.submittedAt).toLocaleDateString() : '',
      createdBy: p.createdBy?.name || '',
      rejectionReason: p.rejectionReason || '',
    });

    // Alternate row colors
    if (i % 2 === 0) {
      row.eachCell((cell) => {
        cell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFF5F5F7' } };
      });
    }
    row.alignment = { vertical: 'middle', wrapText: false };
  });

  // Summary sheet
  const summarySheet = workbook.addWorksheet('Summary');
  summarySheet.addRow(['CSEA Finance Proposal Report Summary']);
  summarySheet.addRow([`Generated: ${new Date().toLocaleString()}`]);
  summarySheet.addRow([]);
  summarySheet.addRow(['Metric', 'Value']);
  summarySheet.addRow(['Total Proposals', proposals.length]);
  summarySheet.addRow(['Approved', proposals.filter(p => [PROPOSAL_STATUSES.APPROVED, PROPOSAL_STATUSES.COMPLETED, PROPOSAL_STATUSES.WAITING_FOR_BILLS].includes(p.status)).length]);
  summarySheet.addRow(['Rejected', proposals.filter(p => p.status === PROPOSAL_STATUSES.REJECTED).length]);
  summarySheet.addRow(['Pending Review', proposals.filter(p => [PROPOSAL_STATUSES.SUBMITTED, PROPOSAL_STATUSES.UNDER_REVIEW, PROPOSAL_STATUSES.RESUBMITTED].includes(p.status)).length]);
  summarySheet.addRow(['Completed', proposals.filter(p => p.status === PROPOSAL_STATUSES.COMPLETED).length]);
  summarySheet.addRow(['Total Requested Budget (RM)', proposals.reduce((s, p) => s + (p.requestedBudget || 0), 0).toFixed(2)]);

  await workbook.xlsx.writeFile(filePath);
  return { filePath, filename };
};

module.exports = { generatePDF, generateExcel };
