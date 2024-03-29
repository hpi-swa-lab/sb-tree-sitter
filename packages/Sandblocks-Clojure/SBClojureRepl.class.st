Class {
	#name : #SBClojureRepl,
	#superclass : #SBBlock,
	#instVars : [
		'repl',
		'path'
	],
	#category : #'Sandblocks-Clojure'
}

{ #category : #'as yet unclassified' }
SBClojureRepl class >> openFor: aString in: aDirectoryString [

	^ self new
		for: aString;
		path: aDirectoryString;
		open
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> connectToREPL [
	<action>

	self repl: (NREPLClient new
		path: path;
		port: (UIManager default request: 'port?') asNumber;
		yourself)
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> evaluate: aBlock [

	^ self evaluateString: aBlock sourceString
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> evaluateString: aString [

	| replies out |
	replies := repl eval: aString.
	out := Dictionary new.
	out
		at: 'out'
		put: (((replies select: [:r | r includesKey: 'out']) collect: [:r | r at: 'out']) joinSeparatedBy: String cr).
	out
		at: 'err'
		put: (((replies select: [:r | r includesKey: 'err']) collect: [:r | r at: 'err']) joinSeparatedBy: String cr).
	replies
		detect: [:r | r includesKey: 'value']
		ifFound: [:reply | out at: 'value' put: (reply at: 'value')].
	^ out
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
SBClojureRepl >> isArtefact [

	^ true
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> launchREPL [
	<action>

	self repl: (NREPLClient new
		path: path;
		launchREPLProcess;
		yourself)
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs
			collect: [:s | s layoutCommands]
			separatedBy: [SBAlgebraCommand hardLine withGap: true])
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	
	repl ifNotNil: #terminate
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> path: aString [

	path := aString
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> repl: aRepl [

	repl := aRepl.
	self submorphsDo: [:m | (m isKindOf: SBRow) ifTrue: [m delete]].
	self addMorphFront: (SBRow new
		cellGap: 4;
		addMorphBack: SBClojure iconMorph;
		addMorphBack: (SBStringMorph new contents: 'Connected to nREPL :', repl port asString))
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	^ true
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> showHelpFor: aBlock [

	(repl lookup: aBlock contents) ifNotNil: [:doc |
		SBDocsPopup new
			addMorphBack: (SBMultilineOwnTextMorph new contents: (doc asText addAttribute: TextEmphasis italic));
			showBelow: aBlock closeOnDeselect: true]
]
