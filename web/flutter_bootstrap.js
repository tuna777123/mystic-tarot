{{flutter_js}}
{{flutter_build_config}}

const engineConfig = {
  renderer: "canvaskit",
  canvasKitBaseUrl: "canvaskit",
  multiViewEnabled: false,
};

_flutter.loader.load({
  config: engineConfig,
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine(engineConfig);
    await appRunner.runApp();
  },
});
