import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get rapidApiKey => dotenv.env['RAPIDAPI_KEY'] ?? '';

  static String get rapidApiHostAmazon =>
      'real-time-amazon-data.p.rapidapi.com';

  static String get rapidApiHostFlipkart =>
      'real-time-flipkart-api.p.rapidapi.com';

  static String get rapidApiHostGpt =>
      'cheapest-gpt-4-turbo-gpt-4-vision-chatgpt-openai-ai-api.p.rapidapi.com';
}
