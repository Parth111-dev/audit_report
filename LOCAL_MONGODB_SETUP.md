# Setting Up Local MongoDB for Solar Panel Audit App

This guide will help you set up a local MongoDB server that can be accessed only from devices on your local network.

## Prerequisites

1. A computer that will act as your MongoDB server (can be Windows, macOS, or Linux)
2. MongoDB Community Edition installed on the server
3. All devices must be connected to the same local network (WiFi or LAN)

## Step 1: Install MongoDB Community Edition

### Windows
1. Download MongoDB Community Server from [MongoDB Download Center](https://www.mongodb.com/try/download/community)
2. Run the installer and follow the installation wizard
3. Choose "Complete" installation
4. Install MongoDB as a service (recommended)

### macOS
```bash
# Using Homebrew
brew tap mongodb/brew
brew install mongodb-community
```

### Linux (Ubuntu)
```bash
# Import MongoDB public GPG key
wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -

# Create a list file for MongoDB
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Reload local package database
sudo apt-get update

# Install MongoDB packages
sudo apt-get install -y mongodb-org
```

## Step 2: Configure MongoDB for Local Network Access

1. Locate your MongoDB configuration file:
   - Windows: `C:\Program Files\MongoDB\Server\6.0\bin\mongod.cfg`
   - macOS: `/usr/local/etc/mongod.conf`
   - Linux: `/etc/mongod.conf`

2. Edit the configuration file to allow connections from your local network:

```yaml
# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0  # Allow connections from any IP
```

3. Set up authentication (important for security):

```yaml
security:
  authorization: enabled
```

4. Restart MongoDB service:
   - Windows: `Restart-Service -Name MongoDB`
   - macOS: `brew services restart mongodb-community`
   - Linux: `sudo systemctl restart mongod`

## Step 3: Create a Database User

1. Connect to MongoDB shell:
```bash
mongosh
```

2. Create an admin user:
```javascript
use admin
db.createUser({
  user: "adminUser",
  pwd: "securePassword",
  roles: [{ role: "userAdminAnyDatabase", db: "admin" }]
})
```

3. Create a user for the audit database:
```javascript
use audit
db.createUser({
  user: "audituser",
  pwd: "auditpassword",
  roles: [{ role: "readWrite", db: "audit" }]
})
```

## Step 4: Configure Firewall

Allow MongoDB port (27017) through your firewall, but only for local network:

### Windows
```powershell
New-NetFirewallRule -DisplayName "MongoDB" -Direction Inbound -Protocol TCP -LocalPort 27017 -Action Allow -RemoteAddress LocalSubnet
```

### macOS
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/local/bin/mongod
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/local/bin/mongod
```

### Linux (Ubuntu)
```bash
sudo ufw allow from 192.168.0.0/16 to any port 27017
```
Note: Replace `192.168.0.0/16` with your local network range.

## Step 5: Update App Configuration

1. In the app, find the database configuration in `lib/services/database_service.dart`
2. Update the local MongoDB configuration:
```dart
static const String _localMongoHost = "192.168.1.100"; // Change to your MongoDB server IP
static const int _localMongoPort = 27017;
static const String _localMongoUser = "audituser"; 
static const String _localMongoPassword = "auditpassword";
static const String _localMongoDbName = "audit";
```

## Step 6: Test the Connection

1. Open the app on a device connected to your local network
2. Go to the dashboard
3. Tap on the connection indicator in the top right
4. Select "Test Connections" to verify both local and cloud connections
5. Switch to "Local" connection if available

## Security Considerations

1. **IMPORTANT**: The local MongoDB server should only be accessible from your local network
2. Always use strong passwords for MongoDB users
3. Keep your MongoDB server updated with security patches
4. Consider using a VPN if you need to access your local MongoDB from outside your network

## Troubleshooting

1. **Cannot connect to local MongoDB**:
   - Verify MongoDB service is running
   - Check firewall settings
   - Ensure the device is on the same network as the MongoDB server
   - Verify the correct IP address is configured in the app

2. **Authentication failed**:
   - Verify username and password in app configuration
   - Check that the user has appropriate permissions

3. **Data not syncing**:
   - Ensure the 'audits' collection exists in both local and cloud databases
   - Check network connectivity