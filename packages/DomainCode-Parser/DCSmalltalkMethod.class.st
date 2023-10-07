Class {
	#name : #DCSmalltalkMethod,
	#superclass : #SBBlock,
	#instVars : [
		'methodClass'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCSmalltalkMethod class >> emptyIn: aClass [

	^ self new emptyIn: aClass
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod class >> for: aCompiledMethod [

	^ aCompiledMethod isSandblock ifFalse: [self new for: aCompiledMethod] ifTrue: [self new emptyIn: aCompiledMethod methodClass]
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> browse [
	<action>

	Browser newOnClass: self methodClass selector: self selector
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> emptyIn: aClass [

	methodClass := aClass.
	self addMorphBack: (DCBlock parseBlock: '__sb' language: SBTSSmalltalk)
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> externalModification: aBoolean [

	self setProperty: #externalModificationFlag toValue: aBoolean
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> for: aCompiledMethod [

	methodClass := aCompiledMethod methodClass.
	self addMorphBack: (DCBlock parseBlock: aCompiledMethod getSource asString language: SBTSSmalltalk)
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> hasExternalModification [

^ self valueOfProperty: #externalModificationFlag ifAbsent: [ false ]
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> ignoreChangeNotifierDuring: aBlock [

	self setProperty: #ignoreChangeNotifier toValue: true.
	
	aBlock ensure: [self removeProperty: #ignoreChangeNotifier]
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
DCSmalltalkMethod >> intoWorld: aWorld [

	super intoWorld: aWorld.
	SystemChangeNotifier uniqueInstance
		noMoreNotificationsFor: self;
		notify: self ofSystemChangesOfItem: #method using: #methodChanged:
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
DCSmalltalkMethod >> methodChanged: anEvent [

	((self hasProperty: #ignoreChangeNotifier) not and: (anEvent item selector = self selector and: [anEvent item methodClass = self methodClass])) ifTrue: [
		anEvent isRemoved ifTrue: [^ self delete].
		anEvent isModified ifTrue: [
			^ self hasUnsavedChanges
				ifTrue: [self externalModification: true]
				ifFalse: [self reloadMethodInPlaceUndoable: false]]]
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
DCSmalltalkMethod >> reloadMethodInPlaceUndoable: aBoolean [

	| reloaded |
	self externalModification: false.
	reloaded := (DCSmalltalkMethod for: self containingArtefact object)
		hResizing: self containingArtefact hResizing;
		width: self containingArtefact width;
		yourself.
	
	self isInWorld ifTrue: [
		aBoolean
			ifTrue: [self sandblockEditor do: (SBReplaceCommand new target: self replacer: reloaded)]
			ifFalse: [self replaceBy: reloaded]].
	^ reloaded
]

{ #category : #'as yet unclassified' }
DCSmalltalkMethod >> saveTryFixing: aFixBoolean quick: aQuickBoolean [

	| text newSelector |
	(self hasExternalModification not or: [UIManager default confirm: 'Method may have changed elsewhere, continue?'])
		ifTrue: [self externalModification: false]
		ifFalse: [^ false].
	
	self firstSubmorph queryState errorsDo: [:error | aFixBoolean ifTrue: [error tryFixIfFail: [^ false]] ifFalse: [^ false]].
	
	text := aQuickBoolean ifTrue: [self method sourceString] ifFalse: [
		[
			PPFormatter
				formatString: self method sourceString
				class: (self containingArtefact ifNotNil: #relatedClass ifNil: [nil class])
				noPattern: self ~= self containingArtefact]
			on: SyntaxErrorNotification
			do: [self method sourceString]].
	
	self ignoreChangeNotifierDuring: [
		newSelector := self methodClass
			compile: text withSqueakLineEndings asText
			classified: nil].
	
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
