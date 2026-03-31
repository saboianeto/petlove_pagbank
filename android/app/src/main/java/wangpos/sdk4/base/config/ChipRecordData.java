package wangpos.sdk4.base.config;

import android.os.Parcel;
import android.os.Parcelable;

public class ChipRecordData implements Parcelable {
    public static final Creator<ChipRecordData> CREATOR = new Creator<ChipRecordData>() {
        @Override public ChipRecordData createFromParcel(Parcel source) { return new ChipRecordData(source); }
        @Override public ChipRecordData[] newArray(int size) { return new ChipRecordData[size]; }
    };
    public ChipRecordData() {}
    protected ChipRecordData(Parcel in) {}
    @Override public int describeContents() { return 0; }
    @Override public void writeToParcel(Parcel dest, int flags) {}
}
