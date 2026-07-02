// 전역 상태 변수
const USER_ID = 1;
let currentPersona = 'MOM';
let targetBudget = 0;
let totalExpenditure = 0;
let transactionList = [];
let selectedDate = new Date();
let currentViewDate = new Date(); // 달력 표시용

// 모달 내부 입력 임시 상태
let modalTransactionType = 'EXPENDITURE'; // EXPENDITURE | INCOME
let modalAmount = '0';
let modalCategory = '식비';
let modalAsset = '신용카드';

// 카테고리 셋 (지출 vs 수입)
const EXPENDITURE_CATEGORIES = ['식비', '카페', '교통', '쇼핑', '마트', '문화/여가', '의료/건강', '기타'];
const INCOME_CATEGORIES = ['급여', '부업', '용돈', '기타수입'];

// 초기 로딩
document.addEventListener('DOMContentLoaded', () => {
    // 디바이스 시계 실시간 동기화
    updateDeviceTime();
    setInterval(updateDeviceTime, 60000);

    // 초기 데이터 패치
    initializeData();

    // 캘린더 일자 렌더링
    renderCalendar();
});

// 기기 시계 표시 업데이트
function updateDeviceTime() {
    const now = new Date();
    let hours = now.getHours();
    let minutes = now.getMinutes();
    hours = hours < 10 ? '0' + hours : hours;
    minutes = minutes < 10 ? '0' + minutes : minutes;
    document.getElementById('device-time').textContent = hours + ':' + minutes;
}

// 초기 데이터 연동
async function initializeData() {
    try {
        // 1. 유저 정보 조회
        const userRes = await fetch(`/api/v1/users/${USER_ID}`);
        if (userRes.ok) {
            const user = await userRes.json();
            currentPersona = user.personaType;
            updatePersonaUI(currentPersona);
        }

        // 2. 예산 정보 조회
        await fetchBudget();

        // 3. 지출 내역 조회 및 대시보드 갱신
        await fetchTransactions();

    } catch (e) {
        console.error("데이터 초기 로드 실패:", e);
    }
}

// 예산 데이터 패치
async function fetchBudget() {
    const year = currentViewDate.getFullYear();
    const month = currentViewDate.getMonth() + 1;
    try {
        const budgetRes = await fetch(`/api/v1/budgets?userId=${USER_ID}&year=${year}&month=${month}`);
        if (budgetRes.ok) {
            const budget = await budgetRes.json();
            targetBudget = budget.amount;
        } else {
            targetBudget = 0; // 예산이 없는 경우
        }
        updateBudgetUI();
    } catch (e) {
        targetBudget = 0;
        updateBudgetUI();
    }
}

// 소비 내역 패치
async function fetchTransactions() {
    const year = currentViewDate.getFullYear();
    const month = currentViewDate.getMonth() + 1;
    
    // 당월 시작일 ~ 종료일 계산
    const startStr = `${year}-${String(month).padStart(2, '0')}-01`;
    const lastDay = new Date(year, month, 0).getDate();
    const endStr = `${year}-${String(month).padStart(2, '0')}-${String(lastDay).padStart(2, '0')}`;

    try {
        const txRes = await fetch(`/api/v1/account-books?userId=${USER_ID}&startDate=${startStr}&endDate=${endStr}`);
        if (txRes.ok) {
            transactionList = await txRes.json();
            
            // 총지출 및 총수입 계산
            totalExpenditure = transactionList
                .filter(tx => tx.transactionType === 'EXPENDITURE')
                .reduce((sum, tx) => sum + tx.amount, 0);

            // UI 업데이트
            updateBudgetUI();
            renderRecentList();
            renderCalendar();
            renderTimeline();
        }
    } catch (e) {
        console.error("소비 내역 로드 실패:", e);
    }
}

// 예산 잔액 프로그레스 바 UI 갱신
function updateBudgetUI() {
    const remaining = targetBudget - totalExpenditure;
    
    document.getElementById('home-target-budget').textContent = formatWon(targetBudget);
    document.getElementById('home-total-expenditure').textContent = formatWon(totalExpenditure);
    document.getElementById('home-remaining-budget').textContent = formatWon(remaining);
    
    // 설정 탭 입력창 동기화
    document.getElementById('input-target-budget').value = targetBudget;

    // 프로그레스 바 계산
    const bar = document.getElementById('home-budget-progress');
    if (targetBudget > 0) {
        const percent = Math.min((totalExpenditure / targetBudget) * 100, 100);
        bar.style.width = percent + '%';

        // 예산 경고에 따른 색상 분기
        if (percent >= 100) {
            bar.style.backgroundColor = '#ef4444'; // 초과 (레드)
        } else if (percent >= 80) {
            bar.style.backgroundColor = '#f59e0b'; // 경고 (오렌지)
        } else {
            bar.style.backgroundColor = '#ffffff'; // 정상 (화이트)
        }
    } else {
        bar.style.width = '0%';
    }
}

// 최근 소비 목록 렌더링 (홈 화면용 5개)
function renderRecentList() {
    const listContainer = document.getElementById('home-recent-list');
    listContainer.innerHTML = '';

    // 최근 거래순 정렬 후 5개 추출
    const recent = [...transactionList]
        .sort((a, b) => new Date(b.transactionDate) - new Date(a.transactionDate))
        .slice(0, 5);

    if (recent.length === 0) {
        listContainer.innerHTML = '<div class="empty-state">내역이 없습니다. 우측 하단 + 버튼으로 등록해보세요!</div>';
        return;
    }

    recent.forEach(tx => {
        const isExp = tx.transactionType === 'EXPENDITURE';
        const typeClass = isExp ? 'expenditure' : 'income';
        const sign = isExp ? '-' : '+';
        const icon = getCategoryIcon(tx.category);

        const html = `
            <div class="transaction-item">
                <div class="tx-left">
                    <div class="cat-icon-circle ${typeClass}">
                        <i class="${icon}"></i>
                    </div>
                    <div class="tx-info">
                        <span class="tx-content">${tx.content}</span>
                        <span class="tx-meta">${tx.category} | ${tx.transactionDate}</span>
                    </div>
                </div>
                <div class="tx-right">
                    <span class="tx-amount ${typeClass}">${sign}${formatWon(tx.amount)}</span>
                    <span class="delete-tx-btn" onclick="deleteTransaction(${tx.id})"><i class="fa-solid fa-trash-can"></i> 삭제</span>
                </div>
            </div>
        `;
        listContainer.insertAdjacentHTML('beforeend', html);
    });
}

// 탭 전환 기능
function switchTab(tabName) {
    // 탭 콘텐츠 토글
    document.querySelectorAll('.tab-content').forEach(tab => tab.classList.remove('active'));
    document.getElementById(`tab-${tabName}`).classList.add('active');

    // 하단 네비게이션 탭 토글
    document.querySelectorAll('.bottom-nav .nav-item').forEach(item => item.classList.remove('active'));
    document.getElementById(`nav-${tabName}`).classList.add('active');

    // 헤더 타이틀 매핑
    const titleMap = {
        'home': '홈',
        'history': '소비 내역',
        'report': 'AI 자축 코칭',
        'setting': '설정'
    };
    document.getElementById('header-title').textContent = titleMap[tabName];

    // 특정 탭 이동 시 갱신 처리
    if (tabName === 'home' || tabName === 'history') {
        fetchTransactions();
    } else if (tabName === 'report') {
        fetchReportHistory();
    }
}

// 페르소나 설정 UI 동기화
function updatePersonaUI(persona) {
    currentPersona = persona;

    // 설정 탭 내 활성화 카드 표시
    document.querySelectorAll('.persona-card').forEach(card => card.classList.remove('active'));
    const activeCard = document.getElementById(`persona-${persona}`);
    if (activeCard) activeCard.classList.add('active');

    // AI 상단 캐릭터 이모지 및 잔소리 갱신
    const avatarEmoji = document.getElementById('ai-avatar-emoji');
    const personaName = document.getElementById('ai-persona-name');
    const oneLiner = document.getElementById('ai-one-liner');

    const config = {
        'MOM': { emoji: '👩‍👦', name: '엄마', text: getMomOneLiner() },
        'TSUNDERE': { emoji: '😒', name: '츤데레', text: getTsundereOneLiner() },
        'COACH': { emoji: '📈', name: '재테크 코치', text: getCoachOneLiner() }
    };

    avatarEmoji.textContent = config[persona].emoji;
    personaName.textContent = config[persona].name;
    oneLiner.textContent = config[persona].text;
}

// 페르소나별 한줄 잔소리 유동 설정
function getMomOneLiner() {
    if (targetBudget === 0) return "너 예산도 설정 안 하고 가계부를 쓰는 거니? 어서 설정 탭으로 가서 예산부터 짜라!";
    const percent = (totalExpenditure / targetBudget) * 100;
    if (percent >= 100) return "어휴 등짝 스매싱 감이네! 벌써 한 달 예산을 다 탕진해버리면 어떡해?!";
    if (percent >= 80) return "예산 다 갉아먹었다 얘! 숟가락 놓기 전에 돈 아껴 써라!";
    return "이번 달은 용케 예산 안에서 잘 버티고 있구나. 그 마음가짐 쭉 가거라.";
}

function getTsundereOneLiner() {
    if (targetBudget === 0) return "바보야, 예산 설정도 안 하고 뭘 보라는 거야? 빨리 예산이나 세워두라고!";
    const percent = (totalExpenditure / targetBudget) * 100;
    if (percent >= 100) return "하아? 예산을 전부 다 썼다고? 어차피 네가 돈 막 쓸 줄 알았어... 바보!";
    if (percent >= 80) return "더 이상 지출했다간 지갑이 거덜 날 걸? 딱히 걱정해서 하는 경고는 아니니까!";
    return "뭐, 제법 아껴 쓰고 있잖아? 그렇다고 칭찬해 주는 건 아니니까 착각하지 마!";
}

function getCoachOneLiner() {
    if (targetBudget === 0) return "체계적인 금융 관리를 위해 먼저 예산을 수립하십시오. 목표 설정이 절약의 첫걸음입니다.";
    const percent = (totalExpenditure / targetBudget) * 100;
    if (percent >= 100) return "경고: 이번 달 목표 지출 한도를 초과했습니다. 긴급한 자산 통제가 필요합니다.";
    if (percent >= 80) return "알림: 예산 소진율이 80%에 도달했습니다. 비필수적 지출을 전면 동결하십시오.";
    return "현재 재정 건강도가 양호합니다. 예산 범위 내 안정적인 잔액 관리가 지속되고 있습니다.";
}

// 페르소나 변경 API 전송
async function selectPersona(persona) {
    try {
        const res = await fetch(`/api/v1/users/${USER_ID}/persona?personaType=${persona}`, {
            method: 'PUT'
        });
        if (res.ok) {
            updatePersonaUI(persona);
        }
    } catch (e) {
        console.error("페르소나 변경 오류:", e);
    }
}

// 예산 금액 업데이트 API 전송
async function updateTargetBudget() {
    const inputAmount = document.getElementById('input-target-budget').value;
    if (!inputAmount || inputAmount < 0) {
        alert("올바른 예산 금액을 입력해 주세요.");
        return;
    }

    const year = currentViewDate.getFullYear();
    const month = currentViewDate.getMonth() + 1;

    try {
        const res = await fetch('/api/v1/budgets', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                userId: USER_ID,
                amount: parseInt(inputAmount),
                year: year,
                month: month
            })
        });
        if (res.ok) {
            alert("예산이 성공적으로 업데이트되었습니다.");
            await fetchBudget();
        }
    } catch (e) {
        console.error("예산 업데이트 실패:", e);
    }
}

// 캘린더 렌더링 로직
function renderCalendar() {
    const daysContainer = document.getElementById('calendar-days-container');
    if (!daysContainer) return;
    daysContainer.innerHTML = '';

    const year = currentViewDate.getFullYear();
    const month = currentViewDate.getMonth();

    // 1일의 요일 및 달의 총 일수
    const firstDayIndex = new Date(year, month, 1).getDay();
    const totalDays = new Date(year, month + 1, 0).getDate();

    // 이전 달의 마지막 일수
    const prevTotalDays = new Date(year, month, 0).getDate();

    // 이전 달 빈 칸
    for (let i = firstDayIndex; i > 0; i--) {
        const day = prevTotalDays - i + 1;
        daysContainer.insertAdjacentHTML('beforeend', `<span class="day-cell other-month">${day}</span>`);
    }

    // 이번 달 날짜 칸 생성
    for (let d = 1; d <= totalDays; d++) {
        const dStr = `${year}-${String(month+1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
        
        // 당일 지출 합산 계산
        const daySum = transactionList
            .filter(tx => tx.transactionDate === dStr && tx.transactionType === 'EXPENDITURE')
            .reduce((sum, tx) => sum + tx.amount, 0);

        const isActive = isSameDay(selectedDate, new Date(year, month, d)) ? 'active' : '';
        const sumHtml = daySum > 0 ? `<span class="day-sum">-${formatWonShort(daySum)}</span>` : '';

        const html = `
            <div class="day-cell ${isActive}" onclick="selectCalendarDay(${d})">
                ${d}
                ${sumHtml}
            </div>
        `;
        daysContainer.insertAdjacentHTML('beforeend', html);
    }
}

// 달력 특정 일자 클릭 시 타임라인 렌더링 연동
function selectCalendarDay(day) {
    const year = currentViewDate.getFullYear();
    const month = currentViewDate.getMonth();
    selectedDate = new Date(year, month, day);

    // 달력 셀 재생성
    renderCalendar();
    // 타임라인 렌더링
    renderTimeline();
}

// 월 변경 기능 (캘린더용)
function changeMonth(direction) {
    currentViewDate.setMonth(currentViewDate.getMonth() + direction);
    document.getElementById('history-month-text').textContent = `${currentViewDate.getFullYear()}년 ${currentViewDate.getMonth() + 1}월`;
    
    // 데이터 재패치
    fetchBudget();
    fetchTransactions();
}

// 선택 날짜 상세 타임라인 렌더링
function renderTimeline() {
    const label = document.getElementById('selected-date-label');
    const totalLabel = document.getElementById('selected-date-total');
    const listContainer = document.getElementById('history-timeline-list');
    
    if (!listContainer) return;
    listContainer.innerHTML = '';

    const year = selectedDate.getFullYear();
    const month = selectedDate.getMonth() + 1;
    const day = selectedDate.getDate();
    const selectedStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;

    label.textContent = `${month}월 ${day}일 지출/수입 상세`;

    const dayTxs = transactionList.filter(tx => tx.transactionDate === selectedStr);

    const dayExpenditure = dayTxs
        .filter(tx => tx.transactionType === 'EXPENDITURE')
        .reduce((sum, tx) => sum + tx.amount, 0);
    totalLabel.textContent = `당일 지출: ${formatWon(dayExpenditure)}`;

    if (dayTxs.length === 0) {
        listContainer.innerHTML = '<div class="empty-state">해당 일자의 거래 내역이 존재하지 않습니다.</div>';
        return;
    }

    dayTxs.forEach(tx => {
        const isExp = tx.transactionType === 'EXPENDITURE';
        const typeClass = isExp ? 'expenditure' : 'income';
        const sign = isExp ? '-' : '+';
        const icon = getCategoryIcon(tx.category);

        const html = `
            <div class="transaction-item">
                <div class="tx-left">
                    <div class="cat-icon-circle ${typeClass}">
                        <i class="${icon}"></i>
                    </div>
                    <div class="tx-info">
                        <span class="tx-content">${tx.content}</span>
                        <span class="tx-meta">${tx.category}</span>
                    </div>
                </div>
                <div class="tx-right">
                    <span class="tx-amount ${typeClass}">${sign}${formatWon(tx.amount)}</span>
                    <span class="delete-tx-btn" onclick="deleteTransaction(${tx.id})"><i class="fa-solid fa-trash-can"></i> 삭제</span>
                </div>
            </div>
        `;
        listContainer.insertAdjacentHTML('beforeend', html);
    });
}

// 소비/수입 내역 삭제 API 호출
async function deleteTransaction(id) {
    if (!confirm("정말 이 내역을 삭제하시겠습니까?")) return;
    try {
        const res = await fetch(`/api/v1/account-books/${id}`, {
            method: 'DELETE'
        });
        if (res.ok) {
            await fetchTransactions();
        }
    } catch (e) {
        console.error("소비 삭제 실패:", e);
    }
}

// -----------------------------------------------------------------
// 빠른 등록 모달 (Bottom Sheet) 관련 로직
// -----------------------------------------------------------------

function openInputModal() {
    // 임시 상태 초기화
    modalAmount = '0';
    modalCategory = '식비';
    modalAsset = '신용카드';
    document.getElementById('modal-input-content').value = '';
    
    // UI 초기 렌더링
    updateModalUI();
    renderCategoryChips();

    // 모달 활성화
    document.getElementById('input-modal-backdrop').classList.add('active');
}

function closeInputModal() {
    document.getElementById('input-modal-backdrop').classList.remove('active');
}

// 거래 타입(지출 vs 수입) 변경
function selectTransactionType(type) {
    modalTransactionType = type;
    
    const expBtn = document.getElementById('type-btn-expenditure');
    const incBtn = document.getElementById('type-btn-income');

    if (type === 'EXPENDITURE') {
        expBtn.classList.add('active');
        incBtn.classList.remove('active');
        modalCategory = '식비'; // 지출 기본값
    } else {
        incBtn.classList.add('active');
        expBtn.classList.remove('active');
        modalCategory = '급여'; // 수입 기본값
    }

    updateModalUI();
    renderCategoryChips();
}

// 모달 금액 노출 등 UI 동기화
function updateModalUI() {
    const display = document.getElementById('modal-amount-display');
    display.textContent = Number(modalAmount).toLocaleString();
    
    // 자산 활성화 버튼
    const cardBtn = document.getElementById('asset-btn-card');
    const cashBtn = document.getElementById('asset-btn-cash');
    if (modalAsset === '신용카드') {
        cardBtn.classList.add('active');
        cashBtn.classList.remove('active');
    } else {
        cashBtn.classList.add('active');
        cardBtn.classList.remove('active');
    }
}

// 카테고리 칩 선택형 렌더링
function renderCategoryChips() {
    const container = document.getElementById('category-chips-container');
    container.innerHTML = '';

    const list = modalTransactionType === 'EXPENDITURE' ? EXPENDITURE_CATEGORIES : INCOME_CATEGORIES;
    list.forEach(cat => {
        const icon = getCategoryIcon(cat);
        const isActive = modalCategory === cat ? 'active' : '';
        const html = `
            <span class="chip-item ${isActive}" onclick="selectCategory('${cat}')">
                <i class="${icon}"></i> ${cat}
            </span>
        `;
        container.insertAdjacentHTML('beforeend', html);
    });
}

function selectCategory(cat) {
    modalCategory = cat;
    renderCategoryChips();
}

function selectAsset(asset) {
    modalAsset = asset;
    updateModalUI();
}

// 가상 키패드 클릭 핸들러
function pressKey(key) {
    if (key === 'clear') {
        modalAmount = '0';
    } else if (key === 'backspace') {
        if (modalAmount.length > 1) {
            modalAmount = modalAmount.slice(0, -1);
        } else {
            modalAmount = '0';
        }
    } else {
        if (modalAmount === '0') {
            modalAmount = key;
        } else {
            // 최대 길이 9자리 한계 제한
            if (modalAmount.length < 9) {
                modalAmount += key;
            }
        }
    }
    updateModalUI();
}

// 거래 등록 API 최종 전송
async function submitTransaction() {
    const amountVal = parseInt(modalAmount);
    if (amountVal <= 0) {
        alert("금액을 정확히 입력해 주세요.");
        return;
    }

    const inputContent = document.getElementById('modal-input-content').value.trim();
    const finalContent = inputContent !== "" ? inputContent : `${modalCategory} 지출`;

    // 선택된 날짜 문자열 전송 (히스토리에서 고른 날짜 또는 오늘 날짜 연계)
    const year = selectedDate.getFullYear();
    const month = selectedDate.getMonth() + 1;
    const day = selectedDate.getDate();
    const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;

    const body = {
        userId: USER_ID,
        amount: amountVal,
        category: modalCategory,
        content: finalContent,
        transactionDate: dateStr,
        transactionType: modalTransactionType
    };

    try {
        const res = await fetch('/api/v1/account-books', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });
        if (res.ok) {
            closeInputModal();
            // 화면 목록 최신 갱신
            await fetchTransactions();
        }
    } catch (e) {
        console.error("거래 등록 실패:", e);
    }
}

// -----------------------------------------------------------------
// AI 코칭 리포트 호출 및 렌더링 로직
// -----------------------------------------------------------------

// 이미 저장되어 있는 AI 리포트가 있으면 최초 로드
async function fetchReportHistory() {
    try {
        const res = await fetch(`/api/v1/ai-reports?userId=${USER_ID}`);
        if (res.ok) {
            const reports = await res.json();
            if (reports.length > 0) {
                renderAiReportContent(reports[0]);
            } else {
                document.getElementById('report-view-container').style.display = 'none';
            }
        }
    } catch (e) {
        console.error("기존 AI 리포트 로드 실패:", e);
    }
}

// AI 리포트 생성 트리거 호출
async function triggerAiReport() {
    const loading = document.getElementById('report-loading-container');
    const resultBox = document.getElementById('report-view-container');
    
    // 로딩 토글
    loading.style.display = 'flex';
    resultBox.style.display = 'none';

    const year = selectedDate.getFullYear();
    const month = selectedDate.getMonth() + 1;
    const day = selectedDate.getDate();
    const dateStr = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;

    try {
        const res = await fetch(`/api/v1/ai-reports/generate?userId=${USER_ID}&reportDate=${dateStr}`, {
            method: 'POST'
        });
        if (res.ok) {
            const report = await res.json();
            renderAiReportContent(report);
        } else {
            alert("AI 리포트 생성에 실패했습니다.");
        }
    } catch (e) {
        console.error("AI 생성 통신 실패:", e);
        alert("서버 연결에 실패했습니다.");
    } finally {
        loading.style.display = 'none';
    }
}

// AI 리포트 결과 렌더링 및 해시태그 파싱
function renderAiReportContent(report) {
    const resultBox = document.getElementById('report-view-container');
    const emoji = document.getElementById('report-avatar-emoji');
    const title = document.getElementById('report-persona-title');
    const content = document.getElementById('report-content-text');
    const thinking = document.getElementById('report-thinking-text');
    const chips = document.getElementById('report-chips');

    resultBox.style.display = 'flex';

    // 1. 페르소나 매핑
    const config = {
        'MOM': { emoji: '👩‍👦', name: '엄마의 등짝 스매싱 코칭' },
        'TSUNDERE': { emoji: '😒', name: '츤데레의 흥칫뿡 코칭' },
        'COACH': { emoji: '📈', name: '재테크 코치의 자산 분석' }
    };
    emoji.textContent = config[currentPersona].emoji;
    title.textContent = config[currentPersona].name;

    // 2. 생각 흐름 분리 파싱
    let mainReport = report.content;
    let thinkingFlow = "생각 흐름에 대한 데이터가 누락되었습니다.";

    if (report.content.includes('[AI 생각 과정]') && report.content.includes('[최종 AI 분석 리포트]')) {
        const parts = report.content.split('[최종 AI 분석 리포트]');
        thinkingFlow = parts[0].replace('[AI 생각 과정]', '').trim();
        mainReport = parts[1].trim();
    }
    
    thinking.textContent = thinkingFlow;
    content.textContent = mainReport;

    // 3. 해시태그 동적 추출 파싱
    chips.innerHTML = '';
    const tagReg = /#([가-힣a-zA-Z0-9_]+)/g;
    let match;
    let foundTags = [];
    while ((match = tagReg.exec(mainReport)) !== null) {
        foundTags.push('#' + match[1]);
    }

    // 기본 매칭 태그가 없으면 지출 비율에 따른 가상 태그 노출
    if (foundTags.length === 0) {
        if (totalExpenditure > targetBudget) {
            foundTags.push('#예산초과', '#지갑탈탈');
        } else {
            foundTags.push('#절약우수', '#계획성지출');
        }
        foundTags.push('#' + (currentPersona === 'MOM' ? '잔소리모드' : '코칭모드'));
    }

    foundTags.forEach(tag => {
        chips.insertAdjacentHTML('beforeend', `<span class="chip font-tag">${tag}</span>`);
    });
}

// 생각 접기/펼치기
function toggleExpansion() {
    const body = document.getElementById('expansion-body');
    const arrow = document.getElementById('expansion-arrow');
    if (body.style.display === 'none') {
        body.style.display = 'block';
        arrow.style.transform = 'rotate(180deg)';
    } else {
        body.style.display = 'none';
        arrow.style.transform = 'rotate(0deg)';
    }
}

// -----------------------------------------------------------------
// 헬퍼 및 기타 함수들
// -----------------------------------------------------------------

function formatWon(val) {
    return Number(val).toLocaleString() + '원';
}

function formatWonShort(val) {
    if (val >= 10000) {
        return (val / 10000).toFixed(0) + '만';
    }
    return (val / 1000).toFixed(0) + '천';
}

function isSameDay(d1, d2) {
    return d1.getFullYear() === d2.getFullYear() &&
           d1.getMonth() === d2.getMonth() &&
           d1.getDate() === d2.getDate();
}

function getCategoryIcon(cat) {
    const icons = {
        '식비': 'fa-solid fa-utensils',
        '카페': 'fa-solid fa-mug-hot',
        '교통': 'fa-solid fa-bus',
        '쇼핑': 'fa-solid fa-bag-shopping',
        '마트': 'fa-solid fa-cart-shopping',
        '문화/여가': 'fa-solid fa-film',
        '의료/건강': 'fa-solid fa-heart-pulse',
        '기타': 'fa-solid fa-ellipsis',
        '급여': 'fa-solid fa-wallet',
        '부업': 'fa-solid fa-briefcase',
        '용돈': 'fa-solid fa-hand-holding-dollar',
        '기타수입': 'fa-solid fa-sack-dollar'
    };
    return icons[cat] || 'fa-solid fa-receipt';
}
