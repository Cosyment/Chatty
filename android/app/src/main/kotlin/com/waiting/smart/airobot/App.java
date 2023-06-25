package com.waiting.smart.airobot;

import android.util.Log;

import io.flutter.app.FlutterApplication;

import com.umeng.commonsdk.UMConfigure;

public class App extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        Log.i("UMENG", "--->>> FlutterApplication: onCreate enter");
        UMConfigure.setLogEnabled(true);
        UMConfigure.preInit(this, "64979b89a1a164591b38ceda", "Umeng");
    }
}
