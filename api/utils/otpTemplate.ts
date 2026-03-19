interface OtpTemplateProps {
  otp: string;
  purpose: "forgot_password" | "signup";
}

export const otpEmailTemplate = ({
  otp,
  purpose,
}: OtpTemplateProps): string => {
  const title =
    purpose === "forgot_password"
      ? "Reset Your Password"
      : "Verify Your Email";

  return `
  <!DOCTYPE html>
  <html>
  <head>
    <meta charset="UTF-8" />
    <title>${title}</title>
  </head>
  <body style="margin:0;padding:0;background:#f4f6f8;font-family:Arial,sans-serif;">
    <table width="100%" cellpadding="0" cellspacing="0">
      <tr>
        <td align="center" style="padding:40px 0;">
          <table width="420" style="background:#ffffff;border-radius:12px;box-shadow:0 10px 25px rgba(0,0,0,0.08);padding:30px;">
            
            <tr>
              <td align="center">
                <h2 style="margin:0;color:#333;">${title}</h2>
                <p style="color:#666;font-size:14px;margin-top:8px;">
                  Use the OTP below to continue
                </p>
              </td>
            </tr>

            <tr>
              <td align="center" style="padding:20px 0;">
                <div style="
                  font-size:32px;
                  letter-spacing:12px;
                  font-weight:bold;
                  color:#4f46e5;
                  background:#f0f1ff;
                  padding:16px 24px;
                  border-radius:10px;
                  display:inline-block;
                ">
                  ${otp}
                </div>
              </td>
            </tr>

            <tr>
              <td align="center">
                <p style="color:#888;font-size:13px;margin:0;">
                  This OTP will expire in <b>5 minutes</b>.
                </p>
                <p style="color:#888;font-size:13px;">
                  If you didn’t request this, you can safely ignore this email.
                </p>
              </td>
            </tr>

            <tr>
              <td align="center" style="padding-top:20px;">
                <p style="font-size:12px;color:#aaa;">
                  © ${new Date().getFullYear()} Your App Name
                </p>
              </td>
            </tr>

          </table>
        </td>
      </tr>
    </table>
  </body>
  </html>
  `;
};