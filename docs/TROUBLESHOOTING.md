# 트러블슈팅 가이드

플러그인 사용 중 발생하는 문제의 심층 진단, 해결, 롤백 방법입니다.

> **기본 FAQ**는 [SCENARIO-GUIDES.md](./SCENARIO-GUIDES.md#faq)를 먼저 확인하세요.
> 이 문서는 "기본 해결이 안 될 때"의 **심층 진단 + 우회 + 롤백**에 집중합니다.

---

## 빠른 진단

| 증상 | 바로가기 |
|------|---------|
| Hook이 실행되지 않거나 작업이 중단됨 | [→ Hooks 문제 해결](#hooks-문제-해결) |
| MCP 서버 연결 실패 | [→ MCP 서버 문제 해결](#mcp-서버-문제-해결) |
| 스킬이 잘못된 코드를 생성함 | [→ 스킬 코드 롤백](#스킬-코드-롤백) |
| 커맨드/에이전트를 찾을 수 없음 | [→ 플러그인 검증 & 복구](#플러그인-검증--복구) |

---

## Hooks 문제 해결

### Hook이 실행되지 않을 때

기본 확인(`claude plugin validate`)으로 해결되지 않으면 다음을 순서대로 점검합니다.

**1. 실행 권한 확인**

```bash
ls -la scripts/post-write-check.sh
# -rwxr-xr-x 이어야 함

# 권한 없으면 부여
chmod +x scripts/post-write-check.sh
```

**2. hooks.json 설정 확인**

`hooks/hooks.json`의 `matcher`가 `"Write|Edit"`인지 확인. 전체 구조는 파일을 직접 참조.

**3. 직접 실행 테스트**

```bash
bash scripts/post-write-check.sh src/app/test.ts
# → "TypeScript 파일이 수정되었습니다" + exit 0 이어야 함
```

**4. CLAUDE_PLUGIN_ROOT 확인** — `claude plugin list`로 플러그인 경로가 올바른지 확인

### Exit 2로 작업이 중단될 때

`.env` 파일 수정 시 Hook이 exit 2를 반환하여 작업을 중단합니다. **이것은 의도된 보안 동작입니다.**

**원인**: `post-write-check.sh`가 `.env*` 패턴 파일 수정을 차단

**올바른 대응**:
- `.env.example`에는 키 이름만 기록 (값 제외)
- 실제 값은 `.env.local`에 에디터에서 직접 작성
- Claude에게 `.env` 파일 수정을 요청하지 마세요
- `--no-verify` 같은 우회는 지원하지 않습니다

### Server Action 경고 해결

Hook이 Server Action 파일(`_actions/*.ts`)에서 3가지를 검사합니다:

| 경고 | 원인 | 해결 |
|------|------|------|
| `'use server' 지시문이 없습니다` | 파일 첫 줄에 `"use server"` 누락 | 파일 최상단에 추가 |
| `인증 검사가 없습니다` | `auth.api.getSession` 호출 없음 | 아래 패턴 적용 |
| `캐시 무효화가 없습니다` | `revalidatePath` 호출 없음 | 데이터 변경 후 추가 |

올바른 패턴은 [SCENARIO-GUIDES.md](./SCENARIO-GUIDES.md#3-인증-문제)의 Server Action 인증 패턴을 참조하세요.

### Hook 일시 비활성화

긴급 상황에서 Hook을 일시적으로 끄는 방법:

```json
// hooks/hooks.json — hooks 배열을 비움
{
  "hooks": {
    "PostToolUse": []
  }
}
```

> **작업 완료 후 반드시 원복하세요.** 비활성화 시 `.env` 방어도 해제됩니다.

---

## MCP 서버 문제 해결

### 공통 진단

```bash
/mcp              # 상태 확인
claude            # Claude 재시작 (MCP 재연결)
```

3개 MCP 서버 모두 `.claude/settings.local.json`의 `disabledMcpjsonServers`로 관리됩니다. 기본값은 비활성화 상태입니다.

### context7 (라이브러리 문서 조회)

**증상**: "context7 서버에 연결할 수 없습니다" 또는 문서 조회 실패

**원인**: npm 네트워크 문제, `@upstash/context7-mcp@2.1.2` 캐시 손상

**진단**: `npm info @upstash/context7-mcp version`으로 패키지 접근 확인

**수동 대체**: 공식 문서 직접 참조

| 라이브러리 | URL |
|-----------|-----|
| Next.js | https://nextjs.org/docs |
| Prisma | https://www.prisma.io/docs |
| Better Auth | https://www.better-auth.com/docs |
| Tailwind CSS | https://tailwindcss.com/docs |

### next-devtools (개발 서버 연동)

**증상**: 라우트 분석, 에러 진단 불가

**원인**: `pnpm dev` 미실행 상태에서 MCP 연결 시도

**해결**: `pnpm dev` 실행 → `claude` 재시작

**수동 대체**: `ls -la src/app/`으로 라우트 확인, `pnpm build`로 에러 확인, 브라우저 DevTools 활용

### prisma-local (마이그레이션/Studio)

**증상**: Prisma MCP 명령 실행 불가

**원인**: `prisma` CLI 미설치 또는 버전 불일치

**진단**: `pnpm prisma --version`으로 CLI 확인

**수동 대체**: `pnpm prisma validate`, `pnpm prisma migrate dev --name x`, `pnpm prisma studio`, `pnpm prisma generate` 직접 실행

### MCP 서버 활성화/비활성화

`.claude/settings.local.json`에서 관리:

```json
{
  "disabledMcpjsonServers": [
    "context7",
    "next-devtools",
    "prisma-local"
  ]
}
```

- **활성화**: 배열에서 해당 서버 이름 제거
- **비활성화**: 배열에 서버 이름 추가
- 변경 후 Claude 재시작 필요

---

## 스킬 코드 롤백

### 즉시 롤백 (커밋 전)

```bash
git checkout -- <파일경로>             # 특정 파일
git checkout -- src/app/(admin)/      # 디렉토리 단위
git checkout -- .                      # 전체 (주의: 모든 작업 손실)
```

### 커밋 후 롤백

```bash
git revert HEAD              # 마지막 커밋 (새 revert 커밋 생성)
git revert <commit-hash>     # 특정 커밋
```

### 스킬별 알려진 주의사항

| 스킬 | 주의사항 | 확인 방법 |
|------|---------|----------|
| better-auth | Next.js 16에서는 `proxy()` 대신 API Route handler 사용 | `skills/better-auth/SKILL.md` "Proxy" 섹션 |
| prisma-7 | pg adapter 설정 누락 가능 | `src/lib/prisma.ts`에 adapter 설정 확인 |
| tailwind-v4-shadcn | Tailwind v3 문법 혼용 (`config.js` vs `@theme`) | `globals.css`에 `@theme` 블록 사용 확인 |
| testing | mock 파일이 프로덕션 번들에 포함될 수 있음 | `tsconfig.json`의 exclude에 `src/test/` 포함 확인 |

### 코드 생성 후 검증

```bash
pnpm tsc --noEmit     # 타입 검사
pnpm lint             # ESLint 검사
pnpm build            # 빌드 검증
# 또는: /enf:type-check, /enf:code-review
```

---

## 플러그인 검증 & 복구

### 상태 확인

```bash
claude plugin list
claude plugin validate ~/plugins/enf
```

### 완전 재설치

```bash
claude plugin uninstall enf@enf-local
claude plugin install enf@enf-local --scope local
claude plugin validate ~/plugins/enf
```

### 개별 구성 요소 확인

플러그인이 인식되지만 특정 기능만 동작하지 않을 때:

| 구성 요소 | 확인 경로 | 확인 방법 |
|----------|----------|----------|
| Commands | `commands/*.md` | 파일 존재 + YAML frontmatter (`---`로 시작) |
| Skills | `skills/<name>/SKILL.md` | 파일 존재 + frontmatter `triggers` 확인 |
| Agents | `agents/*.md` | 파일 존재 + frontmatter 유효 |
| Hooks | `hooks/hooks.json` | JSON 유효 + 스크립트 실행 권한 |

### 외부 플러그인

```bash
claude plugin uninstall <plugin-name> && claude plugin install <plugin-name>
```

---

## 관련 문서

| 문서 | 내용 |
|------|------|
| [SCENARIO-GUIDES](./SCENARIO-GUIDES.md#faq) | 기초 FAQ (MCP, Hook, Agent, Skill) |
| [INSTALLATION](./INSTALLATION.md) | 설치 문제 해결 |
| [DEVELOPMENT](./DEVELOPMENT.md) | 개발 환경 문제 |
| [CUSTOMIZATION](./CUSTOMIZATION.md) | 플러그인 확장/수정 방법 |
