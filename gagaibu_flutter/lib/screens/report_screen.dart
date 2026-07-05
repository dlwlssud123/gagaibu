import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/app_state.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // AI 페르소나 매핑
    String avatarEmoji = '👩‍👦';
    String reportTitle = '엄마의 등짝 스매싱 코칭';
    if (state.currentPersona == 'TSUNDERE') {
      avatarEmoji = '😒';
      reportTitle = '츤데레의 흥칫뿡 코칭';
    } else if (state.currentPersona == 'COACH') {
      avatarEmoji = '📈';
      reportTitle = '재테크 코치의 자산 분석';
    }

    // AI 생각과 본문 파싱
    String mainReport = "리포트가 생성되지 않았습니다. 아래의 생성 버튼을 눌러주세요.";
    String thinkingFlow = "분석 데이터가 존재하지 않습니다.";
    List<String> tags = [];

    if (state.latestReport != null) {
      final String rawContent = state.latestReport!['content'] ?? '';
      mainReport = rawContent;
      
      if (rawContent.contains('[AI 생각 과정]') && rawContent.contains('[최종 AI 분석 리포트]')) {
        final parts = rawContent.split('[최종 AI 분석 리포트]');
        thinkingFlow = parts[0].replaceAll('[AI 생각 과정]', '').trim();
        mainReport = parts[1].trim();
      } else {
        thinkingFlow = "생각 과정 로그가 생략되었습니다.";
      }

      // 해시태그 추출
      final RegExp tagReg = RegExp(r'#([가-힣a-zA-Z0-9_]+)');
      final Iterable<RegExpMatch> matches = tagReg.allMatches(mainReport);
      for (final match in matches) {
        final tag = match.group(0);
        if (tag != null && !tags.contains(tag)) {
          tags.add(tag);
        }
      }

      // 기본 해시태그 조율 폴백
      if (tags.isEmpty) {
        if (state.totalExpenditure > state.targetBudget) {
          tags.addAll(['#예산초과', '#지갑탈탈']);
        } else {
          tags.addAll(['#절약우수', '#계획성지출']);
        }
        tags.add('#${state.currentPersona == 'MOM' ? '잔소리모드' : '코칭모드'}');
      }
    }

    return Column(
      children: [
        // 1. 리포트 주기 선택 서브 탭바
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          color: Colors.white,
          child: Row(
            children: [
              _buildTabButton(context, state, 'DAILY', '일간'),
              const SizedBox(width: 8.0),
              _buildTabButton(context, state, 'WEEKLY', '주간'),
              const SizedBox(width: 8.0),
              _buildTabButton(context, state, 'MONTHLY', '월간'),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFE9ECEF)),

        // 2. 메인 컨텐츠 영역
        Expanded(
          child: state.isReportGenerating
              ? _buildLoadingView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // 리포트 설명
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _getReportDescription(state.currentReportType),
                          textAlign: Center,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),

                      // 해시태그 칩스 배열
                      if (tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 4.0,
                          alignment: WrapAlignment.center,
                          children: tags.map((tag) {
                            return Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                              backgroundColor: const Color(0xFFECFDF5),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14.0),
                      ],

                      // 메인 보고서 카드
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
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      avatarEmoji,
                                      style: const TextStyle(fontSize: 22.0),
                                    ),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Text(
                                    reportTitle,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.0),
                                child: Divider(height: 1, color: Color(0xFFF1F3F5)),
                              ),
                              // Markdown Body
                              MarkdownBody(
                                data: mainReport,
                                styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.black87,
                                    height: 1.5,
                                  ),
                                  h4: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black87,
                                    height: 1.6,
                                  ),
                                  strong: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEF4444),
                                  ),
                                  listBullet: const TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // 3. AI 생각 과정 아코디언 (Expansion Panel)
                      if (state.latestReport != null)
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          elevation: 1,
                          shadowColor: Colors.black12,
                          child: ExpansionTile(
                            leading: const Icon(Icons.psychology, color: Colors.blue),
                            title: const Text(
                              'AI의 의도 및 생각 알고리즘 보기',
                              style: TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Text(
                                    thinkingFlow,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 11.5,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      const SizedBox(height: 32.0),
                    ],
                  ),
                ),
        ),

        // 4. 하단 생성 및 갱신 액션 버튼
        if (!state.isReportGenerating)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton.icon(
                onPressed: () => state.generateReport(),
                icon: const Icon(Icons.auto_awesome, size: 18.0, color: Colors.white),
                label: Text(
                  _getButtonText(state.currentReportType),
                  style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981), // 초록 버튼
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  elevation: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabButton(BuildContext context, AppState state, String type, String label) {
    final isActive = state.currentReportType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => state.switchReportType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF343A40) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8.0),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            ),
            const SizedBox(height: 20.0),
            Text(
              'NVIDIA Nemotron 모델이 예산과 지출 세부 로그를 기반으로 잔소리를 충전하고 있습니다...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReportDescription(String type) {
    switch (type) {
      case 'DAILY': return 'NVIDIA NIM AI가 금일 하루 지출을 분석합니다.';
      case 'WEEKLY': return 'NVIDIA NIM AI가 지난 7일 동안의 지출 패턴을 분석합니다.';
      case 'MONTHLY': return 'NVIDIA NIM AI가 당월 한 달 동안의 예산 대비 소비를 분석합니다.';
      default: return '';
    }
  }

  String _getButtonText(String type) {
    switch (type) {
      case 'DAILY': return '일간 리포트 생성 / 갱신';
      case 'WEEKLY': return '주간 리포트 생성 / 갱신';
      case 'MONTHLY': return '월간 리포트 생성 / 갱신';
      default: return '리포트 생성';
    }
  }
}
