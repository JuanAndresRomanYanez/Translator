import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translator App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TranslationScreen(),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final apiKey = "TU_API_KEY"; // Reemplaza con tu propia API key de Google Cloud Translation

  String _inputText = '';
  String _outputText = '';
  String? selectedSourceLanguage;
  String? selectedTargetLanguage;

  final languages = [
    {"code": "en", "name": "English"},
    {"code": "es", "name": "Spanish"},
    {"code": "fr", "name": "French"},
    {"code": "de", "name": "German"},
    // Agrega más idiomas según sea necesario
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translator'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter text to translate',
              ),
              onChanged: (value) {
                setState(() {
                  _inputText = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedSourceLanguage,
                    hint: Text('Select source language'),
                    items: languages.map((language) {
                      return DropdownMenuItem<String>(
                        value: language["code"],
                        child: Text(language["name"]!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSourceLanguage = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedTargetLanguage,
                    hint: Text('Select target language'),
                    items: languages.map((language) {
                      return DropdownMenuItem<String>(
                        value: language["code"],
                        child: Text(language["name"]!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTargetLanguage = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                if (_inputText.isNotEmpty && selectedTargetLanguage != null) {
                  final translation = await translateText(
                      _inputText, selectedTargetLanguage!);
                  setState(() {
                    _outputText = translation;
                  });
                }
              },
              child: Text('Translate'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Translated text:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: Container(
                height: 200,
                child: SingleChildScrollView(
                  child: Text(
                    _outputText,
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> translateText(
      String text, String targetLanguageCode) async {
    final response = await http.post(
      Uri.parse(
          'https://translation.googleapis.com/language/translate/v2?key=$apiKey'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'q': text,
        'target': targetLanguageCode,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final translatedText = data['data']['translations'][0]['translatedText'];
      return translatedText;
    } else {
      throw Exception('Failed to translate text');
    }
  }
}
