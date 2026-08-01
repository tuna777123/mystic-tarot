import 'package:flutter_test/flutter_test.dart';
import 'package:mystic_tarot/main.dart';
import 'package:mystic_tarot/src/app.dart';
import 'package:mystic_tarot/src/flagship.dart';
import 'package:mystic_tarot/src/language_preferences.dart';
import 'package:mystic_tarot/src/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the Mystic onboarding', (tester) async {
    await tester.pumpWidget(const MysticApp());
    await tester.pumpAndSettle();
    expect(find.text('Your patterns are already speaking.'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Türkçe'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
    expect(find.text('Português (Brasil)'), findsOneWidget);
    expect(find.text('Italiano'), findsNothing);
    expect(find.text('Deutsch'), findsNothing);
  });

  testWidgets('living fate map is visible in both launch languages', (tester) async {
    await tester.pumpWidget(
      const TestAppShell(
        child: LivingFateMapScreen(
          language: MysticLanguage.english,
          readings: <ReadingRecord>[],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('LIVING FATE MAP'), findsOneWidget);
    expect(find.text('Your story changes with every return.'), findsOneWidget);
    expect(find.text('ENTER MY PATH'), findsOneWidget);

    await tester.pumpWidget(
      const TestAppShell(
        child: LivingFateMapScreen(
          language: MysticLanguage.turkish,
          readings: <ReadingRecord>[],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('YAŞAYAN KADER HARİTASI'), findsOneWidget);
    expect(find.text('Hikâyen her dönüşünde değişiyor.'), findsOneWidget);
    expect(find.text('YOLUMA GİR'), findsOneWidget);
  });

  testWidgets('destiny hub opens its private empty state', (tester) async {
    await tester.pumpWidget(
      const TestAppShell(
        child: DestinyHubScreen(
          language: MysticLanguage.english,
          readings: <ReadingRecord>[],
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Your destiny pattern begins here.'), findsOneWidget);
    expect(find.text('Your first connection is waiting.'), findsOneWidget);
    expect(find.text('BEGIN MY FIRST READING'), findsOneWidget);
  });

  testWidgets('Turkish remains active inside the card selection flow', (tester) async {
    await tester.pumpWidget(
      const TestAppShell(
        child: ReadingFlow(
          language: MysticLanguage.turkish,
          kind: ReadingKind.daily,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bugün için net bir mesaj'), findsOneWidget);
    expect(find.text('Nefesini yavaşlat.'), findsOneWidget);
    expect(find.text('ŞU AN NASIL HİSSEDİYORSUN?'), findsOneWidget);
    expect(find.text('KARTLARINI SEÇ'), findsOneWidget);
    expect(find.text('SEÇİMİMİ MÜHÜRLE'), findsOneWidget);
    expect(find.text('Write your question (optional)'), findsNothing);
  });

  testWidgets('Turkish emotion choices fit a phone without clipping', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const TestAppShell(
        child: ReadingFlow(
          language: MysticLanguage.turkish,
          kind: ReadingKind.daily,
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in <String>['Belirsiz', 'Umutlu', 'Kaygılı', 'Dengeli', 'Meraklı']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved Turkish preference restores the Turkish shell', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      LanguagePreferences.storageKey: AppLanguage.turkish.name,
      'onboarding_complete': true,
      'user_name': 'Tuna',
      'user_intention': 'clarity',
    });

    await tester.pumpWidget(const MysticApp());
    await tester.pumpAndSettle();

    expect(find.text('YOLUNA HOŞ GELDİN'), findsOneWidget);
    expect(find.text('Oku'), findsOneWidget);
    expect(find.text('Yol'), findsOneWidget);
    expect(find.text('Günlük'), findsOneWidget);
    expect(find.text('Sen'), findsOneWidget);
    expect(find.text('WELCOME TO YOUR PATH'), findsNothing);
  });

  test('launch language selector exposes only complete languages', () {
    expect(launchLanguages, <MysticLanguage>[
      MysticLanguage.english,
      MysticLanguage.turkish,
      MysticLanguage.spanish,
      MysticLanguage.french,
      MysticLanguage.portugueseBrazil,
    ]);
  });

  testWidgets('Turkish remains active in profile and settings', (tester) async {
    await tester.pumpWidget(
      const TestAppShell(
        child: ProfileScreen(language: MysticLanguage.turkish),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('KİM OLDUĞUNU GÖR'), findsOneWidget);
    expect(find.text('SENİN İSTATİSTİKLERİN'), findsOneWidget);
    expect(find.text('AYARLAR'), findsOneWidget);
    expect(find.text('Mistik kimliğim'), findsOneWidget);
    expect(find.text('Kişiselleştirme'), findsOneWidget);
    expect(find.text('Gizlilik ve veri'), findsOneWidget);
    expect(find.text('Yardım ve destek'), findsOneWidget);
  });

  testWidgets('Turkish premium preview never falls back to English', (tester) async {
    await tester.pumpWidget(
      const TestAppShell(
        child: PremiumReadingPreview(
          language: MysticLanguage.turkish,
          kind: ReadingKind.celticCross,
          question: '',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('İLK İŞARETİN'), findsOneWidget);
    expect(find.text('İlk işaret şekilleniyor…'), findsOneWidget);
    expect(find.text('İlk işaret hazır'), findsOneWidget);
    expect(find.text('Açılımının geri kalanı'), findsOneWidget);
    expect(find.text('İlk mesajını al'), findsOneWidget);
    expect(find.text('YOUR FIRST SIGNAL'), findsNothing);
    expect(find.text('The first signal is forming…'), findsNothing);
    expect(find.text('Get my first message'), findsNothing);
  });

  testWidgets('Turkish journey, weekly summary and Arcana Vault stay localized', (tester) async {
    await tester.pumpWidget(
      const TestAppShell(
        child: JourneyScreen(language: MysticLanguage.turkish),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('BÜYÜK ARKANA YOLCULUĞU'), findsOneWidget);
    expect(find.text('22 bölüm mühürlendi'), findsOneWidget);
    expect(find.text('MYSTIC HİKÂYE STÜDYOSU'), findsOneWidget);

    await tester.pumpWidget(
      TestAppShell(
        child: JournalScreen(
          language: MysticLanguage.turkish,
          readings: const <ReadingRecord>[],
          onOpenReading: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ARCANA KASASI'), findsOneWidget);
    expect(find.text('HAFTALIK MYSTIC ÖZETİN'), findsOneWidget);
    expect(find.text('Hikâyen ilk işaretini bekliyor.'), findsOneWidget);
    expect(find.text('LIVING JOURNAL'), findsNothing);
  });
}
