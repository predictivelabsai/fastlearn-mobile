const fastLearnWebOrigin = 'https://fastlearn.fun';

Uri fastLearnWebUri(String path, {bool returnToMobile = false}) {
  final uri = Uri.parse('$fastLearnWebOrigin$path');
  if (!returnToMobile) return uri;

  return uri.replace(
    queryParameters: {...uri.queryParameters, 'return_to': 'mobile'},
  );
}
