\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{leafcv}[2020/01/13 Example LaTeX LeafCV]

\def\LeafCV@langLong{UKenglish}
\def\LeafCV@lang{en}
\def\LeafCV@selectlanguage\selectlanguage{UKenglish}

\DeclareOption{en}{\def\LeafCV@lang{en} \def\LeafCV@langLong{UKenglish}
  \def\LeafCV@selectlanguage{\selectlanguage{UKenglish}}}

\DeclareOption{fr}{\def\LeafCV@lang{fr}\def\LeafCV@langLong{french}
  \def\LeafCV@selectlanguage{\selectlanguage{french}}}

\def\LeafCV@langCase{%
  \ifnum\pdf@strcmp{\LeafCV@lang}{fr}=0 %
     \expandafter\@firstoftwo
  \else
    \expandafter\@secondoftwo
  \fi}
\ProcessOptions\relax

\RequirePackage{etoolbox}

\AtEndPreamble{
\RequirePackage[french, UKenglish]{babel}
\RequirePackage{xcolor}
\definecolor{LeafCVGreen}{HTML}{017100}
\definecolor{LeafCVRed}{HTML}{800000}
\definecolor{LeafCVGrey}{HTML}{808080}
\RequirePackage[hidelinks]{hyperref}
\renewcommand\UrlFont{\color{LeafCVGrey}\fontseries{l}\selectfont}
\RequirePackage{tikz}
\RequirePackage{tabto}
\RequirePackage{calc}

\hypersetup{pdfinfo={
Title={\@author{} -- CV},
Author={\@author}}}
}

\AtBeginDocument{
\LeafCV@selectlanguage
}

\def\@totpages{??}
\AtEndDocument{\clearpage{\addtocounter{page}{-1}\immediate\write\@auxout{\string\gdef\string\@totpages{\the\c@page}}}\addtocounter{page}{+1}}

\def\thepage{\the\c@page}

\RequirePackage[a4paper, top=2cm, bottom=2cm, left=2cm, right=2cm,footskip=0.85cm]{geometry}
\RequirePackage[light,math]{kurier}
\RequirePackage[sfdefault,thin]{roboto}

\renewcommand{\normalsize}{\fontsize{12}{15}\fontseries{t}\selectfont}
\DeclareTextFontCommand{\textbf}{\fontseries{l}\selectfont}
\DeclareTextFontCommand{\linkstyle}{\color{LeafCVGrey}\fontseries{l}\selectfont}

\setlength{\parindent}{0em}
\setlength{\parskip}{0.5em}

\newcommand{\jobtitle}[1]{\def\@jobtitle{#1}}
\newcommand{\address}[1]{\def\@address{#1}}
\newcommand{\email}[1]{\def\@email{#1}}
\newcommand{\website}[1]{\def\@website{#1}}

\def\@oddfoot{\normalfont\color{LeafCVGrey}\setlength{\dimen0}{17.9cm-\widthof{Page~ \thepage{}~ \LeafCV@langCase{sur}{of}~ \@totpages}}\hspace{\dimen0}Page~ \thepage{}~ \LeafCV@langCase{sur}{of}~ \@totpages}
\let\@evenfoot\@oddfoot

\def\maketitle{
\begin{minipage}[t]{.65\textwidth}\vspace{-0.3cm}
\fontsize{24}{29}\fontseries{t}\selectfont\normalfont\color{LeafCVGreen}\@author\\[4pt]
\ifdefined\@jobtitle\fontsize{18}{22}\fontseries{t}\selectfont\normalfont\color{LeafCVRed}\@jobtitle\\[6pt]\fi
\ifdefined\@date\normalsize\normalfont\color{LeafCVGrey} \LeafCV@langCase{Mise à jour :}{Last updated:} \LeafCV@selectlanguage\@date\\\fi
\end{minipage}%
\begin{minipage}[t]{.35\textwidth}\vspace{-0.3cm}
\begin{flushright}
\color{LeafCVGrey}
\ifdefined\@address\@address\\\fi
\ifdefined\@email\href{mailto:\@email}{\@email}\\\fi
\ifdefined\@website\href{\@website}{\@website}\\\fi
\end{flushright} 
\end{minipage}
}

\def\section{%
    \@startsection
    {section}{1}{0pt}{-18pt}%
    {3pt}{\tabto*{-6mm}\begin{tikzpicture}\fill[color=white,opacity=0] (0,0.0) rectangle (3.6,0.22); \fill[color=LeafCVRed] (0,0.05) rectangle (3.6,0.22); \end{tikzpicture}\tabto{33mm}\normalfont\textcolor{LeafCVGreen}}%
}

\def\subsection{%
    \@startsection
    {section}{2}{0pt}{-12pt}%
    {3pt}{\fontsize{15}{18}\fontseries{t}\selectfont\normalfont\textcolor{LeafCVGrey}}%
}

\newcommand{\cvline}[2]{\par{\setlength{\tabcolsep}{0cm}
\begin{tabular}{p{3.3cm}p{13.7cm}}
\raggedleft #1\kern0.29cm& \raggedright #2
\end{tabular}}}
