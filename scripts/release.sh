#!/bin/bash

# HamoniKR SSH Client 릴리즈 스크립트
# 이 스크립트는 dev 브랜치에서 master 브랜치로 변경사항을 병합하고
# 새로운 버전 태그를 생성하여 릴리즈를 수행합니다.

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 스크립트의 실제 위치 확인
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# 프로젝트 루트 디렉토리 (스크립트의 상위 디렉토리)
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# 프로젝트 루트 디렉토리로 이동
cd "$PROJECT_ROOT"

echo -e "${BLUE}=== HamoniKR SSH Client 릴리즈 스크립트 ===${NC}"
echo -e "${YELLOW}프로젝트 디렉토리: ${NC}$PROJECT_ROOT"

# 현재 브랜치 확인
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "dev" ]; then
    echo -e "${RED}Error: dev 브랜치에서만 실행할 수 있습니다.${NC}"
    echo -e "${YELLOW}현재 브랜치: ${NC}$CURRENT_BRANCH"
    exit 1
fi

# 커밋되지 않은 변경사항 확인
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}Error: 커밋되지 않은 변경사항이 있습니다. 먼저 모든 변경사항을 커밋해주세요.${NC}"
    exit 1
fi

# master와 dev 브랜치의 차이 확인
git fetch origin master dev
MASTER_HEAD=$(git rev-parse origin/master)
DEV_HEAD=$(git rev-parse origin/dev)

if [ "$MASTER_HEAD" == "$DEV_HEAD" ]; then
    echo -e "${RED}Error: master 브랜치와 dev 브랜치의 내용이 동일합니다.${NC}"
    echo -e "${YELLOW}릴리즈할 새로운 변경사항이 없습니다.${NC}"
    exit 1
fi

# 현재 버전 가져오기 (lib/PACUtils.pm에서 추출)
if [ ! -f "lib/PACUtils.pm" ]; then
    echo -e "${RED}Error: lib/PACUtils.pm 파일을 찾을 수 없습니다.${NC}"
    exit 1
fi

CURRENT_VERSION_FROM_FILE=$(grep "our \$APPVERSION" lib/PACUtils.pm | sed -n "s/our \$APPVERSION = '\([^']*\)';/\1/p")
if [ -z "$CURRENT_VERSION_FROM_FILE" ]; then
    echo -e "${RED}Error: lib/PACUtils.pm에서 APPVERSION을 찾을 수 없습니다.${NC}"
    exit 1
fi

# 버전에서 -숫자 부분 제거 (예: 6.4.0-2 -> 6.4.0)
CLEAN_VERSION=$(echo "$CURRENT_VERSION_FROM_FILE" | sed 's/-[0-9]*$//')
CURRENT_VERSION="v$CLEAN_VERSION"

# Git 태그에서도 확인하여 더 높은 버전이 있으면 사용
GIT_VERSION=$(git tag --sort=-v:refname | grep '^v' | head -n1 2>/dev/null || echo "v0.0.0")
if [ "$GIT_VERSION" != "v0.0.0" ]; then
    # 버전 비교 (간단한 비교)
    if [[ "$GIT_VERSION" > "$CURRENT_VERSION" ]]; then
        CURRENT_VERSION="$GIT_VERSION"
    fi
fi

echo -e "${YELLOW}lib/PACUtils.pm에서 발견된 버전: ${NC}$CURRENT_VERSION_FROM_FILE"
echo -e "${YELLOW}Git에서 발견된 최신 태그: ${NC}$GIT_VERSION"

# 버전 증가 함수
increment_version() {
    local version=$1
    local increment_type=$2
    
    # v 접두사 제거
    version=${version#v}
    
    # 버전을 . 으로 분리
    IFS='.' read -ra VERSION_PARTS <<< "$version"
    
    major=${VERSION_PARTS[0]:-0}
    minor=${VERSION_PARTS[1]:-0}
    patch=${VERSION_PARTS[2]:-0}
    
    case $increment_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch|*)
            patch=$((patch + 1))
            ;;
    esac
    
    echo "v$major.$minor.$patch"
}

# 파라미터 파싱
AUTO_YES=false
VERSION_TYPE="patch"

for arg in "$@"; do
    case $arg in
        --yes|-yes|-y|-Y)
            AUTO_YES=true
            # -y 옵션만 사용하면 기본적으로 patch 버전으로 설정
            if [ $# -eq 1 ]; then
                VERSION_TYPE="patch"
            fi
            ;;
        major|minor|patch)
            VERSION_TYPE=$arg
            ;;
        *)
            echo -e "${RED}Error: 알 수 없는 파라미터: $arg${NC}"
            echo -e "${YELLOW}사용법: $0 [major|minor|patch] [--yes|-yes|-y|-Y]${NC}"
            echo -e "${YELLOW}       $0 -y  (patch 버전 자동 증가)${NC}"
            echo -e "${YELLOW}이 스크립트는 lib/PACUtils.pm의 APPVERSION을 업데이트합니다.${NC}"
            exit 1
            ;;
    esac
done

# 버전 타입 확인
if [[ ! "$VERSION_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo -e "${RED}Error: 버전 타입은 major, minor, patch 중 하나여야 합니다.${NC}"
    exit 1
fi

# 새 버전 생성
NEW_VERSION=$(increment_version $CURRENT_VERSION $VERSION_TYPE)

# lib/PACUtils.pm 버전 업데이트
echo -e "\n${YELLOW}lib/PACUtils.pm 버전 업데이트 중...${NC}"
# 업데이트 전 버전 출력
echo -e "${YELLOW}업데이트 전 APPVERSION:${NC}"
grep "our \$APPVERSION" lib/PACUtils.pm

# 새 버전으로 업데이트 (v 접두사 제거하고 -1 추가)
NEW_VERSION_WITH_BUILD="${NEW_VERSION#v}-1"

# OS 확인 후 적절한 sed 명령어 사용
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/our \$APPVERSION = '[^']*';/our \$APPVERSION = '$NEW_VERSION_WITH_BUILD';/" lib/PACUtils.pm
else
    # Linux 및 기타
    sed -i "s/our \$APPVERSION = '[^']*';/our \$APPVERSION = '$NEW_VERSION_WITH_BUILD';/" lib/PACUtils.pm
fi

# 업데이트 후 버전 출력
echo -e "${YELLOW}업데이트 후 APPVERSION:${NC}"
grep "our \$APPVERSION" lib/PACUtils.pm



# 변경사항 요약 표시
echo -e "\n${YELLOW}변경사항 요약:${NC}"
git --no-pager log --oneline origin/master..origin/dev

echo -e "\n${YELLOW}현재 버전: ${NC}$CURRENT_VERSION"
echo -e "${YELLOW}새로운 버전: ${NC}$NEW_VERSION"
echo -e "\n${GREEN}릴리즈 프로세스를 시작합니다...${NC}"

# 사용자 확인
if [ "$AUTO_YES" = true ]; then
    echo -e "\n${YELLOW}--yes 옵션이 설정되어 릴리즈를 자동으로 진행합니다.${NC}"
else
    read -p "계속 진행하시겠습니까? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}릴리즈가 취소되었습니다.${NC}"
        exit 1
    fi
fi

# lib/PACUtils.pm 변경사항 커밋
echo -e "\n${YELLOW}lib/PACUtils.pm 변경사항 커밋${NC}"
git add lib/PACUtils.pm
git commit -m "chore: bump version to ${NEW_VERSION}"

# 릴리즈 프로세스 실행
echo -e "\n${BLUE}=== 릴리즈 프로세스 시작 ===${NC}"

echo -e "\n${YELLOW}1. master 브랜치로 전환${NC}"
git checkout master
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: master 브랜치로 전환 실패${NC}"
    exit 1
fi

echo -e "\n${YELLOW}2. master 브랜치 업데이트${NC}"
git pull origin master
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: master 브랜치 업데이트 실패${NC}"
    exit 1
fi

echo -e "\n${YELLOW}3. dev 브랜치 머지${NC}"
git merge dev --no-ff -m "Merge dev branch for release ${NEW_VERSION}"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: dev 브랜치 머지 실패${NC}"
    exit 1
fi

echo -e "\n${YELLOW}4. 새로운 태그 생성${NC}"
git tag -a $NEW_VERSION -m "Release $NEW_VERSION

- HamoniKR SSH Client $NEW_VERSION 릴리즈
- 변경사항은 CHANGELOG.md를 참조하세요"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: 태그 생성 실패${NC}"
    exit 1
fi

echo -e "\n${YELLOW}5. master 브랜치 변경사항 푸시${NC}"
git push origin master
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: master 브랜치 푸시 실패${NC}"
    exit 1
fi

echo -e "\n${YELLOW}6. 태그 푸시${NC}"
git push origin $NEW_VERSION
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: 태그 푸시 실패${NC}"
    exit 1
fi

echo -e "\n${YELLOW}7. dev 브랜치로 복귀${NC}"
git checkout dev
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: dev 브랜치로 복귀 실패${NC}"
    exit 1
fi

echo -e "\n${YELLOW}8. dev 브랜치에 master의 변경사항 동기화${NC}"
git merge master --no-ff -m "Sync with master after release ${NEW_VERSION}"
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: dev 브랜치 동기화 실패${NC}"
    exit 1
fi

git push origin dev
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: dev 브랜치 푸시 실패${NC}"
    exit 1
fi

echo -e "\n${GREEN}=== 릴리즈 완료 ===${NC}"
echo -e "${GREEN}✅ 버전 ${NEW_VERSION} 릴리즈가 성공적으로 완료되었습니다!${NC}"
echo -e "${YELLOW}📋 다음 단계:${NC}"
echo -e "   - GitHub 릴리즈 페이지에서 릴리즈 노트 작성"
echo -e "   - 패키지 빌드 및 배포 확인"
echo -e "   - 문서 업데이트 확인"
echo -e "\n${YELLOW}🔗 유용한 링크:${NC}"
echo -e "   - 릴리즈 태그: https://github.com/hamonikr/hamonikr-ssh/releases/tag/${NEW_VERSION}"
echo -e "   - 커밋 히스토리: https://github.com/hamonikr/hamonikr-ssh/commits/master"
