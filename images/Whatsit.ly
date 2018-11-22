\version "2.18.2"
melody = \relative c' {
  \clef treble
  \key f \major
  \time 4/4
  \numericTimeSignature
  \tempo 4=114

  r2 r4 
  c16 d f d <d f a>8._. <d~ f~ a~>16_. <d f a>8 <c~ e~ g~> <c e g>4
  c16 d f d <c e g>8._. <c~ e~ g~>16_. <c e g>8 <a~ f'~ d> <a f' d>16 e' d8
  c16 d f d <bes d f>4 g'8 <c,~ e~> <c e>16 d c4 c8 <a c g'>4_. <a d f>2 r4
}

\score {
  \new Staff \melody
  \layout { }
  \midi { }
}
