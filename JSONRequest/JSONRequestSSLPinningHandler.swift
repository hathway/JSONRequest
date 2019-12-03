//
//  JSONRequestSSLPinningHandler.swift
//  JSONRequest
//
//  Created by Yevhenii Hutorov on 11.11.2019.
//  Copyright © 2019 Hathway. All rights reserved.
//

import CommonCrypto

///JSONRequestSSLPinningHandler helps to associate a host with their hash of expected certificate public key
/// - Example: 
///````
/// let sslPinningHandler = JSONRequestSSLPinningHandler()
/// sslPinningHandler["ordering.api.com"] = "<cert key>"
/// JSONRequest.authChallengeHandler = sslPinningHandler
///````
/// - Note: To obtain a hash of cerificate public key You should run these commands on terminal
/// 
///openssl s_client -connect **host**:**port** -showcerts < /dev/null | openssl x509 -outform DER > certificate.der
///
///openssl x509 -pubkey -noout -in certificate.der -inform DER | openssl rsa -outform DER -pubin -in /dev/stdin 2>/dev/null > certificatekey.der
///
///python -sBc \"from \_\_future\_\_ import print_function;import hashlib;print(hashlib.sha256(open(\'certificatekey.der\',\'rb\').read()).digest(), end=\'\')\" | base64
///
///[Certificate and Public Key Pinning]: https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning
///For more information, see [Certificate and Public Key Pinning].
@available(iOS 10.3, *)
public final class JSONRequestSSLPinningHandler: JSONRequestAuthChallengeHandler {
    let rsa2048Asn1Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]

    /// dictionary with SSL pinning info
    /// # Parameters:
    ///     key: Host
    ///     value: Certificate Public Key hash
    /// - Important: Host must be used without a schema
    /// ````
    ///let sslPinningHandler = JSONRequestSSLPinningHandler()
    ///sslPinningHandler["ordering.api.olo.com"] = "EXEMPLRQHWwFk9jBZYEayPhZnPvUMtJpQ" // Correct host
    ///sslPinningHandler["https://peetniks.okta.com"] = "EXEMPLRQHWwFk9jBZYEayPhZnPvUMtJpQ" // Incorrect host
    ///````
    public var cerificatePublicKeys: [String: String]

    public init() {
        cerificatePublicKeys = [:]
    }

    private func sha256(data: Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

        #warning("Check this code for warning fix")
//        keyWithHeader.withUnsafeBytes { (data: UnsafeRawBufferPointer) in
//            _ = CC_SHA256(data.baseAddress, CC_LONG(keyWithHeader.count), &hash)
//        }
        keyWithHeader.withUnsafeBytes {
           _ = CC_SHA256($0, CC_LONG(keyWithHeader.count), &hash)
        }

        return Data(hash).base64EncodedString()
    }

    public func handle(_ session: URLSession, challenge: URLAuthenticationChallenge) -> JSONRequestAuthChallengeResult {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            return JSONRequestAuthChallengeResult(disposition: .performDefaultHandling)
        }

        let policies = NSMutableArray()
        let host = challenge.protectionSpace.host
        guard let pinnedPublicKeyHash = cerificatePublicKeys[host] else { return JSONRequestAuthChallengeResult(disposition: .performDefaultHandling) }

        policies.add(SecPolicyCreateSSL(true, host as CFString))
        SecTrustSetPolicies(serverTrust, policies)

        var result: SecTrustResultType = SecTrustResultType(rawValue: 0)!
        SecTrustEvaluate(serverTrust, &result)

        guard result == .unspecified || result == .proceed, let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return JSONRequestAuthChallengeResult(disposition: .cancelAuthenticationChallenge)
        }

        guard let serverPublicKey = SecCertificateCopyPublicKey(serverCertificate),
              let serverPublicKeyData: NSData = SecKeyCopyExternalRepresentation(serverPublicKey, nil ) else {
            return JSONRequestAuthChallengeResult(disposition: .performDefaultHandling)
        }
        let keyHash = sha256(data: serverPublicKeyData as Data)
        if keyHash == pinnedPublicKeyHash {
            // Success! This is our server
            return JSONRequestAuthChallengeResult(disposition: .useCredential, credential: URLCredential(trust: serverTrust))
        } else {
            return JSONRequestAuthChallengeResult(disposition: .cancelAuthenticationChallenge)
        }
    }
}
