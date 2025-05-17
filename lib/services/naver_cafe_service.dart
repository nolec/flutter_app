import 'dart:convert';
import 'package:http/http.dart' as http;

class NaverCafeService {
  final String clientId;
  final String clientSecret;

  NaverCafeService({required this.clientId, required this.clientSecret});

  Future<List<Map<String, dynamic>>> fetchCafes({
    required double lat,
    required double lng,
    int radius = 10,
    int display = 10,
  }) async {
    final url = Uri.parse(
      'https://openapi.naver.com/v1/search/local.json?query=카페&display=$display&start=1&sort=random&coordinate=$lng,$lat&radius=$radius',
    );
    final response = await http.get(
      url,
      headers: {
        'X-Naver-Client-Id': clientId,
        'X-Naver-Client-Secret': clientSecret,
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      return List<Map<String, dynamic>>.from(data['items']);
    } else {
      throw Exception('카페 목록을 불러오지 못했습니다: ${response.body}');
    }
  }
}
