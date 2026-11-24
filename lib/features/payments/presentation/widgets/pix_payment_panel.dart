import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:aura/features/payments/domain/payments.dart';
import 'package:aura/features/portal/l10n/portal_strings.dart';

/// Componente reutilizável do Pix (usado pelo paywall da Etapa 08): plano, valor,
/// QR, copia-e-cola, tempo restante, status e "Verificar pagamento". A atualização
/// automática é proporcional (5s → 10s → 20s → 30s) e para quando expira ou aprova.
/// [onCheck] consulta o servidor e devolve 'approved' | 'pending' | 'expired' | 'rejected'.
class PixPaymentPanel extends StatefulWidget {
  const PixPaymentPanel({
    super.key,
    required this.charge,
    required this.planName,
    required this.priceLabel,
    required this.onCheck,
    this.onNewCharge,
  });
  final PixCharge charge;
  final String planName;
  final String priceLabel;
  final Future<String> Function() onCheck;
  final VoidCallback? onNewCharge;

  @override
  State<PixPaymentPanel> createState() => _PixPaymentPanelState();
}

class _PixPaymentPanelState extends State<PixPaymentPanel> {
  Timer? _tick;
  Timer? _poll;
  int _attempt = 0;
  bool _busy = false;
  String _status = 'pending';

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => mounted ? setState(() {}) : null);
    _schedule();
  }

  void _schedule() {
    const steps = [5, 10, 20, 30];
    _poll?.cancel();
    _poll = Timer(Duration(seconds: steps[_attempt.clamp(0, 3)]), () async {
      if (!mounted || widget.charge.expired || _status != 'pending') return;
      await _check();
      _attempt++;
      _schedule();
    });
  }

  Future<void> _check() async {
    if (_busy) return;
    setState(() => _busy = true);
    final st = await widget.onCheck();
    if (mounted) setState(() { _busy = false; _status = st; });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _poll?.cancel();
    super.dispose();
  }

  String _remaining() {
    final d = widget.charge.expiresAt?.difference(DateTime.now());
    if (d == null || d.isNegative) return '00:00';
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final t = PortalStrings.watch(context);
    final c = widget.charge;
    final expired = c.expired || _status == 'expired';
    final days = c.plan == PayPlan.annual ? 365 : 30;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('${widget.planName} · ${widget.priceLabel}', style: Theme.of(context).textTheme.titleMedium),
      Text(t('Acesso por $days dias. Pix avulso: não renova sozinho.',
          'Access for $days days. One-time Pix: it does not renew by itself.',
          'Acceso por $days días. Pix único: no se renueva solo.')),
      const SizedBox(height: 12),
      if (_status == 'approved')
        Text(t('Pagamento confirmado!', 'Payment confirmed!', '¡Pago confirmado!'))
      else if (expired) ...[
        Text(t('Este Pix expirou.', 'This Pix has expired.', 'Este Pix expiró.')),
        if (widget.onNewCharge != null)
          FilledButton(onPressed: widget.onNewCharge, child: Text(t('Gerar novo Pix', 'Generate new Pix', 'Generar nuevo Pix'))),
      ] else ...[
        if (c.qrBase64 != null)
          Center(child: Image.memory(base64Decode(c.qrBase64!), width: 200, height: 200)),
        const SizedBox(height: 8),
        SelectableText(c.qrCode ?? '', maxLines: 3),
        OutlinedButton.icon(
          icon: const Icon(Icons.copy),
          label: Text(t('Copiar código Pix', 'Copy Pix code', 'Copiar código Pix')),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: c.qrCode ?? ''));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t('Código copiado', 'Code copied', 'Código copiado'))));
            }
          },
        ),
        const SizedBox(height: 8),
        Text(t('Aguardando pagamento · expira em ${_remaining()}',
            'Waiting for payment · expires in ${_remaining()}',
            'Esperando el pago · expira en ${_remaining()}')),
        TextButton(
          onPressed: _busy ? null : _check,
          child: Text(t('Verificar pagamento', 'Check payment', 'Verificar pago')),
        ),
      ],
    ]);
  }
}
