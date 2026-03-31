package wangpos.sdk4.base.config;

import android.os.Parcel;
import android.os.Parcelable;

public class ScanConfig implements Parcelable {
    public static final Creator<ScanConfig> CREATOR = new Creator<ScanConfig>() {
        @Override public ScanConfig createFromParcel(Parcel source) { return new ScanConfig(source); }
        @Override public ScanConfig[] newArray(int size) { return new ScanConfig[size]; }
    };
    public ScanConfig() {}
    protected ScanConfig(Parcel in) {}
    @Override public int describeContents() { return 0; }
    @Override public void writeToParcel(Parcel dest, int flags) {}
}
