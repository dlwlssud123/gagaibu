import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/transaction.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final oCcy = NumberFormat("#,###", "ko_KR");

    // 잔여 예산 계산
    final remainingBudget = state.targetBudget - state.totalExpenditure;
    double progressPercent = 0.0;
    if (state.targetBudget > 0) {
      progressPercent = state.totalExpenditure / state.targetBudget;
      if (progressPercent > 1.0) progressPercent = 1.0;
    }

    // 게이지 색상 분기
    Color progressColor = const Color(0xFF10B981); // 정상 (초록)
    if (progressPercent >= 1.0) {
      progressColor = const Color(0xFFEF4444); // 초과 (빨강)
    } else if (progressPercent >= 0.8) {
      progressColor = const Color(0xFFF59E0B); // 경고 (오렌지)
    }

    // AI 배너 설정
    String avatarEmoji = '👩‍👦';
    String personaName = '엄마';
    String oneLiner = '오늘도 돈 쓸 생각 하니? 예산 보고 정신 차려라!';
    if (state.currentPersona == 'TSUNDERE') {
      avatarEmoji = '😒';
      personaName = '츤데레';
      oneLiner = '흥, 딱히 널 걱정해서 해주는 조언은 아니니까!';
    } else if (state.currentPersona == 'COACH') {
      avatarEmoji = '📈';
      personaName = '재테크 코치';
      oneLiner = '체계적인 금융 관리를 위해 먼저 예산을 수립하십시오.';
    }

    // 잔소리 한줄 동적 설정
    oneLiner = _getOneLiner(state);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. AI 잔소리 배너 카드
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF343A40),
                  const Color(0xFF212529).withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: const BoxDecoration(
                    color: Color(0xFF495057),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    avatarEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        personaName,
                        style: const TextStyle(
                          color: Color(0xFFCED4DA),
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        oneLiner,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // 2. 예산 요약 카드
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            elevation: 3,
            shadowColor: Colors.black12,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '이번 달 남은 예산',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => state.switchTab('setting'),
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 14.0, color: Colors.blue),
                            SizedBox(width: 2.0),
                            Text(
                              '설정',
                              style: TextStyle(fontSize: 13.0, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    '${oCcy.format(remainingBudget)}원',
                    style: TextStyle(
                      fontSize: 26.0,
                      fontWeight: FontWeight.w900,
                      color: progressPercent >= 1.0 ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 8.0,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '총 지출: ${oCcy.format(state.totalExpenditure)}원',
                        style: const TextStyle(fontSize: 13.0, color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '목표 예산: ${oCcy.format(state.targetBudget)}원',
                        style: const TextStyle(fontSize: 13.0, color: Colors.black54),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // 3. 소비 내역 필터링 및 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 소비 내역',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey[300]!, width: 0.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.homeFilter,
                    dense: true,
                    style: const TextStyle(fontSize: 12.0, color: Colors.black87, fontWeight: FontWeight.bold),
                    onChanged: (String? newValue) {
                      if (newValue != null) state.updateHomeFilter(newValue);
                    },
                    items: const [
                      DropdownMenuItem(value: 'ALL', child: Text('전체 내역')),
                      DropdownMenuItem(value: 'OVERSPEND', child: Text('과소비 (3만원↑)')),
                      DropdownMenuItem(value: 'INCOME', child: Text('수입만')),
                      DropdownMenuItem(value: 'CAT_식비', child: Text('식비')),
                      DropdownMenuItem(value: 'CAT_마트/편의점', child: Text('마트/편의점')),
                      DropdownMenuItem(value: 'CAT_교통/차량', child: Text('교통/차량')),
                      DropdownMenuItem(value: 'CAT_구독/정기결제', child: Text('구독/고정비')),
                      DropdownMenuItem(value: 'CAT_문화/여가', child: Text('문화/여가')),
                    ],
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 12.0),

          // 4. 리스트 렌더링
          _buildRecentList(context, state, oCcy),
        ],
      ),
    );
  }

  Widget _buildRecentList(BuildContext context, AppState state, NumberFormat oCcy) {
    final recentList = state.filteredRecentTransactions;

    if (recentList.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.receipt_long, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 8.0),
            Text(
              '조회 가능한 소비 내역이 없습니다.',
              style: TextStyle(fontSize: 13.0, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // 최대 5개 노출
    final showList = recentList.take(5).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: showList.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F3F5)),
      itemBuilder: (context, index) {
        final tx = showList[index];
        final isExp = tx.transactionType == TransactionType.EXPENDITURE;
        final sign = isExp ? '-' : '+';
        final color = isExp ? Colors.red[700] : Colors.teal[700];
        final bg = isExp ? Colors.red[50] : Colors.teal[50];
        
        final catLabel = tx.subCategory != null ? '${tx.category} > ${tx.subCategory}' : tx.category;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  getCategoryIcon(tx.category),
                  size: 20.0,
                  color: color,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.content,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '$catLabel | ${tx.transactionDate}',
                      style: const TextStyle(
                        fontSize: 11.5,
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
                      fontSize: 14.5,
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
                        fontSize: 11.5,
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

  String _getOneLiner(AppState state) {
    if (state.targetBudget == 0) {
      if (state.currentPersona == 'MOM') {
        return '너 예산도 설정 안 하고 가계부를 쓰는 거니? 어서 설정 탭으로 가서 예산부터 짜라!';
      } else if (state.currentPersona == 'TSUNDERE') {
        return '바보야, 예산 설정도 안 하고 뭘 보라는 거야? 빨리 예산이나 세워두라고!';
      } else {
        return '체계적인 금융 관리를 위해 먼저 예산을 수립하십시오. 목표 설정이 절약의 첫걸음입니다.';
      }
    }

    final percent = state.totalExpenditure / state.targetBudget;
    if (percent >= 1.0) {
      if (state.currentPersona == 'MOM') {
        return '어휴 등짝 스매싱 감이네! 벌써 한 달 예산을 다 탕진해버리면 어떡해?!';
      } else if (state.currentPersona == 'TSUNDERE') {
        return '하아? 예산을 전부 다 썼다고? 어차피 네가 돈 막 쓸 줄 알았어... 바보!';
      } else {
        return '경고: 이번 달 목표 지출 한도를 초과했습니다. 긴급한 자산 통제가 필요합니다.';
      }
    } else if (percent >= 0.8) {
      if (state.currentPersona == 'MOM') {
        return '예산 다 갉아먹었다 얘! 숟가락 놓기 전에 돈 아껴 써라!';
      } else if (state.currentPersona == 'TSUNDERE') {
        return '더 이상 지출했다간 지갑이 거덜 날 걸? 딱히 걱정해서 하는 경고는 아니니까!';
      } else {
        return '알림: 예산 소진율이 80%에 도달했습니다. 비필수적 지출을 전면 동결하십시오.';
      }
    } else {
      if (state.currentPersona == 'MOM') {
        return '이번 달은 용케 예산 안에서 잘 버티고 있구나. 그 마음가짐 쭉 가거라.';
      } else if (state.currentPersona == 'TSUNDERE') {
        return '뭐, 제법 아껴 쓰고 있잖아? 그렇다고 칭찬해 주는 건 아니니까 착각하지 마!';
      } else {
        return '현재 재정 건강도가 양호합니다. 예산 범위 내 안정적인 잔액 관리가 지속되고 있습니다.';
      }
    }
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
