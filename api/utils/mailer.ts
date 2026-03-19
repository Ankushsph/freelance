import nodemailer from 'nodemailer';

// Create transporter with Gmail SMTP
export const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.MAIL_USER,
    pass: process.env.MAIL_PASS,
  },
});

// Verify transporter configuration
transporter.verify((error, success) => {
  if (error) {
    console.log('❌ Email service error:', error.message);
    console.log('⚠️  Email OTP will be logged to console instead');
  } else {
    console.log('✅ Email service ready to send OTPs');
  }
});
