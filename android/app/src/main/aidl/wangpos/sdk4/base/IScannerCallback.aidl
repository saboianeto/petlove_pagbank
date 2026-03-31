// IScannerCallback.aidl
package wangpos.sdk4.base;

// Declare any non-default types here with import statements

interface IScannerCallback {
    /**
     * Demonstrates some basic types that you can use as parameters
     * and return values in AIDL.
     */

    int resultCallback(inout byte[] RecvBuff,  int len);
}