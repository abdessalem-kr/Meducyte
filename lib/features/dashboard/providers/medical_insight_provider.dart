import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicalInsight {
  final String title;
  final String source;
  final String date;
  final String url;
  final String? abstractText;

  const MedicalInsight({
    required this.title,
    required this.source,
    required this.date,
    required this.url,
    this.abstractText,
  });
}

const List<MedicalInsight> fallbackInsights = [
  MedicalInsight(
    title: 'SGLT2 Inhibitors in Patients with Heart Failure',
    source: 'New England Journal of Medicine',
    date: '2024',
    url: 'https://pubmed.ncbi.nlm.nih.gov/32955177/',
    abstractText: 'SGLT2 inhibitors reduce the risk of cardiovascular death or hospitalization for heart failure.',
  ),
  MedicalInsight(
    title: 'Immunotherapy in Advanced Non-Small-Cell Lung Cancer',
    source: 'The Lancet',
    date: '2024',
    url: 'https://pubmed.ncbi.nlm.nih.gov/30353860/',
    abstractText: 'Pembrolizumab shows durable survival benefits in patients with PD-L1 expressing NSCLC.',
  ),
  MedicalInsight(
    title: 'Artificial Intelligence in the Detection of Diabetic Retinopathy',
    source: 'Nature Medicine',
    date: '2025',
    url: 'https://pubmed.ncbi.nlm.nih.gov/31591599/',
    abstractText: 'Deep learning systems achieve high sensitivity and specificity in screening diabetic retinopathy.',
  ),
];

final randomMedicalTerms = [
  'heart failure therapy',
  'diabetic nephropathy',
  'lung cancer immunotherapy',
  'alzheimers monoclonal antibodies',
  'hypertension guidelines',
  'stroke endovascular therapy',
  'cardiovascular risk factor',
  'crispr gene editing clinical',
  'rheumatoid arthritis biologics',
  'chronic kidney disease sglt2',
  'asthma biologic therapy',
];

final medicalInsightProvider = FutureProvider<MedicalInsight>((ref) async {
  final dio = Dio();
  final random = Random();
  final term = randomMedicalTerms[random.nextInt(randomMedicalTerms.length)];

  try {
    // 1. Search for recent articles matching the random medical term
    final searchUrl = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi';
    final searchResponse = await dio.get(
      searchUrl,
      queryParameters: {
        'db': 'pubmed',
        'term': '$term AND "has abstract"[Filter]',
        'retmax': '5',
        'retmode': 'json',
      },
    );

    if (searchResponse.statusCode == 200 && searchResponse.data != null) {
      final data = searchResponse.data;
      if (data is Map<String, dynamic> && data.containsKey('esearchresult')) {
        final idList = data['esearchresult']['idlist'] as List?;
        if (idList != null && idList.isNotEmpty) {
          // Pick a random ID from the retrieved list
          final selectedId = idList[random.nextInt(idList.length)].toString();

          // 2. Fetch metadata for the selected article
          final summaryUrl = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi';
          final summaryResponse = await dio.get(
            summaryUrl,
            queryParameters: {
              'db': 'pubmed',
              'id': selectedId,
              'retmode': 'json',
            },
          );

          if (summaryResponse.statusCode == 200 && summaryResponse.data != null) {
            final summaryData = summaryResponse.data;
            if (summaryData is Map<String, dynamic> && summaryData.containsKey('result')) {
              final result = summaryData['result'] as Map<String, dynamic>;
              final articleDetails = result[selectedId] as Map<String, dynamic>?;

              if (articleDetails != null) {
                final String title = articleDetails['title'] ?? 'Medical Insight';
                final String source = articleDetails['source'] ?? 'PubMed Source';
                final String pubDate = articleDetails['pubdate'] ?? '';
                final String year = pubDate.split(' ').first;

                // Clean title if it ends with a dot or has brackets
                var cleanTitle = title.trim();
                if (cleanTitle.endsWith('.')) {
                  cleanTitle = cleanTitle.substring(0, cleanTitle.length - 1);
                }
                if (cleanTitle.startsWith('[') && cleanTitle.endsWith(']')) {
                  cleanTitle = cleanTitle.substring(1, cleanTitle.length - 1);
                }

                return MedicalInsight(
                  title: cleanTitle,
                  source: source,
                  date: year,
                  url: 'https://pubmed.ncbi.nlm.nih.gov/$selectedId/',
                );
              }
            }
          }
        }
      }
    }
  } catch (e) {
    debugPrint('DEBUG: medicalInsightProvider error: $e');
  }

  // Fallback to a high-quality curated insight if request fails
  return fallbackInsights[random.nextInt(fallbackInsights.length)];
});
