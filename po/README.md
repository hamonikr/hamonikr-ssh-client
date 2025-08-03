# Ásbrú Connection Manager 번역 가이드

이 디렉토리는 Ásbrú Connection Manager의 국제화(i18n) 및 번역 파일들을 포함합니다.

## 파일 구조

```
po/
├── README.md              # 이 파일
├── Makefile              # 번역 파일 빌드 자동화
├── extract-strings.sh    # 번역 가능한 문자열 추출 스크립트
├── asbru-cm.pot         # 번역 템플릿 파일
├── ko.po                # 한국어 번역 파일
├── ko.mo                # 컴파일된 한국어 번역 파일 (바이너리)
└── ko/                  # 로케일 디렉토리 구조
    └── LC_MESSAGES/
        └── asbru-cm.mo
```

## 번역 시스템 개요

Ásbrú Connection Manager는 GNU gettext 시스템을 사용하여 국제화를 지원합니다:

- **PACi18n.pm**: gettext 바인딩 및 번역 함수 제공
- **__t()**: 번역 함수 (소스 코드에서 사용)
- **po/**: 번역 파일 디렉토리
- 시스템 설치 시: `/usr/share/locale/`에 번역 파일 설치

## 사용 방법

### 1. 새로운 번역 가능한 문자열 추가

소스 코드에서 번역 가능한 문자열을 추가하려면:

```perl
# 기존
set_label('Export config...');

# 번역 가능하게 변경
set_label(__t('Export config...'));
```

### 2. 번역 템플릿 업데이트

새로운 문자열을 추출하려면:

```bash
make extract-pot
# 또는
./extract-strings.sh
```

### 3. 기존 번역 업데이트

새로운 문자열을 기존 번역 파일에 병합:

```bash
make update-po
```

### 4. 번역 파일 편집

`ko.po` 파일을 편집하여 번역 추가:

```po
#: ../lib/PACConfig.pm:130
msgid "Default Global Options"
msgstr "기본 전역 옵션"
```

### 5. 번역 파일 컴파일

번역 파일을 바이너리 형태로 컴파일:

```bash
make all
```

### 6. 번역 파일 설치

로케일 디렉토리에 설치:

```bash
make install
```

## 새로운 언어 추가

새로운 언어 지원을 추가하려면:

1. **PO 파일 생성**:
   ```bash
   msginit -l ja_JP.UTF-8 -o ja.po -i asbru-cm.pot --no-translator
   ```

2. **Makefile 업데이트**:
   ```makefile
   LANGUAGES = ko ja
   POFILES = ko.po ja.po
   ```

3. **debian/rules 업데이트**:
   ```bash
   for lang in ko ja; do \
   ```

## 데비안 패키지 빌드

데비안 패키지 빌드 시 번역 파일이 자동으로 포함됩니다:

1. **빌드 의존성**: `debian/control`에 `gettext` 포함
2. **빌드 과정**: `debian/rules`에서 번역 파일 자동 빌드
3. **설치 위치**: `/usr/share/locale/[언어]/LC_MESSAGES/asbru-cm.mo`

## 테스트

번역이 제대로 작동하는지 테스트:

```bash
# 한국어로 실행
LANG=ko_KR.UTF-8 ./asbru-cm

# 또는 직접 테스트
LANG=ko_KR.UTF-8 perl -I lib -e "use PACi18n; PACi18n::init_i18n('ko_KR.UTF-8'); print PACi18n::__i18n('Help') . \"\n\";"
```

## 현재 지원 언어

- 🇰🇷 한국어 (ko) - 부분 번역
- 🇺🇸 영어 (en) - 기본 언어

## 기여하기

번역에 기여하려면:

1. `po/ko.po` 파일 편집
2. 번역 추가/수정
3. `make all`로 컴파일 테스트
4. Pull Request 제출

## 문제 해결

### 번역이 표시되지 않는 경우

1. 로케일이 설치되어 있는지 확인: `locale -a | grep ko`
2. MO 파일이 올바른 위치에 있는지 확인
3. 환경 변수 확인: `echo $LANG`

### gettext를 찾을 수 없는 경우

```bash
sudo apt-get install gettext
```

## 관련 파일

- `lib/PACi18n.pm`: 국제화 모듈
- `lib/PACUtils.pm`: __t() 함수 정의
- `asbru-cm`: 메인 스크립트 (i18n 초기화)
- `debian/rules`: 패키지 빌드 규칙
- `debian/control`: 빌드 의존성