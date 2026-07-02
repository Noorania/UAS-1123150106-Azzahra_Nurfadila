import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../widgets/feature_icon.dart';
import '../../widgets/pin_pad.dart';

class PinPage extends StatefulWidget {
  final Map<String, dynamic> flowData;
  const PinPage({super.key, required this.flowData});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  String _pin = '';
  bool _busy = false;
  bool _hasError = false;

  void _onComplete(String pin) {
    // In production, validate PIN with backend first before proceeding.
    // Here we simulate: any 6-digit PIN is accepted as correct.
    setState(() => _busy = true);

    final kind = widget.flowData['kind'] as String? ?? '';

    if (kind == 'topup') {
      // Topup tidak butuh OTP — langsung proses.
      _processTopup();
    } else {
      // transfer / payment / deeplink WAJIB verifikasi TOTP dulu.
      // PENTING: sebelumnya di sini langsung dispatch PaymentTransferRequested
      // dengan otpCode hardcode '000000' — itu penyebab bug "PIN masuk tapi
      // balik lagi / INVALID_OTP". Sekarang kita arahkan dulu ke halaman TOTP,
      // baru transfer dieksekusi di sana dengan kode OTP yang sesungguhnya.
      context.push('/2fa/totp', extra: {
        'mode': 'payment',
        'flowData': widget.flowData,
      }).then((_) {
        if (mounted) {
          setState(() {
            _busy = false;
            _pin = '';
          });
        }
      });
    }
  }

  void _processTopup() {
    final flow = widget.flowData;
    context.read<PaymentBloc>().add(PaymentTopupRequested(
          (flow['amount'] as num).toDouble(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentTopupSuccess) {
          context.go('/success', extra: {
            'title': 'Top up berhasil',
            'subtitle': 'Saldo kamu bertambah',
            'amount': state.amount,
            'lines': [
              ['Jumlah', CurrencyFormatter.format(state.amount)],
              ['Saldo sekarang', CurrencyFormatter.format(state.balance)],
            ],
          });
        } else if (state is PaymentError) {
          setState(() => _busy = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.ink),
                  onPressed: () => context.go('/home'),
                ),
              ),
              if (_busy) ...[
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 18),
                      Text('Memproses transaksi…',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate600,
                          )),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                    child: Column(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(child: Icon(Icons.lock_outline_rounded, size: 26, color: AppColors.primary)),
                        ),
                        const SizedBox(height: 16),
                        const Text('Masukkan PIN',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                            )),
                        const SizedBox(height: 6),
                        const Text('Masukkan 6 digit PIN keamanan kamu',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13.5, color: AppColors.slate500)),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 80),
                          transform: _hasError ? (Matrix4.identity()..translate(10.0)) : Matrix4.identity(),
                          child: PinPad(
                            value: _pin,
                            onChanged: (v) => setState(() => _pin = v),
                            onComplete: _onComplete,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text.rich(TextSpan(
                          text: 'Lupa PIN? ',
                          style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12.5, color: AppColors.slate400),
                          children: [
                            TextSpan(
                              text: 'Reset',
                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}