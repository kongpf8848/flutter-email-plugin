//
//  CZExchange.swift
//  CZEWSSwiftDemo
//
//  Created by Su Xiaozhou on 2018/11/10.
//  Copyright © 2018 Chirpeur. All rights reserved.
//

import Foundation

class CZExchange {
    static var readRetryCount: UInt64 {
        // 1 retry more than IMAP retry count
        return 2
    }
    
    static var sendRetryCount: UInt64 {
        // 1 retry more than SMTP retry count
        return 2
    }
    
    static private func packCString(original: String) -> Data? {
        return "\(original)\0".data(using: .utf8)
    }
    
    class func exchangeInit() {
        czews_startup()
    }
    
    class func exchangeCleanup() {
        czews_cancel_all_requests()
        czews_teardown()
    }
    
    class func discover(email: String, password: String, domain: String = "") -> String? {
        guard let emailData = packCString(original: email) else { return nil }
        guard let passwordData = packCString(original: password) else { return nil }
        guard let domainData = packCString(original: domain) else { return nil }
        let start = Date()
        guard let serviceUriCString = czews_discover([UInt8](emailData), [UInt8](passwordData),
                                                     [UInt8](domainData), UInt64(2)) else { return nil }
        let serviceUriString = String(cString: serviceUriCString)
        czews_free(serviceUriCString)
        return serviceUriString
    }
    
    // This is the only api which won't block the caller
    class func getSMTPAddress(email: String) -> String? {
        guard let emailData = packCString(original: email) else { return nil }
        guard let smtpAddress = czews_get_smtp_address([UInt8](emailData)) else { return nil }
        let smtpAddressString = String(cString: smtpAddress).lowercased()
        czews_free(smtpAddress)
        return smtpAddressString
    }
    
    class func newSession(uri: String, email: String, password: String, domain: String = "") -> UnsafeMutableRawPointer? {
        guard let uriData = packCString(original: uri) else { return nil }
        guard let emailData = packCString(original: email) else { return nil }
        guard let passwordData = packCString(original: password) else { return nil }
        guard let domainData = packCString(original: domain) else { return nil }
        let start = Date()
        guard let sess = czews_new_session([UInt8](uriData), [UInt8](emailData),
                                           [UInt8](passwordData), [UInt8](domainData)) else { return nil }
        let session = sess
        return session
    }
    
    class func checkAccount(sess: UnsafeMutableRawPointer, proxy: String? = nil, proxyAuth: String? = nil) -> String? {
        if let proxy = proxy, !proxy.isEmpty, let proxyData = packCString(original: proxy),
            let proxyAuthData = packCString(original: proxyAuth ?? "") {
            czews_set_proxy(sess, [UInt8](proxyData), [UInt8](proxyAuthData))
        } else {
            czews_set_proxy(sess, nil, nil)
        }
        let start = Date()
        guard let resultCString = czews_check_account(sess, readRetryCount) else { return nil }
        let result = String(cString: resultCString)
        czews_free(resultCString)
        return result
    }
    
    class func getFolders(sess: UnsafeMutableRawPointer) -> String? {
        let start = Date()
        guard let resultCString = czews_get_folders(sess, readRetryCount) else { return nil }
        let result = String(cString: resultCString)
        czews_free(resultCString)
        return result
    }
    
    // baseUid: 本地最大的 uid, 返回在此之后（更新）的所有 uid
    class func getUids(sess: UnsafeMutableRawPointer, folderID: String, baseUid: UInt64 = 0) -> String? {
        guard let folderIDData = "\(folderID)\0".data(using: .utf8) else { return nil }
        let start = Date()
        guard let resultCString = czews_get_uids(sess, [UInt8](folderIDData), baseUid, readRetryCount) else { return nil }
        let result = String(cString: resultCString)
        czews_free(resultCString)
        return result
    }
    
    class func getMessages(sess: UnsafeMutableRawPointer, xml uids: String) -> String? {
        guard let uidsData = packCString(original: uids) else { return nil }
        let start = Date()
        guard let resultCString = czews_get_messages(sess, [UInt8](uidsData), readRetryCount) else { return nil }
        let result = String(cString: resultCString)
        czews_free(resultCString)
        return result
    }
    
    class func copyMessages(sess: UnsafeMutableRawPointer, xml uids: String, folderID: String) -> String? {
        guard let uidsData = packCString(original: uids) else { return nil }
        guard let folderData = packCString(original: folderID) else { return nil }
        let start = Date()
        guard let resultCString = czews_copy_message(sess, [UInt8](uidsData), [UInt8](folderData), sendRetryCount) else { return nil }
        let result = String(cString: resultCString)
        czews_free(resultCString)
        return result
    }
    
    class func copyMessagesToInbox(sess: UnsafeMutableRawPointer, xml uids: String) -> String? {
        return copyMessages(sess: sess, xml: uids, folderID: "")
    }

    class func updateMessages(sess: UnsafeMutableRawPointer, xml uids: String, isRead: Bool = true) -> String? {
        guard let uidsData = packCString(original: uids) else { return nil }
        let isReadData: UInt64 = isRead ? 1 : 0
        let start = Date()
        guard let resultCString = czews_update_message(sess, [UInt8](uidsData), isReadData, sendRetryCount) else { return nil }
        let result = String(cString: resultCString)
        czews_free(resultCString)
        return result
    }
    
    class func deleteMessages(sess: UnsafeMutableRawPointer, xml uids: String, hardDelete: Bool = false) -> String? {
        guard let uidsData = packCString(original: uids) else { return nil }
        let hardDeleteData: UInt64 = hardDelete ? 1 : 0
        let start = Date()
        guard let resultCString = czews_delete_messages(sess, [UInt8](uidsData), hardDeleteData, sendRetryCount) else { return nil }
        let result = String(cString: resultCString)
        czews_free(resultCString)
        return result
    }
    
    class func downloadAttachment(sess: UnsafeMutableRawPointer, attId: String, callbackId: UInt64 = 5000000) -> String? {
        guard let attIdData = packCString(original: attId) else { return nil }
        let start = Date()
        guard let resultCString = czews_download_attachment(sess, [UInt8](attIdData), callbackId, readRetryCount) else { return nil }
        let result = String(cString: resultCString)
        czews_free(resultCString)
        return result
    }
    
    class func resolveNames(sess: UnsafeMutableRawPointer, name: String) -> String? {
        guard let dataPack = packCString(original: name) else { return nil }
        let start = Date()
        guard let resultCString = czews_resolve_names(sess, [UInt8](dataPack), readRetryCount) else { return nil }
        let result = String(cString: resultCString)
        czews_free(resultCString)
        return result
    }
    
    class func downloadProgress(sess: UnsafeMutableRawPointer, callbackId: UInt64) -> UInt64 {
        let result = czews_download_progress(sess, callbackId)
        return result
    }
    
    // https://git.yixindev.net:888/mail-authority/CZews-cpp/blob/chanzhi/platform/message.xml
    class func sendMessage(sess: UnsafeMutableRawPointer, xml message: String ) -> String? {
        guard let messageData = packCString(original: message) else { return nil }
        let start = Date()
        guard let resultCString = czews_send_message(sess, [UInt8](messageData), sendRetryCount) else { return nil }
        let result = String(cString: resultCString)
        czews_free(resultCString)
        return result
    }
    
    class func subscribe(sess: UnsafeMutableRawPointer) -> String? {
        let freq = UInt64(12)
        guard let urlData = packCString(original: "http://apidev.chirpmailapp.com/exchange/callback?id=123") else { return nil }
        let start = Date()
        guard let resultCString = czews_subscribe(sess, freq, [UInt8](urlData), readRetryCount) else { return nil }
        let result = String(cString: resultCString)
        czews_free(resultCString)
        return result
    }
    
    class func cancelAllRequests() {
        czews_cancel_all_requests()
    }
}
