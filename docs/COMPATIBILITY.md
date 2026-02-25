# 호환성 매트릭스

etvibe-nextjs-fullstack (enf) 플러그인이 지원하는 기술 스택 버전과 호환성 정보입니다.

---

## 목차

- [지원 버전 매트릭스](#지원-버전-매트릭스)
- [MCP 서버 버전](#mcp-서버-버전)
- [알려진 비호환](#알려진-비호환)
- [스킬별 검증 버전](#스킬별-검증-버전)
- [업그레이드 노트](#업그레이드-노트)

---

## 지원 버전 매트릭스

| 기술 | 지원 범위 | 최소 버전 | package.json 키 |
|------|----------|----------|-----------------|
| **Next.js** | 16.x | 16.0.0 | `next` |
| **React** | 19.x | 19.0.0 | `react` |
| **Prisma** | 7.x | 7.0.0 | `@prisma/client` / `prisma` (dev) |
| **Better Auth** | ^1.4.0 | 1.4.0 | `better-auth` |
| **Tailwind CSS** | 4.x | 4.0.0 | `tailwindcss` |
| **TypeScript** | ^5.0.0 | 5.0.0 | `typescript` (dev) |

### 플러그인 버전

| 플러그인 버전 | 호환 스택 | 비고 |
|-------------|----------|------|
| 0.9.x | 위 매트릭스 전체 | 현재 버전 |

---

## MCP 서버 버전

| MCP 서버 | 고정 버전 | 비고 |
|----------|----------|------|
| context7 | `@upstash/context7-mcp@2.1.2` | Phase 2에서 버전 고정 |
| next-devtools | `next-devtools-mcp@0.3.10` | Phase 2에서 버전 고정 |
| prisma-local | `prisma mcp` | 프로젝트 로컬 Prisma CLI 사용 |

---

## 알려진 비호환

| 기술 | 비호환 버전 | 증상 | 대처 |
|------|-----------|------|------|
| Next.js | 15.x 이하 | `proxy.ts` 미지원, middleware.ts 사용 필요 | Next.js 16으로 업그레이드 |
| React | 18.x 이하 | `useActionState` 미지원 | React 19로 업그레이드 |
| Prisma | 6.x 이하 | `prisma.config.ts` 미지원, pg adapter 불필요 | Prisma 7로 업그레이드 |
| Better Auth | 1.3.x 이하 | API 변경으로 인증 패턴 불일치 | 1.4.x 이상으로 업그레이드 |
| Tailwind CSS | 3.x 이하 | `@theme` 디렉티브 미지원, config.js 방식 | Tailwind 4로 업그레이드 |

---

## 스킬별 검증 버전

각 스킬의 `tested-with` 메타데이터는 해당 스킬 내용이 검증된 버전을 나타냅니다.

| 스킬 | 핵심 의존성 | 검증 버전 |
|------|-----------|----------|
| `prisma-7` | Prisma, TypeScript | 7.x, 5.x |
| `better-auth` | Better Auth, Next.js, TypeScript | ^1.4.0, 16.x, 5.x |
| `tailwind-v4-shadcn` | Tailwind CSS, React, TypeScript | 4.x, 19.x, 5.x |
| `coding-conventions` | Next.js, TypeScript | 16.x, 5.x |
| `testing` | Next.js, React, Prisma, TypeScript | 16.x, 19.x, 7.x, 5.x |

---

## 업그레이드 노트

### Next.js 15 → 16

- `middleware.ts` → `proxy.ts` 마이그레이션
- `proxy()` 함수 export (기존 `middleware()` 대체)
- Edge Runtime → Node.js Runtime 기본값

### Prisma 6 → 7

- `prisma.config.ts` 설정 파일 필수 (프로젝트 루트)
- pg adapter 필수 (`@prisma/adapter-pg`)
- Client 생성 위치 변경 (`src/generated/prisma`)

### Better Auth 1.3 → 1.4

- `toNextJsHandler` import 경로 변경
- 세션 API 안정화

### Tailwind CSS 3 → 4

- `tailwind.config.js` → CSS `@theme` 디렉티브
- PostCSS 설정 불필요 (Lightning CSS 내장)
- JIT 모드 기본 활성화

---

## 버전 확인 방법

`/enf:health` 커맨드로 현재 프로젝트의 호환성을 자동 검증할 수 있습니다.

```bash
/enf:health              # 전체 호환성 검사
```

---

## 관련 문서

| 문서 | 설명 |
|------|------|
| [TROUBLESHOOTING](./TROUBLESHOOTING.md) | 호환성 문제 해결 |
| [SKILLS-ACTIVATION](./SKILLS-ACTIVATION.md) | 스킬 상세 가이드 |
| [CHANGELOG](../CHANGELOG.md) | 버전 이력 |
