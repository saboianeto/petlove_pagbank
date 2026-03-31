import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PagbankTapOnConfig {
  PagbankTapOnConfig._();

  static final PagbankTapOnConfig instance = PagbankTapOnConfig._();

  String? apiKey;
  String? partnerId;
  bool sandbox = true;

  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;

  void configure({
    required String apiKey,
    String? partnerId,
    bool sandbox = true,
  }) {
    this.apiKey = apiKey;
    this.partnerId = partnerId;
    this.sandbox = sandbox;
  }
}

class PagbankTapOnResponse {
  final bool success;
  final String message;
  final String? transactionId;

  PagbankTapOnResponse({
    required this.success,
    required this.message,
    this.transactionId,
  });
}

class PagbankTapOnService {
  PagbankTapOnService._();
  static final PagbankTapOnService instance = PagbankTapOnService._();

  static const MethodChannel _channel = MethodChannel(
    'petlove_pagbank/pagbank_tapon',
  );

  Future<bool> isTapOnAvailable() async {
    try {
      final bool available = await _channel.invokeMethod('isTapOnAvailable');
      return available;
    } on PlatformException {
      return false;
    }
  }

  Future<PagbankTapOnResponse> startCreditPayment({
    required String amount,
    int installments = 1,
  }) async {
    final config = PagbankTapOnConfig.instance;
    if (!config.isConfigured) {
      return PagbankTapOnResponse(
        success: false,
        message: 'Configuração TAP ON não definida.',
      );
    }

    final payload = {
      'apiKey': config.apiKey,
      'partnerId': config.partnerId,
      'amount': amount,
      'installments': installments,
      'type': 'CREDIT',
      'sandbox': config.sandbox,
    };

    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'startTapOnPayment',
        payload,
      );

      final status = (result?['status'] ?? '').toString().toLowerCase();
      final message =
          result?['message']?.toString() ?? 'Resposta TAP ON indisponível';

      if (status == 'success') {
        return PagbankTapOnResponse(
          success: true,
          message: message,
          transactionId: result?['transactionId']?.toString(),
        );
      }

      if (status == 'canceled' || status == 'cancelled') {
        return PagbankTapOnResponse(
          success: false,
          message: 'Pagamento cancelado: $message',
        );
      }

      return PagbankTapOnResponse(
        success: false,
        message: 'Falha TAP ON: $message',
      );
    } on PlatformException catch (e) {
      return PagbankTapOnResponse(
        success: false,
        message: e.message ?? 'Erro TAP ON',
      );
    }
  }

  Future<void> configureFromToasts({
    required String apiKey,
    String? partnerId,
    bool sandbox = true,
  }) async {
    PagbankTapOnConfig.instance.configure(
      apiKey: apiKey,
      partnerId: partnerId,
      sandbox: sandbox,
    );
  }
}
