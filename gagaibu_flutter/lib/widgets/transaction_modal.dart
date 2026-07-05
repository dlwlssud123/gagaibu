import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';

class TransactionModal extends StatefulWidget {
  const TransactionModal({super.key});

  @override
  State<TransactionModal> createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  TransactionType _txType = TransactionType.EXPENDITURE;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  String _selectedCategory = '식비';
  String _selectedSubCategory = '배달/외식';
  String _selectedAsset = '신용카드';
  DateTime _selectedDate = DateTime.now();

  // 대소분류 카테고리 데이터 맵
  static const Map<String, Map<String, List<String>>> categoryMap = {
    'EXPENDITURE': {
      '식비': ['배달/외식', '카페/디저트', '식재료/밀키트'],
      '마트/편의점': ['편의점', '대형마트'],
      '교통/차량': ['대중교통(지하철/버스)', '택시', '차량 유지비(기름값/정비)'],
      '주거/통신': ['월세/관리비', '공과금(전기/가스/수도)', '통신비(휴대폰/인터넷)'],
      '구독/정기결제': ['OTT/콘텐츠(유튜브 등)', 'IT/생산성 툴(Google 등)'],
      '패션/미용': ['의류/잡화', '미용실/화장품'],
      '생활용품': ['가구/가전', '일반 생활잡화(다이소 등)'],
      '문화/여가': ['문화생활(영화/공연/게임)', '운동/헬스(헬스장 등)', '기타 취미(식물 등)'],
      '건강/의료': ['병원비', '약국(일반 의약품)'],
      '여행/숙박': ['국내 여행', '해외 여행(일본 등)'],
      '교육/자기개발': ['학원/인강(인프런 등)', '도서 구입', '전공/자격증 접수비'],
      '경조사/선물': ['경조사비(축의금 등)', '지인 선물', '데이트 비용'],
      '기타': ['기타 지출']
    },
    'INCOME': {
      '주수입': ['급여(알바비/월급)'],
      '부수입': ['용돈', '당근마켓(중고거래)', '금융수익(배당금/이자)'],
      '기타': ['기타 수입']
    }
  };

  @override
  void initState() {
    super.initState();
    // 초기 날짜 동기화
    final state = Provider.of<AppState>(context, listen: false);
    _selectedDate = state.selectedDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _txType = type;
      if (type == TransactionType.EXPENDITURE) {
        _selectedCategory = '식비';
        _selectedSubCategory = '배달/외식';
      } else {
        _selectedCategory = '주수입';
        _selectedSubCategory = '급여(알바비/월급)';
      }
    });
  }

  void _onCategoryChanged(String cat) {
    setState(() {
      _selectedCategory = cat;
      final typeStr = _txType == TransactionType.EXPENDITURE ? 'EXPENDITURE' : 'INCOME';
      final subs = categoryMap[typeStr]![cat] ?? [];
      _selectedSubCategory = subs.isNotEmpty ? subs[0] : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final typeStr = _txType == TransactionType.EXPENDITURE ? 'EXPENDITURE' : 'INCOME';
    final mainCats = categoryMap[typeStr]!.keys.toList();
    final subCats = categoryMap[typeStr]![_selectedCategory] ?? [];

    final isExp = _txType == TransactionType.EXPENDITURE;
    final themeColor = isExp ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom, // 소프트 키보드 대응 여백
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 바 데코레이션 핸들
              Center(
                child: Container(
                  width: 36.0,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 14.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),

              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '수입/지출 빠른 등록',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20.0),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),

              // 1. 거래 유형 선택기
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: '지출',
                      isActive: isExp,
                      color: const Color(0xFFEF4444),
                      onTap: () => _onTypeChanged(TransactionType.EXPENDITURE),
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: _buildTypeButton(
                      label: '수입',
                      isActive: !isExp,
                      color: const Color(0xFF3B82F6),
                      onTap: () => _onTypeChanged(TransactionType.INCOME),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 2. 금액 입력창 (숫자 키보드 연동)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey[200]!, width: 1.0),
                ),
                child: Row(
                  children: [
                    Text(
                      '₩',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number, // 시스템 숫자 키보드
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w900,
                          color: themeColor,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          hintText: '0',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // 3. 대분류 카테고리 칩 선택
              const Text(
                '대분류 선택',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black45),
              ),
              const SizedBox(height: 8.0),
              SizedBox(
                height: 38.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: mainCats.length,
                  itemBuilder: (context, index) {
                    final cat = mainCats[index];
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSel,
                        onSelected: (selected) {
                          if (selected) _onCategoryChanged(cat);
                        },
                        selectedColor: const Color(0xFF343A40),
                        backgroundColor: Colors.grey[100],
                        side: BorderSide.none,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12.0),

              // 4. 소분류 카테고리 칩 선택
              const Text(
                '소분류 선택',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black45),
              ),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: subCats.map((sub) {
                  final isSel = _selectedSubCategory == sub;
                  final activeBg = isExp ? const Color(0xFFFFE3E3) : const Color(0xFFE7F5FF);
                  final activeFg = isExp ? const Color(0xFFE03131) : const Color(0xFF1C7ED6);

                  return ChoiceChip(
                    label: Text(
                      sub,
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        color: isSel ? activeFg : Colors.black87,
                      ),
                    ),
                    selected: isSel,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedSubCategory = sub;
                        });
                      }
                    },
                    selectedColor: activeBg,
                    backgroundColor: Colors.grey[50],
                    side: BorderSide(
                      color: isSel ? activeFg.withOpacity(0.5) : Colors.grey[200]!,
                      width: 0.8,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),

              // 5. 내용/메모 기입창
              const Text(
                '내용 / 메모',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black45),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: _contentController,
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: '어디에 쓰셨나요? (예: 홈플러스 장보기)',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // 6. 거래 날짜 선택창
              const Text(
                '거래 날짜',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black45),
              ),
              const SizedBox(height: 8.0),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd').format(_selectedDate),
                        style: const TextStyle(fontSize: 13.0, color: Colors.black87),
                      ),
                      const Icon(Icons.calendar_month, size: 16.0, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // 7. 결제 자산 선택
              const Text(
                '결제 자산 선택',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.black45),
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  Expanded(
                    child: _buildAssetButton(
                      label: '카드',
                      icon: Icons.credit_card,
                      isActive: _selectedAsset == '신용카드',
                      onTap: () => setState(() => _selectedAsset = '신용카드'),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: _buildAssetButton(
                      label: '현금/계좌',
                      icon: Icons.account_balance,
                      isActive: _selectedAsset == '현금/이체',
                      onTap: () => setState(() => _selectedAsset = '현금/이체'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

              // 8. 등록 완료 버튼
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final amountVal = int.tryParse(_amountController.text);
                    if (amountVal == null || amountVal <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('금액을 정확히 입력해 주세요.')),
                      );
                      return;
                    }
                    
                    final contentVal = _contentController.text.trim();
                    final finalContent = contentVal.isNotEmpty ? contentVal : _selectedSubCategory;

                    final tx = Transaction(
                      userId: state.userId,
                      amount: amountVal,
                      category: _selectedCategory,
                      subCategory: _selectedSubCategory,
                      content: finalContent,
                      transactionDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
                      transactionType: _txType,
                    );

                    final success = await state.addTransaction(tx);
                    if (success) {
                      Navigator.pop(context); // 모달 닫기
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('서버에 지출을 등록하지 못했습니다.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.check, color: Colors.white, size: 18.0),
                  label: const Text(
                    '입력 완료',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14.0),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required String label,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.0,
        decoration: BoxDecoration(
          color: isActive ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: isActive
              ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildAssetButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isActive ? const Color(0xFF343A40) : const Color(0xFFE9ECEF),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.0, color: isActive ? const Color(0xFF343A40) : Colors.grey),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: isActive ? const Color(0xFF343A40) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
