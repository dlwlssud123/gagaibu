import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final oCcy = NumberFormat("#,###", "ko_KR");

    final year = state.currentViewDate.year;
    final month = state.currentViewDate.month;

    // 1일의 요일 및 달의 총 일수 계산
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstDayOfWeek = firstDayOfMonth.weekday % 7; // 0: 일요일, 1: 월요일, ...
    final totalDays = DateTime(year, month + 1, 0).day;

    // 이전 달 마지막 일수
    final prevTotalDays = DateTime(year, month, 0).day;

    return Column(
      children: [
        // 1. 월 선택 탐색 바
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.black54),
                onPressed: () => state.changeMonth(-1),
              ),
              Text(
                '$year년 $month월',
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.black54),
                onPressed: () => state.changeMonth(1),
              ),
            ],
          ),
        ),

        // 2. 요일 헤더 표시줄
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
              final isSun = day == '일';
              final isSat = day == '토';
              Color txtColor = Colors.black54;
              if (isSun) txtColor = Colors.red[400]!;
              if (isSat) txtColor = Colors.blue[400]!;

              return SizedBox(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: txtColor,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8.0),

        // 3. 달력 일자 그리드 카드
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6.0,
                crossAxisSpacing: 6.0,
                childAspectRatio: 0.9,
              ),
              itemCount: firstDayOfWeek + totalDays,
              itemBuilder: (context, index) {
                // 이전 달 빈 칸
                if (index < firstDayOfWeek) {
                  final dayNum = prevTotalDays - (firstDayOfWeek - index) + 1;
                  return Center(
                    child: Text(
                      '$dayNum',
                      style: const TextStyle(color: Colors.black26, fontSize: 13.0),
                    ),
                  );
                }

                // 이번 달 일자
                final dayNum = index - firstDayOfWeek + 1;
                final cellDate = DateTime(year, month, dayNum);
                final isSelected = state.selectedDate.year == year &&
                    state.selectedDate.month == month &&
                    state.selectedDate.day == dayNum;

                // 일일 지출 합계
                final dateStr = '$year-${month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
                final dayExpenditure = state.transactionList
                    .where((tx) => tx.transactionDate == dateStr && tx.transactionType == TransactionType.EXPENDITURE)
                    .fold(0, (sum, tx) => sum + tx.amount);

                return GestureDetector(
                  onTap: () => state.selectDate(cellDate),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF343A40) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 1)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNum',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (cellDate.weekday == 7 ? Colors.red[600] : (cellDate.weekday == 6 ? Colors.blue[600] : Colors.black87)),
                          ),
                        ),
                        if (dayExpenditure > 0) ...[
                          const SizedBox(height: 2.0),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '-${_formatWonShort(dayExpenditure)}',
                              style: TextStyle(
                                fontSize: 9.0,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.orange[300] : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16.0),

        // 4. 선택 일자 타임라인 리스트
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 타임라인 헤더
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.selectedDate.month}월 ${state.selectedDate.day}일 상세 내역',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '지출 합계: ${oCcy.format(state.selectedDateTotalExpenditure)}원',
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE9ECEF)),

                // 타임라인 아이템 리스트
                Expanded(child: _buildTimelineList(context, state, oCcy)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineList(BuildContext context, AppState state, NumberFormat oCcy) {
    final list = state.selectedDateTransactions;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment, size: 40.0, color: Colors.grey[300]),
            const SizedBox(height: 8.0),
            Text(
              '해당 날짜에 등록된 지출/수입이 없습니다.',
              style: TextStyle(fontSize: 12.5, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
      itemBuilder: (context, index) {
        final tx = list[index];
        final isExp = tx.transactionType == TransactionType.EXPENDITURE;
        final sign = isExp ? '-' : '+';
        final color = isExp ? Colors.red[700] : Colors.teal[700];
        final bg = isExp ? Colors.red[50] : Colors.teal[50];
        
        final catLabel = tx.subCategory != null ? '${tx.category} > ${tx.subCategory}' : tx.category;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getCategoryIcon(tx.category),
                  size: 18.0,
                  color: color,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.content,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      catLabel,
                      style: const TextStyle(
                        fontSize: 11.0,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${oCcy.format(tx.amount)}원',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  GestureDetector(
                    onTap: () {
                      if (tx.id != null) {
                        state.deleteTransaction(tx.id!);
                      }
                    },
                    child: Text(
                      '삭제',
                      style: TextStyle(
                        fontSize: 11.0,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatWonShort(int val) {
    if (val >= 10000) {
      double value = val / 10000;
      if (value == value.toInt()) {
        return '${value.toInt()}만';
      }
      return '${value.toStringAsFixed(1)}만';
    }
    return '${(val / 1000).toStringAsFixed(0)}천';
  }

  IconData getCategoryIcon(String cat) {
    switch (cat) {
      case '식비': return Icons.restaurant;
      case '마트/편의점': return Icons.storefront;
      case '교통/차량': return Icons.directions_car;
      case '주거/통신': return Icons.home;
      case '구독/정기결제': return Icons.autorenew;
      case '패션/미용': return Icons.checkroom;
      case '생활용품': return Icons.shopping_bag;
      case '문화/여가': return Icons.sports_esports;
      case '건강/의료': return Icons.local_hospital;
      case '여행/숙박': return Icons.card_travel;
      case '교육/자기개발': return Icons.school;
      case '경조사/선물': return Icons.card_giftcard;
      case '기타': return Icons.more_horiz;
      case '주수입': return Icons.account_balance_wallet;
      case '부수입': return Icons.monetization_on;
      default: return Icons.receipt;
    }
  }
}
