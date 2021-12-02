Class {
	#name : #SBTSFile,
	#superclass : #SBBlock,
	#instVars : [
		'filepath'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSFile >> filepath [

	^ filepath
]

{ #category : #'as yet unclassified' }
SBTSFile >> filepath: aString language: aLanguageClass [

	filepath := aString.
	
	FileStream readOnlyFileNamed: aString do: [:stream |
		self addMorphBack: (SBRow new
			cellGap: 4;
			addMorphBack: (aLanguageClass icon ifNotNil: #asMorph ifNil: [SBIcon iconFile]);
			addMorphBack: (SBStringMorph new
				contents: (FileDirectory localNameFor: aString);
				bold)).
		self addMorphBack: ((aLanguageClass parseAndReplace: stream contents) hResizing: #spaceFill)]
]

{ #category : #'as yet unclassified' }
SBTSFile >> initialize [

	super initialize.
	
	self
		layoutInset: 4;
		useAlgebraLayout;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator new
]

{ #category : #'as yet unclassified' }
SBTSFile >> isArtefact [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSFile >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: {
			self firstSubmorph layoutCommands.
			SBAlgebraCommand hardLine withGap: true.
			self submorphs second layoutCommands}
]

{ #category : #'as yet unclassified' }
SBTSFile >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	FileStream
		forceNewFileNamed: self filepath
		do: [:stream | stream nextPutAll: self childSandblocks first sourceString].
	^ true
]
