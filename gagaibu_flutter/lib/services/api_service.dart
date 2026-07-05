import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import '../models/budget.dart';

class ApiService {
  // 로컬 스프링 부트 포트 8080 통신용 Base URL
  // 안드로이드 에뮬레이터 환경에서는 10.0.2.2가 로컬 컴퓨터의 localhost에 해당합니다.
  // 실기기 또는 iOS 시뮬레이터 구동 시에는 실제 컴퓨터의 IP 주소 또는 localhost로 변경 가능합니다.
  static const String baseUrl = 'http://10.0.2.2:8080';

  // 1. 유저 정보 조회
  static async Map<String, dynamic> getUser(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/v1/users/$userId'));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      throw Exception('유저 정보를 조회할 수 없습니다. Status: ${response.statusCode}');
    }
  }

  // 2. AI 페르소나 변경
  static async bool updatePersona(int userId, String personaType) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/users/$userId/persona?personaType=$personaType'),
    );
    return response.statusCode == 200;
  }

  // 3. 예산 조회 (특정 연/월)
  static async Budget? getBudget(int userId, int year, int month) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/budgets?userId=$userId&year=$year&month=$month'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return Budget.fromJson(data as Map<String, dynamic>);
    } else if (response.statusCode == 204 || response.statusCode == 404) {
      return null; // 예산이 아직 설정 안 됨
    } else {
      throw Exception('예산 조회 실패. Status: ${response.statusCode}');
    }
  }

  // 4. 예산 설정/변경
  static async bool setBudget(int userId, int amount, int year, int month) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/budgets'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'amount': amount,
        'year': year,
        'month': month,
      }),
    );
    return response.statusCode == 200;
  }

  // 5. 가계부 내역 기간 조회
  static async List<Transaction> getTransactions(int userId, String startDate, String endDate) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/account-books?userId=$userId&startDate=$startDate&endDate=$endDate'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return list.map((item) => Transaction.fromJson(item as Map<String, dynamic>)).toList();
    } else {
      throw Exception('거래 내역 로드 실패. Status: ${response.statusCode}');
    }
  }

  // 6. 거래 내역 신규 등록 (대분류-소분류 전달 포함)
  static async bool createTransaction(Transaction tx) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/account-books'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(tx.toJson()),
    );
    return response.statusCode == 200;
  }

  // 7. 거래 내역 삭제
  static async bool deleteTransaction(int txId) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/v1/account-books/$txId'));
    return response.statusCode == 200;
  }

  // 8. 기존 AI 리포트 이력 조회
  static async List<Map<String, dynamic>> getAiReports(int userId, String reportType) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/ai-reports?userId=$userId&reportType=$reportType'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> list = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } else {
      return [];
    }
  }

  // 9. AI 리포트 즉시 생성 요청
  static async Map<String, dynamic> generateAiReport(int userId, String reportDate, String reportType) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/ai-reports/generate?userId=$userId&reportDate=$reportDate&reportType=$reportType'),
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } else {
      throw Exception('AI 리포트 생성 실패. Status: ${response.statusCode}');
    }
  }
}
