import 'package:TrueTrack/services/ai_service.dart';
import 'package:TrueTrack/services/mock/mock_data.dart';

class MockAiService implements AiService {
  @override
  Future<String> summarizeReviews({
    required dynamic reviews,
    required String source,
    required String productUrl,
    required String productName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return mockReviewSummary;
  }

  @override
  Future<String> summarizeSpecs({
    required String productName,
    required Map<String, dynamic> specifications,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockSpecSummary;
  }
}
