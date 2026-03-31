package com.example.petlove_pagbank

import android.app.Activity
import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.IBinder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import wangpos.sdk4.base.IBaseService

class MainActivity : FlutterActivity() {
    private val CHANNEL = "wangpos_printer"
    private val TAPON_CHANNEL = "petlove_pagbank/pagbank_tapon"
    private val TAPON_REQUEST_CODE = 9012
    private var baseService: IBaseService? = null
    private var pendingResult: MethodChannel.Result? = null
    private var pendingArgs: Map<String, Any?>? = null
    private var pendingTapOnResult: MethodChannel.Result? = null

    private val serviceConnection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            baseService = IBaseService.Stub.asInterface(service)
            pendingArgs?.let { args ->
                doPrint(args, pendingResult!!)
                pendingArgs = null
                pendingResult = null
            }
        }
        override fun onServiceDisconnected(name: ComponentName?) { baseService = null }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        bindWangPos()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "printReceipt") {
                val args: Map<String, Any?> = mapOf(
                    "codigo"    to call.argument<String>("codigo"),
                    "valor"     to call.argument<String>("valor"),
                    "tipo"      to call.argument<String>("tipo"),
                    "dataHora"  to call.argument<String>("dataHora"),
                    "logoBytes" to call.argument<ByteArray>("logoBytes")
                )
                val service = baseService
                if (service != null) {
                    doPrint(args, result)
                } else {
                    pendingArgs = args
                    pendingResult = result
                    bindWangPos()
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TAPON_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isTapOnAvailable" -> {
                    val exists = packageManager.getLaunchIntentForPackage("br.com.pagseguro.tapon") != null
                    result.success(exists)
                }
                "startTapOnPayment" -> {
                    if (pendingTapOnResult != null) {
                        result.error("TAPON_IN_PROGRESS", "Já existe uma operação TAP ON em andamento", null)
                        return@setMethodCallHandler
                    }

                    val amount = call.argument<String>("amount") ?: "0"
                    val installments = call.argument<Int>("installments") ?: 1
                    val apiKey = call.argument<String>("apiKey") ?: ""
                    val partnerId = call.argument<String>("partnerId")

                    val uriBuilder = Uri.parse("tapon://pagbank/payment").buildUpon()
                    uriBuilder.appendQueryParameter("type", "credit")
                    uriBuilder.appendQueryParameter("amount", amount)
                    uriBuilder.appendQueryParameter("installments", installments.toString())
                    uriBuilder.appendQueryParameter("apiKey", apiKey)
                    partnerId?.let { uriBuilder.appendQueryParameter("partnerId", it) }
                    uriBuilder.appendQueryParameter("sandbox", call.argument<Boolean>("sandbox")?.toString() ?: "true")

                    val intent = Intent(Intent.ACTION_VIEW, uriBuilder.build())

                    if (intent.resolveActivity(packageManager) != null) {
                        pendingTapOnResult = result
                        startActivityForResult(intent, TAPON_REQUEST_CODE)
                    } else {
                        result.success(mapOf("status" to "failure", "message" to "TAP ON não encontrado"))
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun bindWangPos() {
        val intent = Intent("wangpos.sdk4.base.service.BaseService").apply {
            setPackage("wangpos.sdk4.base")
        }
        bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
    }

    private fun doPrint(args: Map<String, Any?>, result: MethodChannel.Result) {
        try {
            val service = baseService ?: run {
                result.error("SERVICE_NOT_BOUND", "Servico WangPOS nao conectado.", null)
                return
            }

            val codigo    = args["codigo"]    as? String ?: ""
            val valor     = args["valor"]     as? String ?: ""
            val tipo      = args["tipo"]      as? String ?: ""
            val dataHora  = args["dataHora"]  as? String ?: ""
            val logoBytes = args["logoBytes"] as? ByteArray

            service.printInit()

            // Logo
            if (logoBytes != null) {
                val logoBitmap = BitmapFactory.decodeByteArray(logoBytes, 0, logoBytes.size)
                if (logoBitmap != null) {
                    service.printImage(logoBitmap, logoBitmap.height, 1) // 1 = center
                }
            }

            // Corpo do comprovante
            service.printString("================================", 24, 1, false, false)
            service.printString("  COMPROVANTE DE PAGAMENTO", 20, 1, false, false)
            service.printString("================================", 24, 1, false, false)
            service.printString("Codigo  : #$codigo", 22, 0, false, false)
            service.printString("Data    : $dataHora", 22, 0, false, false)
            service.printString("Tipo    : $tipo", 22, 0, false, false)
            service.printString("Status  : APROVADO", 22, 0, false, false)
            service.printString("--------------------------------", 22, 1, false, false)
            service.printString("TOTAL   : R$ $valor", 26, 0, true, false)
            service.printString("================================", 24, 1, false, false)
            service.printPaper(5)
            service.printFinish()

            result.success("Comprovante impresso com sucesso!")
        } catch (e: Exception) {
            result.error("PRINT_ERROR", "Erro ao imprimir: ${e.message}", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == TAPON_REQUEST_CODE) {
            pendingTapOnResult?.let { result ->
                when (resultCode) {
                    Activity.RESULT_OK -> result.success(
                        mapOf(
                            "status" to "success",
                            "message" to "Pagamento TAP ON aprovado",
                            "transactionId" to (data?.getStringExtra("transactionId") ?: "")
                        )
                    )
                    Activity.RESULT_CANCELED -> result.success(
                        mapOf(
                            "status" to "canceled",
                            "message" to "Pagamento TAP ON cancelado pelo usuário"
                        )
                    )
                    else -> result.success(
                        mapOf(
                            "status" to "failure",
                            "message" to "Pagamento TAP ON finalizado com código $resultCode"
                        )
                    )
                }
                pendingTapOnResult = null
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        try { unbindService(serviceConnection) } catch (_: Exception) {}
    }
}
