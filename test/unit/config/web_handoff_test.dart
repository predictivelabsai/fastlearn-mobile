import 'package:flutter_test/flutter_test.dart';
import 'package:carhero/config/web_handoff.dart';

void main() {
  test('mobile auth handoff uses the fixed FastLearn return marker', () {
    final uri = fastLearnWebUri('/auth/login', returnToMobile: true);

    expect(uri.origin, 'https://fastlearn.fun');
    expect(uri.path, '/auth/login');
    expect(uri.queryParameters, {'return_to': 'mobile'});
  });

  test('ordinary web handoffs do not add the mobile return marker', () {
    expect(
      fastLearnWebUri('/app/chat').toString(),
      'https://fastlearn.fun/app/chat',
    );
  });
}
