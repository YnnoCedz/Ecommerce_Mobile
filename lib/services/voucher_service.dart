import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/voucher.dart';

class VoucherService {
  static Future<List<Voucher>> fetchVouchers() async {
    final response = await http.get(Uri.parse(Config.vouchersListEndpoint));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Voucher.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load vouchers');
    }
  }
}
