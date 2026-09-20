# 습관 트래커 작업일지

## 2026-09-20
### 수정
- `index.html:197` **SUPABASE_URL 오류 수정** — `https://zmgcxueaesedyfkkxlzi.supabase.co/rest/v1/` → `https://zmgcxueaesedyfkkxlzi.supabase.co`
  - supabase-js의 `createClient()`는 **프로젝트 베이스 URL**을 받아 내부적으로 `/rest/v1`, `/auth/v1` 등을 붙인다. `/rest/v1/`가 붙어 있으면 요청이 `/rest/v1/rest/v1/...`, 로그인은 `/rest/v1/auth/v1/...` 로 나가 **구글 로그인·저장 둘 다 실패**했을 상태였음.
- 백업: `backup/2026-09-20/index.html` (수정 전 원본)

### 확인
- 코드 검토 결과 나머지 로직 이상 없음: 부팅 시 `localLoad()` → `render()`(595~596) → supabase 동적 import → `getSession()`/`onAuthStateChange` → `pull()`
- 동기화: `save()`가 rev 갱신 + localStorage 저장 + 600ms 디바운스 `push()`, `pull()`은 rev 큰 쪽 승리(LWW). 설계 문서와 일치
- `supabase-setup.sql` 은 인계 문서의 스키마와 동일 (테이블 + RLS 3정책)

### 배포 (같은 날 이어서)
- 로컬 폴더를 git 저장소로 초기화하고 원격 `Dorongyee/habit_tracker`(Public, main) 에 연결
- `.gitignore` 에 `backup/` 추가 — 로컬 백업이 Pages에 배포되지 않게
- 커밋 `c0ca588` 푸시 (`e5ee0c3..c0ca588`). 원격에는 `index.html` 하나만 있었고 `supabase-setup.sql` 은 이때 처음 올라감
- **GitHub Pages 활성화** — `gh api -X POST repos/Dorongyee/habit_tracker/pages` (source: main / root)
- 배포 확인: https://dorongyee.github.io/habit_tracker/ → HTTP 200, 배포본 197행이 수정된 베이스 URL인 것 확인

### 검증 (실제 브라우저 구동)
chrome-devtools MCP 설치(user 스코프) + 이번 세션에서는 puppeteer-core로 Chrome을 직접 띄워 확인.
- `GET https://dorongyee.github.io/habit_tracker/` → **HTTP 200**, title `습관 점수표`
- 모바일 뷰포트(430x900, DPR2) 렌더링 정상 — 게이트 화면, 다크테마, 구글 로그인 버튼 노출 확인 (스크린샷)
- 게이트 상태: `gateVisible=true`, 문구 "구글 계정으로 로그인하면 폰과 PC에서 같은 기록을 볼 수 있습니다.", 버튼 `구글 계정으로 로그인` — "설정이 비어 있습니다" 아님 = **키 정상 인식**
- JS 런타임 에러 **0건**, supabase-js CDN 동적 import 성공
- 로그인 버튼 클릭 → `accounts.google.com/v3/signin/identifier` 로 이동, 화면에 "zmgcxueaesedyfkkxlzi.supabase.co(으)로 이동" 표시
  → **redirect_uri_mismatch 없음**. 구글 콘솔의 승인된 리디렉션 URI가 올바르게 등록된 것이 실증됨
- Supabase `/auth/v1/settings` 조회: `google: true` (초기엔 false였고, 사용자가 프로바이더 켠 뒤 재확인)
- `/auth/v1/authorize?provider=google` 302 Location 검사: client_id / redirect_uri(supabase callback) / redirect_to(Pages 주소) 3개 모두 정상

### 남은 이슈
- `https://dorongyee.github.io/favicon.ico` **404** (유일한 네트워크 에러). 동작엔 영향 없음. "홈 화면에 추가" 시 아이콘이 기본값으로 보임 → 아이콘 추가는 사용자 요청 시 진행
- 실제 구글 계정 로그인 후 데이터 저장/폰-PC 동기화는 **사용자 계정 자격증명이 필요해 미검증**

### 다음 할 일
1. ~~구글 OAuth 클라이언트 생성~~ 완료 (client_id `752067815700-g21gbl...`)
2. ~~Supabase Google 프로바이더 활성화~~ 완료 (`google: true` 확인)
3. ~~URL Configuration~~ 완료 (302 응답의 redirect_to 로 확인)
4. **사용자 실제 로그인 → 폰·PC 교차 동기화 확인** ← 남음

### 비고
- 로컬 폴더가 git 저장소가 아니었음 (`.git` 없음) → GitHub 업로드는 웹 UI로 한 것으로 보임
- 배포 작업 진행 중: GitHub CLI 설치 → 저장소 연결 → GitHub Pages 활성화

## 2026-09-20 (2차)
### 수정
- `index.html:146` **로그인 후에도 게이트 화면이 안 사라지는 버그 수정** — `.gate[hidden]{display:none}` 규칙 추가
  - 원인: `.gate{...display:flex}` 는 클래스 선택자(명시도 0,1,0)라 브라우저 기본 스타일 `[hidden]{display:none}` 를 이김. `hideGate()` 가 `gate.hidden = true` 를 해도 **실제로는 계속 화면을 덮고 있었음**
  - 로그인 자체와 동기화는 정상 작동 중이었고, 오버레이만 안 걷힌 것
- 백업: `backup/2026-09-20-2/index.html`

### 검증
- 수정 전 배포본(실측): `gate.hidden = true` 후에도 `display: flex`, `stillCoversScreen: true`
- 수정 후 로컬: `display: none`, `stillCoversScreen: false`
- 수정 후 배포본 재검증(빌드 `4d93852` 반영 확인 후): `display: none`, `stillCoversScreen: false` → **해결**
- 게이트를 걷은 뒤 앱 화면 스크린샷 확인: 오늘 탭 정상 렌더링, 날짜 "9월 20일 (일)" **일요일 빨간색 적용 확인**, 원형 게이지·하단 탭 3개 정상
