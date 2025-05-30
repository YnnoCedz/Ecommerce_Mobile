import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressService {
  static const String baseUrl = 'https://psgc.gitlab.io/api';

  static Future<List<Map<String, String>>> fetchProvinces() async {
    final res = await http.get(Uri.parse('$baseUrl/provinces/'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      List<Map<String, String>> provinces =
          data.map<Map<String, String>>((item) {
            return {'code': item['code'], 'name': item['name']};
          }).toList();

      // Sort alphabetically by 'name'
      provinces.sort((a, b) => a['name']!.compareTo(b['name']!));

      return provinces;
    }
    throw Exception('Failed to load provinces');
  }

  static Future<List<Map<String, String>>> fetchCities(
    String provinceCode,
  ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/provinces/$provinceCode/cities-municipalities/'),
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map<Map<String, String>>((item) {
        return {'code': item['code'], 'name': item['name']};
      }).toList();
    }
    throw Exception('Failed to load cities');
  }

  static Future<List<Map<String, String>>> fetchBarangays(
    String cityCode,
  ) async {
    final res = await http.get(
      Uri.parse('$baseUrl/cities-municipalities/$cityCode/barangays/'),
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map<Map<String, String>>((item) {
        return {'code': item['code'], 'name': item['name']};
      }).toList();
    }
    throw Exception('Failed to load barangays');
  }
}
