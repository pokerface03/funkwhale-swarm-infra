#!/bin/bash
set -e

###########################
# Helper functions
###########################
# Function to update or append a line in a file using sed.
# Arguments: file, search pattern, new line
update_or_append_line() {
  local file="$1"
  local pattern="$2"
  local newline="$3"

  if grep -q "^${pattern}" "$file"; then
    # Update the line that starts with the pattern
    sed -i "s|^${pattern}.*|${newline}|" "$file"
  else
    # If not found, append to the end
    echo "${newline}" >> "$file"
  fi
}

###########################
# Step 1: Copy environment file (env.prod.sample) to the target .env path
###########################
echo "Copy env.prod.sample to .env..."
echo "${funkwhale_env_file}" -->  "${funkwhale_env_path}"
cp "${funkwhale_env_file}" "${funkwhale_env_path}"
chown "${dockeruser}:${dockeruser}" "${funkwhale_env_path}"
chmod 0644 "${funkwhale_env_path}"

###########################
# Step 2: Update FUNKWHALE_VERSION in .env file
###########################
echo "Update FUNKWHALE_VERSION in .env file..."
update_or_append_line "${funkwhale_env_path}" "FUNKWHALE_VERSION=" "FUNKWHALE_VERSION=${FUNKWHALE_VERSION}"

###########################
# Step 3: Set permissions 600 for the .env file
###########################
echo "Setting permissions 600 for the .env file..."
chmod 0600 "${funkwhale_env_path}"

###########################
# Step 4: Generate Django secret key
###########################
echo "Generate Django secret key..."
secret_key=$(openssl rand -base64 45)

###########################
# Step 5: Update DJANGO_SECRET_KEY in .env file
###########################
echo "Update DJANGO_SECRET_KEY in .env file..."
update_or_append_line "${funkwhale_env_path}" "DJANGO_SECRET_KEY=" "DJANGO_SECRET_KEY=${secret_key}"

###########################
# Step 6: Update FUNKWHALE_HOSTNAME in .env file
###########################
echo "Update FUNKWHALE_HOSTNAME in .env file..."
update_or_append_line "${funkwhale_env_path}" "FUNKWHALE_HOSTNAME=" "FUNKWHALE_HOSTNAME=${funkwhale_hostname}"

###########################
# Step 7: Generate final Nginx configuration using envsubst
###########################
echo "Generate final Nginx configuration using envsubst..."
# Export variables from the .env file
set -a
source "${funkwhale_env_path}"
set +a

# Run envsubst replacing all variables
envsubst "$(env | awk -F '=' '{printf " \$%s", $1}')" < "${nginx_config_dir}/funkwhale.template" > "${nginx_config_dir}/funkwhale.conf"

echo "Complete setup of Funkwhale and Nginx."
