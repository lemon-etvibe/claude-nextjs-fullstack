---
description: Code quality review - TypeScript, performance, security, and best practices audit
allowed-tools:
  - Read
  - Glob
  - Grep
  - mcp__context7__query-docs
  - mcp__context7__resolve-library-id
skills:
  - vercel-react-best-practices
---

# /code-review Command

Reviews code in the specified file or directory.

> **Tools used**: References latest Next.js/React docs via context7 MCP, validates performance patterns with the `vercel-react-best-practices` skill

## Usage

```
/code-review <file-path|directory>
/code-review src/app/(admin)/_actions/customer.ts
/code-review src/components/ui
```

## Review Checklist

### 1. TypeScript Quality

- [ ] Usage of `any` type (replace with unknown or specific types)
- [ ] Strict mode compliance
- [ ] Unnecessary type declarations where type inference is possible
- [ ] Appropriate use of generics

### 2. React/Next.js Patterns

- [ ] Unnecessary 'use client' directives
- [ ] Server Components used by default
- [ ] Proper Suspense boundary placement
- [ ] metadata export (for pages)

### 3. Performance Optimization

- [ ] **Sequential await waterfall** - Consider parallelizing with Promise.all()
- [ ] **Dynamic import for heavy components** - Modals, editors, charts
- [ ] **Minimal data passing at RSC to CC boundary**
- [ ] **Individual file imports for lucide-react**
- [ ] **Lazy init for useState initial values**

### 4. Server Action Patterns (when applicable)

- [ ] 'use server' directive present
- [ ] Better Auth authentication check
- [ ] Zod schema validation
- [ ] revalidatePath cache invalidation
- [ ] Proper error return format

### 5. Prisma Queries (when applicable)

- [ ] Use select to query only necessary fields
- [ ] N+1 query prevention (use include)
- [ ] Proper index utilization

### 6. Security

- [ ] User input validation
- [ ] SQL injection prevention (using Prisma)
- [ ] XSS prevention
- [ ] No sensitive information exposure

### 7. Code Style

- [ ] Import order convention (React/Next > external > internal > types)
- [ ] Components PascalCase, utilities camelCase
- [ ] Accessibility (a11y) attributes

## Output Format

Provide review results in the following format:

```markdown
## 코드 리뷰 결과: {파일명}

### 발견된 이슈

#### 심각 (즉시 수정 필요)
- 이슈 설명 및 위치
- 수정 제안

#### 경고 (권장 수정)
- 이슈 설명 및 위치
- 수정 제안

#### 정보 (선택적 개선)
- 개선 제안

### 잘된 점
- 좋은 패턴 언급

### 총평
전체적인 코드 품질 평가
```

## Related Agents and Skills

- Based on the **dev-assistant** agent's code review checklist
- Validates React/Next.js performance optimization patterns with the **vercel-react-best-practices** skill
- Verifies against latest official documentation via **context7 MCP**

## Vercel Best Practices Check Items

The following Vercel recommended patterns are also verified during code review:

- [ ] Server Components used by default (use 'use client' only when necessary)
- [ ] Data fetching optimization (fetch caching, revalidate)
- [ ] Image optimization (next/image, priority, sizes)
- [ ] Font optimization (next/font)
- [ ] Metadata configuration (generateMetadata)
- [ ] Streaming and Suspense boundaries
- [ ] Route Handlers vs Server Actions selection
- [ ] Bundle size optimization (dynamic import, tree-shaking)
