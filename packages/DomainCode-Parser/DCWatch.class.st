Class {
	#name : #DCWatch,
	#superclass : #DCReplacement,
	#instVars : [
		'exampleValues'
	],
	#classVars : [
		'Watches'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCWatch class >> registerWatch: aWatch [

	Watches := Watches ifNil: [WeakArray with: aWatch] ifNotNil: [Watches copyWith: aWatch]
]

{ #category : #'as yet unclassified' }
DCWatch class >> report: anObject for: anId [

	self watches do: [:watch | watch ifNotNil: [watch id = anId ifTrue: [watch reportValue: anObject env: SBExecutionEnvironment value]]].
	^ anObject
]

{ #category : #'as yet unclassified' }
DCWatch class >> unregisterWatch: aWatch [

	Watches := self watches copyWithout: aWatch
]

{ #category : #'as yet unclassified' }
DCWatch class >> watches [

	^ Watches ifNil: [Watches := WeakArray new]
]

{ #category : #'as yet unclassified' }
DCWatch >> drawnColor [

	^ self colorPolicy toolColorFor: self
]

{ #category : #'as yet unclassified' }
DCWatch >> exampleFinished: anExample [

	exampleValues at: anExample ifPresent: [:val | val exampleFinished: anExample]
]

{ #category : #'as yet unclassified' }
DCWatch >> exampleStarting: anExample [

	(exampleValues at: anExample ifAbsentPut: [ | display |
		display := SBExampleValueDisplay new.
		self addMorphBack: (exampleValues at: anExample put: display).
		anExample ifNotNil: [anExample when: #outOfWorld send: #exampleStopped: to: self with: anExample].
		display])
		exampleStarting: anExample;
		name: (anExample ifNotNil: #label ifNil: ['global'])
]

{ #category : #'as yet unclassified' }
DCWatch >> exampleStopped: anExample [

	exampleValues at: anExample ifPresent: [:val |
		self removeMorph: val.
		exampleValues removeKey: anExample]
]

{ #category : #'as yet unclassified' }
DCWatch >> expression [

	^ (self source type = 'parenthesized_expression'
		ifTrue: [self source childNodes second]
		ifFalse: [self source]) childNodes third
]

{ #category : #'as yet unclassified' }
DCWatch >> id [

	^ (self source type = 'parenthesized_expression' ifTrue: [self source childSandblocks first] ifFalse: [self source]) childNodes fifth contents allButFirst allButLast
]

{ #category : #'as yet unclassified' }
DCWatch >> initialize [

	super initialize.
	exampleValues := Dictionary new.
	self layoutPolicy: TableLayout new.
	self listDirection: #topToBottom
]

{ #category : #'as yet unclassified' }
DCWatch >> intoWorld: aWorld [

	| editor |
	super intoWorld: aWorld.
	self class registerWatch: self.
	
	editor := self sandblockEditor.
	(editor respondsTo: #examples) ifTrue: [editor examples registerWatch: self]
]

{ #category : #'as yet unclassified' }
DCWatch >> isWatch [

	^ true
]

{ #category : #'as yet unclassified' }
DCWatch >> layoutCommands [

	^ SBAlgebraCommand container
		morph: self;
		data: (self submorphs collect: [:s | s layoutCommands] separatedBy: [SBAlgebraCommand hardLine])
]

{ #category : #'as yet unclassified' }
DCWatch >> layoutInset [

	^ 4 @ 4
]

{ #category : #'as yet unclassified' }
DCWatch >> listensToExamples [

	^ true
]

{ #category : #'as yet unclassified' }
DCWatch >> outOfWorld: aWorld [

	super outOfWorld: aWorld.
	self class unregisterWatch: self
]

{ #category : #'as yet unclassified' }
DCWatch >> reportValue: aString env: anEnvironment [

	(anEnvironment isNil and: [(exampleValues includesKey: nil) not]) ifTrue: [self exampleStarting: anEnvironment].
	
	exampleValues at: anEnvironment ifPresent: [:display | | converted |
		converted := (aString isString and: [aString matchesRegex: '-?\d+(\.\d+)?'])
			ifTrue: [aString asNumber]
			ifFalse: [aString].
		converted = 'inf' ifTrue: [converted := Float infinity].
		
		display reportValue: converted name: (anEnvironment ifNotNil: #label ifNil: ['']).
		anEnvironment ifNil: [display exampleFinished: anEnvironment]].
	self triggerEvent: #reportedValue with: aString
]
