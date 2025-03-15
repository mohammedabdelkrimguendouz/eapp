import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  final String cloudName = "dab9slohu";
  final String apiKey = "928934898761597";
  final String apiSecret = "L9_pI0KIQ4RXg83xAgufSRNRjzg";

  Future<String?> uploadImage(File imageFile) async {
    try {
      var url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      var request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = "ml_default" // يمكنك تخصيص upload preset من Cloudinary
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        print(jsonResponse['secure_url']);
        return jsonResponse['secure_url'];
      } else {
        return null;
      }
    } catch (e) {

      return null;
    }
  }
}
