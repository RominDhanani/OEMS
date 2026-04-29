import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

// --- Configuration ---
// Primary Brand Colors (Deep Corporate Blue & Gold Accent)
const BRAND_COLOR = [30, 58, 138]; // #1e3a8a (Dark Blue)
const ACCENT_COLOR = [234, 179, 8]; // #eab308 (Gold/Amber)
const TEXT_DARK = [15, 23, 42]; // #0f172a (Slate 900)
const TEXT_MUTED = [100, 116, 139]; // #64748b (Slate 500)
const BG_LIGHT = [248, 250, 252]; // #f8fafc (Slate 50)

let pdfCurrencyConfig = {
    symbol: 'Rs.',
    locale: 'en-IN',
    rate: 1
};

export const updatePdfConfig = (newConfig) => {
    pdfCurrencyConfig = { ...pdfCurrencyConfig, ...newConfig };
};

const sanitizeForPdf = (text) => {
    if (typeof text !== 'string') return text;
    return text
        .replace(/₹/g, 'Rs.')
        .replace(/€/g, 'EUR')
        .replace(/£/g, 'GBP')
        .replace(/¥/g, 'JPY')
        .replace(/د.إ/g, 'AED')
        .replace(/SR/g, 'SAR');
};

// --- Helpers ---
const formatCurrency = (amount) => {
    if (amount === null || amount === undefined) return '-';
    let { symbol, locale, rate } = pdfCurrencyConfig;

    const convertedAmount = parseFloat(amount) * (rate || 1);

    const formatted = symbol + ' ' + convertedAmount.toLocaleString(locale, {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });

    return sanitizeForPdf(formatted);
};

const formatDate = (dateString, includeTime = false) => {
    if (!dateString) return '-';
    const options = { day: '2-digit', month: 'short', year: 'numeric' };
    if (includeTime) {
        options.hour = '2-digit';
        options.minute = '2-digit';
    }
    return new Date(dateString).toLocaleDateString('en-GB', options);
};

// --- Branding ---

/**
 * Draws a professional vector logo and header.
 * @param {jsPDF} doc 
 * @param {string} title 
 * @param {string} docId 
 * @param {string} date 
 */
export const drawBrandHeader = (doc, title, docId, date) => {
    const pageWidth = doc.internal.pageSize.width;



    // 2. Logo Section (Left) - Scaled down ~30%
    // Vector Logo: Abstract "Hexagon" structure representing stability
    const logoX = 15;
    const logoY = 12; // Shifted up slightly

    doc.setFillColor(...BRAND_COLOR);
    doc.setDrawColor(...BRAND_COLOR);

    // Briefcase Icon on Rounded Square (App Icon Style)

    // 55. Icon Container (Rounded Square) - Reduced by 30% (13 -> 9)
    const iconSize = 9;
    doc.setFillColor(67, 56, 202);
    doc.roundedRect(logoX, logoY, iconSize, iconSize, 2, 2, 'F'); // Radius reduced to 2

    // 2. White Briefcase Parts
    doc.setFillColor(255, 255, 255);
    doc.setDrawColor(255, 255, 255);

    // Handle (Stroke)
    const handleW = 3.5; // 5 -> 3.5
    const handleH = 1.8; // 2.5 -> 1.8
    const handleX = logoX + (iconSize - handleW) / 2;
    const handleY = logoY + 2; // Adjusted Y relative to smaller box

    doc.setLineWidth(0.8); // 1 -> 0.8
    doc.roundedRect(handleX, handleY, handleW, handleH, 0.4, 0.4, 'D');

    // Body (Filled Rect)
    const bodyW = 6.3; // 9 -> 6.3
    const bodyH = 4.2; // 6 -> 4.2
    const bodyX = logoX + (iconSize - bodyW) / 2;
    const bodyY = handleY + 1; // Overlap handle slightly

    doc.roundedRect(bodyX, bodyY, bodyW, bodyH, 0.8, 0.8, 'F');

    // Horizontal Line/Band details
    doc.setDrawColor(67, 56, 202);
    doc.setLineWidth(0.4); // 0.5 -> 0.4
    doc.line(bodyX, bodyY + 1.8, bodyX + bodyW, bodyY + 1.8);

    // Brand Name - Adjusted X position for better spacing
    const textX = logoX + iconSize + 6; // More breathing room

    // Scaled from 18 to 13pt
    doc.setFontSize(14); // Slightly larger for impact
    doc.setTextColor(...BRAND_COLOR);
    doc.setFont('helvetica', 'bold');
    doc.text("OFFICE EXPENSE", textX, logoY + 5);

    // Subtext - Scaled from 8 to 6pt
    doc.setFontSize(6.5);
    doc.setTextColor(...TEXT_MUTED);
    doc.setFont('helvetica', 'bold'); // Bold for readability
    doc.setCharSpace(1.5); // Wide tracking for premium feel
    doc.text("MANAGEMENT", textX, logoY + 9);

    // 3. Document Title & Info (Right)
    doc.setFontSize(18); // Larger Title
    doc.setTextColor(...TEXT_DARK);
    doc.setFont('helvetica', 'bold');
    doc.setCharSpace(0); // Reset character spacing
    doc.text(title.toUpperCase(), pageWidth - 15, 18, { align: 'right' }); // Moved up slightly

    // Meta Data Grid (Right aligned below title)
    doc.setFontSize(8);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(...TEXT_MUTED);

    // Tighter stacking for "ERP" look
    doc.text(`ID: ${docId}`, pageWidth - 15, 24, { align: 'right' });
    doc.text(`Date: ${date}`, pageWidth - 15, 28, { align: 'right' });

    // 4. Thick Professional Divider Line
    doc.setDrawColor(...BRAND_COLOR); // Brand Blue Divider
    doc.setLineWidth(1.5); // Thick "Accent" line
    doc.line(15, 38, pageWidth - 15, 38);
};

export const drawFooter = (doc) => {
    const pageCount = doc.internal.getNumberOfPages();
    const pageWidth = doc.internal.pageSize.width;
    const pageHeight = doc.internal.pageSize.height;

    for (let i = 1; i <= pageCount; i++) {
        doc.setPage(i);

        // Divider
        doc.setDrawColor(226, 232, 240);
        doc.line(15, pageHeight - 15, pageWidth - 15, pageHeight - 15);

        // Footer Text
        doc.setFontSize(8);
        doc.setTextColor(...TEXT_MUTED);
        doc.text("Generated by Office Expense Management System", 15, pageHeight - 10);
        doc.text(`Page ${i} of ${pageCount}`, pageWidth - 15, pageHeight - 10, { align: 'right' });
    }
};

export const drawStatusBadge = (doc, status) => {
    if (!status) return;

    let bgColor = [100, 116, 139]; // Default Grey
    let text = status.toUpperCase();

    switch (status) {
        case 'APPROVED':
        case 'COMPLETED':
        case 'RECEIVED':
        case 'ALLOCATED':
        case 'ACTIVE':
        case 'ASSIGNED':
            bgColor = [22, 163, 74]; // Green 600
            break;
        case 'REJECTED':
        case 'DEACTIVATED':
            bgColor = [220, 38, 38]; // Red 600
            break;
        case 'PENDING':
        case 'PENDING_APPROVAL':
        case 'CREATED':
            bgColor = [217, 119, 6]; // Amber 600
            break;
    }

    // Badge Position - "Stamp" style in Top Right corner, below metadata
    // Aligned with the right edge

    // Doc width is usually 210mm. Right margin 15mm.
    const pageWidth = doc.internal.pageSize.width;
    const badgeW = 22;
    const badgeH = 5;
    const badgeX = pageWidth - 15 - badgeW; // Right align
    const badgeY = 31; // Below the date (which is at 28)

    doc.setFillColor(...bgColor);
    doc.roundedRect(badgeX, badgeY, badgeW, badgeH, 1, 1, 'F');

    doc.setFontSize(6);
    doc.setTextColor(255, 255, 255);
    doc.setFont('helvetica', 'bold');
    doc.text(text, badgeX + (badgeW / 2), badgeY + 3.5, { align: 'center' });
};

// --- Generators ---

export const generateExpensePDF = (expense) => {
    const doc = new jsPDF();
    const docId = `EXP-${String(expense.id).padStart(4, '0')}`;

    drawBrandHeader(doc, "Expense Invoice", docId, formatDate(expense.expense_date));
    drawStatusBadge(doc, expense.status);

    const data = [
        ['Subject', expense.title],
        ['Category', expense.category],
        ['Amount', formatCurrency(expense.amount)],
        ['Submitted By', expense.full_name || expense.user_name],
        ['Role', expense.user_role || 'User'],
        ['Department', expense.department || '-'],
        ['Approved By', expense.approved_by_name || '-'],
        ['Description', expense.description || '-']
    ];

    autoTable(doc, {
        startY: 45, // Moved up from 55
        head: [['Field', 'Details']],
        body: data,
        theme: 'striped',
        headStyles: { fillColor: BRAND_COLOR, textColor: 255, fontStyle: 'bold' },
        columnStyles: {
            0: { cellWidth: 50, fontStyle: 'bold', textColor: TEXT_DARK },
            1: { textColor: TEXT_DARK }
        },
        styles: { cellPadding: 4, fontSize: 9 } // Slightly more compact
    });

    drawFooter(doc);
    doc.save(`Expense_${docId}.pdf`);
};

export const generateFundPDF = (fund) => {
    const doc = new jsPDF();
    const docId = `TRX-${String(fund.id).padStart(4, '0')}`;

    drawBrandHeader(doc, "Fund Statement", docId, formatDate(fund.created_at));
    drawStatusBadge(doc, fund.status);

    const data = [
        ['Transaction Type', fund.to_user_id ? 'Allocation' : 'Return'],
        ['From', fund.from_user_name || fund.manager_name || '-'],
        ['To', fund.to_user_name || '-'],
        ['Amount', formatCurrency(fund.amount)],
        ['Payment Mode', fund.payment_mode || 'CASH'],
    ];

    if (fund.payment_mode === 'CHEQUE') {
        data.push(
            ['Cheque No', fund.cheque_number || '-'],
            ['Bank', fund.bank_name || '-'],
            ['Cheque Date', formatDate(fund.cheque_date)]
        );
    } else if (fund.payment_mode === 'UPI') {
        data.push(
            ['UPI ID', fund.upi_id || '-'],
            ['Txn ID', fund.transaction_id || '-']
        );
    }

    if (fund.description) {
        data.push(['Description', fund.description]);
    }

    autoTable(doc, {
        startY: 45, // Moved up
        head: [['Attribute', 'Value']],
        body: data,
        theme: 'grid',
        headStyles: { fillColor: [5, 150, 105], textColor: 255 }, // Emerald for Funds
        columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 } },
        styles: { cellPadding: 4, fontSize: 9 }
    });

    drawFooter(doc);
    doc.save(`Fund_${docId}.pdf`);
};

export const generateExpansionPDF = (fund) => {
    const doc = new jsPDF();
    const docId = `REQ-${String(fund.id).padStart(4, '0')}`;

    drawBrandHeader(doc, "Expansion Use", docId, formatDate(fund.requested_at));
    drawStatusBadge(doc, fund.status);

    const data = [
        ['Requester', fund.manager_name],
        ['Requested Amount', formatCurrency(fund.requested_amount)],
        ['Approved Amount', fund.approved_amount ? formatCurrency(fund.approved_amount) : '-'],
        ['Justification', fund.justification || '-']
    ];

    autoTable(doc, {
        startY: 45, // Moved up
        head: [['Details', 'Information']],
        body: data,
        theme: 'striped',
        headStyles: { fillColor: [217, 119, 6], textColor: 255 }, // Amber
        styles: { cellPadding: 4, fontSize: 9 }
    });

    drawFooter(doc);
    doc.save(`Expansion_${docId}.pdf`);
};

export const generateUserPDF = (user) => {
    const doc = new jsPDF();
    const docId = `USR-${String(user.id).padStart(4, '0')}`;

    drawBrandHeader(doc, "User Profile", docId, formatDate(user.created_at));
    drawStatusBadge(doc, user.status);

    const data = [
        ['Full Name', user.full_name],
        ['Email', user.email],
        ['Role', user.role],
        ['Mobile', user.mobile_number || '-'],
        ['Assigned Manager', user.manager_name || 'Unassigned'],
        ['Registered On', new Date(user.created_at).toLocaleString()]
    ];

    autoTable(doc, {
        startY: 45, // Moved up
        head: [['Attribute', 'Access Details']],
        body: data,
        theme: 'striped',
        headStyles: { fillColor: [79, 70, 229] }, // Indigo
        columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 } },
        styles: { fontSize: 9, cellPadding: 4 }
    });

    drawFooter(doc);
    doc.save(`User_${user.full_name.replace(/\s+/g, '_')}.pdf`);
};

export const generateManagerReportPDF = (manager) => {
    const doc = new jsPDF();
    const docId = `MGR-${String(manager.manager_id).padStart(4, '0')}`;
    const date = new Date().toLocaleDateString();

    drawBrandHeader(doc, "Manager Statement", docId, date);

    // Summary Section
    doc.setFontSize(11); // Scaled down
    doc.setTextColor(...BRAND_COLOR);
    doc.setFont('helvetica', 'bold');
    doc.text("Financial Summary", 14, 45); // Moved up

    const summaryData = [
        ['Allocated Funds', formatCurrency(manager.total_received)],
        ['Manager Own Usage', formatCurrency(manager.manager_own_usage)],
        ['Allocated to Team', formatCurrency(manager.total_allocated_to_team)],
        ['Current Balance', formatCurrency(manager.manager_balance)]
    ];

    autoTable(doc, {
        startY: 48, // Moved up
        head: [['Metric', 'Value']],
        body: summaryData,
        theme: 'grid',
        headStyles: { fillColor: BRAND_COLOR },
        columnStyles: { 0: { fontStyle: 'bold' } },
        styles: { fontSize: 9, cellPadding: 4 }
    });

    // Team Breakdown
    doc.text("Team Allocation Breakdown", 14, doc.lastAutoTable.finalY + 12);

    const teamData = manager.team_usage_breakdown.map(user => [
        user.name,
        formatCurrency(user.allocated_fund),
        formatCurrency(user.used_fund),
        formatCurrency(user.balance)
    ]);

    if (teamData.length === 0) {
        teamData.push([{ content: 'No team members assigned', colSpan: 4, styles: { halign: 'center' } }]);
    }

    autoTable(doc, {
        startY: doc.lastAutoTable.finalY + 15,
        head: [['Team Member', 'Allocated', 'Used', 'Balance']],
        body: teamData,
        theme: 'striped',
        headStyles: { fillColor: [71, 85, 105] }, // Slate
        styles: { fontSize: 9, cellPadding: 4 }
    });

    drawFooter(doc);
    doc.save(`Manager_Report_${manager.manager_name.replace(/\s+/g, '_')}.pdf`);
};

export const generateProfessionalPDF = (title, columns, data, options = {}) => {
    // 1. Determine optimal layout based on column count
    const colCount = columns.length;
    const orientation = colCount > 7 ? 'l' : 'p'; // 'l' for landscape, 'p' for portrait
    const fontSize = colCount > 10 ? 7 : (colCount > 8 ? 8 : 9);

    const doc = new jsPDF({
        orientation: orientation,
        unit: 'mm',
        format: 'a4'
    });

    const pageWidth = doc.internal.pageSize.width;

    drawBrandHeader(doc, title, "RPT-GEN", new Date().toLocaleDateString());

    const tableRows = data.map(item => columns.map(col => {
        let value = item[col.key];
        if (col.format) value = col.format(value, item);
        return sanitizeForPdf(value) || '-';
    }));

    // Pass footer rows directly, assuming they are either raw or already formatted correctly
    const processedFooter = options.footerRows ? options.footerRows.map(row => 
        row.map(cell => ({
            ...cell,
            content: sanitizeForPdf(cell.content)
        }))
    ) : null;

    autoTable(doc, {
        startY: 45,
        head: [columns.map(col => col.header)],
        body: tableRows,
        foot: processedFooter,
        theme: 'striped',
        headStyles: {
            fillColor: BRAND_COLOR,
            fontSize: fontSize + 1,
            fontStyle: 'bold',
            halign: 'center'
        },
        footStyles: {
            fillColor: [241, 245, 249],
            textColor: TEXT_DARK,
            fontStyle: 'bold',
            fontSize: fontSize
        },
        styles: {
            fontSize: fontSize,
            cellPadding: orientation === 'l' ? 2 : 3,
            overflow: 'linebreak',
            halign: 'left'
        },
        columnStyles: {
            // ID column usually short
            id: { cellWidth: 12 },
            // Date column usually fixed width
            expense_date: { cellWidth: 22 },
            created_at: { cellWidth: 22 },
            requested_at: { cellWidth: 22 },
            // Amount column usually right aligned
            amount: { halign: 'right', cellWidth: 25 },
            requested_amount: { halign: 'right', cellWidth: 25 },
            approved_amount: { halign: 'right', cellWidth: 25 }
        },
        alternateRowStyles: { fillColor: BG_LIGHT },
        margin: { left: 15, right: 15 }
    });

    drawFooter(doc);
    doc.save(`${title.toLowerCase().replace(/\s+/g, '_')}.pdf`);
};

export { BRAND_COLOR, formatCurrency, formatDate };
