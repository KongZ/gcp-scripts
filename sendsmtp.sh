USERNAME="AWS Secret ID"
PASSWORD="SMTP Password"
AUTH_TEXT=`echo -ne "\${USERNAME}\0${PASSWORD}" | base64`
AUTH_USER=`echo "${USERNAME}" | base64`
AUTH_PASS=`echo "${PASSWORD}" | base64`

openssl s_client -crlf -starttls smtp -connect email-smtp.us-east-1.amazonaws.com:587 <<EOF
AUTH LOGIN
$AUTH_USER
$AUTH_PASS
MAIL FROM: no-reply@email.com
rcpt to: no-reply@email.com
DATA
From: no-reply@email.com
Subject: Test message!

Hi,

This is a test message!

Best,
.
EOF
