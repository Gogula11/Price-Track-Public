import 'dart:convert';
import 'package:TrueTrack/services/rapidapi_client.dart';

class AiService {
  final RapidApiClient _client;
  final String _host =
      'cheapest-gpt-4-turbo-gpt-4-vision-chatgpt-openai-ai-api.p.rapidapi.com';

  AiService(this._client);

  Future<String> summarizeReviews({
    required dynamic reviews,
    required String source,
    required String productUrl,
    required String productName,
  }) async {
    final prompt = _buildReviewPrompt(reviews, source, productUrl, productName);
    return _getCompletion(prompt);
  }

  Future<String> summarizeSpecs({
    required String productName,
    required Map<String, dynamic> specifications,
  }) async {
    final prompt = '''
Analyze these product specifications for $productName and provide a concise summary:
- Highlight 3-5 key features
- Mention any unique selling points
- Suggest ideal use cases
- Note any potential drawbacks
- Avoid using bolding or italics symbols
- maximum of 150 words and give points wise output
- do not use asterisks
- do not start a sentence if you cannot complete it

Specifications:
${jsonEncode(specifications)}
''';
    return _getCompletion(prompt);
  }

  Future<String> _getCompletion(String prompt) async {
    const url =
        'https://cheapest-gpt-4-turbo-gpt-4-vision-chatgpt-openai-ai-api.p.rapidapi.com/v1/chat/completions';

    final response = await _client.post(url, _host,
        body: json.encode({
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "model": "gpt-4o",
          "max_tokens": 200,
          "temperature": 0.9,
        }));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices']?[0]?['message']?['content'] ??
          'No summary available.';
    }

    return 'Failed to generate summary. Status code: ${response.statusCode}';
  }

  String _buildReviewPrompt(
      dynamic reviews, String source, String productUrl, String productName) {
    final reviewsText = source == 'Amazon'
        ? reviews as String
        : _formatFlipkartReviews(reviews as List<dynamic>);

    return '''
For the product "$productName", please summarize these $source reviews
in under 100 words and suggest alternative products to the user without
mentioning the exact product name. Suggest 2-3 brands along with their
key advantages:

$reviewsText

Product URL: $productUrl

Guidelines:
1. Keep the summary concise.
2. Focus on the key positive/negative aspects.
3. Suggest 2-3 alternative brands.
4. Mention brand advantages only.
5. Avoid marketing language.
6. Avoid using bolding or italics symbols.
7. Also give the alternative in another paragraph and in point wise format.
''';
  }

  String _formatFlipkartReviews(List<dynamic> reviews) {
    if (reviews.isEmpty) return 'No customer reviews available.';
    return reviews.take(5).map((review) {
      return '"${review['title'] ?? 'No title'}"\n'
          '${review['review'] ?? 'No review content'}\n'
          '- ${review['reviewer'] ?? 'Anonymous'} '
          'from ${review['location'] ?? 'Unknown location'}, '
          'on ${review['date'] ?? 'Unknown date'}\n\n';
    }).join();
  }
}
