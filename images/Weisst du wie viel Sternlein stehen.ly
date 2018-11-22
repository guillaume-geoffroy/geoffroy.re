#(define (tie::tab-clear-tied-fret-numbers grob)
   (let* ((tied-fret-nr (ly:spanner-bound grob RIGHT)))
      (ly:grob-set-property! tied-fret-nr 'transparent #t)))

\version "2.14.0"
\paper {
   indent = #0
   print-all-headers = ##t
   ragged-right = ##f
   ragged-bottom = ##t
}
\layout {
   \context { \Score
      \override MetronomeMark #'padding = #'5
   }
   \context { \Staff
      \override TimeSignature #'style = #'numbered
      \override StringNumber #'transparent = ##t
   }
   \context { \TabStaff
      \override TimeSignature #'style = #'numbered
      \override Stem #'transparent = ##t
      \override Beam #'transparent = ##t
      \override Tie  #'after-line-breaking = #tie::tab-clear-tied-fret-numbers
   }
   \context { \TabVoice
      \override Tie #'stencil = ##f
   }
   \context { \StaffGroup
      \consists "Instrument_name_engraver"
   }
}
TrackAVoiceAMusic = #(define-music-function (parser location inTab) (boolean?)
#{
   \clef treble
   \key f \major
   \time 3/4
   \oneVoice
   r2 f'8 g'8 
   a'4 a'4 bes'8 g'8 
   d''4 c''4 a'8 c''8 
   c''4 bes'4 c''8 bes'8 
   a'2 f'8 g'8 
   a'4 a'4 bes'8 g'8 
   d''4 c''4 a'8 c''8 
   c''4 bes'4 c''8 bes'8 
   a'2 c''8 a'8 
   a'4 g'4 d''8 bes'8 
   bes'4 a'4 c''8 a'8 
   a'4 g'4 d''8 bes'8 
   bes'4 a'4 f'8 g'8 
   a'4 a'4 bes'8 g'8 
   d''4 c''4 a'8 c''8 
   c''4 bes'4 c''8 g'8 
   f'2 r4 
   \bar "|."
   \pageBreak
#})
TrackAVoiceBMusic = #(define-music-function (parser location inTab) (boolean?)
#{
#})
TrackALyrics = \lyricmode {
   \set ignoreMelismata = ##t
   Weißt du,  wie viel Stern- lein  steh- en
an dem blau- en Him- mels- zelt?
Weißt du, wie viel Wol- ken geh- en
weit- hin ü- ber al- le Welt?
Gott der  Herr hat sie ge- zäh- let,
dass ihm auch nicht ein- es feh- let
an der gan- zen gro- ßen Zahl,  
an der gan- zen gro- ßen Zahl.
   \unset ignoreMelismata
}
TrackAStaff = \new Staff <<
   \context Voice = "TrackAVoiceAMusic" {
      \removeWithTag #'chords
      \removeWithTag #'texts
      \TrackAVoiceAMusic ##f
   }
   \context Voice = "TrackAVoiceBMusic" {
      \removeWithTag #'chords
      \removeWithTag #'texts
      \TrackAVoiceBMusic ##f
   }
   \new Lyrics \lyricsto "TrackAVoiceAMusic" \TrackALyrics
>>
TrackATabStaff = \new TabStaff \with { stringTunings = #`( ,(ly:make-pitch 0 2 NATURAL) ,(ly:make-pitch -1 6 NATURAL) ,(ly:make-pitch -1 4 NATURAL) ,(ly:make-pitch -1 1 NATURAL) ,(ly:make-pitch -2 5 NATURAL) ,(ly:make-pitch -2 2 NATURAL) ) } <<
   \context TabVoice = "TrackAVoiceAMusic" {
      \removeWithTag #'chords
      \removeWithTag #'texts
      \TrackAVoiceAMusic ##t
   }
   \context TabVoice = "TrackAVoiceBMusic" {
      \removeWithTag #'chords
      \removeWithTag #'texts
      \TrackAVoiceBMusic ##t
   }
   \new Lyrics \lyricsto "TrackAVoiceAMusic" \TrackALyrics
>>
TrackAStaffGroup = \new StaffGroup <<
   \TrackAStaff
>>
\score {
   \TrackAStaffGroup
   \header {
      title = "" 
      composer = "" 
   }
}
