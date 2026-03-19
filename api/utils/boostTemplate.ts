interface BoostTemplateProps {
  id: string;
  name: string;
  userId: string;
  contact: string;
  timeSlot: string;
  message?: string | null;
}

export const boostEmailTemplate = ({
  id,
  name,
  userId,
  contact,
  timeSlot,
  message,
}: BoostTemplateProps): string => {
  const title = "New Boost Request";

  const baseUrl = process.env.API_BASE_URL; // ex: https://api.yourapp.com

  const approveUrl = `${baseUrl}/api/boost/action?id=${id}&type=approve`;
  const rejectUrl = `${baseUrl}/api/boost/action?id=${id}&type=reject`;

  return `
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<title>${title}</title>
</head>

<body style="
  margin:0;
  padding:0;
  background:#f4f6f8;
  font-family:Arial,sans-serif;
">

<table width="100%" cellpadding="0" cellspacing="0">
<tr>
<td align="center" style="padding:40px 0;">

<table width="450" style="
  background:#ffffff;
  border-radius:14px;
  box-shadow:0 12px 28px rgba(0,0,0,0.1);
  padding:32px;
">

<!-- HEADER -->
<tr>
<td align="center">

<h2 style="
  margin:0;
  color:#111;
  font-weight:600;
">
🚀 New Boost Request
</h2>

<p style="
  color:#666;
  font-size:14px;
  margin-top:6px;
">
Review and take action
</p>

</td>
</tr>

<!-- INFO -->
<tr>
<td style="padding:24px 0;">

<table width="100%" style="
  background:#f9faff;
  border-radius:12px;
  padding:18px;
  font-size:14px;
  line-height:22px;
">

<tr>
<td width="35%"><b>Name</b></td>
<td>${name}</td>
</tr>

<tr>
<td><b>User ID</b></td>
<td>${userId}</td>
</tr>

<tr>
<td><b>Contact</b></td>
<td>${contact}</td>
</tr>

<tr>
<td><b>Time Slot</b></td>
<td>${timeSlot}</td>
</tr>

<tr>
<td><b>Status</b></td>
<td style="color:#f59e0b;"><b>Pending</b></td>
</tr>

${message ? `
<tr>
<td colspan="2" style="padding-top:12px;">
<div style="background:#e0f2fe; border-left:4px solid #0284c7; padding:12px; border-radius:8px;">
<p style="margin:0 0 6px 0; color:#0369a1; font-size:12px; font-weight:600;">📩 Message from User:</p>
<p style="margin:0; color:#0c4a6e; font-size:14px; line-height:1.5;">${message}</p>
</div>
</td>
</tr>
` : ''}

</table>

</td>
</tr>

<!-- ACTION BUTTONS -->
<tr>
<td align="center" style="padding-bottom:24px;">

<a href="${approveUrl}"
style="
  background:#22c55e;
  color:white;
  padding:12px 28px;
  border-radius:8px;
  text-decoration:none;
  font-weight:600;
  margin-right:12px;
  display:inline-block;
">
Approve
</a>

<a href="${rejectUrl}"
style="
  background:#ef4444;
  color:white;
  padding:12px 28px;
  border-radius:8px;
  text-decoration:none;
  font-weight:600;
  display:inline-block;
">
Reject
</a>

</td>
</tr>

<!-- FOOTER -->
<tr>
<td align="center">

<p style="
  color:#888;
  font-size:13px;
  margin:0;
">
This action will update the request instantly.
</p>

<p style="
  color:#aaa;
  font-size:12px;
  margin-top:6px;
">
© ${new Date().getFullYear()} Konnect Platform
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
