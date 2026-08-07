class StoreScreenshotDevice {
  const StoreScreenshotDevice({
    required this.slug,
    required this.width,
    required this.height,
    required this.devicePixelRatio,
  });

  final String slug;
  final int width;
  final int height;
  final double devicePixelRatio;

  double get logicalWidth => width / devicePixelRatio;
  double get logicalHeight => height / devicePixelRatio;
}

enum StoreScreenshotScene {
  dailyGuidance('01-daily-guidance'),
  explainableReading('02-explainable-reading'),
  mysticMirror('03-mystic-mirror'),
  livingPath('04-living-path'),
  mysticPlus('05-free-ad-supported');

  const StoreScreenshotScene(this.slug);

  final String slug;
}

const storeScreenshotLocales = <String>['en', 'tr', 'es', 'fr', 'pt-BR'];

const storeScreenshotDevices = <StoreScreenshotDevice>[
  StoreScreenshotDevice(
    slug: 'apple-6.9',
    width: 1290,
    height: 2796,
    devicePixelRatio: 3,
  ),
  StoreScreenshotDevice(
    slug: 'google-play-phone',
    width: 1080,
    height: 1920,
    devicePixelRatio: 3,
  ),
];

int get expectedStoreScreenshotCount =>
    storeScreenshotLocales.length *
    storeScreenshotDevices.length *
    StoreScreenshotScene.values.length;

String storeScreenshotRelativePath({
  required StoreScreenshotDevice device,
  required String locale,
  required StoreScreenshotScene scene,
}) => '${device.slug}/$locale/${scene.slug}.png';
