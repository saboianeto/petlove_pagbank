package com.example.petlove_pagbank

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import wangpos.sdk4.base.IBaseService

class MainActivity : FlutterActivity() {
    private val CHANNEL = "wangpos_printer"
    private var baseService: IBaseService? = null
    private var pendingResult: MethodChannel.Result? = null
    private var pendingArgs: Map<String, String>? = null

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
                val args = mapOf(
                    "codigo"    to (call.argument<String>("codigo") ?: ""),
                    "valor"     to (call.argument<String>("valor") ?: ""),
                    "tipo"      to (call.argument<String>("tipo") ?: ""),
                    "dataHora"  to (call.argument<String>("dataHora") ?: "")
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
    }

    private fun bindWangPos() {
        val intent = Intent("wangpos.sdk4.base.service.BaseService").apply {
            setPackage("wangpos.sdk4.base")
        }
        bindService(intent, serviceConnection, Context.BIND_AUTO_CREATE)
    }

    private fun doPrint(args: Map<String, String>, result: MethodChannel.Result) {
        try {
            val service = baseService ?: run {
                result.error("SERVICE_NOT_BOUND", "Servico WangPOS nao conectado.", null)
                return
            }

            val codigo   = args["codigo"] ?: ""
            val valor    = args["valor"] ?: ""
            val tipo     = args["tipo"] ?: ""
            val dataHora = args["dataHora"] ?: ""

            // fontSize: 24=normal, align: 0=left, 1=center, 2=right
            service.printInit()
            service.printString("================================", 24, 1, false, false)
            service.printString("        petlove", 28, 1, true, false)
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

    override fun onDestroy() {
        super.onDestroy()
        try { unbindService(serviceConnection) } catch (_: Exception) {}
    }
}
