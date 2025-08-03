#!/usr/bin/perl
use strict;
use warnings;
use utf8;
binmode STDOUT, ':utf8';

# 한국어 번역 매핑
my %translations = (
    # 기본 UI 요소
    'Save' => '저장',
    'Cancel' => '취소',
    'OK' => '확인',
    'Apply' => '적용',
    'Close' => '닫기',
    'Open' => '열기',
    'New' => '새로 만들기',
    'Delete' => '삭제',
    'Edit' => '편집',
    'Copy' => '복사',
    'Paste' => '붙여넣기',
    'Cut' => '잘라내기',
    'Undo' => '실행 취소',
    'Redo' => '다시 실행',
    'Find' => '찾기',
    'Replace' => '바꾸기',
    'Select All' => '모두 선택',
    
    # 연결 관련
    'Connect' => '연결',
    'Disconnect' => '연결 끊기',
    'Connection' => '연결',
    'Host' => '호스트',
    'Port' => '포트',
    'Username' => '사용자명',
    'Password' => '비밀번호',
    'Private Key' => '개인 키',
    'Public Key' => '공개 키',
    'Authentication' => '인증',
    'Login' => '로그인',
    'Logout' => '로그아웃',
    
    # 네트워크
    'Network' => '네트워크',
    'Proxy' => '프록시',
    'Direct' => '직접',
    'SSH' => 'SSH',
    'Telnet' => 'Telnet',
    'FTP' => 'FTP',
    'SFTP' => 'SFTP',
    'VNC' => 'VNC',
    'RDP' => 'RDP',
    
    # 터미널
    'Terminal' => '터미널',
    'Console' => '콘솔',
    'Shell' => '셸',
    'Command' => '명령',
    'Execute' => '실행',
    'Script' => '스크립트',
    'Log' => '로그',
    'History' => '기록',
    
    # 설정
    'Settings' => '설정',
    'Configuration' => '구성',
    'Options' => '옵션',
    'Preferences' => '환경설정',
    'Default' => '기본값',
    'Advanced' => '고급',
    'General' => '일반',
    'Security' => '보안',
    
    # 파일 및 폴더
    'File' => '파일',
    'Folder' => '폴더',
    'Directory' => '디렉토리',
    'Path' => '경로',
    'Browse' => '찾아보기',
    'Upload' => '업로드',
    'Download' => '다운로드',
    
    # 상태
    'Connected' => '연결됨',
    'Disconnected' => '연결 끊김',
    'Connecting' => '연결 중',
    'Ready' => '준비',
    'Busy' => '사용 중',
    'Error' => '오류',
    'Warning' => '경고',
    'Information' => '정보',
    'Success' => '성공',
    'Failed' => '실패',
    
    # 시간
    'Timeout' => '시간 초과',
    'Delay' => '지연',
    'Duration' => '지속 시간',
    'Start' => '시작',
    'Stop' => '정지',
    'Pause' => '일시 정지',
    'Resume' => '재개',
    
    # 창 및 탭
    'Window' => '창',
    'Tab' => '탭',
    'Panel' => '패널',
    'Toolbar' => '도구 모음',
    'Statusbar' => '상태 표시줄',
    'Menubar' => '메뉴 표시줄',
    
    # 기타
    'Version' => '버전',
    'About' => '정보',
    'License' => '라이선스',
    'Copyright' => '저작권',
    'Author' => '작성자',
    'Description' => '설명',
    'Name' => '이름',
    'Title' => '제목',
    'Size' => '크기',
    'Type' => '유형',
    'Status' => '상태',
    'Properties' => '속성',
    'Details' => '세부 정보',
    'Summary' => '요약',
    'Total' => '전체',
    'Available' => '사용 가능',
    'Enabled' => '사용',
    'Disabled' => '사용 안 함',
    'Visible' => '표시',
    'Hidden' => '숨김',
    'Selected' => '선택됨',
    'Unselected' => '선택 안 됨',
    'Active' => '활성',
    'Inactive' => '비활성',
    'Online' => '온라인',
    'Offline' => '오프라인',
);

# ko.po 파일 읽기
open my $fh, '<:utf8', 'ko.po' or die "Cannot open ko.po: $!";
my $content = do { local $/; <$fh> };
close $fh;

my $changes = 0;

# 각 번역에 대해 처리
for my $english (keys %translations) {
    my $korean = $translations{$english};
    
    # msgid "English" 다음에 msgstr ""가 있는 패턴 찾기
    if ($content =~ s/(msgid\s+"\Q$english\E"\s*\n\s*msgstr\s+)""/$1"$korean"/g) {
        $changes++;
        print "번역 추가: '$english' -> '$korean'\n";
    }
}

if ($changes > 0) {
    # 파일에 다시 쓰기
    open my $out_fh, '>:utf8', 'ko.po' or die "Cannot write ko.po: $!";
    print $out_fh $content;
    close $out_fh;
    
    print "\n총 " . $changes . "개의 번역이 추가되었습니다.\n";
} else {
    print "추가할 번역이 없습니다.\n";
}