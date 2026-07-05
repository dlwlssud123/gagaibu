import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final TextEditingController _budgetController = TextEditingController();

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    
    // 최초 1회 또는 예산 변경 감지 시 컨트롤러 텍스트 동기화
    if (_budgetController.text.isEmpty || int.tryParse(_budgetController.text) != state.targetBudget) {
      _budgetController.text = state.targetBudget.toString();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 이번 달 예산 설정 카드
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            elevation: 2,
            shadowColor: Colors.black12,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune, color: Colors.black87, size: 20.0),
                      SizedBox(width: 8.0),
                      Text(
                        '이번 달 예산 설정',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),
                  const Text(
                    '목표 예산 금액 (원)',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '예: 1000000',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(color: Color(0xFF10B981)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      ElevatedButton(
                        onPressed: () async {
                          final amount = int.tryParse(_budgetController.text);
                          if (amount == null || amount < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('올바른 예산 금액을 입력해 주세요.')),
                            );
                            return;
                          }
                          final success = await state.updateTargetBudget(amount);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('예산 설정이 업데이트되었습니다.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF343A40),
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        ),
                        child: const Text(
                          '변경',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13.0),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // 2. AI 코칭 페르소나 선택 리스트
          const Text(
            'AI 코칭 페르소나 성격 선택',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12.0),

          // 엄마
          _buildPersonaCard(
            context: context,
            state: state,
            type: 'MOM',
            emoji: '👩‍👦',
            title: '엄마',
            description: '따뜻하지만 때로는 뼈 때리는 등짝 스매싱 잔소리',
          ),
          const SizedBox(height: 10.0),

          // 츤데레
          _buildPersonaCard(
            context: context,
            state: state,
            type: 'TSUNDERE',
            emoji: '😒',
            title: '츤데레',
            description: '"흥, 딱히 널 걱정해서 해주는 조언은 아니니까!"',
          ),
          const SizedBox(height: 10.0),

          // 재테크 코치
          _buildPersonaCard(
            context: context,
            state: state,
            type: 'COACH',
            emoji: '📈',
            title: '재테크 코치',
            description: '데이터 기반의 차분하고 논리적인 저축 피드백',
          ),
        ],
      ),
    );
  }

  Widget _buildPersonaCard({
    required BuildContext context,
    required AppState state,
    required String type,
    required String emoji,
    required String title,
    required String description,
  }) {
    final isActive = state.currentPersona == type;

    return GestureDetector(
      onTap: () => state.setPersona(type),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isActive ? const Color(0xFF10B981) : const Color(0xFFE9ECEF),
            width: isActive ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 22.0),
              ),
            ),
            const SizedBox(width: 14.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 20.0,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: Colors.grey[300],
                size: 20.0,
              ),
          ],
        ),
      ),
    );
  }
}
