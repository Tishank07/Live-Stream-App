import 'dart:convert';
import 'package:http/http.dart' as http;

// Auth token we will use to generate a meeting and connect to it
String token =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcGlrZXkiOiJkN2RmNWQxNS0xODI2LTRiODktYjljZS1kNDVlZmYyMGY0NzQiLCJwZXJtaXNzaW9ucyI6WyJhbGxvd19qb2luIl0sImlhdCI6MTcxMDMwNzY2OCwiZXhwIjoxNzEyODk5NjY4fQ.tEANOiYk_4hQNkhkmy3g-enRoAn7MRntYrunrT4tBVc";

// API call to create meeting

Future<String> createMeeting() async {
  final http.Response httpResponse = await http.post(
    Uri.parse("https://api.videosdk.live/v2/rooms"),
    headers: {'Authorization': token},
  );

  return json.decode(httpResponse.body)['roomId'];
}

