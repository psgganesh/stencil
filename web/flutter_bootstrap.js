{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    fontFallbackBaseUrl: new URL('assets/assets/fonts/', window.location.href)
      .toString(),
  },
});
