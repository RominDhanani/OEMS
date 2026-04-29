import { generateExpensePDF, generateFundPDF, generateExpansionPDF } from './pdfGenerator';

const getDocumentUrl = (path) => {
    if (!path) return null;
    // Normalize slashes
    let cleanPath = path.replace(/\\/g, '/');

    // Remove "public/" or "backend/" if present (just in case)
    cleanPath = cleanPath.replace(/^public\//, '').replace(/^backend\//, '');

    // If path is absolute (C:/...) try to extract from 'uploads/'
    if (cleanPath.includes('uploads/')) {
        cleanPath = cleanPath.substring(cleanPath.indexOf('uploads/'));
    } else if (!cleanPath.startsWith('uploads/')) {
        // If it doesn't have uploads/, assume it's directly in uploads
        cleanPath = `uploads/${cleanPath}`;
    }

    return `${window.location.protocol}//${window.location.hostname}:5000/${cleanPath}`;
};


export const handleViewDocument = (path) => {
    const url = getDocumentUrl(path);
    if (!url) return alert('No document found');
    window.open(url, '_blank');
};

export const handleDownloadDocument = async (path, filename) => {
    const url = getDocumentUrl(path);
    if (!url) return alert('No document found');

    try {
        const response = await fetch(url);
        if (!response.ok) throw new Error('Download failed');
        const blob = await response.blob();
        const blobUrl = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = blobUrl;
        link.download = filename || path.replace(/\\/g, '/').split('/').pop() || 'document';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        window.URL.revokeObjectURL(blobUrl);
    } catch (error) {
        console.error('Download error:', error);
        alert('Failed to download document');
    }
};

export const handleDownloadPDF = (data, type = 'EXPENSE') => {
    switch (type) {
        case 'EXPENSE':
            generateExpensePDF(data);
            break;
        case 'FUND':
            generateFundPDF(data);
            break;
        case 'EXPANSION':
            generateExpansionPDF(data);
            break;
        default:
            console.error('Unknown PDF type:', type);
    }
};
