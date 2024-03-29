Class {
	#name : #SBTSStMethod,
	#superclass : #SBBlock,
	#instVars : [
		'methodClass'
	],
	#category : #'Sandblocks-TSSmalltalk'
}

{ #category : #'as yet unclassified' }
SBTSStMethod class >> for: aCompiledMethod [

	^ self new for: aCompiledMethod
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> browse [
	<action>

	Browser newOnClass: self methodClass selector: self selector
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> for: aCompiledMethod [

	methodClass := aCompiledMethod methodClass.
	self addMorphBack: (SBTSFileParser new parse: aCompiledMethod getSource asString language: SBTSSmalltalk).
	self method firstSubmorph applyReplacement
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> initialize [

	super initialize.
	
	self
		hResizing: #rigid;
		vResizing: #shrinkWrap;
		layoutPolicy: SBAlgebraLayout new;
		attachDecorator: SBMoveDecorator new;
		attachDecorator: SBResizableDecorator new;
		layoutInset: 4
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> isArtefact [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> isMethod [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> layoutCommands [

	^ SBAlgebraCommand container
		data: (self submorphs collect: [:b | b layoutCommands] separatedBy: [SBAlgebraCommand hardLine]);
		morph: self
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> method [

	^ self firstSubmorph
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> methodClass [

	^ self firstSubmorph firstSubmorph class = SBTSSTMethodDeclaration ifTrue: [self firstSubmorph firstSubmorph firstSubmorph object] ifFalse: [methodClass]
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> object [

	^ (self methodClass ifNil: [^ self])
		compiledMethodAt: self selector
		ifAbsent: [self]
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	| text newSelector |
	text := aQuickBoolean
		ifTrue: [self method sourceString]
		ifFalse: [self method prettySourceString].
	
	newSelector := self methodClass compile: text asText classified: nil.
	
	^ true
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> selector [

	^ (((self method childSandblocks first childSandblocks
		viewFrom: 1
		by: 2) collect: [:p | p contents]) joinSeparatedBy: '') asSymbol
]

{ #category : #'as yet unclassified' }
SBTSStMethod >> semantics [

	^ SBTSSmalltalk
]
