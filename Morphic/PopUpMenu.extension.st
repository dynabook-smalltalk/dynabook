Extension { #name : #PopUpMenu }

{ #category : #'*Morphic-Menus' }
PopUpMenu >> morphicStartUpLeftFlush [
	"Build and invoke this menu with no initial selection.  By Jerry Archibald, 4/01.
	If in MVC, align menus items with the left margin.
	Answer the selection associated with the menu item chosen by the user or nil if none is chosen.  
	The mechanism for getting left-flush appearance in mvc leaves a tiny possibility for misadventure: if the user, in mvc, puts up the jump-to-project menu, then hits cmd period while it is up, then puts up a second jump-to-project menu before dismissing or proceeding through the debugger, it's possible for mvc popup-menus thereafter to appear left-aligned rather than centered; this very unlikely condition can be cleared by evaluating 'PopUpMenu alignment: 2'"

	^self startUp
]

{ #category : #'*Morphic-Menus' }
PopUpMenu >> morphicStartUpWithCaption: captionOrNil icon: aForm at: location allowKeyboard: aBoolean [
	"Display the menu, with caption if supplied. Wait for the mouse button to go down, then track the selection as long as the button is pressed. When the button is released,
	Answer the index of the current selection, or zero if the mouse is not released over  any menu item. Location specifies the desired topLeft of the menu body rectangle. The final argument indicates whether the menu should seize the keyboard focus in order to allow the user to navigate it via the keyboard."

	selection := Cursor normal
				showWhile: [| menuMorph |
					menuMorph := MVCMenuMorph from: self title: nil.
					(captionOrNil notNil
							or: [aForm notNil])
						ifTrue: [menuMorph addTitle: captionOrNil icon: aForm].
					MenuIcons decorateMenu: menuMorph.
					menuMorph
						invokeAt: location
						in: ActiveWorld
						allowKeyboard: aBoolean].
	^ selection
]
