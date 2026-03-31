package com.example.petlove_pagbank

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "petlove_pagbank/pagbank_tapon"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isTapOnAvailable" -> {
                    val hasTapOn = packageManager.getLaunchIntentForPackage("br.com.pagseguro.tapon") != null
                    result.success(hasTapOn)
                }
                "startTapOnPayment" -> {
                    val amount = call.argument<String>("amount") ?: "0"
                    val apiKey = call.argument<String>("apiKey")
                    val installments = call.argument<Int>("installments") ?: 1

                    // Montar URL/Intent de acordo com documentação actual TAP ON (única referência de exemplo abaixo)
                    val uri = Uri.parse("tapon://pagbank/payment?type=credit&amount=$amount&installments=$installments")
                    val intent = Intent(Intent.ACTION_VIEW, uri)

                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        val response = mapOf("status" to "success", "transactionId" to "pending")
                        result.success(response)
                    } else {
                        result.success(mapOf("status" to "failure", "message" to "TAP ON não encontrado"))
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}

