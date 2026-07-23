import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'monetization.dart';
import 'theme.dart';
import 'widgets.dart';

class MysticPaywallScreen extends StatefulWidget {
  const MysticPaywallScreen({
    required this.source,
    this.priceByPlan = const {},
    this.onPurchase,
    this.onRestore,
    super.key,
  });

  final PaywallSource source;
  final Map<MysticPlan, String> priceByPlan;
  final Future<PurchaseStatus> Function(MysticPlan plan)? onPurchase;
  final Future<PurchaseStatus> Function()? onRestore;

  @override
  State<MysticPaywallScreen> createState() => _MysticPaywallScreenState();
}

class _MysticPaywallScreenState extends State<MysticPaywallScreen> {
  MysticPlan selectedPlan = MysticPlan.yearly;
  PurchaseStatus status = PurchaseStatus.idle;

  bool get purchaseEnabled => !kIsWeb && widget.onPurchase != null;

  @override
  Widget build(BuildContext context) {
    final selectedOffer = MysticOffer.launchCatalog.firstWhere(
      (offer) => offer.plan == selectedPlan,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.close),
        ),
        title: const Text('Mystic Plus'),
      ),
      body: MysticBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          children: [
            const Text('✦', textAlign: TextAlign.center, style: TextStyle(fontSize: 54, color: MysticColors.gold)),
            const SizedBox(height: 10),
            Text('Turn every reading into a path that remembers you.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(_sourceMessage(widget.source), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 22),
            const _BenefitRow(icon: Icons.all_inclusive, title: 'Unlimited deep readings', subtitle: 'Love, career, money, shadow work, and more.'),
            const _BenefitRow(icon: Icons.auto_awesome, title: 'Unlimited Oracle dialogue', subtitle: 'Keep exploring after the first interpretation.'),
            const _BenefitRow(icon: Icons.hub_outlined, title: 'Full Living Fate insights', subtitle: 'See recurring cards, emotional shifts, and transitions.'),
            const _BenefitRow(icon: Icons.lock_outline, title: 'Private by design', subtitle: 'Your journal remains on your device.'),
            const SizedBox(height: 18),
            ...MysticOffer.launchCatalog.map((offer) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PlanCard(
                    offer: offer,
                    price: widget.priceByPlan[offer.plan],
                    selected: selectedPlan == offer.plan,
                    onTap: () => setState(() => selectedPlan = offer.plan),
                  ),
                )),
            const SizedBox(height: 8),
            GoldButton(
              label: _primaryLabel(selectedOffer),
              icon: status == PurchaseStatus.loading || status == PurchaseStatus.pending ? Icons.hourglass_top : Icons.auto_awesome,
              onPressed: purchaseEnabled && status != PurchaseStatus.loading && status != PurchaseStatus.pending ? _purchase : null,
            ),
            const SizedBox(height: 10),
            if (!purchaseEnabled)
              Text(
                kIsWeb
                    ? 'Subscriptions are purchased through the App Store or Google Play app. No payment is processed in this web preview.'
                    : 'Store products are not available yet. No payment will be taken.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (_statusMessage() != null) ...[
              const SizedBox(height: 10),
              Text(_statusMessage()!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onRestore == null || status == PurchaseStatus.loading ? null : _restore,
              child: const Text('Restore purchases'),
            ),
            Text(
              selectedPlan.includesTrial
                  ? '7 days free, then the localized yearly price shown by your store. Cancel anytime in store settings.'
                  : 'Renews monthly at the localized price shown by your store. Cancel anytime in store settings.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase() async {
    final purchase = widget.onPurchase;
    if (purchase == null) return;
    setState(() => status = PurchaseStatus.loading);
    final result = await purchase(selectedPlan);
    if (!mounted) return;
    setState(() => status = result);
    if (result == PurchaseStatus.purchased || result == PurchaseStatus.restored) {
      Navigator.maybePop(context, true);
    }
  }

  Future<void> _restore() async {
    final restore = widget.onRestore;
    if (restore == null) return;
    setState(() => status = PurchaseStatus.loading);
    final result = await restore();
    if (!mounted) return;
    setState(() => status = result);
    if (result == PurchaseStatus.restored || result == PurchaseStatus.purchased) {
      Navigator.maybePop(context, true);
    }
  }

  String _primaryLabel(MysticOffer offer) {
    if (status == PurchaseStatus.loading) return 'Connecting to store…';
    if (status == PurchaseStatus.pending) return 'Purchase pending';
    if (offer.plan.includesTrial) return 'Start 7-day free trial';
    return 'Continue with monthly';
  }

  String? _statusMessage() => switch (status) {
        PurchaseStatus.cancelled => 'Purchase cancelled. Nothing was charged.',
        PurchaseStatus.failed => 'The store could not complete the purchase. Try again later.',
        PurchaseStatus.pending => 'Your store is still processing this purchase.',
        PurchaseStatus.refunded => 'This subscription was refunded and Plus access is inactive.',
        PurchaseStatus.expired => 'Your previous subscription has expired.',
        _ => null,
      };
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 13),
        child: Row(children: [
          Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: MysticColors.gold.withValues(alpha: .12), shape: BoxShape.circle), child: Icon(icon, color: MysticColors.gold, size: 21)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ])),
        ]),
      );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.offer, required this.selected, required this.onTap, this.price});
  final MysticOffer offer;
  final String? price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: selected ? const LinearGradient(colors: [Color(0xFF654491), Color(0xFF291A3D)]) : null,
            color: selected ? null : Colors.white.withValues(alpha: .045),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? MysticColors.gold : Colors.white12, width: selected ? 1.5 : 1),
          ),
          child: Row(children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? MysticColors.gold : MysticColors.muted),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(offer.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: MysticColors.gold.withValues(alpha: .15), borderRadius: BorderRadius.circular(10)), child: Text(offer.badge, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 8, fontWeight: FontWeight.w900))),
              ]),
              const SizedBox(height: 5),
              Text(offer.valueMessage, style: Theme.of(context).textTheme.bodyMedium),
            ])),
            const SizedBox(width: 8),
            Text(price ?? 'Store price', textAlign: TextAlign.right, style: const TextStyle(color: MysticColors.gold, fontWeight: FontWeight.w900)),
          ]),
        ),
      );
}

String _sourceMessage(PaywallSource source) => switch (source) {
      PaywallSource.dailyLimit => 'You reached today’s free deep-reading limit. Keep your path moving with unlimited access.',
      PaywallSource.premiumSpread => 'Unlock the complete spreads built for the questions that need more depth.',
      PaywallSource.oracleDialogue => 'Continue the Oracle conversation without stopping after the first answer.',
      PaywallSource.profile => 'Upgrade your personal practice with every Mystic Plus feature.',
      _ => 'Unlock the complete Mystic experience and let your path grow over time.',
    };
