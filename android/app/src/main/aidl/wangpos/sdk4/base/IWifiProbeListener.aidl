// IWifiprobeListener.aidl
package wangpos.sdk4.base;

// Declare any non-default types here with import statements

interface IWifiProbeListener {
    /**
     * Demonstrates some basic types that you can use as parameters
     * and return wifiprobe data in AIDL.
     */
     void callBackProbeData(in String data);
}
