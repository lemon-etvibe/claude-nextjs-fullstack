---
description: 성능 분석 - 번들 크기, Core Web Vitals, 렌더링 전략 점검
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
---

# /perf-audit 명령어

애플리케이션의 성능을 분석하고 최적화 방안을 제시합니다.

## 사용법

```
/perf-audit                     # 전체 분석
/perf-audit <파일경로>          # 특정 파일 분석
/perf-audit src/app/(site)      # 특정 디렉토리 분석
```

## 분석 영역

### 1. Waterfall 패턴 검사 (CRITICAL)

순차적 데이터 요청을 찾아 병렬화를 제안합니다.

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

### 2. Bundle Size 분석

```bash
# 번들 분석 명령어
pnpm build
npx @next/bundle-analyzer
```

#### 주요 검사 항목

- [ ] lucide-react 전체 import 여부
- [ ] 무거운 라이브러리 (moment, lodash 등) 사용
- [ ] 불필요한 클라이언트 컴포넌트
- [ ] dynamic import 미적용 대형 컴포넌트

### 3. Dynamic Import 적용 대상

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

### 4. Core Web Vitals 체크리스트

#### LCP (Largest Contentful Paint) ≤ 2.5초

- [ ] LCP 요소에 `priority` 속성
- [ ] 이미지에 `fetchPriority="high"`
- [ ] 크리티컬 CSS 인라인화
- [ ] 서버 응답 시간 < 200ms

#### INP (Interaction to Next Paint) ≤ 100ms

- [ ] Server Components 우선 사용
- [ ] 'use client' 최소화
- [ ] 이벤트 핸들러 최적화
- [ ] useDeferredValue 활용

#### CLS (Cumulative Layout Shift) ≤ 0.1

- [ ] 모든 이미지 width/height 명시
- [ ] 폰트 display: swap
- [ ] 스켈레톤 UI 사용
- [ ] 동적 콘텐츠 공간 예약

### 5. 렌더링 전략 검토

| 페이지 유형      | 권장 전략   | 설정                 |
| --------------- | ---------- | -------------------- |
| 정적 콘텐츠     | SSG        | generateStaticParams |
| 자주 변경       | ISR        | revalidate: 300      |
| 실시간 데이터   | Dynamic    | force-dynamic        |
| 부분 동적       | PPR        | experimental_ppr     |

### 6. 이미지 최적화

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

## 분석 출력 형식

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

## 연계 에이전트

이 명령어는 `performance-expert` 에이전트의 최적화 가이드라인을 기반으로 합니다.
