---
description: Performance analysis - bundle size, Core Web Vitals, and rendering strategy audit
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# /perf-audit Command

Analyzes application performance and provides optimization recommendations.

## Usage

```
/perf-audit                     # 전체 분석
/perf-audit <file-path>         # 특정 파일 분석
/perf-audit src/app/(site)      # 특정 디렉토리 분석
```

## Analysis Areas

### 1. Waterfall Pattern Detection (CRITICAL)

Finds sequential data requests and suggests parallelization.

```typescript
// BAD: 순차 실행 (650ms = 200 + 250 + 200)
const customer = await fetchCustomer(id)
const campaigns = await fetchCampaigns(id)
const stats = await fetchStats(id)

// GOOD: 병렬 실행 (250ms = max(200, 250, 200))
const [customer, campaigns, stats] = await Promise.all([
  fetchCustomer(id),
  fetchCampaigns(id),
  fetchStats(id),
])
```

### 2. Bundle Size Analysis

```bash
# 번들 분석 명령어
pnpm build
npx @next/bundle-analyzer
```

#### Key Check Items

- [ ] Full import of lucide-react
- [ ] Usage of heavy libraries (moment, lodash, etc.)
- [ ] Unnecessary client components
- [ ] Large components without dynamic import

### 3. Dynamic Import Candidates

```typescript
import dynamic from "next/dynamic"

// 1. 모달/다이얼로그
const CustomerDialog = dynamic(() => import("./CustomerDialog"))

// 2. 리치 텍스트 에디터
const RichTextEditor = dynamic(() => import("./RichTextEditor"), { ssr: false })

// 3. 차트/그래프
const StatsChart = dynamic(() => import("./StatsChart"), { ssr: false })

// 4. 코드 하이라이터
const CodeBlock = dynamic(() => import("./CodeBlock"), { ssr: false })
```

### 4. Core Web Vitals Checklist

#### LCP (Largest Contentful Paint) <= 2.5s

- [ ] `priority` attribute on LCP element
- [ ] `fetchPriority="high"` on images
- [ ] Critical CSS inlined
- [ ] Server response time < 200ms

#### INP (Interaction to Next Paint) <= 100ms

- [ ] Server Components used by default
- [ ] Minimize 'use client'
- [ ] Optimize event handlers
- [ ] Leverage useDeferredValue

#### CLS (Cumulative Layout Shift) <= 0.1

- [ ] All images specify width/height
- [ ] Font display: swap
- [ ] Skeleton UI used
- [ ] Space reserved for dynamic content

### 5. Rendering Strategy Review

| Page Type | Recommended Strategy | Configuration |
| --------------- | ---------- | -------------------- |
| Static content | SSG | generateStaticParams |
| Frequently changing | ISR | revalidate: 300 |
| Real-time data | Dynamic | force-dynamic |
| Partially dynamic | PPR | experimental_ppr |

### 6. Image Optimization

```tsx
import Image from "next/image"

<Image
  src="/images/hero.webp"
  alt="Hero"
  width={1200}
  height={630}
  priority                    // LCP 이미지
  fetchPriority="high"
  quality={85}
  sizes="(max-width: 768px) 100vw, 1200px"
/>
```

## Analysis Output Format

```markdown
## 성능 분석 결과

### 1. Waterfall 이슈
| 파일 | 라인 | 문제 | 권장 수정 |
| ---- | ---- | ---- | --------- |

### 2. Bundle Size 이슈
| 패키지/파일 | 크기 | 문제 | 권장 수정 |
| ----------- | ---- | ---- | --------- |

### 3. Dynamic Import 대상
| 컴포넌트 | 파일 | 이유 |
| -------- | ---- | ---- |

### 4. Core Web Vitals 개선점
#### LCP
- ...
#### INP
- ...
#### CLS
- ...

### 5. 렌더링 전략 제안
| 페이지 | 현재 | 권장 | 이유 |
| ------ | ---- | ---- | ---- |

### 6. 우선순위 작업
1. [높음] ...
2. [중간] ...
3. [낮음] ...
```

## Related Agents

This command is based on the `performance-expert` agent's optimization guidelines.
