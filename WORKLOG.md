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

### 다음 할 일 (사용자 수동 작업)
1. 구글 OAuth 클라이언트 생성 — 승인된 리디렉션 URI = `https://zmgcxueaesedyfkkxlzi.supabase.co/auth/v1/callback`
2. Supabase > Authentication > Providers > Google 에 ID/시크릿 입력
3. Supabase > Authentication > URL Configuration — Site URL / Redirect URLs = `https://dorongyee.github.io/habit_tracker/`
4. 폰·PC 교차 로그인 동기화 확인

### 비고
- 로컬 폴더가 git 저장소가 아니었음 (`.git` 없음) → GitHub 업로드는 웹 UI로 한 것으로 보임
- 배포 작업 진행 중: GitHub CLI 설치 → 저장소 연결 → GitHub Pages 활성화
