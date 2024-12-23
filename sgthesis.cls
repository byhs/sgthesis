% sgthesis.cls
% \NeedsTeXFormat{LaTeX2e}
\ProvidesClass{sgthesis}[2024/12/12 Sogang University Thesis Class]

% report 클래스 기반, A4용지 11pt, two-sided
\LoadClass[a4paper, 11pt]{report}

% 폰트 설정
\RequirePackage{unicode-math}
\RequirePackage{luatexko}
\setmainfont{Latin Modern Roman}
\setsansfont{Latin Modern Sans}
\setmonofont{Latin Modern Mono}
\setmathfont{Latin Modern Math}
%% 한글폰트
\setmainhangulfont{Noto Serif CJK KR}
\setsanshangulfont{Noto Sans CJK KR}
\setmonohangulfont{Noto Sans Mono CJK KR}

% Babel 설정 추가
\RequirePackage[english,korean,provide*=*]{babel}

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

% Hyperref 및 링크 색상
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

% 패키지
\RequirePackage{booktabs}
\RequirePackage{multirow}
\RequirePackage{tabularx}
\RequirePackage{enumitem}
\RequirePackage{caption}
\RequirePackage{subcaption}
\RequirePackage{etoolbox}
\RequirePackage[absolute,overlay]{textpos}
\RequirePackage{luacode}
\RequirePackage{tikz}

\newcommand{\seal}{%
  \raisebox{-0.7ex}{%
    \begin{tikzpicture}[scale=0.5]
      \draw[line width=1pt] (0,0) circle (0.55cm);
      \node at (-0.05,0) {\fontsize{10pt}{10pt}\selectfont 인};
    \end{tikzpicture}%
  }%
}

% textpos 설정
\setlength{\TPHorizModule}{1pt}
\setlength{\TPVertModule}{1pt}
\textblockorigin{0pt}{0pt}

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

% 미리계산
\edef\pageWidthPT{\directlua{tex.sprint(tex.dimen.paperwidth / 65536)}} % 전체 너비
\edef\pageHeightPT{\directlua{tex.sprint(tex.dimen.paperheight / 65536)}} % 전체 높이
\edef\centerWidthPT{\directlua{tex.sprint(tex.dimen.paperwidth / 65536 / 2)}} % 가로 중앙

% mm -> pt 변환 및 하단 기준 위치 계산
\newcommand{\toPt}[1]{\directlua{tex.sprint(toPt("#1"))}}
\newcommand{\ptFromPageBottom}[1]{\directlua{tex.sprint(ptFromPageBottom("#1"))}}
\newcommand{\ptMinusFromWidth}[1]{\directlua{tex.sprint(ptMinusFromWidth("#1"))}}


% 초기화
\newcommand{\sgcommittees}{}% 심사위원 목록

\def\sg@degreeopt{}
\def\sg@languageopt{}

\DeclareKeys{
  degree   .store = \sg@degreeopt,
  doclang .store = \sg@languageopt,
}

% 옵션 처리
\ProcessKeyOptions

% degree 처리 (기본값 master)
\def\sg@degree{master}
\ifdefempty{\sg@degreeopt}{
  % 기본값
}{
  \edef\sg@degree{\sg@degreeopt}
}

% language 처리 (기본값 korean)
\def\sg@doclang{korean}
\ifdefempty{\sg@languageopt}{
  % 기본값
}{
  \edef\sg@doclang{\sg@languageopt}
}
\typeout{DEBUG: doclang \sg@doclang}
\selectlanguage{\sg@doclang} % doclang 옵션에 따라 언어 설정


% 논문 정보
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
\def\sg@acknowledgments{}

% degree 확인
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


% 글씨 크기
% 큰제목 16pt (chatper), 작은제목 13pt (section, subsection, subsubsection)
\RequirePackage{titlesec}
\AtBeginDocument{%
    \selectlanguage{\sg@doclang} % 한번더 doclang 반영. 안하면 잘 안되서 함.
    
    % 각주 9pt
    \makeatletter
    \renewcommand{\footnotesize}{\fontsize{9pt}{11pt}\selectfont}
    \makeatother
    
    % chapter 제목: 16pt, 진하게
    \titleformat{\chapter}[display]
      {\bfseries\fontsize{16pt}{20pt}\selectfont}{\chaptername~\thechapter}{20pt}{}
    
    % section 제목: 13pt, 진하게
    \titleformat{\section}
      {\bfseries\fontsize{13pt}{15.6pt}\selectfont}{\thesection}{1em}{}
    
    % subsection 제목: 13pt, 진하게
    \titleformat{\subsection}
      {\bfseries\fontsize{13pt}{15.6pt}\selectfont}{\thesubsection}{1em}{}
    
    % subsubsection 제목: 13pt, 진하게
    \titleformat{\subsubsection}
      {\bfseries\fontsize{13pt}{15.6pt}\selectfont}{\thesubsubsection}{1em}{}
}




% 논문 정보 셋팅용 명령어 정의
\newcommand{\Title}[1]{\def\sg@title{#1}}
\newcommand{\Subtitle}[1]{\def\sg@subtitle{#1}}
\newcommand{\Author}[1]{\def\sg@author{#1}}
\newcommand{\Supervisor}[1]{\def\sg@supervisor{#1}}
\newcommand{\Department}[1]{\def\sg@department{#1}}
\newcommand{\Major}[1]{\def\sg@major{#1}}
\newcommand{\DegreeDate}[3]{\def\sg@degreeyear{#1}\def\sg@degreemonth{#2}\def\sg@degreeday{#3}}
\newcommand{\ApprovalDate}[3]{\def\sg@approvalyear{#1}\def\sg@approvalmonth{#2}\def\sg@approvalday{#3}}
% Abstract 및 Keywords
\newcommand{\KAbstract}[1]{\def\sg@kabstract{#1}}
\newcommand{\KKeywords}[1]{\def\sg@kkeywords{#1}}
\newcommand{\EAbstract}[1]{\def\sg@eabstract{#1}}
\newcommand{\EKeywords}[1]{\def\sg@ekeywords{#1}}
% Acknowledgments
\newcommand{\Acknowledgments}[1]{\def\sg@acknowledgments{#1}}


% 심사위원 쌓기
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



% 심사위원 출력
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


% 특별히 용지상 위치 있는거에 여백 방해되서 만듬.
\newenvironment{specialpage}{
  \newgeometry{left=0mm, right=0mm, top=0mm, bottom=0mm, nohead, nofoot}
  \thispagestyle{empty}
}{
  \clearpage
  \aftergroup\restoregeometry
}


% 그냥 확인
\typeout{DEBUG: \pageWidthPT}
\typeout{DEBUG: \pageHeightPT}
\typeout{DEBUG: \centerWidthPT}
\typeout{DEBUG: toPt: \toPt{20mm}}
\typeout{DEBUG: ptFromPageBottom: \ptFromPageBottom{40mm}}
\typeout{DEBUG: ptMinusFromWidth: \ptMinusFromWidth{90mm}}


% 겉표지
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
      % "논문 제목이 두줄에 걸칠 때는 사이 간격을 2cm로 함" 이라고 하네요??
      % 부제목
      \vspace{2cm}
      \fontsize{18pt}{18pt}\selectfont \sg@subtitle
    \end{textblock}

    % 부제목 (제목 두줄 안되면 이게 정위치)
    % \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{80mm})
    %   \centering
    %   \noindent
    %   {\setstretch{1.3}\fontsize{18pt}{18pt}\selectfont \sg@subtitle}
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


% 표제면
\newcommand{\MakeTitlePage}{%
  \begin{specialpage}
    % 제목
    %% 좌우 4.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{60mm})
      \centering
      \noindent
      \fontsize{26pt}{26pt}\selectfont \sg@title \\
      %% 표제면은 "논문 제목이 두줄에 걸칠 때는 사이 간격을 2cm로 함"라고 안햇는데 그냥 함.
      % 부제목
      \vspace{2cm}
      \fontsize{18pt}{18pt}\selectfont \sg@subtitle
    \end{textblock}
    
    % 부제목 (이게 정위치)
    %% 좌우 4.5cm 여백
    % \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{80mm})
    %   \centering
    %   \noindent
    %   {\setstretch{1.3}\fontsize{18pt}{18pt}\selectfont \sg@subtitle}
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


% 제출서
\newcommand{\MakeSubmissionSheet}{%
  \begin{specialpage}
    % 제목
    %% 좌우 4.5cm 여백
    \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{50mm})
      \centering
      \noindent
      {\setstretch{1.3}\fontsize{26pt}{26pt}\selectfont \sg@title} \\
      %% 겉표지 따라하기. 자리 모자름.
      % 부제목
      \vspace{2cm}
      {\setstretch{1.3}\fontsize{18pt}{18pt}\selectfont \sg@subtitle}
    \end{textblock}
    
    % 부제목 (이게 정위치)
    % %% 좌우 4.5cm 여백
    % \begin{textblock}{\ptMinusFromWidth{90mm}}[0.5,0](\centerWidthPT,\toPt{70mm})
    %   \centering
    %   \noindent
    %   {\setstretch{1.3}\fontsize{18pt}{18pt}\selectfont \sg@subtitle}
    % \end{textblock}
    
    % 지도교수
    %% 좌우 6.5cm 여백
    % 제목 두줄되면 자리 모자름. 내려야됨.
    % \begin{textblock}{\ptMinusFromWidth{130mm}}[0.5,0](\centerWidthPT,\toPt{100mm})
    \begin{textblock}{\ptMinusFromWidth{130mm}}[0.5,0](\centerWidthPT,\toPt{150mm})
      \centering
      \noindent
      \fontsize{18pt}{18pt}\selectfont 지도교수 \sg@supervisor
    \end{textblock}
    
    % 제출 문구
    %% 좌우 5cm 여백
    % 그냥 모자름. 옆으로 늘림.
    % \begin{textblock}{\ptMinusFromWidth{100mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{100mm})
    \begin{textblock}{\ptMinusFromWidth{80mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{100mm})
      \centering
      \noindent
      \fontsize{16pt}{16pt}\selectfont 이 논문을 \sg@department\ \ifsg@phd 박사 \else 석사 \fi 학위논문으로 제출함
    \end{textblock}

    % 제출일
    %% 좌우 7cm 여백
    \begin{textblock}{\ptMinusFromWidth{140mm}}[0.5,0](\centerWidthPT,\ptFromPageBottom{80mm})
      \centering
      \noindent
      % \fontsize{16pt}{16pt}\selectfont \sg@degreeyear 년 \sg@degreemonth 월 \sg@degreeday 일
      %% 월까지만 나와도 된다고 함.
      \fontsize{16pt}{16pt}\selectfont \sg@degreeyear 년 \sg@degreemonth 월
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

% 인준서
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
      \fontsize{18pt}{18pt}\selectfont
      \setcounter{commcount}{0}%
      \edef\expandedSGCommittees{\noexpand\forcsvlist{\noexpand\printcommittee}{\sgcommittees}}
      \expandedSGCommittees
      
    \end{textblock}
    ~
  \end{specialpage}
}


% 감사의 글
\newcommand{\MakeAcknowledgement}{%
  \ifdefstring{\sg@doclang}{korean}{
    \begin{center}
      \textbf{\Large 감사의글}
    \end{center}
  }{
    \begin{center}
      \textbf{\Large Acknowledgments}
    \end{center}
  }

  \sg@acknowledgments

  ~
  \clearpage
}

% 국문 초록
% \sg@kabstract, \sg@kkeywords
\newcommand{\MakeKoreanAbstract}{%
  \ifdefstring{\sg@doclang}{korean}{
    \section*{국문초록(요약) 및 \underline{주제어(키워드)}}
    \phantomsection
    \addcontentsline{toc}{chapter}{국문초록 및 주제어}
  }{
    \section*{Korean Abstract and \underline{Keywords}}
    \phantomsection
    \addcontentsline{toc}{chapter}{Korean Abstract and Keywords}
  }
  
  \begin{center}
    \textbf{\fontsize{13pt}{15pt}\selectfont \sg@title}
  \end{center}
  
  \sg@kabstract
  \vfill
  
  \noindent\textbf{주제어(키워드, 색인어)}\\
  \noindent\sg@kkeywords\\
  \hrule
  ~
  \clearpage
}

% 영문 초록
% \sg@eabstract, \sg@ekeywords
\newcommand{\MakeEnglishAbstract}{%
  \ifdefstring{\sg@doclang}{korean}{
    \section*{Abstract}
    \phantomsection
    \addcontentsline{toc}{chapter}{영문초록 및 주제어}
  }{
    \section*{Abstract}
    \phantomsection
    \addcontentsline{toc}{chapter}{English Abstract and Keywords}
  }
  
  \begin{center}
    \textbf{\fontsize{13pt}{15pt}\selectfont \sg@title}
  \end{center}
  
  \sg@eabstract
  \vfill
  
  \noindent Key words~:~\sg@ekeywords\\
  \hrule
  ~
  \clearpage
}


% TOC에 추가로 넣을 것들
\apptocmd{\tableofcontents}{\cleardoublepage}{}{}

\pretocmd{\listoffigures}{\phantomsection}{}{}
\patchcmd{\listoffigures}{\chapter*{\listfigurename}}{\chapter*{\listfigurename}\addcontentsline{toc}{chapter}{\protect\textbf{\listfigurename}}}{}{}
\apptocmd{\listoffigures}{\cleardoublepage}{}{}

\pretocmd{\listoftables}{\phantomsection}{}{}
\patchcmd{\listoftables}{\chapter*{\listtablename}}{\chapter*{\listtablename}\addcontentsline{toc}{chapter}{\protect\textbf{\listtablename}}}{}{}
\apptocmd{\listoftables}{\cleardoublepage}{}{}

\newcommand{\ShowBibliographyHeading}{%
  \ifdefstring{\sg@doclang}{korean}{
    \chapter*{참고 문헌}
    \addcontentsline{toc}{chapter}{참고 문헌}
  }{
    \chapter*{References}
    \addcontentsline{toc}{chapter}{References}
  }
}


% Make front matter
\newcommand{\makefrontmatter}{%
    %% Online 제출은 겉표지가 필요없다.
    % \MakeCover   % 겉표지
    % \thispagestyle{empty}
    % \cleardoublepage

    \MakeTitlePage  % 표제면
    \cleardoublepage

    \MakeSubmissionSheet % 제출서
    \cleardoublepage

    \MakeApprovalSheet % 인준서
    \cleardoublepage

    \MakeAcknowledgement % 감사의 글
    \cleardoublepage
}

\endinput
