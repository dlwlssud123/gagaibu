import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/budget.dart';
import '../services/api_service.dart';

class AppState with ChangeNotifier {
  final int userId = 1;
  
  // 1. 활성 네비게이션 탭
  String _activeTab = 'home';
  String get activeTab => _activeTab;

  // 2. 유저 정보 및 AI 페르소나
  String _currentPersona = 'MOM';
  String get currentPersona => _currentPersona;

  // 3. 탐색 날짜 상태
  DateTime _currentViewDate = DateTime.now(); // 달력 및 당월 조회 기준
  DateTime get currentViewDate => _currentViewDate;

  DateTime _selectedDate = DateTime.now(); // 달력에서 터치한 선택 일자
  DateTime get selectedDate => _selectedDate;

  // 4. 예산 및 지출 목록 데이터
  int _targetBudget = 0;
  int get targetBudget => _targetBudget;

  int _totalExpenditure = 0;
  int get totalExpenditure => _totalExpenditure;

  List<Transaction> _transactionList = [];
  List<Transaction> get transactionList => _transactionList;

  // 5. 대시보드 소비 필터 상태
  String _homeFilter = 'ALL'; // ALL | OVERSPEND | INCOME | CAT_...
  String get homeFilter => _homeFilter;

  // 6. AI 보고서 및 로딩 상태
  String _currentReportType = 'DAILY'; // DAILY | WEEKLY | MONTHLY
  String get currentReportType => _currentReportType;

  Map<String, dynamic>? _latestReport;
  Map<String, dynamic>? get latestReport => _latestReport;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isReportGenerating = false;
  bool get isReportGenerating => _isReportGenerating;

  // 초기화 및 데이터 연동
  AppState() {
    initializeData();
  }

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. 유저 정보 페치
      final user = await ApiService.getUser(userId);
      _currentPersona = user['personaType'] ?? 'MOM';
      
      // 2. 예산 및 거래 내역 로드
      await fetchBudgetAndTransactions();
    } catch (e) {
      debugPrint('초기화 데이터 패치 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 예산 및 거래 내역 갱신
  Future<void> fetchBudgetAndTransactions() async {
    final year = _currentViewDate.year;
    final month = _currentViewDate.month;

    // 예산 조회
    try {
      final budget = await ApiService.getBudget(userId, year, month);
      _targetBudget = budget?.amount ?? 0;
    } catch (e) {
      _targetBudget = 0;
    }

    // 당월 범위 계산
    final startStr = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(year, month + 1, 0).day;
    final endStr = '$year-${month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';

    // 거래 데이터 페치
    try {
      _transactionList = await ApiService.getTransactions(userId, startStr, endStr);
      _totalExpenditure = _transactionList
          .where((tx) => tx.transactionType == TransactionType.EXPENDITURE)
          .fold(0, (sum, tx) => sum + tx.amount);
    } catch (e) {
      _transactionList = [];
      _totalExpenditure = 0;
    }
    
    notifyListeners();
  }

  // 탭 전환
  void switchTab(String tabName) {
    _activeTab = tabName;
    notifyListeners();

    if (tabName == 'home' || tabName == 'history') {
      fetchBudgetAndTransactions();
    } else if (tabName == 'report') {
      fetchReportHistory();
    }
  }

  // 페르소나 설정 변경
  Future<void> setPersona(String persona) async {
    try {
      final success = await ApiService.updatePersona(userId, persona);
      if (success) {
        _currentPersona = persona;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('페르소나 변경 실패: $e');
    }
  }

  // 당월 목표 예산 업데이트
  Future<bool> updateTargetBudget(int amount) async {
    final year = _currentViewDate.year;
    final month = _currentViewDate.month;
    try {
      final success = await ApiService.setBudget(userId, amount, year, month);
      if (success) {
        _targetBudget = amount;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('예산 저장 실패: $e');
    }
    return false;
  }

  // 거래 내역 등록
  Future<bool> addTransaction(Transaction tx) async {
    try {
      final success = await ApiService.createTransaction(tx);
      if (success) {
        // 등록 성공 시 활성 날짜 갱신
        final parsedDate = DateTime.parse(tx.transactionDate);
        _selectedDate = parsedDate;
        _currentViewDate = DateTime(parsedDate.year, parsedDate.month, 1);
        
        await fetchBudgetAndTransactions();
        return true;
      }
    } catch (e) {
      debugPrint('거래 등록 실패: $e');
    }
    return false;
  }

  // 거래 내역 삭제
  Future<void> deleteTransaction(int id) async {
    try {
      final success = await ApiService.deleteTransaction(id);
      if (success) {
        await fetchBudgetAndTransactions();
      }
    } catch (e) {
      debugPrint('거래 삭제 실패: $e');
    }
  }

  // 소비 필터 스위칭
  void updateHomeFilter(String filter) {
    _homeFilter = filter;
    notifyListeners();
  }

  // 필터링이 가미된 최근 소비 목록 리스트 반환
  List<Transaction> get filteredRecentTransactions {
    List<Transaction> list = [..._transactionList];

    if (_homeFilter == 'OVERSPEND') {
      list = list.where((tx) => tx.transactionType == TransactionType.EXPENDITURE && tx.amount >= 30000).toList();
    } else if (_homeFilter == 'INCOME') {
      list = list.where((tx) => tx.transactionType == TransactionType.INCOME).toList();
    } else if (_homeFilter.startsWith('CAT_')) {
      final cat = _homeFilter.substring(4);
      list = list.where((tx) => tx.category == cat).toList();
    }

    // 최근 거래순 정렬
    list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return list;
  }

  // 캘린더 월 탐색
  void changeMonth(int direction) {
    _currentViewDate = DateTime(_currentViewDate.year, _currentViewDate.month + direction, 1);
    fetchBudgetAndTransactions();
  }

  // 캘린더 일자 클릭 시 상세 타임라인 선택
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // 선택 날짜의 거래 내역 추출
  List<Transaction> get selectedDateTransactions {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _transactionList.where((tx) => tx.transactionDate == dateStr).toList();
  }

  // 선택 날짜의 총 지출액 계산
  int get selectedDateTotalExpenditure {
    return selectedDateTransactions
        .where((tx) => tx.transactionType == TransactionType.EXPENDITURE)
        .fold(0, (sum, tx) => sum + tx.amount);
  }

  // AI 리포트 주기 전환
  void switchReportType(String type) {
    _currentReportType = type;
    _latestReport = null;
    notifyListeners();
    fetchReportHistory();
  }

  // 기존 저장된 리포트 이력 조회
  Future<void> fetchReportHistory() async {
    try {
      final list = await ApiService.getAiReports(userId, _currentReportType);
      if (list.isNotEmpty) {
        _latestReport = list[0];
      } else {
        _latestReport = null;
      }
      notifyListeners();
    } catch (e) {
      _latestReport = null;
      notifyListeners();
    }
  }

  // AI 리포트 즉시 분석 및 생성
  Future<void> generateReport() async {
    _isReportGenerating = true;
    notifyListeners();

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      final report = await ApiService.generateAiReport(userId, dateStr, _currentReportType);
      _latestReport = report;
    } catch (e) {
      debugPrint('리포트 생성 오류: $e');
    } finally {
      _isReportGenerating = false;
      notifyListeners();
    }
  }
}
