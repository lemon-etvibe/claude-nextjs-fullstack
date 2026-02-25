---
description: 버전 호환성 자동 검증 - 프로젝트 기술 스택과 플러그인 지원 범위 비교
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# /health 명령어

프로젝트의 package.json을 분석하여 enf 플러그인과의 버전 호환성을 검증합니다.

## 사용법

```
/health                  # 전체 호환성 검사
```

## 지원 버전 매트릭스

| 기술 | 지원 범위 | 최소 버전 | package.json 키 |
|------|----------|----------|-----------------|
| Next.js | 16.x | 16.0.0 | `next` |
| React | 19.x | 19.0.0 | `react` |
| Prisma | 7.x | 7.0.0 | `prisma` (devDependencies) 또는 `@prisma/client` (dependencies) |
| Better Auth | ^1.4.0 | 1.4.0 | `better-auth` |
| Tailwind CSS | 4.x | 4.0.0 | `tailwindcss` (dependencies 또는 devDependencies) |
| TypeScript | ^5.0.0 | 5.0.0 | `typescript` (devDependencies) |

## 검사 단계

### 1. Setup — package.json 탐색

프로젝트 루트에서 `package.json`을 찾아 읽습니다.

```bash
# package.json 존재 확인
ls package.json
```

package.json이 없으면 에러를 보고하고 종료합니다:

```
❌ package.json을 찾을 수 없습니다. 프로젝트 루트에서 실행하세요.
```

### 2. Detection — 버전 추출

package.json의 `dependencies`와 `devDependencies`에서 각 패키지의 버전을 추출합니다.

**추출 대상**:
- `dependencies`: `next`, `react`, `@prisma/client`, `better-auth`, `tailwindcss`
- `devDependencies`: `prisma`, `typescript`, `tailwindcss`

**실제 설치 버전 확인** (node_modules가 있는 경우, 더 정확함):

```bash
node -e "console.log(require('next/package.json').version)" 2>/dev/null
node -e "console.log(require('react/package.json').version)" 2>/dev/null
node -e "console.log(require('@prisma/client/package.json').version)" 2>/dev/null
node -e "console.log(require('better-auth/package.json').version)" 2>/dev/null
node -e "console.log(require('typescript/package.json').version)" 2>/dev/null
```

node_modules가 없으면 package.json의 버전 범위를 사용하고 다음 안내를 출력합니다:

```
ℹ️ node_modules가 없어 package.json 선언 버전을 사용합니다.
   정확한 검사를 위해 의존성 설치 후 다시 실행하세요.
```

### 3. Analysis — 호환성 판정

각 패키지에 대해 다음 3단계로 판정합니다:

| 상태 | 조건 | 표시 |
|------|------|------|
| **PASS** | 지원 범위 내 (메이저 버전 일치) | ✅ |
| **WARN** | 버전 파싱 불가 또는 패키지 미설치 | ⚠️ |
| **FAIL** | 지원 범위 밖 (메이저 버전 불일치) | ❌ |

**판정 로직**:

1. **패키지가 package.json에 없음**:
   - 필수 패키지 (`next`, `react`, `typescript`): ⚠️ WARN
   - 선택 패키지 (`better-auth`, `prisma`, `tailwindcss`): ✅ PASS (미사용)

2. **메이저 버전 불일치**: ❌ FAIL
   - 예: next@15.x → ❌ (16.x 필요)

3. **메이저 버전 일치**: ✅ PASS
   - 예: next@16.3.0 → ✅

4. **Better Auth 특수 케이스**:
   - 1.4.x 이상 → ✅ PASS
   - 1.3.x 이하 → ❌ FAIL

5. **버전 범위 문자열 처리**:
   - `^`, `~`, `>=`, `<`, `<=` 접두사를 제거하고 메이저 버전 추출
   - `*`, `latest` → ⚠️ WARN (정확한 버전 파악 불가)

### 4. Report — 결과 출력

```markdown
## 프로젝트 호환성 검사 결과

### 환경 정보
- **플러그인 버전**: enf v0.9.1
- **프로젝트**: {package.json name 필드}

### 버전 호환성

| 기술 | 설치 버전 | 지원 범위 | 상태 |
|------|----------|----------|------|
| Next.js | 16.3.0 | 16.x | ✅ PASS |
| React | 19.1.0 | 19.x | ✅ PASS |
| Prisma | 7.2.0 | 7.x | ✅ PASS |
| Better Auth | 1.4.2 | ^1.4.0 | ✅ PASS |
| Tailwind CSS | 4.1.0 | 4.x | ✅ PASS |
| TypeScript | 5.8.0 | ^5.0.0 | ✅ PASS |

### MCP 서버 상태

`.mcp.json` 파일이 있으면 MCP 서버 버전을 확인합니다.

| MCP 서버 | 기대 버전 | 상태 |
|----------|----------|------|
| context7 | @2.1.2 | ✅ 일치 / ⚠️ 불일치 |
| next-devtools | @0.3.10 | ✅ 일치 / ⚠️ 불일치 |
| prisma-local | (로컬) | ℹ️ prisma CLI 사용 |

### 스킬 호환성

각 스킬의 `tested-with` 메타데이터와 프로젝트 버전을 비교합니다.

| 스킬 | 핵심 의존성 | 상태 |
|------|-----------|------|
| prisma-7 | Prisma 7.x | ✅ 호환 / ❌ 비호환 / ⚠️ 미사용 |
| better-auth | Better Auth ^1.4.0 | ✅ 호환 / ❌ 비호환 / ⚠️ 미사용 |
| tailwind-v4-shadcn | Tailwind CSS 4.x | ✅ 호환 / ❌ 비호환 / ⚠️ 미사용 |
| coding-conventions | TypeScript 5.x | ✅ 호환 |
| testing | Next.js 16.x, React 19.x | ✅ 호환 |

### 요약

| 항목 | 수 |
|------|---|
| ✅ PASS | N |
| ⚠️ WARN | N |
| ❌ FAIL | N |

**결과**: 모든 의존성이 호환됩니다.
```

### FAIL 시 추가 출력

FAIL 항목이 있으면 각 항목에 대해 상세 정보를 제공합니다:

```markdown
### ❌ 비호환 항목 상세

#### 1. Next.js 15.4.0 → 16.x 필요

이 플러그인은 Next.js 16의 다음 기능에 의존합니다:
- `proxy.ts` 파일 컨벤션 (middleware.ts 대체)
- Node.js Runtime 기본값

**업그레이드 방법**:
```bash
pnpm add next@16
```

**참고**: [COMPATIBILITY.md](../docs/COMPATIBILITY.md) 업그레이드 노트 참조
```

## 엣지 케이스

### monorepo 감지

package.json에 `workspaces` 필드가 있으면 다음을 안내합니다:

```
ℹ️ 모노레포 구조가 감지되었습니다.
   앱 디렉토리에서 /enf:health를 실행하세요.
```

### shadcn/ui

shadcn/ui는 npm 패키지가 아니므로 버전 검사에서 제외합니다. `components.json` 파일의 존재 여부만 확인합니다.

## 연계 명령어

- `/enf:init` — 프로젝트 구조 가이드
- `/enf:code-review` — 코드 품질 검사

## 연계 문서

- `docs/COMPATIBILITY.md` — 지원 버전 매트릭스 상세
- `docs/TROUBLESHOOTING.md` — 호환성 문제 해결
