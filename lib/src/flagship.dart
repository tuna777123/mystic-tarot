import 'dart:math';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import 'models.dart';
import 'tarot_data.dart';
import 'theme.dart';
import 'widgets.dart';

enum MysticLanguage {
  english('English', 'EN'),
  turkish('Türkçe', 'TR');

  const MysticLanguage(this.label, this.code);
  final String label;
  final String code;
}

String mysticText(MysticLanguage language, String english, String turkish) =>
    language == MysticLanguage.turkish ? turkish : english;

class ArcanaChapter {
  const ArcanaChapter({
    required this.focusEn,
    required this.focusTr,
    required this.ritualEn,
    required this.ritualTr,
    required this.promptEn,
    required this.promptTr,
  });

  final String focusEn;
  final String focusTr;
  final String ritualEn;
  final String ritualTr;
  final String promptEn;
  final String promptTr;
}

const arcanaChapters = <ArcanaChapter>[
  ArcanaChapter(focusEn: 'Begin before certainty arrives', focusTr: 'Kesinlik gelmeden başla', ritualEn: 'Take one small step you can reverse.', ritualTr: 'Geri döndürebileceğin küçük bir adım at.', promptEn: 'What would I try if I did not need to look ready?', promptTr: 'Hazır görünmek zorunda olmasaydım neyi denerdim?'),
  ArcanaChapter(focusEn: 'Direct your available power', focusTr: 'Elindeki gücü yönlendir', ritualEn: 'Choose one tool and use it for fifteen focused minutes.', ritualTr: 'Bir araç seç ve on beş dakika boyunca yalnızca onu kullan.', promptEn: 'Where am I waiting for a resource I already have?', promptTr: 'Zaten sahip olduğum hangi kaynağı bekliyorum?'),
  ArcanaChapter(focusEn: 'Listen beneath the noise', focusTr: 'Gürültünün altını dinle', ritualEn: 'Sit without input for three quiet minutes.', ritualTr: 'Üç dakika boyunca hiçbir uyaran olmadan sessizce otur.', promptEn: 'What does my body know before my mind explains it?', promptTr: 'Aklım açıklamadan önce bedenim ne biliyor?'),
  ArcanaChapter(focusEn: 'Nourish what should grow', focusTr: 'Büyümesi gerekeni besle', ritualEn: 'Improve one condition around your creative work.', ritualTr: 'Üretimini çevreleyen tek bir koşulu iyileştir.', promptEn: 'What becomes possible when I stop starving my own needs?', promptTr: 'Kendi ihtiyaçlarımı aç bırakmayı bırakırsam ne mümkün olur?'),
  ArcanaChapter(focusEn: 'Build a kind structure', focusTr: 'Şefkatli bir düzen kur', ritualEn: 'Create one boundary that makes tomorrow easier.', ritualTr: 'Yarını kolaylaştıracak tek bir sınır oluştur.', promptEn: 'Which rule protects me, and which one only controls me?', promptTr: 'Hangi kural beni koruyor, hangisi yalnızca kontrol ediyor?'),
  ArcanaChapter(focusEn: 'Choose your living tradition', focusTr: 'Yaşayan geleneğini seç', ritualEn: 'Keep one useful teaching and question one inherited rule.', ritualTr: 'Bir faydalı öğretiyi koru, miras kalan bir kuralı sorgula.', promptEn: 'What deserves my respect rather than blind obedience?', promptTr: 'Kör itaate değil, saygıma layık olan nedir?'),
  ArcanaChapter(focusEn: 'Align desire with values', focusTr: 'Arzunu değerlerinle hizala', ritualEn: 'Name the value beneath one important choice.', ritualTr: 'Önemli bir seçimin altındaki değeri adlandır.', promptEn: 'What choice lets me stay connected without leaving myself?', promptTr: 'Hangi seçim bağımı korurken kendimi terk etmememi sağlar?'),
  ArcanaChapter(focusEn: 'Move with a named direction', focusTr: 'Adını koyduğun yöne ilerle', ritualEn: 'Write your destination before increasing your speed.', ritualTr: 'Hızını artırmadan önce varış noktanı yaz.', promptEn: 'Am I moving toward something or merely escaping?', promptTr: 'Bir şeye mi ilerliyorum, yoksa yalnızca kaçıyor muyum?'),
  ArcanaChapter(focusEn: 'Practice gentle courage', focusTr: 'Yumuşak cesareti uygula', ritualEn: 'Meet one difficult feeling without trying to defeat it.', ritualTr: 'Zor bir duyguyu yenmeye çalışmadan onunla karşılaş.', promptEn: 'What changes when strength no longer means force?', promptTr: 'Güç artık zor kullanmak demek değilse ne değişir?'),
  ArcanaChapter(focusEn: 'Return with your own light', focusTr: 'Kendi ışığınla geri dön', ritualEn: 'Step away from input, then write one honest sentence.', ritualTr: 'Uyaranlardan uzaklaş, sonra dürüst bir cümle yaz.', promptEn: 'Which answer can only be heard in solitude?', promptTr: 'Hangi cevap yalnızlıkta duyulabilir?'),
  ArcanaChapter(focusEn: 'Work with the turning cycle', focusTr: 'Dönen döngüyle birlikte çalış', ritualEn: 'Release one expectation that belongs to yesterday.', ritualTr: 'Düne ait bir beklentiyi bırak.', promptEn: 'What opening appears when I stop demanding the old shape?', promptTr: 'Eski biçimi talep etmeyi bırakırsam hangi fırsat belirir?'),
  ArcanaChapter(focusEn: 'Restore honest proportion', focusTr: 'Dürüst dengeyi yeniden kur', ritualEn: 'Name your part without taking all the blame.', ritualTr: 'Tüm suçu üstlenmeden kendi payını adlandır.', promptEn: 'What decision would I respect if nobody applauded?', promptTr: 'Kimse alkışlamasa hangi kararıma saygı duyardım?'),
  ArcanaChapter(focusEn: 'See from the opposite angle', focusTr: 'Ters açıdan bak', ritualEn: 'Argue sincerely for the view you resist.', ritualTr: 'Direndiğin bakış açısını samimiyetle savun.', promptEn: 'What becomes visible when progress pauses?', promptTr: 'İlerleme durduğunda ne görünür oluyor?'),
  ArcanaChapter(focusEn: 'Release the completed form', focusTr: 'Tamamlanmış biçimi bırak', ritualEn: 'Remove one object, task, or promise that is already over.', ritualTr: 'Zaten bitmiş bir eşya, görev veya sözü kaldır.', promptEn: 'Which identity can no longer carry me forward?', promptTr: 'Hangi kimlik beni artık ileri taşıyamıyor?'),
  ArcanaChapter(focusEn: 'Integrate instead of swinging', focusTr: 'Savrulmak yerine bütünleştir', ritualEn: 'Make the next adjustment small enough to sustain.', ritualTr: 'Bir sonraki ayarı sürdürülebilecek kadar küçük yap.', promptEn: 'Where would five percent be wiser than all or nothing?', promptTr: 'Nerede yüzde beş, ya hep ya hiçten daha akıllıca olur?'),
  ArcanaChapter(focusEn: 'Name the hidden bargain', focusTr: 'Gizli pazarlığın adını koy', ritualEn: 'Write the real cost of one familiar attachment.', ritualTr: 'Tanıdık bir bağımlılığın gerçek bedelini yaz.', promptEn: 'What keeps choosing for me when I stop paying attention?', promptTr: 'Dikkat etmediğimde benim yerime ne seçim yapıyor?'),
  ArcanaChapter(focusEn: 'Protect truth through change', focusTr: 'Değişimde gerçeği koru', ritualEn: 'Separate what is falling from what is genuinely valuable.', ritualTr: 'Yıkılanla gerçekten değerli olanı birbirinden ayır.', promptEn: 'What false structure am I exhausted from maintaining?', promptTr: 'Hangi sahte yapıyı sürdürmekten yoruldum?'),
  ArcanaChapter(focusEn: 'Practice evidence of hope', focusTr: 'Umudun kanıtını üret', ritualEn: 'Do one hopeful act that asks nothing from the outcome.', ritualTr: 'Sonuçtan karşılık beklemeyen umutlu bir eylem yap.', promptEn: 'What small act would make possibility feel safe again?', promptTr: 'Hangi küçük eylem ihtimali yeniden güvenli hissettirir?'),
  ArcanaChapter(focusEn: 'Wait for more light', focusTr: 'Daha fazla ışığı bekle', ritualEn: 'Divide one fear into facts, assumptions, and unknowns.', ritualTr: 'Bir korkuyu gerçekler, varsayımlar ve bilinmeyenler diye ayır.', promptEn: 'Where has uncertainty been disguised as certainty?', promptTr: 'Belirsizlik nerede kesinlik kılığına girdi?'),
  ArcanaChapter(focusEn: 'Let joy be uncomplicated', focusTr: 'Sevincin sade olmasına izin ver', ritualEn: 'Share one warm moment without performing it.', ritualTr: 'Bir sıcak anı gösteriye çevirmeden paylaş.', promptEn: 'What goodness am I making harder than it needs to be?', promptTr: 'Hangi iyiliği gereğinden zor hale getiriyorum?'),
  ArcanaChapter(focusEn: 'Answer the deeper call', focusTr: 'Derindeki çağrıya cevap ver', ritualEn: 'Write what the next version of you refuses to postpone.', ritualTr: 'Bir sonraki halinin ertelemeyi reddettiği şeyi yaz.', promptEn: 'Who am I becoming when old shame is not in charge?', promptTr: 'Eski utanç yönetmediğinde kim oluyorum?'),
  ArcanaChapter(focusEn: 'Honor completion', focusTr: 'Tamamlanmayı onurlandır', ritualEn: 'Close one open loop and name what it taught you.', ritualTr: 'Açık kalan bir döngüyü kapat ve sana ne öğrettiğini yaz.', promptEn: 'What must be celebrated before the next chapter begins?', promptTr: 'Yeni bölüm başlamadan önce ne kutlanmalı?'),
];

class DestinyFlagshipCard extends StatelessWidget {
  const DestinyFlagshipCard({
    required this.records,
    required this.completedDays,
    required this.language,
    required this.onOpen,
    super.key,
  });

  final List<ReadingRecord> records;
  final Set<int> completedDays;
  final MysticLanguage language;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final index = min(21, completedDays.length);
    final card = tarotDeck[index];
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7047A8), Color(0xFF25163B), Color(0xFF14101E)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .42)),
          boxShadow: [BoxShadow(color: MysticColors.violet.withValues(alpha: .18), blurRadius: 30)],
        ),
        child: Row(children: [
          Container(
            width: 72,
            height: 92,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF120D1D).withValues(alpha: .72),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: MysticColors.gold.withValues(alpha: .55)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(card.number, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 9, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(card.symbol, style: const TextStyle(fontSize: 34, color: MysticColors.gold)),
            ]),
          ),
          const SizedBox(width: 15),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              mysticText(language, 'LIVING FATE MAP', 'YAŞAYAN KADER HARİTASI'),
              style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            const SizedBox(height: 7),
            Text(
              mysticText(language, 'Your story changes with every return.', 'Hikâyen her dönüşünde değişiyor.'),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              mysticText(
                language,
                '${records.length} readings connected • Day ${min(22, completedDays.length + 1)} of 22',
                '${records.length} okuma bağlandı • 22 günün ${min(22, completedDays.length + 1)}. günü',
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 11),
            Row(children: [
              Text(mysticText(language, 'ENTER MY PATH', 'YOLUMA GİR'), style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .8)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, color: MysticColors.gold, size: 16),
            ]),
          ])),
        ]),
      ),
    );
  }
}

class DestinyHubScreen extends StatefulWidget {
  const DestinyHubScreen({
    required this.records,
    required this.completedDays,
    required this.reflections,
    required this.lastCompletionDay,
    required this.language,
    required this.onCompleteChapter,
    required this.onStartReading,
    super.key,
  });

  final List<ReadingRecord> records;
  final Set<int> completedDays;
  final Map<int, String> reflections;
  final String? lastCompletionDay;
  final MysticLanguage language;
  final void Function(int index, String reflection) onCompleteChapter;
  final VoidCallback onStartReading;

  @override
  State<DestinyHubScreen> createState() => _DestinyHubScreenState();
}

class _DestinyHubScreenState extends State<DestinyHubScreen> {
  int section = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(mysticText(widget.language, 'My Living Path', 'Yaşayan Yolum')),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(color: MysticColors.gold.withValues(alpha: .1), borderRadius: BorderRadius.circular(15)),
              child: Text('${widget.completedDays.length}/22', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        body: MysticBackground(child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
            child: SegmentedButton<int>(
              segments: [
                ButtonSegment(value: 0, icon: const Icon(Icons.hub_outlined), label: Text(mysticText(widget.language, 'Fate Map', 'Kader Haritası'))),
                ButtonSegment(value: 1, icon: const Icon(Icons.route_outlined), label: Text(mysticText(widget.language, '22 Days', '22 Gün'))),
              ],
              selected: {section},
              onSelectionChanged: (value) => setState(() => section = value.first),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: section == 0
                  ? _DestinyMap(records: widget.records, completedDays: widget.completedDays, language: widget.language, onStartReading: widget.onStartReading)
                  : _ArcanaJourney(
                      records: widget.records,
                      completedDays: widget.completedDays,
                      reflections: widget.reflections,
                      lastCompletionDay: widget.lastCompletionDay,
                      language: widget.language,
                      onComplete: (index, reflection) {
                        widget.onCompleteChapter(index, reflection);
                        setState(() {});
                      },
                    ),
            ),
          ),
        ])),
      );
}

class _DestinyMap extends StatelessWidget {
  const _DestinyMap({
    required this.records,
    required this.completedDays,
    required this.language,
    required this.onStartReading,
  });

  final List<ReadingRecord> records;
  final Set<int> completedDays;
  final MysticLanguage language;
  final VoidCallback onStartReading;

  @override
  Widget build(BuildContext context) {
    final recent = records.take(12).toList();
    final recurring = _mostFrequentCard(recent);
    final emotion = _dominantEmotion(recent);
    final focus = _dominantFocus(recent);
    final currentIndex = min(21, completedDays.length);
    final currentCard = tarotDeck[currentIndex];
    final hasSignal = recent.length >= 2;
    return ListView(key: const ValueKey('map'), padding: const EdgeInsets.fromLTRB(18, 8, 18, 30), children: [
      Container(
        height: 300,
        decoration: BoxDecoration(
          gradient: const RadialGradient(colors: [Color(0xFF4C347B), Color(0xFF171023), Color(0xFF0C0A12)], stops: [0, .6, 1]),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: MysticColors.lavender.withValues(alpha: .28)),
        ),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _FateMapPainter(records: recent.length, chapters: completedDays.length))),
          Center(child: Container(
            width: 104,
            height: 104,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(colors: [Color(0xFFFFE09A), Color(0xFF9A6825), Color(0xFF2C1C28)]),
              boxShadow: [BoxShadow(color: MysticColors.gold.withValues(alpha: .25), blurRadius: 40)],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(currentCard.symbol, style: const TextStyle(fontSize: 36, color: MysticColors.ink)),
              Text(currentCard.name, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.ink, fontSize: 8, fontWeight: FontWeight.w900)),
            ]),
          )),
          Positioned(left: 18, top: 17, child: Text(mysticText(language, 'YOUR LIVING SIGNALS', 'YAŞAYAN SİNYALLERİN'), style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2))),
          Positioned(left: 18, right: 18, bottom: 16, child: Text(
            hasSignal
                ? mysticText(language, 'Your map is built from patterns—not predictions.', 'Haritan tahminlerden değil, örüntülerden oluşuyor.')
                : mysticText(language, 'Two saved readings awaken your first connection.', 'İki kayıtlı okuma ilk bağlantını uyandırır.'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontSize: 9, fontWeight: FontWeight.w700),
          )),
        ]),
      ),
      const SizedBox(height: 18),
      Text(mysticText(language, 'What your path is saying', 'Yolunun söylediği şey'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      _signalTile(context, '◉', mysticText(language, 'RECURRING SYMBOL', 'TEKRARLAYAN SEMBOL'), recurring == null ? mysticText(language, 'No repeated card yet', 'Henüz tekrarlayan kart yok') : '${recurring.$1} ×${recurring.$2}', MysticColors.gold),
      _signalTile(context, emotion.symbol, mysticText(language, 'INNER WEATHER', 'İÇ HAVA'), recent.isEmpty ? mysticText(language, 'Waiting for your first reading', 'İlk okumanı bekliyor') : emotion.label, MysticColors.lavender),
      _signalTile(context, '✦', mysticText(language, 'ACTIVE LIFE AREA', 'AKTİF YAŞAM ALANI'), focus, const Color(0xFF82D8D0)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF352559), Color(0xFF191329)]),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .23)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(mysticText(language, 'CURRENT CHAPTER • ${currentCard.name.toUpperCase()}', 'MEVCUT BÖLÜM • ${currentCard.name.toUpperCase()}'), style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .9)),
          const SizedBox(height: 9),
          Text(mysticText(language, arcanaChapters[currentIndex].focusEn, arcanaChapters[currentIndex].focusTr), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 7),
          Text(
            hasSignal
                ? mysticText(language, 'Your recent $focus questions have carried ${emotion.label.toLowerCase()} energy. This chapter asks you to ${arcanaChapters[currentIndex].ritualEn.toLowerCase()}', 'Son $focus soruların ${emotion.label.toLowerCase()} enerjisi taşıdı. Bu bölüm senden şunu istiyor: ${arcanaChapters[currentIndex].ritualTr}')
                : mysticText(language, 'Begin with one honest reading. Mystic will connect the cards, emotions, and actions that return.', 'Dürüst bir okumayla başla. Mystic tekrar eden kartları, duyguları ve eylemleri birbirine bağlayacak.'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ]),
      ),
      if (records.isEmpty) ...[
        const SizedBox(height: 18),
        GoldButton(label: mysticText(language, 'Create my first signal', 'İlk sinyalimi oluştur'), icon: Icons.auto_awesome, onPressed: onStartReading),
      ],
    ]);
  }

  Widget _signalTile(BuildContext context, String symbol, String title, String value, Color color) => Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .045), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: .18))),
        child: Row(children: [
          Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .13)), child: Text(symbol, style: TextStyle(fontSize: 21, color: color))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontFamily: 'Arial', color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: .9)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontFamily: 'Arial', fontWeight: FontWeight.w800, fontSize: 13)),
          ])),
        ]),
      );
}

class _ArcanaJourney extends StatefulWidget {
  const _ArcanaJourney({
    required this.records,
    required this.completedDays,
    required this.reflections,
    required this.lastCompletionDay,
    required this.language,
    required this.onComplete,
  });

  final List<ReadingRecord> records;
  final Set<int> completedDays;
  final Map<int, String> reflections;
  final String? lastCompletionDay;
  final MysticLanguage language;
  final void Function(int index, String reflection) onComplete;

  @override
  State<_ArcanaJourney> createState() => _ArcanaJourneyState();
}

class _ArcanaJourneyState extends State<_ArcanaJourney> {
  final reflection = TextEditingController();

  @override
  void dispose() {
    reflection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = min(21, widget.completedDays.length);
    final chapter = arcanaChapters[index];
    final card = tarotDeck[index];
    final today = _dayKey(DateTime.now());
    final completedToday = widget.lastCompletionDay == today;
    final journeyComplete = widget.completedDays.length >= 22;
    return ListView(key: const ValueKey('journey'), padding: const EdgeInsets.fromLTRB(18, 8, 18, 32), children: [
      Row(children: [
        Expanded(child: Text(mysticText(widget.language, 'The Major Arcana Journey', 'Büyük Arkana Yolculuğu'), style: Theme.of(context).textTheme.headlineMedium)),
        Text('${widget.completedDays.length}/22', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontWeight: FontWeight.w900)),
      ]),
      const SizedBox(height: 8),
      Text(mysticText(widget.language, 'One chapter a day. No punishment for missing a day.', 'Her gün bir bölüm. Bir gün kaçırmanın cezası yok.'), style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 15),
      ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: widget.completedDays.length / 22, minHeight: 7, backgroundColor: Colors.white10, color: MysticColors.gold)),
      const SizedBox(height: 18),
      _ChapterHero(card: card, day: min(22, index + 1), language: widget.language, complete: journeyComplete),
      const SizedBox(height: 18),
      if (journeyComplete)
        _completion(context)
      else ...[
        _block(context, mysticText(widget.language, 'TODAY’S FOCUS', 'BUGÜNÜN ODAĞI'), mysticText(widget.language, chapter.focusEn, chapter.focusTr), MysticColors.gold),
        _block(context, mysticText(widget.language, 'REAL-WORLD RITUAL', 'GERÇEK HAYAT RİTÜELİ'), mysticText(widget.language, chapter.ritualEn, chapter.ritualTr), MysticColors.lavender),
        _block(context, mysticText(widget.language, 'REFLECTION', 'YANSIMA'), mysticText(widget.language, chapter.promptEn, chapter.promptTr), const Color(0xFF82D8D0)),
        const SizedBox(height: 4),
        TextField(
          controller: reflection,
          maxLength: 240,
          minLines: 3,
          maxLines: 5,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(hintText: mysticText(widget.language, 'Write one honest sentence…', 'Dürüst bir cümle yaz…'), prefixIcon: const Icon(Icons.edit_note)),
        ),
        const SizedBox(height: 10),
        GoldButton(
          label: completedToday
              ? mysticText(widget.language, 'Today’s chapter is sealed', 'Bugünün bölümü mühürlendi')
              : mysticText(widget.language, 'Seal day ${index + 1}', '${index + 1}. günü mühürle'),
          icon: completedToday ? Icons.lock_clock_outlined : Icons.auto_awesome,
          onPressed: completedToday || reflection.text.trim().isEmpty
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  widget.onComplete(index, reflection.text.trim());
                  reflection.clear();
                },
        ),
        if (completedToday) ...[
          const SizedBox(height: 10),
          Text(mysticText(widget.language, 'Return tomorrow. Integration matters more than speed.', 'Yarın dön. Bütünleştirmek hızdan daha önemli.'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
      const SizedBox(height: 24),
      Text(mysticText(widget.language, 'Your sealed chapters', 'Mühürlenmiş bölümlerin'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      SizedBox(
        height: 82,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 22,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, chapterIndex) {
            final done = widget.completedDays.contains(chapterIndex);
            final active = chapterIndex == index && !journeyComplete;
            return Container(
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: done ? MysticColors.gold.withValues(alpha: .12) : active ? MysticColors.violet.withValues(alpha: .3) : Colors.white.withValues(alpha: .035),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: done ? MysticColors.gold : active ? MysticColors.lavender : Colors.white10),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(done ? '✓' : tarotDeck[chapterIndex].symbol, style: TextStyle(fontSize: 21, color: done || active ? MysticColors.gold : MysticColors.muted)),
                const SizedBox(height: 5),
                Text('${chapterIndex + 1}', style: const TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 9, fontWeight: FontWeight.bold)),
              ]),
            );
          },
        ),
      ),
    ]);
  }

  Widget _block(BuildContext context, String label, String body, Color color) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .045), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: .2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontFamily: 'Arial', color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 7),
          Text(body, style: Theme.of(context).textTheme.bodyLarge),
        ]),
      );

  Widget _completion(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF654490), Color(0xFF20152F)]),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .45)),
        ),
        child: Column(children: [
          const Text('♛', style: TextStyle(fontSize: 50, color: MysticColors.gold)),
          const SizedBox(height: 10),
          Text(mysticText(widget.language, 'The first cycle is complete.', 'İlk döngü tamamlandı.'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(mysticText(widget.language, 'Your 22 reflections now live inside your Fate Map. The next cycle will compare who you were with who you are becoming.', '22 yansıman artık Kader Haritanın içinde yaşıyor. Sonraki döngü, olduğun kişiyle dönüşmekte olduğun kişiyi karşılaştıracak.'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
        ]),
      );

  String _dayKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _ChapterHero extends StatelessWidget {
  const _ChapterHero({required this.card, required this.day, required this.language, required this.complete});
  final TarotCardData card;
  final int day;
  final MysticLanguage language;
  final bool complete;

  @override
  Widget build(BuildContext context) => Container(
        height: 240,
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF49336B), Color(0xFF17101F)]),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: MysticColors.gold.withValues(alpha: .45)),
          boxShadow: [BoxShadow(color: MysticColors.violet.withValues(alpha: .17), blurRadius: 30)],
        ),
        child: Stack(alignment: Alignment.center, children: [
          Positioned.fill(child: CustomPaint(painter: const _ArcanaHaloPainter())),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(complete ? mysticText(language, 'CYCLE COMPLETE', 'DÖNGÜ TAMAMLANDI') : mysticText(language, 'DAY $day OF 22', '22 GÜNÜN $day. GÜNÜ'), style: const TextStyle(fontFamily: 'Arial', color: MysticColors.gold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.3)),
            const SizedBox(height: 18),
            Text(card.symbol, style: const TextStyle(fontSize: 65, color: MysticColors.gold)),
            const SizedBox(height: 12),
            Text(card.name, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(card.number, style: const TextStyle(fontFamily: 'Arial', color: MysticColors.lavender, fontWeight: FontWeight.bold)),
          ]),
        ]),
      );
}

class StoryStudioScreen extends StatefulWidget {
  const StoryStudioScreen({
    required this.record,
    required this.guidance,
    required this.language,
    super.key,
  });

  final ReadingRecord record;
  final String guidance;
  final MysticLanguage language;

  @override
  State<StoryStudioScreen> createState() => _StoryStudioScreenState();
}

class _StoryStudioScreenState extends State<StoryStudioScreen> with SingleTickerProviderStateMixin {
  final boundaryKey = GlobalKey();
  late final AnimationController glow = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  int style = 0;
  bool sharing = false;

  @override
  void dispose() {
    glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(mysticText(widget.language, 'Mystic Story Studio', 'Mystic Hikâye Stüdyosu'))),
        body: MysticBackground(child: ListView(padding: const EdgeInsets.fromLTRB(18, 10, 18, 28), children: [
          Text(mysticText(widget.language, 'A cinematic story card, ready to share.', 'Paylaşılmaya hazır sinematik hikâye kartı.'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 15),
          Center(child: AnimatedBuilder(
            animation: glow,
            builder: (context, _) => RepaintBoundary(
              key: boundaryKey,
              child: _StoryCanvas(record: widget.record, guidance: widget.guidance, style: style, pulse: glow.value, language: widget.language),
            ),
          )),
          const SizedBox(height: 17),
          Row(children: [
            Expanded(child: _styleChoice(0, mysticText(widget.language, 'Midnight', 'Gece'))),
            const SizedBox(width: 8),
            Expanded(child: _styleChoice(1, mysticText(widget.language, 'Solar', 'Güneş'))),
            const SizedBox(width: 8),
            Expanded(child: _styleChoice(2, mysticText(widget.language, 'Blood Moon', 'Kanlı Ay'))),
          ]),
          const SizedBox(height: 17),
          GoldButton(label: sharing ? mysticText(widget.language, 'Preparing…', 'Hazırlanıyor…') : mysticText(widget.language, 'Share my story card', 'Hikâye kartımı paylaş'), icon: Icons.ios_share, onPressed: sharing ? null : () => _share(context)),
          const SizedBox(height: 9),
          Text(mysticText(widget.language, 'Exports a private image. Your question and journal notes are never included.', 'Özel bir görsel dışa aktarılır. Sorun ve günlük notların asla eklenmez.'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
        ])),
      );

  Widget _styleChoice(int value, String label) {
    final active = style == value;
    return InkWell(
      onTap: () => setState(() => style = value),
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: active ? MysticColors.gold.withValues(alpha: .13) : Colors.white.withValues(alpha: .04), borderRadius: BorderRadius.circular(15), border: Border.all(color: active ? MysticColors.gold : Colors.white10)),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Arial', color: active ? MysticColors.gold : MysticColors.muted, fontSize: 10, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Future<void> _share(BuildContext context) async {
    setState(() => sharing = true);
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('Story canvas is not ready');
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('Story image could not be encoded');
      final box = context.findRenderObject() as RenderBox?;
      final cards = widget.record.cards.map((item) => item.card.name).join(' • ');
      await SharePlus.instance.share(ShareParams(
        title: 'Mystic Tarot',
        text: '$cards\nhttps://tuna777123.github.io/mystic-tarot/',
        files: [XFile.fromData(bytes.buffer.asUint8List(), mimeType: 'image/png')],
        fileNameOverrides: ['mystic-tarot-story.png'],
        sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      ));
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: '${widget.record.cards.map((item) => item.card.name).join(' • ')}\n${widget.guidance}\nhttps://tuna777123.github.io/mystic-tarot/'));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mysticText(widget.language, 'Sharing was unavailable, so your reading was copied.', 'Paylaşım kullanılamadı; okuman panoya kopyalandı.'))));
    } finally {
      if (mounted) setState(() => sharing = false);
    }
  }
}

class _StoryCanvas extends StatelessWidget {
  const _StoryCanvas({required this.record, required this.guidance, required this.style, required this.pulse, required this.language});
  final ReadingRecord record;
  final String guidance;
  final int style;
  final double pulse;
  final MysticLanguage language;

  @override
  Widget build(BuildContext context) {
    final colors = switch (style) {
      1 => const [Color(0xFF6A4512), Color(0xFF251505), Color(0xFF080711)],
      2 => const [Color(0xFF5B1625), Color(0xFF250A12), Color(0xFF080711)],
      _ => const [Color(0xFF4C3377), Color(0xFF1E142F), Color(0xFF080711)],
    };
    final accent = style == 2 ? const Color(0xFFFF8B9C) : MysticColors.gold;
    return Container(
      width: 300,
      height: 533,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: .65)),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: .1 + pulse * .09), blurRadius: 38)],
      ),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _StoryStarsPainter(pulse: pulse, color: accent))),
        Column(children: [
          Text('MYSTIC TAROT', style: TextStyle(fontFamily: 'Arial', color: accent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2.2)),
          const SizedBox(height: 7),
          Text(widgetKind(record.kind, language), textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 19),
          Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: record.cards.take(3).map((item) => Container(
            width: record.cards.length == 1 ? 125 : 77,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(color: const Color(0xFF100B18).withValues(alpha: .8), borderRadius: BorderRadius.circular(14), border: Border.all(color: accent.withValues(alpha: .62))),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(item.card.number, style: TextStyle(fontFamily: 'Arial', color: accent, fontSize: 8, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Transform.rotate(angle: item.reversed ? pi : 0, child: Text(item.card.symbol, style: TextStyle(fontSize: record.cards.length == 1 ? 44 : 31, color: accent))),
              const SizedBox(height: 18),
              Text(item.card.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', fontSize: 8, fontWeight: FontWeight.w800)),
            ]),
          )).toList())),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: .06), borderRadius: BorderRadius.circular(16), border: Border.all(color: accent.withValues(alpha: .18))),
            child: Text(guidance, maxLines: 5, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Arial', fontSize: 9, height: 1.45, color: MysticColors.mist)),
          ),
          const SizedBox(height: 14),
          Text(mysticText(language, 'A REFLECTION, NOT A FIXED PREDICTION', 'KESİN BİR KEHANET DEĞİL, BİR YANSIMA'), textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Arial', color: accent, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: .7)),
          const SizedBox(height: 5),
          const Text('tuna777123.github.io/mystic-tarot', style: TextStyle(fontFamily: 'Arial', color: MysticColors.muted, fontSize: 7)),
        ]),
      ]),
    );
  }

  static String widgetKind(ReadingKind kind, MysticLanguage language) {
    if (language == MysticLanguage.english) return kind.title;
    return switch (kind) {
      ReadingKind.daily => 'Günlük Rehberlik',
      ReadingKind.love => 'Aşk ve Bağ',
      ReadingKind.career => 'Kariyer Yolu',
      ReadingKind.money => 'Para Enerjisi',
      ReadingKind.decision => 'Karar',
      ReadingKind.spiritual => 'Ruhsal Gelişim',
      ReadingKind.shadow => 'Gölge Çalışması',
      ReadingKind.compatibility => 'Aşk Uyumu',
      ReadingKind.timeline => 'Gelecek Zaman Çizgisi',
      ReadingKind.celticCross => 'Kelt Haçı',
    };
  }
}

class _FateMapPainter extends CustomPainter {
  const _FateMapPainter({required this.records, required this.chapters});
  final int records;
  final int chapters;

  static const points = <Offset>[
    Offset(.14, .22), Offset(.28, .39), Offset(.18, .7), Offset(.39, .78),
    Offset(.51, .2), Offset(.72, .31), Offset(.84, .65), Offset(.66, .78),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final active = max(1, min(points.length, 1 + records + chapters ~/ 3));
    final linePaint = Paint()..color = MysticColors.lavender.withValues(alpha: .28)..strokeWidth = 1.1;
    for (var i = 1; i < active; i++) {
      canvas.drawLine(_point(points[i - 1], size), _point(points[i], size), linePaint);
    }
    for (var i = 0; i < points.length; i++) {
      final on = i < active;
      final point = _point(points[i], size);
      if (on) canvas.drawCircle(point, 9, Paint()..color = MysticColors.gold.withValues(alpha: .08));
      canvas.drawCircle(point, on ? 3 : 1.6, Paint()..color = on ? MysticColors.gold : Colors.white24);
    }
  }

  Offset _point(Offset point, Size size) => Offset(point.dx * size.width, point.dy * size.height);

  @override
  bool shouldRepaint(covariant _FateMapPainter oldDelegate) => oldDelegate.records != records || oldDelegate.chapters != chapters;
}

class _ArcanaHaloPainter extends CustomPainter {
  const _ArcanaHaloPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      paint.color = MysticColors.gold.withValues(alpha: .08 + i * .025);
      canvas.drawCircle(center, 48 + i * 24, paint);
    }
    for (var i = 0; i < 12; i++) {
      final angle = i * pi * 2 / 12;
      final point = center + Offset(cos(angle), sin(angle)) * 104;
      canvas.drawCircle(point, i.isEven ? 2.2 : 1.2, Paint()..color = MysticColors.gold.withValues(alpha: .45));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StoryStarsPainter extends CustomPainter {
  const _StoryStarsPainter({required this.pulse, required this.color});
  final double pulse;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(41);
    for (var i = 0; i < 30; i++) {
      final point = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      canvas.drawCircle(point, i % 5 == 0 ? 1.3 + pulse : .65, Paint()..color = color.withValues(alpha: .13 + (i % 4) * .05));
    }
  }

  @override
  bool shouldRepaint(covariant _StoryStarsPainter oldDelegate) => oldDelegate.pulse != pulse || oldDelegate.color != color;
}

(String, int)? _mostFrequentCard(List<ReadingRecord> records) {
  final counts = <String, int>{};
  for (final record in records) {
    for (final card in record.cards) {
      counts.update(card.card.name, (value) => value + 1, ifAbsent: () => 1);
    }
  }
  if (counts.isEmpty) return null;
  final entry = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
  return (entry.key, entry.value);
}

EmotionalState _dominantEmotion(List<ReadingRecord> records) {
  if (records.isEmpty) return EmotionalState.uncertain;
  final counts = <EmotionalState, int>{};
  for (final record in records) {
    counts.update(record.emotion, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

String _dominantFocus(List<ReadingRecord> records) {
  if (records.isEmpty) return 'Clarity';
  final counts = <ReadingKind, int>{};
  for (final record in records) {
    counts.update(record.kind, (value) => value + 1, ifAbsent: () => 1);
  }
  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key.title;
}
