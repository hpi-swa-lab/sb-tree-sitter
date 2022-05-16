Class {
	#name : #SBClojureRepl,
	#superclass : #SBBlock,
	#instVars : [
		'repl'
	],
	#category : #'Sandblocks-Clojure'
}

{ #category : #'as yet unclassified' }
SBClojureRepl class >> openFor: aString [

	^ self new
		for: aString;
		open
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> evaluate: aBlock [

	(repl eval: aBlock sourceString) explore
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> for: aString [

	self addMorphBack: (SBTSFileParser new parse: aString language: SBClojure)
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> initialize [

	super initialize.
	
	self
		layoutPolicy: SBAlgebraLayout new;
		vResizing: #shrinkWrap;
		hResizing: #rigid;
		layoutInset: 12;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> intoWorld: aWorld [

	super intoWorld: aWorld.
	repl := NREPLClient new.
	repl clone
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> isArtefact [

	^ true
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs collect: [:s | s layoutCommands] separatedBy: [SBAlgebraCommand hardLine])
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	
	repl ifNotNil: #terminate
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> showHelpFor: aBlock [

	(repl lookup: aBlock contents) ifNotNil: [:doc |
		SBDocsPopup new
			addMorphBack: (SBMultilineOwnTextMorph new contents: (doc asText addAttribute: TextEmphasis italic));
			showBelow: aBlock closeOnDeselect: true]
]
