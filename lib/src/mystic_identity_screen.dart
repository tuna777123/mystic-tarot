import 'package:flutter/material.dart';

import 'app_language.dart';
import 'identity_engine.dart';
import 'theme.dart';
import 'widgets.dart';

class MysticIdentityScreen extends StatelessWidget {
  const MysticIdentityScreen({
    required this.snapshot,
    required this.language,
    required this.onContinueJourney,
    super.key,
  });

  final MysticIdentitySnapshot snapshot;
  final AppLanguage language;
  final VoidCallback onContinueJourney;

  String text({
    required String en,
    required String es,
    required String fr,
    required String pt,
    required String tr,
    required String it,
    required String de,
  }) =>
      localized(
        language,
        english: en,
        spanish: es,
        french: fr,
        portugueseBrazil: pt,
        turkish: tr,
        italian: it,
        german: de,
      );

  @override
  Widget build(BuildContext context) {
    final progress = snapshot.progressToEvolution.clamp(0.0, 1.0);
    return Scaffold(
      body: MysticBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Text(
                text(
                  en: 'YOUR MYSTIC SOUL',
                  es: 'TU ALMA MÍSTICA',
                  fr: 'VOTRE ÂME MYSTIQUE',
                  pt: 'SUA ALMA MÍSTICA',
                  tr: 'MİSTİK RUHUN',
                  it: 'LA TUA ANIMA MISTICA',
                  de: 'DEINE MYSTISCHE SEELE',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: MysticColors.gold,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                ),
              ),
              const SizedBox(height: 14),
              _IdentityHero(snapshot: snapshot, language: language),
              const SizedBox(height: 18),
              _section(
                context,
                title: text(
                  en: 'Why Mystic sees this in you',
                  es: 'Por qué Mystic ve esto en ti',
                  fr: 'Pourquoi Mystic voit cela en vous',
                  pt: 'Por que o Mystic vê isso em você',
                  tr: 'Mystic bunu sende neden görüyor',
                  it: 'Perché Mystic vede questo in te',
                  de: 'Warum Mystic das in dir erkennt',
                ),
                child: Column(
                  children: snapshot.signals
                      .map(
                        (signal) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Icon(Icons.auto_awesome, size: 15, color: MysticColors.gold),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(signal, style: Theme.of(context).textTheme.bodyLarge)),
                            ],
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: 16),
              _section(
                context,
                title: text(
                  en: 'Your next evolution',
                  es: 'Tu próxima evolución',
                  fr: 'Votre prochaine évolution',
                  pt: 'Sua próxima evolução',
                  tr: 'Bir sonraki dönüşümün',
                  it: 'La tua prossima evoluzione',
                  de: 'Deine nächste Entwicklung',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            snapshot.nextEvolution,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            color: MysticColors.gold,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        minHeight: 10,
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: .08),
                        valueColor: const AlwaysStoppedAnimation(MysticColors.gold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      text(
                        en: 'Read, reflect, and complete Arcana chapters to evolve this identity naturally.',
                        es: 'Lee, reflexiona y completa capítulos de los Arcanos para desarrollar esta identidad de forma natural.',
                        fr: 'Lisez, réfléchissez et terminez les chapitres des Arcanes pour faire évoluer naturellement cette identité.',
                        pt: 'Leia, reflita e conclua capítulos dos Arcanos para desenvolver essa identidade naturalmente.',
                        tr: 'Bu kimliği doğal biçimde geliştirmek için oku, düşün ve Arkana bölümlerini tamamla.',
                        it: 'Leggi, rifletti e completa i capitoli degli Arcani per far evolvere naturalmente questa identità.',
                        de: 'Lies, reflektiere und schließe Arkana-Kapitel ab, um diese Identität natürlich weiterzuentwickeln.',
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GoldButton(
                label: text(
                  en: 'Continue my journey',
                  es: 'Continuar mi viaje',
                  fr: 'Continuer mon voyage',
                  pt: 'Continuar minha jornada',
                  tr: 'Yolculuğuma devam et',
                  it: 'Continua il mio viaggio',
                  de: 'Meine Reise fortsetzen',
                ),
                icon: Icons.hub_outlined,
                onPressed: onContinueJourney,
              ),
              const SizedBox(height: 10),
              Text(
                text(
                  en: 'Calculated privately on this device from your reading patterns and progress.',
                  es: 'Se calcula de forma privada en este dispositivo a partir de tus patrones de lectura y progreso.',
                  fr: 'Calculé de manière privée sur cet appareil à partir de vos habitudes de lecture et de vos progrès.',
                  pt: 'Calculado de forma privada neste dispositivo com base nos seus padrões de leitura e progresso.',
                  tr: 'Okuma örüntülerin ve ilerlemen kullanılarak yalnızca bu cihazda hesaplanır.',
                  it: 'Calcolato in modo privato su questo dispositivo in base ai tuoi schemi di lettura e ai tuoi progressi.',
                  de: 'Wird privat auf diesem Gerät anhand deiner Lesemuster und deines Fortschritts berechnet.',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 9, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, {required String title, required Widget child}) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .045),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: .09)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}

class _IdentityHero extends StatelessWidget {
  const _IdentityHero({required this.snapshot, required this.language});

  final MysticIdentitySnapshot snapshot;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7047A8), Color(0xFF2B1941), Color(0xFF130D1D)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .42)),
          boxShadow: [BoxShadow(color: MysticColors.violet.withValues(alpha: .22), blurRadius: 38)],
        ),
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF100A18).withValues(alpha: .72),
                border: Border.all(color: MysticColors.gold.withValues(alpha: .6)),
                boxShadow: [BoxShadow(color: MysticColors.gold.withValues(alpha: .13), blurRadius: 28)],
              ),
              child: Text(_symbol(snapshot.primary), style: const TextStyle(fontSize: 42, color: MysticColors.gold)),
            ),
            const SizedBox(height: 16),
            Text(snapshot.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(snapshot.summary, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: .1)),
              ),
              child: Text(
                _confidenceText(snapshot.confidence, language),
                style: const TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 10, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      );

  static String _confidenceText(int confidence, AppLanguage language) => localized(
        language,
        english: '$confidence% identity confidence',
        spanish: '$confidence% de confianza de identidad',
        french: '$confidence% de confiance identitaire',
        portugueseBrazil: '$confidence% de confiança de identidade',
        turkish: '%$confidence kimlik güveni',
        italian: '$confidence% di affidabilità dell’identità',
        german: '$confidence% Identitätssicherheit',
      );

  static String _symbol(MysticArchetype archetype) => switch (archetype) {
        MysticArchetype.seeker => '☾',
        MysticArchetype.alchemist => '✦',
        MysticArchetype.sage => '◉',
        MysticArchetype.guardian => '♜',
        MysticArchetype.visionary => '☀',
      };
}
