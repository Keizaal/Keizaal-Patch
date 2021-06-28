;/ Decompiled by Champollion V1.0.1
Source   : iHUDControlScript.psc
Modified : 2015-02-15 18:17:40
Compiled : 2015-02-15 18:17:42
User     : Gopher
Computer : GOPHERSGAMING-P
/;
scriptName iHUDControlScript extends Quest

;-- Properties --------------------------------------
globalvariable property iHUDEnabled auto
globalvariable property iHUDHealthFastFade auto
globalvariable property iHUDStaminaFastFade auto
globalvariable property iHUDMagickaFastFade auto
ihudenemyhealthscript property iHUDEnemyHealth auto
ihudstaminabarscript property iHUDStaminaBar auto
ihudhealthbarscript property iHUDHealthBar auto
ihudmagickabarscript property iHUDMagickaBar auto
globalvariable property iHUDUpdateDelay auto
globalvariable property iHUDKeyActionToggle auto
ihudcrosshairscript property iHUDCrosshair auto
globalvariable property iHUDCrosshairOnActivate auto
globalvariable property iHUDCrosshairOnMelee auto
globalvariable property iHUDCrosshairOnRanged auto
ihudcompassscript property iHUDCompass auto
ihudwidgetscript property iHUDWidget auto
globalvariable property iHUDCrosshairAlwaysVisible auto
globalvariable property iHUDCrosshairOnSpell auto

;-- Variables ---------------------------------------
Actor player
Bool openSettings
Bool compassOn
Bool keyHeld
Float verticalOffset = 5000.00
Bool toggleOn = true ; true = initial UI state is SHOW UI | false = initial UI state HIDE UI (On new game)
Bool meleeEquipped
Bool bowEquipped
Bool targetSpellEquipped
Bool isFirstPerson = true ; required variable for my custom tweak - Luca|EzioTheDeadPoet

;-- Functions ---------------------------------------

Bool function actorValueIsLessThanPercent(String actorValue, Float percent)

	return player.GetActorValuePercentage(actorValue) < percent / 100 as Float
endFunction

Bool function isKeyActivated()

	return toggleOn as Bool || keyHeld as Bool
endFunction

function iHUDKeyPressed()

	if iHUDKeyActionToggle.GetValueInt()
		toggleOn = !toggleOn
		keyHeld = false
	else
		toggleOn = false
		keyHeld = true
	endIf
	self.processHUD()
endFunction

Bool function isRangedActivatingCrosshair()

	return bowEquipped as Bool && iHUDCrosshairOnRanged.GetValueInt() == 1
endFunction

function OnUpdate()

	; Empty function
endFunction

Bool function isMeleeActivatingCrosshair()

	return !bowEquipped && iHUDCrosshairOnMelee.GetValueInt() == 1
endFunction

Bool function isActive()

	return iHUDEnabled != none && iHUDEnabled.GetValueInt() == 1
endFunction

Bool function shouldShowActivateCrosshair()

	return iHUDCrosshairOnActivate.GetValueInt() == 1 && ihudutilityscript.hasActivateOption()
endFunction

; Skipped compiler generated GetState

Bool function isSpellActivatingCrosshair()

	return targetSpellEquipped as Bool && iHUDCrosshairOnSpell.GetValueInt() == 1
endFunction

function iHUDKeyReleased(Float holdTime)

	keyHeld = false
	self.processHUD()
endFunction

function deactivate()

	self.UnRegisterForCameraState()
	self.UnRegisterForUpdate()
	self.GotoState("Inactive")
	iHUDCompass.show(true)
	iHUDCrosshair.show(true)
	iHUDCrosshair.showSneakMeter()
	iHUDStaminaBar.show(true)
	iHUDHealthBar.show(true)
	iHUDMagickaBar.show(true)
	iHUDEnemyHealth.reset()
endFunction

function startUp()

	self.UnRegisterForUpdate()
	player = game.GetPlayer()
	iHUDEnemyHealth.calibrate()
	if !self.isActive()
		self.deactivate()
	endIf
	if iHUDMagickaFastFade.GetValueInt() > 1 || iHUDMagickaFastFade.GetValueInt() < 0
		iHUDMagickaFastFade.SetValueInt(0)
	endIf
	if iHUDHealthFastFade.GetValueInt() > 1 || iHUDHealthFastFade.GetValueInt() < 0
		iHUDHealthFastFade.SetValueInt(0)
	endIf
	if iHUDStaminaFastFade.GetValueInt() > 1 || iHUDStaminaFastFade.GetValueInt() < 0
		iHUDStaminaFastFade.SetValueInt(0)
	endIf
	iHUDEnemyHealth.processEnemyHealth()
	iHUDMagickaBar.processMagickaBar()
	iHUDHealthBar.processHealthBar()
	iHUDStaminaBar.processStaminaBar()
	self.processEquipment()
	iHUDWidget.initialize()
	self.GotoState("Polling")
	self.RegisterForSingleUpdate(0.100000)
	self.RegisterForCameraState() ; requirement for my custom tweak - Luca|EzioTheDeadPoet
endFunction

; Skipped compiler generated GotoState

Bool function isCrosshairVisible()

	return !ui.IsMenuOpen("Dialogue Menu") && !ui.IsMenuOpen("Book Menu") && !ui.IsMenuOpen("MapMenu") && !player.IsInKillMove() && ((iHUDCrosshairAlwaysVisible.GetValueInt() as Bool || player.isWeaponDrawn() && (self.isSpellActivatingCrosshair() || self.isRangedActivatingCrosshair() || self.isMeleeActivatingCrosshair()) || self.shouldShowActivateCrosshair()) && (isFirstPerson || !Game.IsPluginInstalled( "SmoothCam.esp" ))) ; the `&& (isFirstPerson || !Game.IsPluginInstalled( "SmoothCam.esp" )` is important for the compatibility tweak
endFunction

function processEquipment()

	if player == none
		player = game.GetPlayer()
		return 
	endIf
	bowEquipped = ihudutilityscript.isRangedWeapon(player.GetEquippedWeapon(true)) || ihudutilityscript.isRangedWeapon(player.GetEquippedWeapon(false))
	meleeEquipped = ihudutilityscript.isMeleeWeapon(player.GetEquippedWeapon(true)) || ihudutilityscript.isMeleeWeapon(player.GetEquippedWeapon(false))
	targetSpellEquipped = ihudutilityscript.isTargettedSpell(player.GetEquippedSpell(0)) || ihudutilityscript.isTargettedSpell(player.GetEquippedSpell(1))
endFunction

function processHUD()

	if player == none
		player = game.GetPlayer()
		return 
	endIf
	iHUDCompass.show(self.isKeyActivated())
	iHUDWidget.processWidget(self.isKeyActivated())
	iHUDCrosshair.show(self.isCrosshairVisible())
	iHUDMagickaBar.processMagickaBar()
	iHUDHealthBar.processHealthBar()
	iHUDStaminaBar.processStaminaBar()
endFunction


;-------My custom tweak for smoothcam compatibility
Event OnPlayerCameraState(int oldState, int newState)
	if ( newState == 0)
		isFirstPerson=true
	Else
		isFirstPerson=false
	endIf
	iHUDCrosshair.show(self.isCrosshairVisible())
EndEvent
;-------End of tweak


;-- State -------------------------------------------
state Polling

	function OnUpdate()

		if !self.isActive()
			self.deactivate()
			return 
		endIf
		if !utility.IsInMenuMode()
			self.processEquipment()
			self.processHUD()
		endIf
		self.RegisterForSingleUpdate(iHUDUpdateDelay.getValue())
	endFunction
endState
