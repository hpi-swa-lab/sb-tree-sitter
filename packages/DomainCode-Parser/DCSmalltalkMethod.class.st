Class {
	#name : #DCSmalltalkMethod,
	#superclass : #SBBlock,
	#instVars : [
		'methodClass'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCSmalltalkMethod class >> for: aCompiledMethod [

	^ self new for: aCompiledMethod
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> browse [
	<action>

	Browser newOnClass: self methodClass selector: self selector
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> for: aCompiledMethod [

	methodClass := aCompiledMethod methodClass.
	self addMorphBack: (DCBlock parseBlock: aCompiledMethod getSource asString language: SBTSSmalltalk)
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> initialize [

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
DCSmalltalkMethod >> isArtefact [

	^ true
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> isMethod [

	^ true
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> layoutCommands [

	^ SBAlgebraCommand container
		data: (self submorphs collect: [:b | b layoutCommands] separatedBy: [SBAlgebraCommand hardLine]);
		morph: self
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> method [

	^ self firstSubmorph
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> methodClass [

	^ methodClass
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> object [

	^ (self methodClass ifNil: [^ self])
		compiledMethodAt: self selector
		ifAbsent: [self]
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	| text newSelector |
	text := aQuickBoolean
		ifTrue: [self method sourceString]
		ifFalse: [self method prettySourceString].
	newSelector := self methodClass compile: text asText classified: nil.
	^ true
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> selector [

	| selector |
	selector := (self method queryAll: '[(unary_selector) (binary_selector) (keyword_selector)] @') first.
	
	^ (((selector childSandblocks viewFrom: 1 by: 2) collect: [:p | p contents]) joinSeparatedBy: '') asSymbol
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> type [

	^ nil
]