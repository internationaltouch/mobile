# iOS Code Signing Setup for GitHub Actions

This document describes how to configure the iOS code signing secrets required for the automated iOS build workflow.

## Required Secrets

The iOS build workflow requires the following GitHub repository secrets to be configured:

### 1. `APPLE_CERTIFICATE_BASE64`
**Description**: Base64-encoded Apple Developer certificate (P12 file)

**How to obtain**:
1. Open **Keychain Access** on your Mac
2. Find your Apple Developer certificate (usually named "Apple Development: [Your Name]" or "Apple Distribution: [Your Name]")
3. Right-click the certificate and select "Export [Certificate Name]"
4. Choose "Personal Information Exchange (.p12)" format
5. Set a password for the P12 file
6. Convert to base64: `base64 -i certificate.p12 | pbcopy`
7. Paste the base64 string as the secret value

### 2. `APPLE_CERTIFICATE_PASSWORD`
**Description**: Password for the P12 certificate file

**How to set**:
- Use the password you set when exporting the P12 certificate
- Store this as a GitHub secret

### 3. `APPLE_PROVISIONING_PROFILE_BASE64`
**Description**: Base64-encoded provisioning profile for the app

**How to obtain**:
1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Go to **Profiles** section
4. Create or download the provisioning profile for your app
5. Convert to base64: `base64 -i profile.mobileprovision | pbcopy`
6. Paste the base64 string as the secret value

### 4. `APPLE_TEAM_ID`
**Description**: Your Apple Developer Team ID (10-character alphanumeric string)

**How to find**:
1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Look for "Team ID" in the top-right corner of the page
3. It's a 10-character string like "A1B2C3D4E5"

## Setting Up GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each of the four secrets listed above

## Bundle Identifier Configuration

Ensure your app's bundle identifier in `ios/Runner.xcodeproj/project.pbxproj` matches the one used in your provisioning profile.

## Provisioning Profile Types

### Development Profile
- Use for testing on registered devices
- Allows installation via Xcode, iTunes, or 3uTools
- Limited to devices registered in your developer account

### Ad Hoc Distribution Profile
- Use for distributing to a limited number of devices (up to 100)
- Devices must be registered in your developer account
- Good for beta testing

### App Store Distribution Profile
- Use for App Store submission
- Can also be used for TestFlight distribution

## Testing the Setup

1. Create a pull request to trigger the iOS build workflow
2. Check the workflow run for any code signing errors
3. Download the `ios-ipa` artifact and test installation on a device
4. Review the `ios-build-report` artifact for installation instructions

## Troubleshooting

### Common Issues

1. **Certificate not found**
   - Ensure the certificate is valid and not expired
   - Check that the certificate matches the provisioning profile

2. **Provisioning profile mismatch**
   - Verify the bundle identifier matches
   - Ensure the provisioning profile includes your certificate

3. **Team ID mismatch**
   - Double-check the Team ID in your developer account
   - Ensure it matches the provisioning profile

4. **Keychain issues**
   - The workflow creates a temporary keychain that's cleaned up automatically
   - If builds fail, check the keychain setup steps in the workflow

### Getting Help

For additional support:
- Check Apple's [Code Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/)
- Review GitHub Actions logs for specific error messages
- Contact the development team at [technology@internationaltouch.org](mailto:technology@internationaltouch.org)

## Security Notes

- Never commit certificates or provisioning profiles to the repository
- Use GitHub's encrypted secrets for all sensitive data
- Regularly rotate certificates and update secrets as needed
- Limit repository access to trusted team members