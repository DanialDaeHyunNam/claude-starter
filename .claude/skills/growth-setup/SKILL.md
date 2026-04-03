---
name: growth-setup
description: SEO 메타태그, Google Analytics, Vercel Analytics를 함께 세팅하는 워크플로우.
---

# Growth Setup Skill

SEO, Google Analytics, Vercel Analytics를 프로젝트에 세팅합니다.
비개발자도 이해할 수 있도록 각 설정이 왜 필요한지 설명하고,
사용자와 함께 필요한 설정값(GA ID 등)을 입력합니다.

## When to Use

- 사용자가 `/growth-setup`을 입력했을 때
- `/7-implement-by-claude-teams` 완료 후 자동 호출

## Instructions

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## 성장 도구 세팅 (SEO + Analytics)

```
사용자가 검색으로 들어오고        어떻게 쓰는지 데이터로 확인
┌─────────────────────┐       ┌──────────────────────────┐
│  🔍 Google 검색      │       │  📊 방문자 수             │
│  "간호사 커리어 전환"  │  ──→   │  📊 어디서 왔는지         │
│  → 내 사이트 노출!    │       │  📊 어떤 페이지를 많이 보는지│
└─────────────────────┘       └──────────────────────────┘
        SEO                      Google Analytics
                                 + Vercel Analytics
```

**쉽게 말하면:**

1. **SEO** = 구글에서 내 사이트가 잘 검색되게 하는 설정
   - 사이트 이름, 설명, 미리보기 이미지 같은 것
2. **Google Analytics** = 방문자가 몇 명이고 뭘 하는지 보는 도구
   - 무료, 구글 계정만 있으면 됨
3. **Vercel Analytics** = Vercel에서 제공하는 성능 + 방문 분석
   - 페이지 로딩 속도, 실제 사용자 경험 측정

이 3가지를 지금 한꺼번에 세팅할 거예요.

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "다음 단계로 넘어갑니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

### Step 3: SEO 메타 정보 수집

AskUserQuestion으로 사용자에게 SEO에 필요한 정보를 하나씩 받습니다.

#### 3-1. 사이트 제목
- question: "사이트 이름을 정해주세요.\n구글 검색 결과에 나오는 제목이에요.\n\n예: \"커리어 나침반 — 간호사를 위한 진로 진단\""
- header: "SEO 설정 1/4: 사이트 제목"

#### 3-2. 사이트 설명
- question: "사이트를 한 문장으로 설명해주세요. (50~160자)\n구글 검색 결과에서 제목 아래 나오는 설명이에요.\n\n예: \"간호사 경력을 살린 새로운 직무를 찾아보세요. 5분 진단으로 맞춤 커리어 로드맵을 받아보세요.\""
- header: "SEO 설정 2/4: 사이트 설명"

#### 3-3. 대표 키워드
- question: "사람들이 어떤 키워드로 검색했을 때 내 사이트가 나왔으면 하나요?\n쉼표로 구분해서 3~5개 적어주세요.\n\n예: \"간호사 이직, 간호사 커리어 전환, 간호사 직무 추천\""
- header: "SEO 설정 3/4: 검색 키워드"

#### 3-4. OG 이미지
- question: "SNS에 링크를 공유했을 때 보이는 미리보기 이미지가 있나요?\n없으면 '없음'이라고 해주세요. 나중에 추가할 수 있어요."
- header: "SEO 설정 4/4: 미리보기 이미지"

### Step 4: SEO 구현

수집한 정보로 SEO를 구현합니다.

1. **`src/app/layout.tsx`의 metadata 설정**:
```typescript
import type { Metadata } from "next";

export const metadata: Metadata = {
  title: {
    default: "{사이트 제목}",
    template: "%s | {사이트 짧은 이름}",
  },
  description: "{사이트 설명}",
  keywords: ["{키워드1}", "{키워드2}", ...],
  openGraph: {
    title: "{사이트 제목}",
    description: "{사이트 설명}",
    url: "{배포 URL 또는 placeholder}",
    siteName: "{사이트 이름}",
    locale: "ko_KR",
    type: "website",
    // images: [{ url: "/og-image.png", width: 1200, height: 630 }],
  },
  twitter: {
    card: "summary_large_image",
    title: "{사이트 제목}",
    description: "{사이트 설명}",
  },
  robots: {
    index: true,
    follow: true,
  },
};
```

2. **`public/robots.txt`** 생성:
```
User-agent: *
Allow: /

Sitemap: {배포URL}/sitemap.xml
```

3. **`src/app/sitemap.ts`** 생성:
```typescript
import type { MetadataRoute } from "next";

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = process.env.NEXT_PUBLIC_BASE_URL || "https://example.com";
  return [
    { url: baseUrl, lastModified: new Date(), changeFrequency: "weekly", priority: 1 },
    // 주요 페이지 추가
  ];
}
```

### Step 5: Google Analytics 설정

#### 5-1. GA 계정 안내

사용자에게 안내:

```
📊 Google Analytics를 연결하려면 측정 ID가 필요해요.

아직 없다면 지금 만들 수 있어요:
1. https://analytics.google.com 접속
2. "측정 시작" 클릭
3. 계정 이름 입력 (예: "내 프로젝트")
4. 속성 이름 입력 (예: "커리어 나침반")
5. 웹 스트림 추가 → URL 입력
6. "G-XXXXXXXXXX" 형태의 측정 ID 복사

⏳ 시간이 걸릴 수 있으니, 나중에 하고 싶으면 "나중에"를 선택해주세요.
```

#### 5-2. GA ID 받기

AskUserQuestion:
- question: "Google Analytics 측정 ID를 입력해주세요.\n예: G-XXXXXXXXXX"
- header: "Google Analytics 설정"
- options:
  - label: "나중에 할게요" / description: "GA 설정을 건너뛰고 나중에 추가합니다"

#### 5-3. GA 구현

GA ID를 받으면:

1. **환경변수 추가** — `.env.local`에:
```
NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX
```

2. **`src/app/layout.tsx`에 GA 스크립트 추가**:
```typescript
import Script from "next/script";

// layout의 <head> 또는 <body> 안에:
{process.env.NEXT_PUBLIC_GA_ID && (
  <>
    <Script
      src={`https://www.googletagmanager.com/gtag/js?id=${process.env.NEXT_PUBLIC_GA_ID}`}
      strategy="afterInteractive"
    />
    <Script id="google-analytics" strategy="afterInteractive">
      {`
        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        gtag('js', new Date());
        gtag('config', '${process.env.NEXT_PUBLIC_GA_ID}');
      `}
    </Script>
  </>
)}
```

"나중에"를 선택하면 코드는 넣되 환경변수를 비워두고 안내:
```
GA 코드는 미리 넣어뒀어요.
나중에 .env.local에 NEXT_PUBLIC_GA_ID=G-XXXXXXXXXX 를 추가하면 바로 동작합니다.
```

### Step 6: Vercel Analytics 설정

1. **패키지 설치**:
```bash
bun add @vercel/analytics @vercel/speed-insights
```

2. **`src/app/layout.tsx`에 추가**:
```typescript
import { Analytics } from "@vercel/analytics/react";
import { SpeedInsights } from "@vercel/speed-insights/next";

// layout return 안에:
<Analytics />
<SpeedInsights />
```

사용자에게 안내:
```
✅ Vercel Analytics는 Vercel에 배포하면 자동으로 동작해요.
로컬에서는 데이터가 수집되지 않으니 걱정 마세요.

배포 후 Vercel 대시보드 → Analytics 탭에서 확인할 수 있어요.
```

### Step 7: 빌드 확인 + 완료

```bash
bun run build
```

빌드 성공 확인 후:

```
✅ Growth Setup 완료!

🔍 SEO
   - 메타 태그 설정 완료 (제목, 설명, 키워드, OG)
   - robots.txt 생성 완료
   - sitemap.ts 생성 완료

📊 Google Analytics
   - {설정 완료 / 코드 준비 완료 (ID 미입력)}

📈 Vercel Analytics
   - @vercel/analytics 설치 완료
   - @vercel/speed-insights 설치 완료
   - 배포 후 자동 활성화
```

## Rules

- SEO 정보는 반드시 사용자에게 직접 받는다 (임의로 작성하지 않음)
- GA ID가 없으면 강제하지 않고 나중에 추가할 수 있도록 안내
- 환경변수는 `.env.local`에만 저장 (`.env`에 직접 쓰지 않음)
- 빌드 확인은 필수
