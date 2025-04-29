import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class FaceApiService {
  static Future<Map<String, dynamic>?> searchFace(Uint8List imageBytes) async {
    final uri = Uri.parse(Constants.faceCheckSearchUrl);

    final request = http.MultipartRequest('POST', uri)
      ..headers['x-api-key'] = Constants.faceCheckApiKey
      ..files.add(http.MultipartFile.fromBytes('photo', imageBytes, filename: 'face.jpg'));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("FaceCheck failed: ${response.statusCode} ${response.body}");
      return null;
    }
  }

  static Future<Map<String, dynamic>?> enrollFace(Uint8List imageBytes, String userId) async {
    final uri = Uri.parse(Constants.faceCheckEnrollUrl);

    final request = http.MultipartRequest('POST', uri)
      ..headers['x-api-key'] = Constants.faceCheckApiKey
      ..fields['user_id'] = userId
      ..files.add(http.MultipartFile.fromBytes('photo', imageBytes, filename: 'face.jpg'));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Enrollment failed: ${response.statusCode} ${response.body}");
      return null;
    }
  }
}
