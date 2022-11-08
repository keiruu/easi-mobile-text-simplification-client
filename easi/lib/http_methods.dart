import 'dart:convert';

import 'package:http/http.dart' as http;

// if gagamit ka physical device to debug, run this command sa cmd
// adb reverse tcp:5000 tcp:5000

// Accessing backend hosted on heroku
// sends a request

postSimplifyText(prompt) async {
  var response;
  
  try {
    var url = Uri.parse('https://easi-backend.onrender.com/translate');
    response = await http.post(
      url,
      headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'prompt': prompt,
      }),
    );
  } catch (e) {
    print("There was an error");
    print(e);
  } finally {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    return response.body;
    // var decodedText = json.decode(response.body);
    
    // print("Decoded");
    // print(decodedText['text']);
    // return decodedText['text'];
  }

}