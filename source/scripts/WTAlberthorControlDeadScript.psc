scriptName WTAlberthorControlDeadScript extends ActiveMagicEffect

quest property QuestREF auto

auto state waiting
function OnEffectStart(Actor AkTarget, Actor akCaster)
	TrueDirectionalMovement.SetFreeCamera(false)
	QuestREF.setstage(150)
	gotostate("done")
endFunction
endstate

state done
;do nothing
endstate