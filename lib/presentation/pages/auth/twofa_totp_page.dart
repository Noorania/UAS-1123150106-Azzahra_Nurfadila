import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/auth/otp_bloc.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../../core/services/deeplink_callback_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/code_input.dart';
import '../../widgets/feature_icon.dart';

class TwoFATotpPage extends StatefulWidget {
  final String mode;
  // Diisi hanya saat mode == 'payment' — data transfer/pembayaran yang
  // sedang menunggu OTP (amount, description, kind, dll dari PinPage).
  final Map<String, dynamic>? flowData;

  const TwoFATotpPage({super.key, this.mode = 'login', this.flowData});

  @override
  State<TwoFATotpPage> createState() => _TwoFATotpPageState();
}

class _TwoFATotpPageState extends State<TwoFATotpPage> {
  String _step = 'loading'; // loading, scan, code
  String _code = '';
  bool _hasError = false;
  bool _copied = false;
  bool _busy = false;
  int _ttl = 30;
  Timer? _ticker;

  bool get _isPaymentMode => widget.mode == 'payment';

  @override
  void initState() {
    super.initState();
    if (widget.mode == 'setup') {
      context.read<OtpBloc>().add(OtpRegisterTotp());
    } else {
      setState(() => _step = 'code');
    }
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _ttl = _ttl <= 1 ? 30 : _ttl - 1);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _onCodeChanged(String v) {
    setState(() {
      _code = v;
      _hasError = false;
    });
    if (v.length == 6) {
      if (_isPaymentMode) {
        // PENTING: untuk mode pembayaran, kita TIDAK memanggil OtpVerifyTotp
        // (itu untuk verifikasi TOTP saat login/setup 2FA). Kode TOTP yang
        // user masukkan di sini langsung dikirim sebagai otpCode ke endpoint
        // transfer — backend yang akan memvalidasi kode TOTP tersebut saat
        // memproses transfer. Ini yang menggantikan otpCode hardcode '000000'
        // yang jadi penyebab bug sebelumnya.
        _submitPayment(v);
      } else {
        context.read<OtpBloc>().add(OtpVerifyTotp(v));
      }
    }
  }

  void _submitPayment(String code) {
    final flow = widget.flowData;
    if (flow == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pembayaran tidak ditemukan, silakan ulangi.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _busy = true);

    final kind = flow['kind'] as String? ?? '';

    if (kind == 'transfer') {
      context.read<PaymentBloc>().add(PaymentTransferRequested(
            amount: (flow['amount'] as num).toDouble(),
            description: flow['note'] as String? ?? 'Transfer',
            otpCode: code,
            otpType: AppConstants.otpTypeTotp,
          ));
    } else if (kind == 'payment' || kind == 'deeplink') {
      context.read<PaymentBloc>().add(PaymentTransferRequested(
            amount: (flow['amount'] as num).toDouble(),
            description: flow['description'] as String? ?? 'Pembayaran QRIS',
            otpCode: code,
            otpType: AppConstants.otpTypeTotp,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener untuk mode login/setup (verifikasi TOTP biasa)
        BlocListener<OtpBloc, OtpState>(
          listener: (context, state) {
            if (_isPaymentMode) return; // payment mode tidak pakai OtpBloc
            if (state is OtpTotpSetup) {
              setState(() => _step = 'scan');
            } else if (state is OtpTotpEnabled || state is OtpVerified) {
              context.go('/home');
            } else if (state is OtpInvalid) {
              setState(() => _hasError = true);
              Future.delayed(const Duration(milliseconds: 650), () {
                if (mounted) setState(() { _code = ''; _hasError = false; });
              });
            } else if (state is OtpError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
              );
            }
          },
        ),
        // Listener untuk mode pembayaran (hasil transfer setelah OTP dikirim)
        BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (!_isPaymentMode) return; // mode lain tidak pakai listener ini
            final flow = widget.flowData;
            if (state is PaymentTransferSuccess) {
              final result = state.result;

              // Kirim callback balik ke app merchant (jrb_jewelry) via deeplink
              // jrbjewelry://payment-callback?status=success&... — ini yang
              // membawa fokus kembali ke app jrb_jewelry secara otomatis,
              // supaya user tidak "nyangkut" di app emoney setelah bayar.
              final callbackUrl = flow?['callbackUrl'] as String?;
              final reference = flow?['reference'] as String?;
              if (callbackUrl != null && callbackUrl.isNotEmpty) {
                DeeplinkCallbackService.notifySuccess(
                  callbackUrl: callbackUrl,
                  reference: reference,
                  transactionId: result.transactionId,
                );
              }

              context.go('/success', extra: {
                'title': 'Pembayaran berhasil',
                'subtitle': result.description,
                'amount': result.amount,
                'lines': [
                  ['Jumlah', CurrencyFormatter.format(result.amount)],
                  ['Saldo setelah', CurrencyFormatter.format(result.balanceAfter)],
                  ['Ref', 'DKG${result.transactionId}'],
                ],
              });
            } else if (state is PaymentInvalidOtp) {
              setState(() { _busy = false; _hasError = true; _code = ''; });
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) setState(() => _hasError = false);
              });
            } else if (state is PaymentInsufficientBalance) {
              setState(() => _busy = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saldo tidak mencukupi'),
                  backgroundColor: AppColors.red,
                ),
              );
            } else if (state is PaymentError) {
              setState(() => _busy = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(DkgIcons.arrowLeft, color: AppColors.ink),
                  onPressed: () {
                    if (_isPaymentMode) {
                      context.pop();
                    } else if (_step == 'code' && widget.mode == 'setup') {
                      setState(() => _step = 'scan');
                    } else {
                      context.go(widget.mode == 'setup' ? '/setup-2fa' : '/login');
                    }
                  },
                ),
              ),
              Expanded(
                child: _busy
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 18),
                            Text('Memproses pembayaran…',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate600,
                                )),
                          ],
                        ),
                      )
                    : BlocBuilder<OtpBloc, OtpState>(
                        builder: (context, state) {
                          if (!_isPaymentMode && state is OtpLoading && _step == 'loading') {
                            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                          }
                          if (!_isPaymentMode && _step == 'scan' && state is OtpTotpSetup) {
                            return _buildScanStep(state, context);
                          }
                          return _buildCodeStep(context);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanStep(OtpTotpSetup state, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
      child: Column(
        children: [
          const FeatureIcon(icon: DkgIcons.smartphone, tone: 'violet', size: 74, iconSize: 36),
          const SizedBox(height: 18),
          const Text('Hubungkan Authenticator',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.3,
              )),
          const SizedBox(height: 8),
          const Text(
            'Pindai QR ini dengan Google Authenticator, Authy, atau aplikasi sejenis.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.5, color: AppColors.slate500, height: 1.55),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppColors.shadowCard,
              border: Border.all(color: AppColors.line),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                Uri.parse(state.entity.qrCode).data!.contentAsBytes(),
                width: 172,
                height: 172,
                errorBuilder: (_, __, ___) => Container(
                  width: 172,
                  height: 172,
                  color: AppColors.bg,
                  child: const Center(child: Icon(Icons.qr_code_rounded, size: 80, color: AppColors.slate400)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Atau masukkan kunci manual',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate400,
                      letterSpacing: 0.5,
                    )),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        state.entity.secret,
                        softWrap: true,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: state.entity.secret));
                        setState(() => _copied = true);
                        Future.delayed(const Duration(milliseconds: 1400), () {
                          if (mounted) setState(() => _copied = false);
                        });
                      },
                      icon: Icon(_copied ? DkgIcons.check : DkgIcons.copy,
                          size: 17, color: _copied ? AppColors.green : AppColors.primary),
                      label: Text(_copied ? 'Tersalin' : 'Salin',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            color: _copied ? AppColors.green : AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Saya sudah memindai',
            onPressed: () => setState(() => _step = 'code'),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
      child: Column(
        children: [
          const FeatureIcon(icon: DkgIcons.smartphone, tone: 'violet', size: 74, iconSize: 36),
          const SizedBox(height: 18),
          const Text('Masukkan kode 6 digit',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              )),
          const SizedBox(height: 8),
          const Text('Buka aplikasi authenticator kamu dan masukkan kode yang sedang aktif.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.5, color: AppColors.slate500, height: 1.55)),
          const SizedBox(height: 28),
          AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            transform: _hasError ? (Matrix4.identity()..translate(8.0)) : Matrix4.identity(),
            child: CodeInput(value: _code, onChanged: _onCodeChanged, hasError: _hasError),
          ),
          if (_hasError) ...[
            const SizedBox(height: 12),
            const Text('Kode tidak cocok',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: AppColors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ],
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  value: _ttl / 30,
                  strokeWidth: 2.4,
                  backgroundColor: AppColors.line,
                  valueColor: const AlwaysStoppedAnimation(AppColors.violet),
                ),
              ),
              const SizedBox(width: 8),
              Text('Kode berganti dalam ${_ttl}s',
                  style: const TextStyle(fontSize: 13, color: AppColors.slate500)),
            ],
          ),
        ],
      ),
    );
  }
}