# ``SwCrypt``
=========

### Create public and private RSA keys in DER format
```
let (privateKey, publicKey) = try! CC.RSA.generateKeyPair(2048)
```
### Convert them to PEM format
```
let privateKeyPEM = try SwKeyConvert.PrivateKey.derToPKCS1PEM(privateKey)
let publicKeyPEM = SwKeyConvert.PublicKey.derToPKCS8PEM(publicKey)
```
### Or read them from strings with PEM data
```
let privateKeyDER = SwKeyConvert.PrivateKey.pemToPKCS1DER(privateKeyPEM)
let publicKeyDER = SwKeyConvert.PublicKey.pemToPKCS1DER(publicKeyPEM)
```
### Or encrypt, decrypt the private key (OpenSSL compatible)
```
try SwKeyConvert.PrivateKey.encryptPEM(privateKeyPEM, passphrase: "longpassword", mode: .aes256CBC)
try SwKeyConvert.PrivateKey.decryptPEM(privEncrypted, passphrase: "longpassword")
```
### Get public key from private keys in DER format
```
let publicKeyDER = try? CC.RSA.getPublicKeyFromPrivateKey(privateKeyDER!)
```
### Encrypt, decrypt data with RSA
```
try CC.RSA.encrypt(data, derKey: publicKey, tag: tag, padding: .oaep, digest: .sha1)
try CC.RSA.decrypt(data, derKey: privateKey, tag: tag, padding: .oaep, digest: .sha1)
```
### Sign, verify data with RSA
```
let sign = try? CC.RSA.sign(testMessage, derKey: privKey, padding: .pss, 
 digest: .sha256, saltLen: 16)
let verified = try? CC.RSA.verify(testMessage, derKey: pubKey, padding: .pss,
 digest: .sha256, saltLen: 16, signedData: sign!)
```
### Elliptic curve functions
```
let keys = try? CC.EC.generateKeyPair(384)
let signed = try? CC.EC.signHash(keys!.0, hash: hash)
let verified = try? CC.EC.verifyHash(keys!.1, hash: hash, signedData: signed!)

let shared = try? CC.EC.computeSharedSecret(keys!.0, publicKey: partnerPubKey)

let privComponents = try? CC.EC.getPrivateKeyComponents(keys!.0)
let pubComponents = try? CC.EC.getPublicKeyComponents(keys!.1)

let pubKey = try? CC.EC.createFromData(keySize, x, y)
let pubKey = try? CC.EC.getPublicKeyFromPrivateKey(keys!.0)

```
### Diffie-Hellman functions
```
let dh = try CC.DH.DH(dhParam: .rfc3526Group5)
let myPubKey = try dh.generateKey()
let commonKey = try dh.computeKey(partnerPubKey!)
```
### Encrypt, decrypt data with symmetric ciphers
```
try CC.crypt(.encrypt, blockMode: .cbc, algorithm: .aes, padding: .pkcs7Padding, data: data, key: aesKey, iv: iv)
try CC.crypt(.decrypt, blockMode: .cfb, algorithm: .aes, padding: .pkcs7Padding, data: data, key: aesKey, iv: iv)
```
### Encrypt, decrypt data with symmetric authenticating ciphers
```
try CC.cryptAuth(.encrypt, blockMode: .gcm, algorithm: .aes, data: data, aData: aData, key: aesKey, iv: iv, tagLength: tagLength)
try CC.cryptAuth(.decrypt, blockMode: .ccm, algorithm: .aes, data: data, aData: aData, key: aesKey, iv: iv, tagLength: tagLength)
```
### Digest functions
```
CC.digest(data, alg: .md5)
CC.digest(data, alg: .sha256)
CC.digest(data, alg: .sha512)
```
### HMAC function
```
CC.HMAC(data, alg: .sha512, key: key)
```
### CMAC function
```
CC.CMAC.AESCMAC(input, key: key)
```
### CRC function
```
let output = try? CC.CRC.crc(input, mode: .crc32)
```
### KeyDerivation
```
CC.KeyDerivation.PBKDF2(password, salt: salt, prf: .sha256, rounds: 4096)
```
### Symmetric Key Wrapping
```
try CC.KeyWrap.SymmetricKeyWrap(CC.KeyWrap.rfc3394IV, kek: kek, rawKey: rawKey)
try CC.KeyWrap.SymmetricKeyUnwrap(CC.KeyWrap.rfc3394IV, kek: kek, wrappedKey: wrappedKey)
```
### Upsert, get, delete keys from KeyStore
```
try SwKeyStore.upsertKey(privateKeyPEM, keyTag: "priv", options: [kSecAttrAccessible:kSecAttrAccessibleWhenUnlockedThisDeviceOnly])
try SwKeyStore.getKey("priv")
try SwKeyStore.delKey("priv")
```
-----


Check availability
---------------------

SwCrypt uses dlopen and dlsym to load the CommonCrypto's functions, because not all of them are available in public header files. You have to check the availability before using them.

```
let digestAvailable : Bool = CC.digestAvailable()
let ramdomAvailable : Bool = CC.randomAvailable(()
let hmacAvailable : Bool = CC.hmacAvailable()
let cryptorAvailable : Bool = CC.cryptorAvailable
let keyDerivationAvailable : Bool = CC.KeyDerivation.available()
let keyWrapAvailable : Bool = CC.KeyWrap.available()
let rsaAvailable : Bool = CC.RSA.available()
let dhAvailable : Bool = CC.DH.available()
let ecAvailable : Bool = CC.EC.available()
let crcAvailable : Bool = CC.CRC.available()
let cmacAvailable : Bool = CC.CMAC.available()
let gcmAvailable : Bool = CC.GCM.available()
let ccmAvailable : Bool = CC.CCM.available()

or all in one turn:
let ccAvailable : Bool = CC.available()
```
