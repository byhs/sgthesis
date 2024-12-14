% sgthesis.cls
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sgthesis}[2024/12/12 Sogang University Thesis Class]

% report 클래스 기반, A4용지 11pt
\LoadClass[a4paper,11pt]{report}

% 폰트 설정
\RequirePackage{unicode-math}
\RequirePackage{luatexko}
\setmainfont{Latin Modern Roman}
\setsansfont{Latin Modern Sans}
\setmonofont{Latin Modern Mono}
\setmathfont{Latin Modern Math}
\setmainhangulfont{Noto Serif CJK KR}
\setsanshangulfont{Noto Sans CJK KR}
\setmonohangulfont{Noto Sans Mono CJK KR}

% 여백 설정
\RequirePackage{geometry}
\geometry{
  includeheadfoot,
  top=38mm, bottom=38mm,
  left=35mm, right=35mm,
  headheight=15mm, headsep=0mm,
  footskip=15mm
}

% 줄간격
\RequirePackage{setspace}
\setstretch{1.6}

% 문단 설정
\setlength{\parindent}{2em} 
\setlength{\parskip}{0pt}

% Hyperref 및 링크 색상 설정
\RequirePackage{hyperref}
\RequirePackage[dvipsnames,svgnames,x11names]{xcolor}
\hypersetup{
    colorlinks=true,
    linkcolor=Blue3,
    citecolor=Blue3,
    urlcolor=violet,
    filecolor=red,
    pdfborder={0 0 0},
    bookmarksnumbered=true,
    bookmarksopen=true,
    pdfstartview=Fit,
    pdfdisplaydoctitle=true
}

% 기타 패키지
\RequirePackage{booktabs}
\RequirePackage{multirow}
\RequirePackage{tabularx}
\RequirePackage{enumitem}
\RequirePackage{caption}
\RequirePackage{subcaption}
\RequirePackage{etoolbox} % for \appto and \ifdefempty
\RequirePackage[absolute,overlay,showboxes]{textpos} % 절대 위치 지정 패키지 추가
\RequirePackage{luacode} % Lua code block
% \usepackage{ragged2e} % justifying
\RequirePackage{tikz} % for seal

\newcommand{\seal}{%
  \raisebox{-0.7ex}{% 수직 정렬을 위해 도장을 약간 올립니다. 필요에 따라 값을 조정하세요.
    \begin{tikzpicture}[scale=0.5]
      \draw[line width=1pt] (0,0) circle (0.55cm); % 원 그리기
      \node at (-0.05,0) {\fontsize{10pt}{10pt}\selectfont 인}; % "인" 글자를 약간 왼쪽으로 이동
    \end{tikzpicture}%
  }%
}

% textpos 설정 (단위는 pt로 설정)
\setlength{\TPHorizModule}{1pt}
\setlength{\TPVertModule}{1pt}
\textblockorigin{0pt}{0pt} % 페이지 왼쪽 상단을 기준점으로 설정

% Lua 함수를 정의하여 mm -> pt 변환
\begin{luacode}
  function toPt(length)
    return tex.sp(length) / 65536
  end

  function ptFromPageBottom(length)
    return (tex.dimen.paperheight - tex.sp(length)) / 65536
  end

  function ptMinusFromWidth(length)
    return (tex.dimen.paperwidth - tex.sp(length)) / 65536
  end
\end{luacode}

% LaTeX 명령어: 값을 미리 계산하고 저장
\edef\pageWidthPT{\directlua{tex.sprint(tex.dimen.paperwidth / 65536)}} % 전체 너비
\edef\pageHeightPT{\directlua{tex.sprint(tex.dimen.paperheight / 65536)}} % 전체 높이
\edef\centerWidthPT{\directlua{tex.sprint(tex.dimen.paperwidth / 65536 / 2)}} % 가로 중앙

% mm -> pt 변환 및 하단 기준 위치 계산
\newcommand{\toPt}[1]{\directlua{tex.sprint(toPt("#1"))}}
\newcommand{\ptFromPageBottom}[1]{\directlua{tex.sprint(ptFromPageBottom("#1"))}}
\newcommand{\ptMinusFromWidth}[1]{\directlua{tex.sprint(ptMinusFromWidth("#1"))}}

%%%%%%%%%%%%%%%%%%%%% 추가 사항 %%%%%%%%%%%%%%%%%%%%%

% 옵션값 저장용 변수 초기화
\newcommand{\sgcommittees}{}    % 심사위원 목록을 저장할 변수

\def\sg@degreeopt{}
\def\sg@languageopt{}

% 키 선언: 단순히 .store로 값을 보관
\DeclareKeys{
  degree   .store = \sg@degreeopt,
  language .store = \sg@languageopt,
}


% 옵션 처리
\ProcessKeyOptions

% degree 처리 (기본값 master)
\def\sg@degree{master}
\ifdefempty{\sg@degreeopt}{
  % 기본값 유지
}{
  \edef\sg@degree{\sg@degreeopt}
}

% language 처리 (기본값 english)
\def\sg@language{english}
\ifdefempty{\sg@languageopt}{
  % 기본값 유지
}{
  \edef\sg@language{\sg@languageopt}
}


% 메타데이터 저장용 변수 초기화
\def\sg@title{}       
\def\sg@subtitle{}    
\def\sg@author{}       
\def\sg@supervisor{}   
\def\sg@department{}   
\def\sg@major{}        
\def\sg@degreeyear{}   
\def\sg@degreemonth{}  
\def\sg@degreeday{}    
\def\sg@approvalyear{} 
\def\sg@approvalmonth{}
\def\sg@approvalday{}  
\def\sg@kabstract{}    
\def\sg@kkeywords{}    
\def\sg@eabstract{}    
\def\sg@ekeywords{}    

% degree 판정
\newif\ifsg@master
\newif\ifsg@phd

\ifdefstring{\sg@degree}{phd}{
  \sg@phdtrue
  \sg@masterfalse
}{
  \ifdefstring{\sg@degree}{master}{
    \sg@mastertrue
    \sg@phdfalse
  }{
    \sg@masterfalse
    \sg@phdfalse
  }
}

% 언어 설정에 따른 목차명, Chapter명 변경
\AtBeginDocument{%
  \ifdefstring{\sg@language}{korean}{
    \renewcommand{\contentsname}{차례}
    \renewcommand{\listfigurename}{그림 목차}
    \renewcommand{\listtablename}{표 목차}
    \renewcommand{\chaptername}{제}
    \makeatletter
    \renewcommand{\@makechapterhead}[1]{%
      \vspace*{50\p@}%
      {\parindent \z@ \centering \normalfont
        {\huge \bfseries \chaptername\ \thechapter\ 장}\par\nobreak
        \vskip 20\p@
        {\Huge \bfseries #1}\par\nobreak
        \vskip 40\p@
      }}
    \makeatother
  }
}

% 명령어 정의
\newcommand{\Title}[1]{\def\sg@title{#1}}
\newcommand{\Subtitle}[1]{\def\sg@subtitle{#1}}
\newcommand{\Author}[1]{\def\sg@author{#1}}
\newcommand{\Supervisor}[1]{\def\sg@supervisor{#1}}
\newcommand{\Department}[1]{\def\sg@department{#1}}
\newcommand{\Major}[1]{\def\sg@major{#1}}
\newcommand{\DegreeDate}[3]{\def\sg@degreeyear{#1}\def\sg@degreemonth{#2}\def\sg@degreeday{#3}}
\newcommand{\ApprovalDate}[3]{\def\sg@approvalyear{#1}\def\sg@approvalmonth{#2}\def\sg@approvalday{#3}}

% committee 명령어: 심사위원 누적 using etoolbox
\newcommand{\committee}[1]{%
  \forcsvlist{\addcommittee}{#1}%
}

\newcommand{\addcommittee}[1]{%
  \ifdefempty{\sgcommittees}{%
    \def\sgcommittees{#1}%
  }{%
    \appto{\sgcommittees}{,#1}%
  }%
}

% Abstract 및 Keywords
\newcommand{\KAbstract}[1]{\def\sg@kabstract{#1}}
\newcommand{\KKeywords}[1]{\def\sg@kkeywords{#1}}
\newcommand{\EAbstract}[1]{\def\sg@eabstract{#1}}
\newcommand{\EKeywords}[1]{\def\sg@ekeywords{#1}}

% 심사위원 출력 명령어 및 카운터 정의
\newcounter{commcount}

\newcommand{\printcommittee}[1]{%
    \typeout{#1}
  \ifnum\value{commcount}=0
    \noindent주심: #1 \hfill \seal \par\vspace*{1.5cm}
  \else
    \noindent부심: #1 \hfill \seal \par\vspace*{1.5cm}
  \fi
  \stepcounter{commcount}%
}

% % 심사위원 출력 명령어 수정
% \newcommand{\printcommittee}[1]{%
%     \typeout{#1} % 디버깅용 출력
%   \ifnum\value{commcount}=0
%     \noindent\begin{tabularx}{\linewidth}{@{}l X@{}}
%       주심: #1 & \hfill \seal \\
%     \end{tabularx}\par\vspace*{1.5cm}% 첫 위원은 주심과 도장
%   \else
%     \noindent\begin{tabularx}{\linewidth}{@{}l X@{}}
%       부심: #1 & \hfill \seal \\
%     \end{tabularx}\par\vspace*{1.5cm}% 이후 위원은 부심만
%   \fi
%   \stepcounter{commcount}%
% }

% Define a new environment for special pages
\newenvironment{specialpage}{
  \newgeometry{left=0mm, right=0mm, top=0mm, bottom=0mm, nohead, nofoot}
  \thispagestyle{empty}
}{
  % \clearpage
  \restoregeometry
}



\typeout{DEBUG: \pageWidthPT}
\typeout{DEBUG: \pageHeightPT}
\typeout{DEBUG: \centerWidthPT}
\typeout{DEBUG: toPt: \toPt{20mm}}
\typeout{DEBUG: ptFromPageBottom: \ptFromPageBottom{40mm}}
\typeout{DEBUG: ptMinusFromWidth: \ptMinusFromWidth{90mm}}


% Make Cover
\newcommand{\MakeCover}{%
  \begin{specialpage}
    % 박사학위논문 표시
    \ifsg@phd
      \begin{textblock}{\pageWidthPT}[0.5,0](\centerWidthPT,\toPt{20mm})
        \centering
        \noindent
        \fontsize{18pt}{18pt}\selectfont 박사학위논문
      \end{textblock}
    \fi
    
    % 제목
    %% 좌우 4.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{60mm})
      \centering
      \noindent
      \fontsize{26pt}{26pt}\selectfont \sg@title \\
      %% 논문 제목이 두줄에 걸칠 때는 사이 간격을 2cm로 함???
      % 부제목
      \vspace{2cm}
      \fontsize{18pt}{18pt}\selectfont \sg@subtitle
    \end{textblock}
    
    % 부제목
    % \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{80mm})
    %   \centering
    %   \noindent
    %   \fontsize{18pt}{18pt}\selectfont \sg@subtitle
    % \end{textblock}

    % 제출일
    \begin{textblock}{\pageWidthPT}(0,\ptFromPageBottom{100mm})
      \centering
      \noindent
      \fontsize{16pt}{16pt}\selectfont \sg@degreeyear 년 \sg@degreemonth 월
    \end{textblock}

     % 대학원
     %% 좌우 6.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{130mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{60mm})
      \centering
      \noindent
      \fontsize{22pt}{22pt}\selectfont 서강대학교 대학원
    \end{textblock}
    
     % 학과 및 전공
     %% 좌우 6.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{130mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{50mm})
      \centering
      \noindent
      \fontsize{22pt}{22pt}\selectfont \sg@department과\ifsg@phd ~\sg@major전공\fi
    \end{textblock}
    
    % 이름
    %% 좌우 7cm 여백
    \begin{textblock}{\ptMinusFromWidth{140mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{40mm})
      \centering
      \noindent
      \fontsize{22pt}{22pt}\selectfont \sg@author
    \end{textblock}
    ~
  \end{specialpage}
}


% Make Title Page
\newcommand{\MakeTitlePage}{%
  \begin{specialpage}
    % 제목
    %% 좌우 4.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{60mm})
      \centering
      \noindent
      \fontsize{26pt}{26pt}\selectfont \sg@title \\
      %% 논문 제목이 두줄에 걸칠 때는 사이 간격을 2cm로 함???
      % 부제목
      \vspace{2cm}
      \fontsize{18pt}{18pt}\selectfont \sg@subtitle
    \end{textblock}
    
    % 부제목
    %% 좌우 4.5cm 여백
    % \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{80mm})
    %   \centering
    %   \noindent
    %   \fontsize{18pt}{18pt}\selectfont \sg@subtitle
    % \end{textblock}
    
    % 제출일
    \begin{textblock}{\pageWidthPT}(0,\ptFromPageBottom{100mm})
      \centering
      \noindent
      \fontsize{16pt}{16pt}\selectfont \sg@degreeyear 년 \sg@degreemonth 월
    \end{textblock}

     % 대학원
     %% 좌우 6.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{130mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{60mm})
      \centering
      \noindent
      \fontsize{22pt}{22pt}\selectfont 서강대학교 대학원
    \end{textblock}
    
     % 학과 및 전공
     %% 좌우 6.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{130mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{50mm})
      \centering
      \noindent
      \fontsize{22pt}{22pt}\selectfont \sg@department과
    \end{textblock}
    
    % 이름
    %% 좌우 7cm 여백
    \begin{textblock}{\ptMinusFromWidth{140mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{40mm})
      \centering
      \noindent
      \fontsize{22pt}{22pt}\selectfont \sg@author
    \end{textblock}
    
    ~
  \end{specialpage}
}


% Make Submission Sheet
\newcommand{\MakeSubmissionSheet}{%
  \begin{specialpage}
    % 제목
    %% 좌우 4.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{50mm})
    % 되겠냐에요
    % \begin{textblock}{\ptMinusFromWidth{70mm}}[0.5,0](\centerWidthPT,\toPt{50mm})
      \centering
      \noindent
      \fontsize{22pt}{22pt}\selectfont \sg@title \\
      %% 논문 제목이 두줄에 걸칠 때는 사이 간격을 2cm로 함???
      % 부제목
      % 되겠냐에요
      \vspace{2cm}
      \noindent\fontsize{18pt}{18pt}\selectfont \sg@subtitle
    \end{textblock}
    
    % % 부제목
    % %% 좌우 4.5cm 여백
    % \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{60mm})
    %   \centering
    %   \noindent
    %   \fontsize{18pt}{18pt}\selectfont \sg@subtitle
    % \end{textblock}
    
    % 지도교수
    %% 좌우 6.5cm 여백
    % 되겠냐에요
    % \begin{textblock}{\ptMinusFromWidth{130mm}}[0.5,0](\centerWidthPT,\toPt{100mm})
    \begin{textblock}{\ptMinusFromWidth{130mm}}[0.5,0](\centerWidthPT,\toPt{150mm})
      \centering
      \noindent
      \fontsize{18pt}{18pt}\selectfont 지도교수 \sg@supervisor
    \end{textblock}
    
    % 제출 문구
    %% 좌우 5cm 여백
    % \begin{textblock}{\ptMinusFromWidth{100mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{100mm})
    % 되겠냐에요
    \begin{textblock}{\ptMinusFromWidth{80mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{100mm})
      \centering
      \noindent
      \fontsize{16pt}{16pt}\selectfont 이 논문을 \sg@department\ \ifsg@phd 박사 \else 석사 \fi 학위논문으로 제출함.
    \end{textblock}

    % 제출일
    %% 좌우 7cm 여백
    \begin{textblock}{\ptMinusFromWidth{140mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{80mm})
      \centering
      \noindent
      \fontsize{16pt}{16pt}\selectfont \sg@degreeyear 년 \sg@degreemonth 월 \sg@degreeday 일
    \end{textblock}

    % 대학원
    %% 좌우 6.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{130mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{60mm})
      \centering
      \noindent
      \fontsize{22pt}{22pt}\selectfont 서강대학교 대학원
    \end{textblock}

    % 학과
    %% 좌우 6.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{130mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{50mm})
      \centering
      \noindent
      \fontsize{22pt}{22pt}\selectfont \sg@department
    \end{textblock}

    % 이름
    %% 좌우 7cm 여백
    \begin{textblock}{\ptMinusFromWidth{140mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{40mm})
      \centering
      \noindent
      \fontsize{22pt}{22pt}\selectfont \sg@author
    \end{textblock}
    ~
  \end{specialpage}
}

% Make Approval Sheet
\newcommand{\MakeApprovalSheet}{%
  \begin{specialpage}
    % 인준서 제목
    \begin{textblock}{\pageWidthPT}(0,\toPt{30mm})
      \centering
      \noindent
      \fontsize{22pt}{22pt}\selectfont \underline{논 문 인 준 서}
    \end{textblock}
    
    % 인준 문구
    %% 좌우 4.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{50mm})
      \centering{\fontsize{16pt}{16pt}\selectfont \sg@author의 \sg@department\ \ifsg@phd 박사\else 석사\fi 학위논문을 인준함.}
    \end{textblock}
    
    % 인준 일자
    \begin{textblock}{\pageWidthPT}(0,\toPt{70mm})
      \centering
      \noindent
      \fontsize{16pt}{16pt}\selectfont \sg@approvalyear 년 \sg@approvalmonth 월 \sg@approvalday 일
    \end{textblock}
    
    % 심사위원 명단
    %% 우측 4.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{130mm}}[1,0](\ptMinusFromWidth{45mm},\toPt{100mm})
      % \noindent
      \fontsize{18pt}{18pt}\selectfont
      \setcounter{commcount}{0}%
      \edef\expandedSGCommittees{\noexpand\forcsvlist{\noexpand\printcommittee}{\sgcommittees}}
      \expandedSGCommittees
      
    \end{textblock}
    ~
  \end{specialpage}
}


% Make Acknowledgement
\newcommand{\MakeAcknowledgement}{%
  \thispagestyle{empty}
  감사의 글
  % 
  \clearpage
}

% Make Korean Abstract
\newcommand{\MakeKoreanAbstract}{%
  \thispagestyle{empty}
  국문 초록
  % \sg@kabstract, \sg@kkeywords
  \clearpage
}

% Make English Abstract
\newcommand{\MakeEnglishAbstract}{%
  \thispagestyle{empty}
  Abstract
  % \sg@eabstract, \sg@ekeywords
  \clearpage
}

% Make front matter
\newcommand{\makefrontmatter}{%
    \MakeCover   % 겉표지
    \cleardoublepage

    \MakeTitlePage  % 표제면
    \cleardoublepage

    \MakeSubmissionSheet % 제출서
    \cleardoublepage

    \MakeApprovalSheet % 인준서
    \cleardoublepage
}

\endinput
