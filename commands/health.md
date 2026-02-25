---
description: Automatic version compatibility verification - comparing project tech stack against plugin support range
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# /health Command

Analyzes the project's package.json to verify version compatibility with the enf plugin.

## Usage

```
/health                  # 전체 호환성 검사
```

## Supported Version Matrix

| Technology | Support Range | Minimum Version | package.json Key |
|------|----------|----------|-----------------|
| Next.js | 16.x | 16.0.0 | `next` |
| React | 19.x | 19.0.0 | `react` |
| Prisma | 7.x | 7.0.0 | `prisma` (devDependencies) or `@prisma/client` (dependencies) |
| Better Auth | ^1.4.0 | 1.4.0 | `better-auth` |
| Tailwind CSS | 4.x | 4.0.0 | `tailwindcss` (dependencies or devDependencies) |
| TypeScript | ^5.0.0 | 5.0.0 | `typescript` (devDependencies) |

## Check Steps

### 1. Setup -- package.json Discovery

Finds and reads `package.json` from the project root.

```bash
# package.json 존재 확인
ls package.json
```

If package.json is not found, report an error and exit:

```
❌ package.json을 찾을 수 없습니다. 프로젝트 루트에서 실행하세요.
```

### 2. Detection -- Version Extraction

Extracts each package version from `dependencies` and `devDependencies` in package.json.

**Extraction targets**:
- `dependencies`: `next`, `react`, `@prisma/client`, `better-auth`, `tailwindcss`
- `devDependencies`: `prisma`, `typescript`, `tailwindcss`

**Actual installed version check** (more accurate when node_modules exists):

```bash
node -e "console.log(require('next/package.json').version)" 2>/dev/null
node -e "console.log(require('react/package.json').version)" 2>/dev/null
node -e "console.log(require('@prisma/client/package.json').version)" 2>/dev/null
node -e "console.log(require('better-auth/package.json').version)" 2>/dev/null
node -e "console.log(require('typescript/package.json').version)" 2>/dev/null
```

If node_modules does not exist, use the version ranges from package.json and output the following notice:

```
ℹ️ node_modules가 없어 package.json 선언 버전을 사용합니다.
   정확한 검사를 위해 의존성 설치 후 다시 실행하세요.
```

### 3. Analysis -- Compatibility Verdict

Each package is evaluated in 3 tiers:

| Status | Condition | Symbol |
|------|------|------|
| **PASS** | Within support range (major version matches) | ✅ |
| **WARN** | Version unparseable or package not installed | ⚠️ |
| **FAIL** | Outside support range (major version mismatch) | ❌ |

**Verdict logic**:

1. **Package not in package.json**:
   - Required packages (`next`, `react`, `typescript`): ⚠️ WARN
   - Optional packages (`better-auth`, `prisma`, `tailwindcss`): ✅ PASS (unused)

2. **Major version mismatch**: ❌ FAIL
   - Example: next@15.x -> ❌ (16.x required)

3. **Major version matches**: ✅ PASS
   - Example: next@16.3.0 -> ✅

4. **Better Auth special case**:
   - 1.4.x or above -> ✅ PASS
   - 1.3.x or below -> ❌ FAIL

5. **Version range string handling**:
   - Strip `^`, `~`, `>=`, `<`, `<=` prefixes and extract major version
   - `*`, `latest` -> ⚠️ WARN (exact version cannot be determined)

### 4. Report -- Output Results

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

### Additional Output on FAIL

If there are FAIL items, provide detailed information for each:

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

## Edge Cases

### Monorepo Detection

If package.json contains a `workspaces` field, display the following notice:

```
ℹ️ 모노레포 구조가 감지되었습니다.
   앱 디렉토리에서 /enf:health를 실행하세요.
```

### shadcn/ui

shadcn/ui is not an npm package, so it is excluded from version checks. Only the existence of the `components.json` file is verified.

## Related Commands

- `/enf:init` -- Project Structure guide
- `/enf:code-review` -- Code quality review

## Related Documentation

- `docs/COMPATIBILITY.md` -- Detailed supported version matrix
- `docs/TROUBLESHOOTING.md` -- Compatibility issue resolution
