#!/bin/bash
# Script to package the FYTA integration for Unfolded Circle Remote Two
# Following the official documentation: https://github.com/unfoldedcircle/core-api/blob/main/doc/integration-driver/driver-installation.md
# and the Roon integration's build workflow

# Create package directory
echo "Creating package directory..."
rm -rf package
mkdir -p package/bin
mkdir -p package/config
mkdir -p package/data

# Copy Node.js files to bin directory
echo "Copying files..."
cp -r src/node_modules package/bin/
cp src/*.js package/bin/

# Make the driver.js file executable
echo "Setting file permissions..."
chmod 755 package/bin/driver.js
find package/bin -type f -exec chmod 644 {} \;
find package/bin -type d -exec chmod 755 {} \;
chmod 755 package/bin/driver.js

# Create driver.json in the root directory
echo "Creating driver.json file..."
cat > package/driver.json << 'EOF'
{
  "driver_id": "fyta_plant_monitor",
  "version": "0.1.0",
  "min_core_api": "0.20.0",
  "name": {
    "en": "FYTA Plant Monitor"
  },
  "icon": "uc:plant",
  "description": {
    "en": "Monitor your FYTA plant sensors",
    "de": "Überwache deine FYTA Pflanzensensoren"
  },
  "developer": {
    "name": "Alexander",
    "url": "https://github.com/Schalex01/uc-integration-fyta"
  },
  "home_page": "https://fyta.de/",
  "release_date": "2024-03-13",
  "setup_data_schema": {
    "title": {
      "en": "FYTA Account"
    },
    "description": {
      "en": "Please enter your FYTA account credentials"
    },
    "type": "object",
    "required": [
      "username",
      "password"
    ],
    "properties": {
      "username": {
        "type": "string",
        "title": {
          "en": "Email"
        }
      },
      "password": {
        "type": "string",
        "format": "password",
        "title": {
          "en": "Password"
        }
      },
      "poll_interval": {
        "type": "integer",
        "title": {
          "en": "Update Interval (seconds)"
        },
        "default": 300
      }
    }
  }
}
EOF

# Copy package.json to bin directory
echo "Copying package.json to bin directory..."
cat > package/bin/package.json << 'EOF'
{
  "name": "fyta-integration",
  "version": "0.1.0",
  "description": "FYTA Plant Monitor integration for Unfolded Circle Remote Two",
  "main": "driver.js",
  "type": "module",
  "scripts": {
    "start": "node driver.js"
  },
  "dependencies": {
    "@unfoldedcircle/integration-api": "^0.3.0",
    "axios": "^1.8.3"
  }
}
EOF

# Create package archive with explicit permissions
echo "Creating package archive..."
cd package
tar --no-same-owner --no-same-permissions -czf fyta-integration.tar.gz .
cd ..

echo "Package created at package/fyta-integration.tar.gz"
echo "You can now upload this file through the Remote Two web interface."
echo "To install on your Remote Two:"
echo "1. Enable Developer Mode in Settings > System > Developer Options"
echo "2. Go to Settings > Integrations > Install Custom Integration"
echo "3. Upload the generated package/fyta-integration.tar.gz file"

# If Docker simulator is available, copy to upload directory
DOCKER_UPLOAD_DIR="/Users/alex/GIT/FYTA_Circle_API/HomeassistentFYTA/core-simulator/core-simulator/docker/upload"
if [ -d "$DOCKER_UPLOAD_DIR" ]; then
  echo "Copying package to Docker upload directory..."
  cp package/fyta-integration.tar.gz "$DOCKER_UPLOAD_DIR/"
  echo "Package copied to Docker upload directory at $DOCKER_UPLOAD_DIR"
fi