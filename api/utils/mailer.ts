// Development email service - just logs to console
export const transporter = {
  sendMail: async (mailOptions: any) => {
    console.log("📧 DEVELOPMENT EMAIL SERVICE");
    console.log("From:", mailOptions.from);
    console.log("To:", mailOptions.to);
    console.log("Subject:", mailOptions.subject);
    console.log("HTML Content:", mailOptions.html);
    
    // Extract OTP from HTML for easy testing
    const otpMatch = mailOptions.html.match(/\b\d{4}\b/);
    if (otpMatch) {
      console.log("🔑 OTP FOR TESTING:", otpMatch[0]);
      console.log("🔑 USE THIS OTP IN THE APP:", otpMatch[0]);
      console.log("========================");
    }
    
    // Return success response
    return Promise.resolve({ 
      messageId: "dev-" + Date.now(),
      accepted: [mailOptions.to],
      rejected: [],
      response: "250 Message queued for development"
    });
  }
};