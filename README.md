# SSH and SFTP client library for React Native

[`@termlnk/react-native-ssh-sftp`](https://github.com/termlnk/react-native-ssh-sftp) is a fork of [`@dylankenneally/react-native-ssh-sftp`](https://github.com/dylankenneally/react-native-ssh-sftp) maintained for the [termlnk](https://github.com/termlnk) project. It adds:

- **Gradle 9 / AGP 8 compatibility** — drops the removed `jcenter()` repository and declares the AGP 8+ `namespace`, so the library builds under Expo SDK 55 / React Native 0.85.
- **iOS Simulator support on Apple Silicon** — replaces NMSSH's device-only static libraries with the `CSSH.xcframework` shipped by [DimaRU/Libssh2Prebuild](https://github.com/DimaRU/Libssh2Prebuild), bundling both device and simulator slices.

The wrapping API (`SSHClient`) is otherwise unchanged from upstream, see the [Usage](#usage) section below.

## Installation

```bash
npm install @termlnk/react-native-ssh-sftp
```

### iOS

iOS support relies on two binary pods that this fork wires up automatically:

- [`termlnk/NMSSH`](https://github.com/termlnk/NMSSH) — fork of [`aanah0/NMSSH`](https://github.com/aanah0/NMSSH) (via [`EthanShoeDev/NMSSH`](https://github.com/EthanShoeDev/NMSSH)) with the vendored static libs removed and a dependency on `CSSH-Binary` added.
- `CSSH-Binary` — a tiny CocoaPod, shipped as [`CSSH-Binary.podspec`](./CSSH-Binary.podspec) in this repository, that vends the `CSSH.xcframework` zipped from `DimaRU/Libssh2Prebuild` releases.

#### With Expo (recommended)

Add `expo-build-properties` to the project and inject both pods via `extraPods` in `app.json`:

```json
{
  "expo": {
    "plugins": [
      [
        "expo-build-properties",
        {
          "ios": {
            "extraPods": [
              {
                "name": "CSSH-Binary",
                "podspec": "https://raw.githubusercontent.com/termlnk/react-native-ssh-sftp/main/CSSH-Binary.podspec"
              },
              {
                "name": "NMSSH",
                "git": "https://github.com/termlnk/NMSSH.git",
                "branch": "master"
              }
            ]
          }
        }
      ]
    ]
  }
}
```

Then `npx expo prebuild --platform ios --clean && npx pod-install`.

#### Bare React Native

Add both pods to the project's `ios/Podfile` and run `pod install`:

```ruby
target '[YourApp]' do
  pod 'CSSH-Binary', :podspec => 'https://raw.githubusercontent.com/termlnk/react-native-ssh-sftp/main/CSSH-Binary.podspec'
  pod 'NMSSH', :git => 'https://github.com/termlnk/NMSSH.git', :branch => 'master'
  # ... rest of the target ...
end
```

#### Flipper / OpenSSL conflict

If [Flipper](https://fbflipper.com/) is enabled it ships its own copy of OpenSSL which collides with NMSSH's. Disable Flipper by commenting out the `flipper_configuration` line in the Podfile, or remove the Flipper config from the Expo config plugin.

### Android

No additional setup is required beyond installing the package. The library targets `compileSdk 36` / `targetSdk 36` and `minSdk 21`, and is compatible with the Gradle 9 / AGP 8 wrapper that Expo SDK 55 generates.

### Linking

This project follows React Native's autolinking, so manual linking is not required (RN >= 0.60).

## Usage

All functions that run asynchronously where we have to wait for a result returns Promises that can reject if an error occurred.

### Create a client using password authentication

```javascript
import SSHClient from '@termlnk/react-native-ssh-sftp';

SSHClient.connectWithPassword(
  "10.0.0.10",
  22,
  "user",
  "password"
).then(client => {/*...*/});
```

### Create a client using public key authentication

```javascript
import SSHClient from '@termlnk/react-native-ssh-sftp';

SSHClient.connectWithKey(
  "10.0.0.10",
  22,
  "user",
  privateKey="-----BEGIN RSA...",
  passphrase
).then(client => {/*...*/});
```

#### Public key authentication is also supported

```plaintext
{privateKey: '-----BEGIN RSA......'}
{privateKey: '-----BEGIN RSA......', publicKey: 'ssh-rsa AAAAB3NzaC1yc2EA......'}
{privateKey: '-----BEGIN RSA......', publicKey: 'ssh-rsa AAAAB3NzaC1yc2EA......', passphrase: 'Password'}
```

### Close client

```javascript
client.disconnect();
```

### Execute SSH command

```javascript
const command = 'ls -l';
client.execute(command)
  .then(output => console.warn(output));
```

### Shell

#### Start shell

- Supported ptyType: vanilla, vt100, vt102, vt220, ansi, xterm

```javascript
const ptyType = 'vanilla';
client.startShell(ptyType)
  .then(() => {/*...*/});
```

#### Read from shell

```javascript
client.on('Shell', (event) => {
  if (event)
    console.warn(event);
});
```

#### Write to shell

```javascript
const str = 'ls -l\n';
client.writeToShell(str)
  .then(() => {/*...*/});
```

#### Close shell

```javascript
client.closeShell();
```

### SFTP

#### Connect SFTP

```javascript
client.connectSFTP()
  .then(() => {/*...*/});
```

#### List directory

```javascript
const path = '.';
client.sftpLs(path)
  .then(response => console.warn(response));
```

#### Create directory

```javascript
client.sftpMkdir('dirName')
  .then(() => {/*...*/});
```

#### Rename file or directory

```javascript
client.sftpRename('oldName', 'newName')
  .then(() => {/*...*/});
```

#### Remove directory

```javascript
client.sftpRmdir('dirName')
  .then(() => {/*...*/});
```

#### Remove file

```javascript
client.sftpRm('fileName')
  .then(() => {/*...*/});
```

#### Download file

```javascript
client.sftpDownload('[path-to-remote-file]', '[path-to-local-directory]')
  .then(downloadedFilePath => {
    console.warn(downloadedFilePath);
  });

// Download progress (setup before call)
client.on('DownloadProgress', (event) => {
  console.warn(event);
});

// Cancel download
client.sftpCancelDownload();
```

#### Upload file

```javascript
client.sftpUpload('[path-to-local-file]', '[path-to-remote-directory]')
  .then(() => {/*...*/});

// Upload progress (setup before call)
client.on('UploadProgress', (event) => {
  console.warn(event);
});

// Cancel upload
client.sftpCancelUpload();
```

#### Close SFTP

```javascript
client.disconnectSFTP();
```

## Credits

This package wraps the following libraries, which provide the actual SSH/SFTP functionality:

- [NMSSH](https://github.com/aanah0/NMSSH) on iOS, via [`termlnk/NMSSH`](https://github.com/termlnk/NMSSH) for the XCFramework-based binary chain.
- [JSch](http://www.jcraft.com/jsch/) on Android, via [Matthias Wiedemann's fork](https://github.com/mwiede/jsch).
- [`CSSH.xcframework`](https://github.com/DimaRU/Libssh2Prebuild) bundling libssh2 + OpenSSL with both device and simulator slices.

This package is a fork of Emmanuel Natividad's [react-native-ssh-sftp](https://github.com/enatividad/react-native-ssh-sftp). The fork chain:

1. [Gabriel Paul "Cley Faye" Risterucci](https://github.com/KeeeX/react-native-ssh-sftp)
1. [Bishoy Mikhael](https://github.com/MrBmikhael/react-native-ssh-sftp)
1. [Qian Sha](https://github.com/shaqian/react-native-ssh-sftp)
1. [Dylan Kenneally](https://github.com/dylankenneally/react-native-ssh-sftp)
1. [termlnk](https://github.com/termlnk/react-native-ssh-sftp) — current
