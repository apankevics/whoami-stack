#!/bin/sh
set -e # Exit immediately if a command exits with a non-zero status

CERT_PATH="/etc/nginx/certs"

# Define a function to print errors in red
error_exit() {
	# shellcheck disable=SC2028
	echo "\033[1;31mERROR:\033[0m $1" >&2
	exit 1
}

# Function to print messages in color
info() {
	# shellcheck disable=SC2028
	echo "\033[1;32mINFO:\033[0m $1"
}

# Function to check if certificate exists and validate expiration date
check_certificate() {
	CERT_FILE="$CERT_PATH/$VIRTUAL_HOST.crt"

	# Check if certificate exists
	if [ -f "$CERT_FILE" ]; then
		# Extract expiration date from certificate
		EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
		EXPIRY_TIMESTAMP=$(date -d "$EXPIRY_DATE" +%s)
		CURRENT_TIMESTAMP=$(date +%s)
		REMAINING_DAYS=$(((EXPIRY_TIMESTAMP - CURRENT_TIMESTAMP) / 86400))

		info "Certificate for $VIRTUAL_HOST is valid for $REMAINING_DAYS more days."

		# If certificate expires in less than CERTIFICATE_RENEW_DAYS, renew it
		if [ "$REMAINING_DAYS" -le "$CERTIFICATE_RENEW_DAYS" ]; then
			info "Certificate is expiring in $REMAINING_DAYS days. Renewing..."
			return 1 # Indicate certificate needs renewal
		fi

		info "Certificate is valid and does not need renewal."
		return 0 # Indicate certificate is valid
	else
		info "No certificate found for $VIRTUAL_HOST. Issuing a new one..."
		return 1 # Indicate certificate needs to be issued
	fi
}

# Issue the certificate if it doesn't exist
issue_certificate() {
	info "Issuing certificate for $VIRTUAL_HOST..."

	# Register account if needed
	acme.sh --register-account -m "$DEFAULT_EMAIL" || error_exit "Failed to register account with ACME."

	# Issue new certificate
	acme.sh --issue --dns dns_duckdns -d "$VIRTUAL_HOST" || error_exit "Failed to issue certificate for $VIRTUAL_HOST."

	# Install the new certificate
	acme.sh --install-cert -d "$VIRTUAL_HOST" \
		--key-file "$CERT_PATH"/"$VIRTUAL_HOST".key \
		--fullchain-file "$CERT_PATH"/"$VIRTUAL_HOST".crt || error_exit "Failed to install certificate for $VIRTUAL_HOST."

	# Add a cron job to run renewal validation every day at midnight
	echo "0 0 * * * /acme-sh-entry.sh >> /var/log/acme-renew.log 2>&1" | crontab - || error_exit "Can't update crontab."

	info "Certificate successfully issued and installed for $VIRTUAL_HOST!"
}

# Check if certificate exists and validate its expiration
check_certificate || {
	issue_certificate
}

info "Process completed successfully for $VIRTUAL_HOST!"
