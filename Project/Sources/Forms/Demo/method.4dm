// Syllabe manquante — driven by cs.hero.

Case of

		//______________________________________________________
	: (Form event code=On Load)

		Form.transition:=cs.hero.ElementTransition.new()
		Form.game:=cs.MissingSyllable.new(Form.transition)

		//______________________________________________________
	: (Form event code=On Timer)

		Form.transition.onTimer()

		//______________________________________________________
	: (Form event code=On Clicked)

		var $name : Text:=FORM Event.objectName

		Case of
			: (Position("chBtn_"; $name)=1)
				Form.game.choose(Num(Substring($name; 7)))
			: ($name="btnSpeaker")
				Form.game.toggleSound()
		End case

		//______________________________________________________
	: (Form event code=On Unload)

		SET TIMER(0)

		//______________________________________________________
End case
