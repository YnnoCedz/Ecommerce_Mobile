import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game_product.dart';
import '../config.dart';

class GameService {
  static Future<List<GameProduct>> fetchGames() async {
    final response = await http.get(Uri.parse(Config.gamesEndpoint));
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => GameProduct.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load games');
    }
  }
}
