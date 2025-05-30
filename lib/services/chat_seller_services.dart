import 'dart:convert';
import 'dart:io';
import 'package:final_ecommerce/models/chat_seller_message.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import '../config.dart';

class ChatService {
  // FETCH conversation between user and seller
  static Future<List<SellerChatMessage>> fetchMessagesWithSeller({
    required int userId,
    required int sellerId,
  }) async {
    final response = await http.get(
      Uri.parse(
        "${Config.baseUrl}/get_messages_with_seller.php?user_id=$userId&seller_id=$sellerId",
      ),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['status'] == 'success') {
        return (body['messages'] as List)
            .map((e) => SellerChatMessage.fromJson(e))
            .toList();
      }
    }
    throw Exception('Failed to fetch messages');
  }

  // SEND message with optional attachment
  static Future<bool> sendSellerMessage({
    required int userId,
    required int sellerId,
    required String message,
    File? attachment,
  }) async {
    var uri = Uri.parse("${Config.baseUrl}/send_message_to_seller.php");
    var request = http.MultipartRequest('POST', uri);

    request.fields['user_id'] = userId.toString();
    request.fields['seller_id'] = sellerId.toString();
    request.fields['message'] = message;

    if (attachment != null) {
      final mimeType = lookupMimeType(attachment.path);
      final fileStream = http.ByteStream(attachment.openRead());
      final fileLength = await attachment.length();

      request.files.add(
        http.MultipartFile(
          'attachment',
          fileStream,
          fileLength,
          filename: attachment.path.split('/').last,
          contentType: MediaType.parse(mimeType ?? 'application/octet-stream'),
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final result = jsonDecode(responseBody);

    return result['status'] == 'success';
  }
}
