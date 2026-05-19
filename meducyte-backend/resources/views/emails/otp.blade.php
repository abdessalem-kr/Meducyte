<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Meducyte — One-time code</title>
</head>
<body style="margin:0; padding:0; font-family: Arial, Helvetica, sans-serif; background:#f3f6fb;">
  <table width="100%" cellpadding="0" cellspacing="0" role="presentation">
    <tr>
      <td align="center" style="padding:30px 10px;">
        <table width="600" cellpadding="0" cellspacing="0" role="presentation" style="background:#ffffff; border-radius:12px; overflow:hidden; box-shadow:0 6px 18px rgba(0,0,0,0.06);">
          <tr>
            <td style="padding:28px; text-align:center; background: linear-gradient(90deg,#0ea5e9 0%, #3b82f6 100%);">
              <h1 style="margin:0; color:#fff; font-size:22px;">Meducyte</h1>
            </td>
          </tr>

          <tr>
            <td style="padding:28px;">
              <p style="margin:0 0 14px 0; color:#333; font-size:16px;">Hello,</p>
              <p style="margin:0 0 18px 0; color:#555; font-size:14px;">
                {{ $type === 'email_verification' ? 'Use this code to verify your email address for Meducyte.' : 'Use this code to reset your Meducyte account password.' }}
              </p>

              <div style="display:flex; justify-content:center; margin:22px 0;">
                <div style="padding:18px 26px; border-radius:8px; background:#f1f8ff; border:1px dashed #cfe9ff; font-size:28px; letter-spacing:6px; color:#0b62a8;">
                  {{ $otp }}
                </div>
              </div>

              <p style="margin:0 0 8px 0; color:#666; font-size:13px;">
                This code expires in {{ $expiresIn }} minutes.
              </p>
              <p style="margin:16px 0 0 0; color:#999; font-size:12px;">
                If you did not request this, please ignore this email.
              </p>

              <hr style="margin:22px 0; border:none; border-top:1px solid #eee;">

              <p style="margin:0; font-size:13px; color:#777;">Thanks,<br/>The Meducyte Team</p>
            </td>
          </tr>

          <tr>
            <td style="padding:12px; text-align:center; background:#f7fbff; color:#9aa9c7; font-size:12px;">
              &copy; {{ date('Y') }} Meducyte — Learn better, faster.
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>