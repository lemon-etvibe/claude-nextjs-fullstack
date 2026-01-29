---
name: tailwind-v4-shadcn
description: Tailwind CSS v4 + shadcn/ui 폼 패턴 및 스타일링 가이드
---

# Tailwind CSS v4 + shadcn/ui 가이드

## Tailwind CSS v4 주요 변경사항

### 1. CSS-first 설정

```css
/* globals.css - Tailwind v4 방식 */
@import "tailwindcss";

@theme {
  /* 커스텀 색상 */
  --color-primary: #0059ff;
  --color-secondary: #111111;

  /* 커스텀 폰트 */
  --font-sans: "Pretendard Variable", sans-serif;

  /* 커스텀 간격 */
  --spacing-18: 4.5rem;
}
```

> `tailwind.config.js` 대신 CSS `@theme` 디렉티브 사용

### 2. 새로운 유틸리티

```html
<!-- 컨테이너 쿼리 -->
<div class="@container">
  <div class="@lg:grid-cols-3">...</div>
</div>

<!-- 3D 변환 -->
<div class="rotate-x-12 perspective-500">...</div>

<!-- 그라디언트 위치 -->
<div class="bg-linear-to-r from-blue-500 from-30%">...</div>
```

### 3. 변수 기반 색상

```html
<!-- v3 -->
<div class="bg-blue-500 hover:bg-blue-600">

<!-- v4 - CSS 변수 활용 -->
<div class="bg-[--color-primary] hover:bg-[--color-primary-hover]">
```

---

## shadcn/ui 패턴

### 1. 설치 및 초기화

```bash
# shadcn/ui 초기화 (new-york 스타일)
pnpm dlx shadcn@latest init

# 컴포넌트 추가
pnpm dlx shadcn@latest add button card form input
```

### 2. 폼 패턴 (React Hook Form + Zod)

```tsx
"use client"

import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { z } from "zod"
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"

const formSchema = z.object({
  name: z.string().min(2, "이름은 2자 이상이어야 합니다"),
  email: z.string().email("유효한 이메일을 입력하세요"),
})

type FormValues = z.infer<typeof formSchema>

export function CustomerForm() {
  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: { name: "", email: "" },
  })

  const onSubmit = (data: FormValues) => {
    console.log(data)
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        <FormField
          control={form.control}
          name="name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>이름</FormLabel>
              <FormControl>
                <Input placeholder="홍길동" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>이메일</FormLabel>
              <FormControl>
                <Input type="email" placeholder="email@example.com" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? "저장 중..." : "저장"}
        </Button>
      </form>
    </Form>
  )
}
```

### 3. Server Action과 함께 사용

```tsx
"use client"

import { useActionState } from "react"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { updateCustomer } from "../_actions/customer"

export function CustomerEditForm({ customer }: { customer: Customer }) {
  const [state, formAction, pending] = useActionState(
    updateCustomer.bind(null, customer.id),
    null
  )

  const form = useForm({
    resolver: zodResolver(customerSchema),
    defaultValues: {
      name: customer.name,
      email: customer.email,
    },
  })

  return (
    <Form {...form}>
      <form action={formAction} className="space-y-4">
        {/* FormFields */}

        {state?.error && (
          <p className="text-sm text-destructive">{state.error}</p>
        )}

        <Button type="submit" disabled={pending}>
          {pending ? "저장 중..." : "저장"}
        </Button>
      </form>
    </Form>
  )
}
```

### 4. 다이얼로그/모달

```tsx
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"

export function CustomerDialog() {
  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button>고객 추가</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>새 고객 등록</DialogTitle>
        </DialogHeader>
        <CustomerForm />
      </DialogContent>
    </Dialog>
  )
}
```

### 5. 데이터 테이블 (TanStack Table)

```tsx
"use client"

import {
  useReactTable,
  getCoreRowModel,
  flexRender,
} from "@tanstack/react-table"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"

const columns = [
  { accessorKey: "name", header: "이름" },
  { accessorKey: "email", header: "이메일" },
  { accessorKey: "status", header: "상태" },
]

export function CustomerTable({ data }) {
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
  })

  return (
    <Table>
      <TableHeader>
        {table.getHeaderGroups().map((headerGroup) => (
          <TableRow key={headerGroup.id}>
            {headerGroup.headers.map((header) => (
              <TableHead key={header.id}>
                {flexRender(header.column.columnDef.header, header.getContext())}
              </TableHead>
            ))}
          </TableRow>
        ))}
      </TableHeader>
      <TableBody>
        {table.getRowModel().rows.map((row) => (
          <TableRow key={row.id}>
            {row.getVisibleCells().map((cell) => (
              <TableCell key={cell.id}>
                {flexRender(cell.column.columnDef.cell, cell.getContext())}
              </TableCell>
            ))}
          </TableRow>
        ))}
      </TableBody>
    </Table>
  )
}
```

---

## 테마 커스터마이징

### globals.css 구조

```css
@import "tailwindcss";

@theme {
  /* 프로젝트 색상 */
  --color-primary: #0059ff;
  --color-primary-hover: #0047cc;
  --color-secondary: #111111;
  --color-muted: #f4f4f5;

  /* 반경 */
  --radius-lg: 0.75rem;
  --radius-xl: 1rem;
  --radius-2xl: 1.5rem;
}

/* shadcn/ui 컴포넌트 변수 */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 0 0% 6.7%;
    --primary: 220 100% 50%;
    --primary-foreground: 0 0% 100%;
    /* ... */
  }
}
```

### 컴포넌트 확장

```tsx
// components/ui/button.tsx 커스터마이징
const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-xl font-semibold transition-colors",
  {
    variants: {
      variant: {
        default: "bg-primary text-white hover:bg-primary-hover",
        outline: "border border-gray-200 bg-white hover:bg-gray-50",
        ghost: "hover:bg-gray-100",
      },
      size: {
        default: "h-10 px-4",
        sm: "h-8 px-3 text-sm",
        lg: "h-12 px-6",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)
```

---

## 주의사항

1. **Tailwind v4는 PostCSS 설정 불필요** - Lightning CSS 내장
2. **JIT 모드 기본 활성화** - 별도 설정 불필요
3. **다크 모드**: `@media (prefers-color-scheme: dark)` 또는 `.dark` 클래스
4. **shadcn/ui 업데이트**: `pnpm dlx shadcn@latest diff` 로 변경사항 확인
