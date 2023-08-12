//
//  ewsc.h
//  ews
//
//  Created by Sean Zhu on 2018/10/9.
//  Copyright © 2018 Chirpeur. All rights reserved.
//

#ifndef EWSC_H_
#define EWSC_H_
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Tip: all (unsigned char*) passed in or out from the APIs are C-style strings.
// the caller needs to make sure the passed in strings are null-terminated.
// the returned string from an API call are promised to be null-terminated.
// the returned string needs to be freed by czews_free() from the caller.

// czews_startup() and czews_teardown() are not thread-safe and must be called from main (UI) thread.
// initialize the czews library, should be called *ONLY* once at the very beginning.
void czews_startup();
// frees the resource used by czews library, should be called *ONLY* once at the very end.
void czews_teardown();

// The following APIs are thread-safe.
// creates a new ews session with given credentials.
// domain can be set to null or empty string if not used.
void *czews_new_session(const unsigned char *ews_uri, const unsigned char *email_address, 
                        const unsigned char *password, const unsigned char *domain);

// delete an ews session once it's not needed.
// note that the call to czews_del_session will return immediatelly and the session will be freed 
// in a background thread after all its pending operations are completed or canceled.
void czews_del_session(void *sess);

// frees a memory block previously returned by the following APIs.
void czews_free(void *ptr);

// cancel all ongoing requests
void czews_cancel_all_requests();

// discover the ews server address with given credentials.
// domain can be set to null or empty string if not used.
// returns null on failure.
unsigned char *czews_discover(const unsigned char *email_address, const unsigned char *password, 
                              const unsigned char *domain, uint64_t retries);

// discover the ews server and smtp address with given credentials.
// domain can be set to null or empty string if not used.
// returns json:
// {
// "server_url": "outlook.office365.com",
// "smtp_address": "seanz@chirpeur.com",
// "error": true/false,
// "auth_error": false
//}
unsigned char *czews_discover_ex(const unsigned char *email_address, const unsigned char *password, 
                              const unsigned char *domain, uint64_t retries);

// returns the primary smtp address of current session
// the primary smtp address doesn't have to be the mail address used to create session
// other people will see this primary smtp address when receiving emails from this session.
// the return value is the primary address (successfull response) or empty string (error or account not verified)
// i.e. mailchat@wifi.com
// note that this api call will return immediately, and it can be called from any thread.
unsigned char *czews_get_smtp_address(const unsigned char *email_address);

void czews_set_proxy(void *sess, const unsigned char *address, const unsigned char *authorization);

// the return value from the following APIs are defined as follows:
// * null: operation is canceled, all queued but not started operations with this session need to be cancelled.
// * json: 
// {
// "name": value,
// "error": true/false,
// "auth_error": true/false,
// "error_message": "error message (if available)"
// }
// name and value vary depending on the particular API.

// check whether an account is valid.
// returns: name=inbox, value=id of inbox
// the caller has no necessary to store the inbox id, it's here just to indicate success or failure.
unsigned char *czews_check_account(void *sess, uint64_t retries);

// get the folder list
// returns: name=folders, value=[folder], folder={displayName, totalCount, unreadCount, eid, ekey, type}
/*
{
"folders":[
{
"displayName":"Inbox",
"totalCount":12,
"unreadCount":3,
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwAuAAAAAAByqBsH/R8fTKfgnfle3gOgAQBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAAA=",
"ekey":"AQAAABYAAABn8bZhgDO2S7wC0k+26fa3AABCi7CV",
"type":"inbox"
},
{
"displayName":"Sent Items",
"totalCount":1,
"unreadCount":0,
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwAuAAAAAAByqBsH/R8fTKfgnfle3gOgAQBn8bZhgDO2S7wC0k+26fa3AAAAAAEJAAA=",
"ekey":"AQAAABYAAABn8bZhgDO2S7wC0k+26fa3AAAAAACD",
"type":"sent_items"
},
{
"displayName":"Deleted Items",
"totalCount":1,
"unreadCount":0,
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwAuAAAAAAByqBsH/R8fTKfgnfle3gOgAQBn8bZhgDO2S7wC0k+26fa3AAAAAAEKAAA=",
"ekey":"AQAAABYAAABn8bZhgDO2S7wC0k+26fa3AAAAAACE",
"type":"deleted_items"
},
{
"displayName":"Drafts",
"totalCount":0,
"unreadCount":0,
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwAuAAAAAAByqBsH/R8fTKfgnfle3gOgAQBn8bZhgDO2S7wC0k+26fa3AAAAAAEPAAA=",
"ekey":"AQAAABYAAABn8bZhgDO2S7wC0k+26fa3AAAAAACJ",
"type":"drafts"
},
{
"displayName":"Junk Email",
"totalCount":0,
"unreadCount":0,
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwAuAAAAAAByqBsH/R8fTKfgnfle3gOgAQBn8bZhgDO2S7wC0k+26fa3AAAAAAEUAAA=",
"ekey":"AQAAABYAAABn8bZhgDO2S7wC0k+26fa3AAAAAACY",
"type":"junk_email"
},
{
"displayName":"Archive",
"totalCount":0,
"unreadCount":0,
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwAuAAAAAAByqBsH/R8fTKfgnfle3gOgAQBn8bZhgDO2S7wC0k+26fa3AAAAAAFZAAA=",
"ekey":"AQAAABYAAABn8bZhgDO2S7wC0k+26fa3AAAAAASG",
"type":"unspecified"
},
{
"displayName":"Sub folder of Inbox",
"totalCount":1,
"unreadCount":0,
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwAuAAAAAAByqBsH/R8fTKfgnfle3gOgAQBn8bZhgDO2S7wC0k+26fa3AAA+u9CAAAA=",
"ekey":"AQAAABYAAABn8bZhgDO2S7wC0k+26fa3AAA+uocx",
"type":"sub_inbox"
}
],
"error":false,
"auth_error":false
}
*/
unsigned char *czews_get_folders(void *sess, uint64_t retries);

// get uids newer than given uid. set base_uid to 0 for bootstrap.
// returns: name=uids, value=[uid], uid={eid, ekey, uid, size}
/*
{
"uids":[
{
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AABCjVgaAAA=",
"ekey":"CQAAABYAAABn8bZhgDO2S7wC0k+26fa3AABCi6br",
"uid":340561268083,
"size":36135
},
{
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AABCjVgYAAA=",
"ekey":"CQAAABYAAABn8bZhgDO2S7wC0k+26fa3AABCi6L3",
"uid":340554809491,
"size":36387
}
],
"error":false,
"auth_error":false
}
*/
unsigned char *czews_get_uids(void *sess, const unsigned char *folder_id, uint64_t base_uid, uint64_t retries);

// get messages with given uids
// uids_xml:
/*
<UIDs>
<UID eid="AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAA+u+ImAAA=" ekey="CQAAAA=="/>
<UID eid="AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAA+u+IlAAA=" ekey="CQAAAA=="/>
<UID eid="AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAAdY4uYAAA=" ekey="CQAAAA=="/>
</UIDs>
*/
// returns: name=messages, value=[message], message=......
// If multiple items were preovided in uids_xml, the returned items may be a subset of given items (- failed items won't be returned).
// Recommended batch (UID) count: ~50
/*
The folowing json shows response with 2 messages. The first message comes with an attachment.
{
"messages":[
{
"from":{
"name":"seanz",
"address":"seanz@yeetalk.net"
},
"sender":{
"name":"",
"address":""
},
"to":[
{
"name":"Test All",
"address":"testa@chirpeur.com"
}
],
"subject":"Re: Hello",
"body":{
"type":"HTML",
"truncated":false,
"content":"<html>\r\n<head>\r\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\r\n</head>\r\n<body>\r\n<code name=\"chirp-audio\"></code>\r\n</body>\r\n</html>\r\n"
},
"timestamp":{"epoch":1540205953,"str":"2018-10-22T10:59:13.367Z"},
"importance":"Normal",
"read":false,
"attachments":[
{
"id":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAA+u+ImAAABEgAQAL+UErynAWBKgc37BBIJSc0=",
"name":"audio.m4a",
"contentType":"audio/mp4",
"size":86256,
"inline":false
}
],
"id":{
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAA+u+ImAAA=",
"ekey":"CQAAABYAAABn8bZhgDO2S7wC0k+26fa3AAA+uo02"
},
"inReplyTo":"",
"messageId":"<M4RVSM6QV5ATiL3IWJviex6Ob.1540205940013@chirpeur.tech>+E4E492B73C61F6B9",
"references":"<a1a9e9c4-396f-4d14-ad8a-a3b036e12466@iPhone> <M4RVSM6QV5ATiL3IWJviex6Ob.1540205940013@chirpeur.tech>"
},
{
"from":{
"name":"seanz",
"address":"seanz@yeetalk.net"
},
"sender":{
"name":"",
"address":""
},
"to":[
{
"name":"Test All",
"address":"testa@chirpeur.com"
}
],
"subject":"Hello",
"body":{
"type":"HTML",
"truncated":false,
"content":"<html>\r\n<head>\r\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\r\n</head>\r\n<body>\r\nHappy&nbsp;\r\n</body>\r\n</html>\r\n"
},
"timestamp":{"epoch":1540205841,"str":"2018-10-22T10:57:21.544Z"},
"importance":"Normal",
"read":false,
"id":{
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAA+u+IlAAA=",
"ekey":"CQAAABYAAABn8bZhgDO2S7wC0k+26fa3AAA+uo0R"
},
"inReplyTo":"",
"messageId":"<a1a9e9c4-396f-4d14-ad8a-a3b036e12466@iPhone>+85636B7B63A9D399",
"references":""
}
],
"error":false,
"auth_error":false
}
*/
unsigned char *czews_get_messages(void *sess, const unsigned char *uids_xml, uint64_t retries);

/*
copy messages to another folder.
uids_xml are the same as update_message.
if to_folder is nil, messages will be copied to inbox.

returns the same format as update_message, except the element name is "copied".
*/
unsigned char *czews_copy_message(void *sess, const unsigned char *uids_xml, const unsigned char *to_folder, uint64_t retries);

// update messages' read status
// is_read: 0 (unread)/1 (read)
// returns: name=changes, value=[change]
/*
{
"changes":[
{
"oldId":{
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAA+u+ImAAA=",
"ekey":"CQAAAA=="
},
"newId":{
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAA+u+ImAAA=",
"ekey":"CQAAAA=="
}
},
{
"oldId":{
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAA+u+IlAAA=",
"ekey":"CQAAAA=="
},
"newId":{
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAA+u+IlAAA=",
"ekey":"CQAAAA=="
}
}
],
"error":false,
"auth_error":false
}
The caller need to update the eid & ekey in database with new eid & ekey.
If multiple items were preovided in uids_xml, the returned items may be a subset of given items (- failed items won't be returned).
*/
unsigned char *czews_update_message(void *sess, const unsigned char *uids_xml, uint64_t is_read, uint64_t retries);

// delete messages
// hard_delete: 0 - soft delete (move to Deleted Items folder), 1 - hard delete (Permanentlly Deleted)
// returns name=deleted, value=[item ids]
/*
{
"changes":[
{
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAA+u+ImAAA=",
"ekey":"CQAAAA=="
},
{
"eid":"AAMkADg0MTFhOTczLTAzZGQtNGJlOC04ZGYxLWQ2ZTA5MTJiOWY0YwBGAAAAAAByqBsH/R8fTKfgnfle3gOgBwBn8bZhgDO2S7wC0k+26fa3AAAAAAEMAABn8bZhgDO2S7wC0k+26fa3AAA+u+IlAAA=",
"ekey":"CQAAAA=="
}
],
"error":false,
"auth_error":false
}
*/
unsigned char *czews_delete_messages(void *sess, const unsigned char *uids_xml, uint64_t hard_delete, uint64_t retries);

// download an attachment
// att_id=previously returned attachment id
// callback_id=session-wide unique integer, can be used to query download progress later.
// returns: name=attachment, value={name, mime-type, size, data}, size=sizeof(data), data=base64(raw data)
/*
{
"attachment":{
"id":"ddklsjfdasldkjfasdlfjasdklfjas",
"name":"audio.m4a",
"contentType":"audio/mp4",
"contentId":"",
"contentLocation":"",
"size":114648,
"inline":false，
"content":"AAAAHGZ0eXBNNEEgAAAAAE00QSBtcDQyaXNvbQAABK1tb292AAAAbG12aGQAAAAA1......"
},
"error":false,
"auth_error":false
}
*/
unsigned char *czews_download_attachment(void *sess, const unsigned char *att_id, uint64_t callback_id, uint64_t retries);

// query the download progress of given callback_id
// returns:
// * 0: callback_id not valid or download hasn't started yet or error, the caller should do nothing after this point.
// * positive value: currently downloaded bytes (may be greater than the expected total size).
// note that the returned value may be smaller than previously returned values, i.e. 
// the first download attempt was interrupted and then the second attempt was issued.
uint64_t czews_download_progress(void *sess, uint64_t callback_id);

// send a message
// message_xml: null-terminated string, encoded message in xml, see message.xml for example.
// returns: name=message, value={eid, ekey, uid, size}
unsigned char *czews_send_message(void *sess, const unsigned char *message_xml, uint64_t retries);

unsigned char *czews_subscribe(void *sess, const uint64_t status_frequency, const unsigned char *url, uint64_t retries);

unsigned char *czews_find_unread_messages(void *sess, const unsigned char *timestamp, uint64_t retries);

/**
 * {
"mailboxes":[
{
"name":"\u6731\u70b3\u5bbd(zhubk)",
"address":"zhubk@zenmen.com"
},
{
"name":"\u6731\u6210\u521a(zhucg)",
"address":"zhucg@zenmen.com"
}
],
"error":false,
"auth_error":false,
"error_message":""
}
 * */
unsigned char *czews_resolve_names(void *sess, const unsigned char *name, uint64_t retries);

/*
sample output:
{
"subscription":{"subscription_id":"EABleDAxLnplbm1lbi5jb3JwEAAAAHL1PFn9yb5CrzP9LVrWLWf3YIns+pbWCBAAAAARzA4qmYIqQa2/SgUpO3gG","watermark":"AQAAAKKPbLZfRohAnOYUi+TLiyf75TEEAAAAAAA="},
"error":false,
"auth_error":false
}

"error" (and "auth_error") can be true on error.
*/
void *czews_subscribe_raw(const unsigned char *ews_uri, const unsigned char *email_address, 
                        const unsigned char *password, const unsigned char *domain,
                        const uint64_t status_frequency, const unsigned char *url);
// with devicehost param
void *czews_subscribe_raw_dh(const unsigned char *ews_uri, const unsigned char *email_address, 
                        const unsigned char *password, const unsigned char *domain,
                        const unsigned char *devicehost,
                        const uint64_t status_frequency, const unsigned char *url);

/*
sample output:
{
"messages":[
{
"from":{
"name":"HR",
"address":"hr@chirpeur.com"
},
"sender":{
"name":"",
"address":""
},
"to":[
{
"name":"Sean Zhu",
"address":"seanz@chirpeur.com"
}
],
"subject":"\u8f6c\u53d1: \u5218\u96f7\u9e4f | 6\u5e74\uff0c\u5e94\u8058 Android | \u4e0a\u6d77 20k-35k\u3010Boss\u76f4\u8058\u3011",
"body":{
"type":"Text",
"truncated":false,
"content":""
},
"timestamp":{"epoch":1550720091,"str":"2019-02-21T03:34:51.547Z"},
"importance":"Normal",
"read":false,
"attachments":[
{
"id":"AAMkADNjYWYxNDNiLThjOTQtNGI2Ny1hOWQzLWRkNWI3NDg0ZmZlOABGAAAAAACIFWsDwElKT6wzAgwtDwVfBwAP9hY2+Yx6SbdsojNJqMgIAAAAAAEMAAAP9hY2+Yx6SbdsojNJqMgIAACP5bL1AAABEgAQAGff0cSvsGhEv+N1qHLuFeI=",
"name":"\u3010Android  \u4e0a\u6d77 20k-35k\u3011\u5218\u96f7\u9e4f 6\u5e74.doc",
"contentType":"application/octet-stream",
"contentId":"8FB1DAA96243B046B9AD884973DD71A6@apcprd06.prod.outlook.com",
"contentLocation":"",
"size":35094,
"inline":false
}
],
"id":{
"eid":"AAMkADNjYWYxNDNiLThjOTQtNGI2Ny1hOWQzLWRkNWI3NDg0ZmZlOABGAAAAAACIFWsDwElKT6wzAgwtDwVfBwAP9hY2+Yx6SbdsojNJqMgIAAAAAAEMAAAP9hY2+Yx6SbdsojNJqMgIAACP5bL1AAA=",
"ekey":"CQAAABYAAAAP9hY2+Yx6SbdsojNJqMgIAACP1jo3"
},
"inReplyTo":"<1550719960016_35253_17687_4453.sc-10_9_51_122-inbound0$hr@chirpeur.com>",
"messageId":"<SG2PR0601MB204840B032EE4FF8A27C8C9BAD7E0@SG2PR0601MB2048.apcprd06.prod.outlook.com>",
"references":"<1550719960016_35253_17687_4453.sc-10_9_51_122-inbound0$hr@chirpeur.com>"
}
],
"latest_timestamp":"2019-02-20T06:06:45.419Z",
"error":false,
"auth_error":false
}

"error" (and "auth_error") can be true on error.
"latest_timestamp" may be empty on error.
*/
void *czews_find_unread_messages_raw(const unsigned char *ews_uri, const unsigned char *email_address, 
                        const unsigned char *password, const unsigned char *domain,
                        const unsigned char *timestamp);

// with devicehost param
void *czews_find_unread_messages_raw_dh(const unsigned char *ews_uri, const unsigned char *email_address, 
                        const unsigned char *password, const unsigned char *domain,
                        const unsigned char *devicehost,
                        const unsigned char *timestamp);

#ifdef __cplusplus
}
#endif

#endif /* EWSC_H_ */
