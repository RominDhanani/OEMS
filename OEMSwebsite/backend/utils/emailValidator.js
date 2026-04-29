const dns = require('dns').promises;

/**
 * List of common disposable/dummy email domains to block.
 */
const DISPOSABLE_DOMAINS = [
    'mailinator.com', 'tempmail.org', 'guerrillamail.com', '10minutemail.com',
    'trashmail.com', 'getairmail.com', 'dispostable.com', 'sharklasers.com',
    'yopmail.com', 'maildrop.cc', 'malinator.com', 'spamgourmet.com',
    'fakeinbox.com', 'discard.email', 'teleworm.us', 'armyspy.com',
    'dropmail.me', 'moakt.com', 'disposable.com', 'temp-mail.org',
    'example.com', 'test.com', 'invalid.com', 'domain.com', 'testing.com',
    'localhost', 'none.com', 'noreply.com', 'dummy.com', 'email.com',
    'sample.com', 'demo.com', 'user.com', 'mail.com'
];

const BLOCKED_KEYWORDS = [
    'tempmail', 'disposable', 'throwaway', 'fake', 'test', 'dummy', 'spam',
    'admin', 'root', 'user1', 'user2', 'user3', 'test01', 'testing'
];

const containsRandomPattern = (localPart) => {
    // Block local parts that are just generic name + numbers (e.g., user123, test999)
    const genericPatterns = [/user\d+/i, /test\d+/i, /admin\d+/i, /abc\d+/i];
    if (genericPatterns.some(pattern => pattern.test(localPart))) return true;

    // Block very long random-looking hex/numeric strings
    if (localPart.length > 8 && /^[0-9a-f]+$/i.test(localPart)) return true;

    return false;
};

/**
 * Validates if an email is a real, non-disposable, and theoretically reachable address.
 * @param {string} email - The email address to validate.
 * @returns {Promise<{isValid: boolean, message: string}>}
 */
const isRealtimeEmail = async (email) => {
    if (!email || typeof email !== 'string' || !email.includes('@')) {
        return { isValid: false, message: 'Invalid email format' };
    }

    const [localPart, domain] = email.split('@');
    if (!localPart || !domain) {
        return { isValid: false, message: 'Invalid email format' };
    }

    // 0. Local part validation
    if (localPart.length < 3) {
        return { isValid: false, message: 'Email prefix (the part before @) must be at least 3 characters long.' };
    }

    if (containsRandomPattern(localPart)) {
        return { isValid: false, message: 'This email format looks random or generic. Please use your original, permanent email address.' };
    }

    const domainLower = domain.toLowerCase();

    // 1. Check if domain is in disposable/dummy list
    if (DISPOSABLE_DOMAINS.includes(domainLower)) {
        return { isValid: false, message: 'This email provider is not allowed. Please use a permanent, original email address (e.g., Gmail, Outlook).' };
    }

    // 2. Check for blocked keywords in domain
    if (BLOCKED_KEYWORDS.some(keyword => domainLower.includes(keyword))) {
        return { isValid: false, message: 'Invalid email domain pattern detected. Please use a real email address.' };
    }

    // 3. Perform DNS Verification (Realtime verification)
    try {
        // Attempt to resolve MX records
        const mxRecords = await dns.resolveMx(domainLower).catch(() => []);

        if (mxRecords && mxRecords.length > 0) {
            // Check for empty or localhost MX records
            const isSuspicious = mxRecords.some(mx =>
                !mx.exchange ||
                mx.exchange === 'localhost' ||
                mx.exchange === '127.0.0.1' ||
                mx.exchange.includes('example.com')
            );
            if (isSuspicious) {
                return { isValid: false, message: 'This email domain is using a dummy mail server. Please use a real email address.' };
            }
        } else {
            // Fallback: Check for A records
            const aRecords = await dns.resolve(domainLower).catch(() => []);
            if (!aRecords || aRecords.length === 0) {
                return { isValid: false, message: 'This email domain does not exist or cannot receive emails. Please use a real email address.' };
            }
        }
    } catch (error) {
        return { isValid: false, message: 'The email domain provided is invalid or non-reachable.' };
    }

    return { isValid: true, message: 'Email verified' };
};

module.exports = { isRealtimeEmail };
