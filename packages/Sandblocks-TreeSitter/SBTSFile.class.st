Class {
	#name : #SBTSFile,
	#superclass : #SBBlock,
	#instVars : [
		'filepath',
		'runButton',
		'runCancelBlock'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBTSFile >> artefactChanged: aMethodBlock [

	aMethodBlock = self ifTrue: [self root updateAllHighlights]
]

{ #category : #'as yet unclassified' }
SBTSFile >> filepath [

	^ filepath
]

{ #category : #'as yet unclassified' }
SBTSFile >> filepath: aString [

	self
		filepath: aString
		language: (SBGrammarLanguage allSubclasses detect: [:lang | lang fileSuffix = 'c'])
]

{ #category : #'as yet unclassified' }
SBTSFile >> filepath: aString language: aLanguageClass [

	filepath := aString.
	
	FileStream readOnlyFileNamed: aString do: [:stream |
		self addMorphBack: (SBRow new
			cellGap: 4;
			cellPositioning: #center;
			addMorphBack: aLanguageClass iconMorph;
			addMorphBack: (SBStringMorph new
				contents: (FileDirectory localNameFor: aString);
				bold);
			addMorphBack: (Morph new
				extent: 8 @ 0;
				color: Color transparent)).
		self addMorphBack: ((aLanguageClass parseAndReplace: stream contents) hResizing: #spaceFill)].
	
	self root factory runtime ifNotNil: [
		self firstSubmorph addMorphBack: (runButton := SBIcon iconPlay
			balloonText: 'Run file';
			on: #click send: #toggleRun to: self)]
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
SBTSFile >> root [

	^ self childSandblocks first
]

{ #category : #'as yet unclassified' }
SBTSFile >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	FileStream
		forceNewFileNamed: self filepath
		do: [:stream | stream nextPutAll: (aQuickBoolean ifTrue: [self root sourceString] ifFalse: [self root prettySourceString])].
	^ true
]

{ #category : #'as yet unclassified' }
SBTSFile >> toggleRun [

	runCancelBlock
		ifNotNil: [
			runCancelBlock value.
			runButton changeIconName: #iconPlay.
			runCancelBlock := nil]
		ifNil: [
			((self root factory runtime
				evaluateFileAsync: self filepath
				cancel: [:b | runCancelBlock := b]) then: [:b |
				b value: [:status :stdout :stderr |
					{status. stdout. stderr} explore.
					runButton changeIconName: #iconPlay.
					runCancelBlock := nil]]) ifRejected: [:err | err signal].
			runButton changeIconName: #iconStop]
]
