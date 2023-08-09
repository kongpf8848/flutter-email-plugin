package com.chirpeur.chirpmail.jniutil;

public class JniUtils {

    static {
        System.loadLibrary("jni_chirp_mail");
    }

    /**
     * 应用关闭时清理
     */
    public static void clearJni() {
        JniUtils.tearDown();
        JniUtils.czcryptoCleanup();
    }

    //exchange
    public static native void startUp(String ca_bundle, int debug);

    public static native void tearDown();

    public static native long newSession(String uri, String email_address, String password, String domain);

    public static native void delSession(long session);

    public static native String discover(String email_address, String password, String domain, long retries);

    public static native String discoverEx(String email_address, String password, String domain, long retries);

    public static native String getSmtpAddress(String email_address);

    public static native void setProxy(long session, String address, String authorization);

    public static native String checkAccount(long session, long retries);

    public static native String getFolders(long session, long retries);

    public static native String getUids(long session, String folder_id, long base_uid, long retries);

    public static native byte[] getMessages(long session, String uids_xml, long retries);

    public static native String updateMessages(long session, String uids_xml, long is_read, long retries);

    public static native String deleteMessages(long session, String uids_xml, long hard_delete, long retries);

    public static native String downloadAttachment(long session, String att_id, long callback_id, long retries);

    public static native long downloadProgress(long session, long callback_id);

    public static native String sendMessage(long session, String message_xml, long retries);

    public static native String resolveNames(long session, String name, long retries);

    //interface encrypt decrypt
    public static native void czcryptoInit();

    public static native void czcryptoCleanup();

    public static native String czcryptoEncrypt(String deviceId, String in, int len);

    public static native String czcryptoDecrypt(String deviceId, String in, int len);

    public static native String czcryptoEncryptFile(String salt, String fromFilePath, String toFilePath);

    public static native String czcryptoDecryptFile(String salt, String fromFilePath, String toFilePath);

    public static native byte[] czcryptoEncryptByte(String salt, byte[] in, long len);

    public static native byte[] czcryptoDecryptByte(String salt, byte[] in, long len);

    //hash hash_r
    public static native String czuuidHashR(String uuid, int len);

    //wellknown
    public static native void wellKnownLoad(String pathToList);

    public static native long wellKnownTest(String emailAddress);
}