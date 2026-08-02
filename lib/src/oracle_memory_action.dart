import 'package:flutter/material.dart';

import 'flagship.dart';
import 'theme.dart';

class OracleMemoryAction extends StatelessWidget {
  const OracleMemoryAction({
    required this.turnCount,
    required this.language,
    required this.onTap,
    super.key,
  });

  final int turnCount;
  final MysticLanguage language;
  final VoidCallback onTap;

  String _copy({
    required String en,
    required String tr,
    required String es,
    required String fr,
    required String pt,
  }) =>
      switch (language) {
        MysticLanguage.turkish => tr,
        MysticLanguage.spanish => es,
        MysticLanguage.french => fr,
        MysticLanguage.portugueseBrazil => pt,
        _ => en,
      };

  @override
  Widget build(BuildContext context) {
    final hasMemory = turnCount > 0;
    final title = hasMemory
        ? _copy(
            en: 'Oracle Memory',
            tr: 'Oracle Hafızası',
            es: 'Memoria del Oráculo',
            fr: 'Mémoire de l’Oracle',
            pt: 'Memória do Oráculo',
          )
        : _copy(
            en: 'Ask the Oracle',
            tr: 'Oracle’a sor',
            es: 'Preguntar al Oráculo',
            fr: 'Interroger l’Oracle',
            pt: 'Perguntar ao Oráculo',
          );
    final subtitle = hasMemory
        ? _copy(
            en: '$turnCount saved exchange${turnCount == 1 ? '' : 's'} on this device',
            tr: 'Bu cihazda kayıtlı $turnCount konuşma',
            es: '$turnCount intercambio${turnCount == 1 ? '' : 's'} guardado${turnCount == 1 ? '' : 's'} en este dispositivo',
            fr: '$turnCount échange${turnCount == 1 ? '' : 's'} enregistré${turnCount == 1 ? '' : 's'} sur cet appareil',
            pt: '$turnCount conversa${turnCount == 1 ? '' : 's'} salva${turnCount == 1 ? '' : 's'} neste dispositivo',
          )
        : _copy(
            en: 'Continue this reading with one grounded follow-up',
            tr: 'Bu okumayı gerçekçi bir devam sorusuyla sürdür',
            es: 'Continúa esta lectura con una pregunta concreta',
            fr: 'Poursuivez ce tirage avec une question ancrée',
            pt: 'Continue esta leitura com uma pergunta prática',
          );

    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: MysticColors.violet.withValues(alpha: .13),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: hasMemory
                  ? MysticColors.gold.withValues(alpha: .3)
                  : MysticColors.lavender.withValues(alpha: .2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MysticColors.gold.withValues(alpha: .12),
                ),
                child: Text(
                  hasMemory ? '◉' : '✦',
                  style: const TextStyle(
                    color: MysticColors.gold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MysticColors.lavender,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_rounded,
                color: MysticColors.gold,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
