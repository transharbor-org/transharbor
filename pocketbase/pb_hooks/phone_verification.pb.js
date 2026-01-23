/// PocketBase hook for phone verification
/// Generates OTP and sets expiration

onRecordBeforeCreateRequest((e) => {
    const collection = e.record.collection();
    
    if (collection.name !== 'phone_verification') {
        return;
    }

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Set OTP and expiration (10 minutes)
    e.record.set('otp', otp);
    e.record.set('verified', false);
    e.record.set('expires_at', new Date(Date.now() + 10 * 60 * 1000).toISOString());
    
}, 'phone_verification');

onRecordAfterCreateRequest((e) => {
    const collection = e.record.collection();
    
    if (collection.name !== 'phone_verification') {
        return;
    }
    
    // Log verification request
    console.log(`OTP generated for phone: ${e.record.get('phone')}`);
    
}, 'phone_verification');

// Prevent duplicate phone numbers in users collection
onRecordBeforeCreateRequest((e) => {
    const collection = e.record.collection();
    
    if (collection.name !== 'users') {
        return;
    }
    
    const phone = e.record.get('phone');
    if (!phone) {
        throw new BadRequestError('Phone number is required');
    }
    
    // Check for existing phone number
    const existingUser = $app.dao().findFirstRecordByFilter(
        'users',
        `phone = '${phone}'`
    );
    
    if (existingUser) {
        throw new BadRequestError('Phone number already registered');
    }
    
}, 'users');

// Rate limiting for phone verification requests
const verificationAttempts = new Map();

onRecordBeforeCreateRequest((e) => {
    const collection = e.record.collection();
    
    if (collection.name !== 'phone_verification') {
        return;
    }
    
    const phone = e.record.get('phone');
    const now = Date.now();
    const attempts = verificationAttempts.get(phone) || [];
    
    // Remove attempts older than 1 hour
    const recentAttempts = attempts.filter(timestamp => now - timestamp < 60 * 60 * 1000);
    
    // Allow max 5 attempts per hour
    if (recentAttempts.length >= 5) {
        throw new BadRequestError('Too many verification attempts. Please try again later.');
    }
    
    recentAttempts.push(now);
    verificationAttempts.set(phone, recentAttempts);
    
}, 'phone_verification');
