---
name: push
description: Git 원격 저장소 푸시 - 안전한 푸시 워크플로우
allowed-tools:
  - Bash
---

# /push 명령어

현재 브랜치를 원격 저장소에 푸시합니다.

## 사용법

```
/push                   # 현재 브랜치 푸시
/push --force           # 강제 푸시 (주의!)
/push -u                # upstream 설정 후 푸시
```

## 워크플로우

### 1. 사전 체크

```bash
# 현재 브랜치 확인
git branch --show-current

# 커밋되지 않은 변경사항 확인
git status

# 원격과의 차이 확인
git log origin/$(git branch --show-current)..HEAD --oneline
```

### 2. 푸시 실행

#### 첫 푸시 (upstream 설정)

```bash
git push -u origin $(git branch --show-current)
```

#### 이후 푸시

```bash
git push
```

### 3. 푸시 후 확인

```bash
git log origin/$(git branch --show-current) --oneline -3
```

## 안전 체크리스트

### 푸시 전 확인

- [ ] 올바른 브랜치인가?
- [ ] 커밋되지 않은 변경사항이 없는가?
- [ ] 로컬 커밋이 의도한 것인가?
- [ ] main/master 브랜치가 아닌가?

### 강제 푸시 경고

```
⚠️  경고: --force 옵션은 원격 히스토리를 덮어씁니다!

다음 경우에만 사용하세요:
- 개인 브랜치의 rebase 후
- PR 리뷰 피드백 반영 후 squash
- 실수로 푸시한 민감 정보 제거

절대 금지:
- main/master 브랜치
- 다른 팀원이 작업 중인 브랜치
```

## 일반적인 문제 해결

### 1. 원격에 변경사항이 있는 경우

```bash
# 먼저 pull
git pull --rebase origin $(git branch --show-current)

# 그 다음 push
git push
```

### 2. upstream이 설정되지 않은 경우

```bash
git push -u origin $(git branch --show-current)
```

### 3. 권한 오류

```bash
# SSH 키 확인
ssh -T git@github.com

# 또는 HTTPS 토큰 확인
```

## 출력 형식

```markdown
## 푸시 결과

### 사전 체크
- **현재 브랜치**: feat/customer-login
- **커밋되지 않은 변경**: 없음
- **푸시할 커밋**: 3개

### 푸시할 커밋 목록
```
abc1234 feat(customer): 로그인 폼 구현
def5678 feat(customer): 로그인 API 연동
ghi9012 test(customer): 로그인 테스트 추가
```

### 실행 결과
```bash
git push -u origin feat/customer-login
```

- **상태**: 성공
- **원격 URL**: https://github.com/user/repo

### 다음 단계
- `/pr` - Pull Request 생성
```

## 연계 명령어

- `/commit` - 커밋 생성
- `/pr` - PR 생성
