# TODO

etvibe-nextjs-fullstack 플러그인 로드맵

---

## In Progress

- [ ] 새 프로젝트 초기 세팅 워크플로우 설계

---

## Backlog

### 설치 경험 개선

- [ ] **새 프로젝트 생성 스크립트** (`scripts/create.sh`)
  - `create-next-app` 실행
  - Prisma 7 초기 설정 (schema, pg adapter)
  - Better Auth 초기 설정
  - Tailwind v4 + shadcn/ui 설정
  - 기본 폴더 구조 생성
- [ ] **GUI 폴더 선택 다이얼로그** (선택적 개선)
  - macOS: AppleScript (`osascript`)
  - Windows: .NET FolderBrowserDialog

### 플러그인 기능

- [ ] 프로젝트 헬스체크 커맨드 (`/enf:health`)
- [ ] 의존성 버전 검사 및 업데이트 제안
- [ ] 환경 변수 템플릿 생성 (`.env.example`)

### 문서

- [ ] 새 프로젝트 생성 가이드 추가
- [ ] 트러블슈팅 가이드 확장
- [ ] 영문 README (선택)

---

## Done

- [x] 인터랙티브 프로젝트 경로 입력 모드 (2025-01-29)
- [x] Tab 자동완성 지원 - macOS/Linux (2025-01-29)
- [x] 플러그인 삭제 가이드 문서화 (2025-01-29)

---

## Notes

- 새 프로젝트 생성은 템플릿 저장소 vs 스크립트 방식 검토 필요
- Windows PowerShell Tab 완성은 기술적 한계로 인자 전달 방식 권장
