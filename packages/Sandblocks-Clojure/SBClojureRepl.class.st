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
SBClojureRepl >> evaluate: aBlock [

	| replies out |
	replies := repl eval: aBlock sourceString.
	out := Dictionary new.
	out at: 'out' put: ((replies select: [:r | r includesKey: 'out']) joinSeparatedBy: String cr).
	out at: 'err' put: ((replies select: [:r | r includesKey: 'err']) joinSeparatedBy: String cr).
	replies
		detect: [:r | r includesKey: 'value']
		ifFound: [:reply | out at: 'value' put: (reply at: 'value')].
	out explore
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

	(repl := NREPLClient new path: path) launchREPLProcess
		ifTrue: [UIManager default inform: 'connected']
		ifFalse: [UIManager default inform: 'could not connect']
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
SBClojureRepl >> path: aString [

	path := aString
]

{ #category : #'as yet unclassified' }
SBClojureRepl >> showHelpFor: aBlock [

	(repl lookup: aBlock contents) ifNotNil: [:doc |
		SBDocsPopup new
			addMorphBack: (SBMultilineOwnTextMorph new contents: (doc asText addAttribute: TextEmphasis italic));
			showBelow: aBlock closeOnDeselect: true]
]
