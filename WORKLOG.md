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

### 비고
- 로컬 폴더가 git 저장소가 아니었음 (`.git` 없음) → GitHub 업로드는 웹 UI로 한 것으로 보임
- 배포 작업 진행 중: GitHub CLI 설치 → 저장소 연결 → GitHub Pages 활성화
