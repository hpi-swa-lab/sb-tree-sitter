Class {
	#name : #SBBashPrompt,
	#superclass : #SBBlock,
	#category : #'Sandblocks-Bash'
}

{ #category : #'as yet unclassified' }
SBBashPrompt >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBTextBubble new
			when: #contentsChanged send: #update to: self;
			layoutInset: 4);
		cellGap: 4;
		hResizing: #rigid;
		vResizing: #shrinkWrap;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured;
		width: 300;
		changeTableLayout;
		layoutInset: 4
]

{ #category : #'as yet unclassified' }
SBBashPrompt >> update [

	[ | newBlock |
		newBlock := (SBTSFileParser new parse: self firstSubmorph contents language: SBBash)
			localColorPolicy: (self colorPolicy copy enlarge: true);
			hResizing: #spaceFill.
		self submorphCount > 1 ifTrue: [self submorphs second delete].
		self addMorphBack: newBlock]
		on: SBTSSyntaxError
		do: [:err | ]
]
