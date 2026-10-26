/*
MissingSyllable ("Syllabe manquante") — a picture and its word with one syllable blanked
(che · __ · ); the child taps the missing syllable. Animated by Hero (cs.hero).

Store the instance in Form.game.

(4D evaluates left-to-right with NO operator precedence, so arithmetic inside a comparison
or an index is parenthesised.)
*/

property transition : cs.hero.ElementTransition
property palette : Collection:=[0x00E8B84B; 0x005B9BD5; 0x006FB98F; 0x00E0736A; 0x009B8BC4]
property colorIdx : Integer:=0

property words : Collection:=[\
{emoji: "🏍️"; word: "moto"; syls: ["mo"; "to"]}; \
{emoji: "🐴"; word: "cheval"; syls: ["che"; "val"]}; \
{emoji: "🐰"; word: "lapin"; syls: ["la"; "pin"]}; \
{emoji: "🐢"; word: "tortue"; syls: ["tor"; "tue"]}; \
{emoji: "🦁"; word: "lion"; syls: ["li"; "on"]}; \
{emoji: "🏠"; word: "maison"; syls: ["mai"; "son"]}; \
{emoji: "🌞"; word: "soleil"; syls: ["so"; "leil"]}; \
{emoji: "🐷"; word: "cochon"; syls: ["co"; "chon"]}; \
{emoji: "🐮"; word: "vache"; syls: ["va"; "che"]}; \
{emoji: "🦆"; word: "canard"; syls: ["ca"; "nard"]}; \
{emoji: "🍎"; word: "pomme"; syls: ["pom"; "me"]}; \
{emoji: "🦋"; word: "papillon"; syls: ["pa"; "pi"; "llon"]}; \
{emoji: "🍫"; word: "chocolat"; syls: ["cho"; "co"; "lat"]}; \
{emoji: "🍌"; word: "banane"; syls: ["ba"; "na"; "ne"]}; \
{emoji: "🚗"; word: "voiture"; syls: ["voi"; "tu"; "re"]}; \
{emoji: "🦒"; word: "girafe"; syls: ["gi"; "ra"; "fe"]}; \
{emoji: "🍅"; word: "tomate"; syls: ["to"; "ma"; "te"]}; \
{emoji: "🐌"; word: "escargot"; syls: ["es"; "car"; "got"]}]

property slotsMax : Integer:=4
property answer : Text                      // the missing syllable
property choices : Collection
property score : Integer:=0
property busy : Boolean:=False
property sound : Boolean:=True

Class constructor($transition : cs.hero.ElementTransition)

	This.transition:=$transition
	OBJECT SET VISIBLE(*; "glyph"; False)
	OBJECT SET VISIBLE(*; "truth"; False)
	This.newQuestion()

	// === === === === === === === === === === === === === === === === === === === ===
Function toggleSound()

	This.sound:=Not(This.sound)
	If (This.sound)
		OBJECT SET TITLE(*; "speaker"; "🔊")
	Else
		OBJECT SET TITLE(*; "speaker"; "🔇")
	End if

	// === === === === === === === === === === === === === === === === === === === ===
Function newQuestion()

	var $w : Object:=This.words[(Random % This.words.length)]
	var $n : Integer:=$w.syls.length
	var $blank : Integer:=(Random % $n)
	This.answer:=$w.syls[$blank]

	// choices: the answer plus two distractor syllables from other words
	var $opts : Collection:=[This.answer]
	var $guard : Integer:=0
	While (($opts.length<3) & ($guard<200))
		$guard:=$guard+1
		var $ow : Object:=This.words[(Random % This.words.length)]
		var $s : Text:=$ow.syls[(Random % $ow.syls.length)]
		If (($opts.indexOf($s)=-1) & ($w.syls.indexOf($s)=-1))
			$opts.push($s)
		End if
	End while
	This.choices:=This._shuffle($opts)

	OBJECT SET TITLE(*; "emoji"; $w.emoji)
	This._renderSlots($w.syls; $blank)
	This._renderChoices()

	OBJECT SET TITLE(*; "score"; String(This.score))
	OBJECT SET VISIBLE(*; "glyph"; False)
	OBJECT SET VISIBLE(*; "truth"; False)

	This.colorIdx:=((This.colorIdx+1) % This.palette.length)
	This.transition.animate("card").to({backgroundColor: This.palette[This.colorIdx]}).duration(300).easing("easeInOutQuad").start()
	This._popIn("emoji")

	This.busy:=False

	// === === === === === === === === === === === === === === === === === === === ===
Function choose($i : Integer)

	If (This.busy)
		return
	End if
	This.busy:=True

	var $pick : Text:=This.choices[($i-1)]
	var $right : Boolean:=($pick=This.answer)

	OBJECT SET TITLE(*; "truth"; "→ "+This.answer)
	OBJECT SET VISIBLE(*; "truth"; True)

	if ($right)
		This.score:=This.score+1
		OBJECT SET TITLE(*; "score"; String(This.score))
		This._bumpScore()
		This._showGlyph("✓")
	else
		This._showGlyph("✗")
		This._shakeCard()
		If (This.sound)
			BEEP
		End if
	end if

	This.transition.animate("tick").to({left: 1}).delay(1300).then(Formula(Form.game._advance())).start()

Function _advance()

	OBJECT SET COORDINATES(*; "tick"; 0; -10; 1; -9)
	This.newQuestion()

	// === === === === === === === === === === === === === === === === === === === ===
	// the word's syllables in a row; the blank slot shows "?" and is tinted
Function _renderSlots($syls : Collection; $blank : Integer)

	var $n : Integer:=$syls.length
	var $cw : Integer:=60
	var $gap : Integer:=8
	var $total : Integer:=($n*$cw)+(($n-1)*$gap)
	var $startx : Integer:=190-($total\2)
	var $y : Integer:=(64+232)

	var $k : Integer
	For ($k; 1; This.slotsMax)
		var $pad : Text:="slot_"+String($k)
		var $lbl : Text:="slotLbl_"+String($k)
		If ($k<=$n)
			var $x : Integer:=$startx+(($k-1)*($cw+$gap))
			OBJECT SET COORDINATES(*; $pad; $x; $y; $x+$cw; $y+48)
			OBJECT SET COORDINATES(*; $lbl; $x; $y; $x+$cw; $y+48)
			If (($k-1)=$blank)
				OBJECT SET TITLE(*; $lbl; "?")
				OBJECT SET RGB COLORS(*; $pad; 0x00FFE08A; 0x00FFE08A)
			Else
				OBJECT SET TITLE(*; $lbl; $syls[($k-1)])
				OBJECT SET RGB COLORS(*; $pad; 0x00FFFFFF; 0x00FFFFFF)
			End if
			OBJECT SET VISIBLE(*; $pad; True)
			OBJECT SET VISIBLE(*; $lbl; True)
		Else
			OBJECT SET VISIBLE(*; $pad; False)
			OBJECT SET VISIBLE(*; $lbl; False)
		End if
	End for

	// three syllable choices in a row
Function _renderChoices()

	var $pad : Integer:=86
	var $gap : Integer:=12
	var $total : Integer:=(3*$pad)+(2*$gap)
	var $startx : Integer:=190-($total\2)
	var $y : Integer:=(64+330)
	var $i : Integer
	For ($i; 1; 3)
		var $s : Text:=String($i)
		var $x : Integer:=$startx+(($i-1)*($pad+$gap))
		OBJECT SET COORDINATES(*; "chPad_"+$s; $x; $y; $x+$pad; $y+56)
		OBJECT SET COORDINATES(*; "chLbl_"+$s; $x; $y; $x+$pad; $y+56)
		OBJECT SET COORDINATES(*; "chBtn_"+$s; $x; $y; $x+$pad; $y+56)
		OBJECT SET TITLE(*; "chLbl_"+$s; This.choices[($i-1)])
	End for

	// === === === === === === === === === === === === === === === === === === === ===
Function _shuffle($c : Collection) : Collection

	var $src : Collection:=$c.copy()
	var $out : Collection:=[]
	While ($src.length>0)
		var $k : Integer:=(Random % $src.length)
		$out.push($src[$k])
		$src.remove($k)
	End while
	return $out

Function _popIn($name : Text)

	var $s:=cs.hero.ElementState.new($name)
	var $cx : Integer:=$s.left+($s.width\2)
	var $cy : Integer:=$s.top+($s.height\2)
	OBJECT SET COORDINATES(*; $name; $cx; $cy; $cx; $cy)
	This.transition.animate($name).to({left: $s.left; top: $s.top; width: $s.width; height: $s.height}).duration(280).easing("easeOutBack").start()

Function _showGlyph($char : Text)

	OBJECT SET TITLE(*; "glyph"; $char)
	var $g:=cs.hero.ElementState.new("glyph")
	var $cx : Integer:=$g.left+($g.width\2)
	var $cy : Integer:=$g.top+($g.height\2)
	OBJECT SET COORDINATES(*; "glyph"; $cx; $cy; $cx; $cy)
	OBJECT SET VISIBLE(*; "glyph"; True)
	This.transition.animate("glyph").to({left: $g.left; top: $g.top; width: $g.width; height: $g.height}).duration(240).easing("easeOutBack").start()

Function _bumpScore()

	This.transition.animate("score").to({fontSize: 40}).duration(130).easing("easeOutQuad").then(Formula(Form.game._scoreBack())).start()

Function _scoreBack()

	This.transition.animate("score").to({fontSize: 28}).duration(180).easing("easeInOutCubic").start()

Function _shakeCard()

	var $c:=cs.hero.ElementState.new("card")
	This.transition.animate("card").from({left: $c.left-16}).to({left: $c.left}).duration(600).easing("easeOutElastic").start()
