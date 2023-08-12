 //
 //  Cryptor.swift
 //  Mail
 //
 //  Created by Kingiol on 2018/9/18.
 //  Copyright © 2018 Chan Zhi. All rights reserved.
 //

 import Foundation

 enum ErrorsToThrow: Error {
     case notFound
     case timeout
     case tokenIllegal
     case failed
     case cancelled
     case operationFailed
     case initializationFailed
     case fileNotFound
     case fileNotReadable
     case fileSizeIsTooHigh
     case httpStatusCodeNotFound
     case weakSelf
     case mailboxInactive
     case responseHTTPStatusCode(/*HTTP Status Code*/Int?)
     case storageExceeded
     case buyIAPError
     case sendInviteContactMailError(Error)
     case authFailed
 }

 struct CryptorSalt {
     static let chirpEvent = "chirp_event"
     static let deviceSecretCode = "CHIRPEUR-UUID-SECRET"
     static let proxySecretCode = "CHIRPEUR-PROXY-SECRET"
 }

 class Cryptor {

     class func cryptorInit() {
         czcrypto_set_runtime(1)
         czcrypto_init()
     }

     class func cryptoCleanUp() {
         czcrypto_cleanup()
     }

     class func encrypt(with original: String, deviceID: String = "") -> String? {
         guard let originalData = original.data(using: .utf8) else { return nil }
         let originalBytes = [UInt8](originalData)
         guard let deviceData = "\(deviceID)\0".data(using: .utf8) else { return nil }
         let deviceBytes = [UInt8](deviceData)
         guard let encryptoCString = czcrypto_encrypt(deviceBytes, originalBytes, Int32(originalData.count)) else { return nil }
         let encryptoString = String(cString: encryptoCString)
         czcrypto_free(encryptoCString)
         return encryptoString
     }

     class func decrypt(with original: String, deviceID: String = "") -> String? {
         guard let originalData = original.data(using: .utf8) else { return nil }
         let originalBytes = [UInt8](originalData)
         guard let deviceData = "\(deviceID)\0".data(using: .utf8) else { return nil }
         let deviceBytes = [UInt8](deviceData)
         var ret: Int32 = 0
         guard let decryptoCString = czcrypto_decrypt(deviceBytes, originalBytes, Int32(originalData.count), &ret) else { return nil }
         let decryptoString = String(cString: decryptoCString)
         czcrypto_free(decryptoCString)
         return decryptoString
     }

     class func uuidHashR(with original: String) -> String? {
         guard let originalData = original.data(using: .utf8) else { return nil }
         let originalBytes = [UInt8](originalData)
         guard let hashCString = czuuid_hash_r(originalBytes, Int32(originalData.count)) else { return nil }
         let hashString = String(cString: hashCString)
         czuuid_free(hashCString)
         return hashString
     }
    
     class func encryptOrDecryptFiles(files: [(URL, URL)], uuid: String, encrypt: Bool, completion: @escaping([(URL, URL, String)]) -> Void) {
         DispatchQueue.global(qos: .utility).async {
             var results: [(URL, URL, String)] = []
             do {
                 for filePair in files {
                     guard let srcData = "\(filePair.0.path)\0".data(using: .utf8),
                         let dstData = "\(filePair.1.path)\0".data(using: .utf8),
                         let uuidData = "\(uuid)\0".data(using: .utf8) else {
                         throw ErrorsToThrow.failed
                     }
                     let srcBytes = [UInt8](srcData)
                     let dstBytes = [UInt8](dstData)
                     let uuidBytes = [UInt8](uuidData)
                     guard let fileHashCString = encrypt ? czcrypto_encrypt_file(uuidBytes, srcBytes, dstBytes) : czcrypto_decrypt_file(uuidBytes, srcBytes, dstBytes) else {
                         throw ErrorsToThrow.failed
                     }
                     results.append((filePair.0, filePair.1, String(cString: fileHashCString)))
                     czcrypto_free(fileHashCString)
                 }
             } catch {
                 // clear part finished files
                 for filePair in results {
                     try? FileManager.default.removeItem(at: filePair.1)
                 }
                 results.removeAll()
             }
             // callback
             DispatchQueue.main.async {
                 completion(results)
             }
         }
     }
    
     /**
      Encrypt files
      - Parameters:
      - files: Array of files to be encrypted. file.0 is the source file, will be encrypted and written to file.1.
      - uuid: the UUID of file owner (usually current Account UUID)
      - completion: completion callback. parameters is array of files with their hash strings.
     
      On failure, an empty array will be passed to completion callback.
      */
     class func encryptFiles(files: [(URL, URL)], uuid: String, completion: @escaping([(URL, URL, String)]) -> Void) {
         encryptOrDecryptFiles(files: files, uuid: uuid, encrypt: true, completion: completion)
     }
    
     /**
      Decrypt files
      - Parameters:
      - files: Array of files to be decrypted. file.0 is the source file, will be decrypted and written to file.1.
      - uuid: the UUID of file owner (usually current Account UUID)
      - completion: completion callback. parameters is array of files with their hash strings.

      On failure, an empty array will be passed to completion callback.
      */
     class func decryptFiles(files: [(URL, URL)], uuid: String, completion: @escaping([(URL, URL, String)]) -> Void) {
         encryptOrDecryptFiles(files: files, uuid: uuid, encrypt: false, completion: completion)
     }
    
  
 }
