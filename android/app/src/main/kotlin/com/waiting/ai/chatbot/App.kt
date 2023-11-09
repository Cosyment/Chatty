package com.waiting.ai.chatbot

import android.app.Application
import com.umeng.commonsdk.UMConfigure

class App : Application() {
    override fun onCreate() {
        super.onCreate()
//        UMConfigure.setLogEnabled(true)
//        UMConfigure.preInit(this, "64979b89a1a164591b38ceda", "official")
        UMConfigure.submitPolicyGrantResult(this, true)
    }
}