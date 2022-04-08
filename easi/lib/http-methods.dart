import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

// if gagamit ka physical device to debug, run this command sa cmd
// adb reverse tcp:3000 tcp:3000

// Make a request

postSimplifyText(prompt) async {
  try {
    var url = Uri.parse('http://localhost:3000/translate');
    var response = await http.post(
      url,
      headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'prompt': prompt,
      }),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    var decodedText = json.decode(response.body);

    return decodedText['text'];
  } catch (e) {
    print("There was an error");
    print(e);
  }
}