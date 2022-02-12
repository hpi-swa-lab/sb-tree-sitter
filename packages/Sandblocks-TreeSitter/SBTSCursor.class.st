Class {
	#name : #SBTSCursor,
	#superclass : #Object,
	#instVars : [
		'library',
		'cursor',
		'atEnd',
		'factory'
	],
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'as yet unclassified' }
SBTSCursor >> atEnd [

	^ atEnd
]

{ #category : #'as yet unclassified' }
SBTSCursor >> createRestorePoint [

	^ library cursorCopy: cursor
]

{ #category : #'as yet unclassified' }
SBTSCursor >> currentDo: aBlock [

	| type node template |
	type := self type.
	node := SBTSNodeSymbol new type: type factory: self factory.
	template := self factory bodyNodeForRule: type ifAbsent: [
		node := self resolveAlias: type in: self parentType with: self factory aliasOccurrences.
		node unpackAlias].
	^ aBlock value: type value: node makeConcrete value: ((template isKindOf: SBTSNodeAlias) ifTrue: [template element] ifFalse: [template])
]

{ #category : #'as yet unclassified' }
SBTSCursor >> currentFieldName [

	^ library cursorCurrentFieldName: cursor
]

{ #category : #'as yet unclassified' }
SBTSCursor >> currentTemplate [

	| type |
	type := self type.
	^ self factory
		bodyNodeForRule: type
		ifAbsent: [(self resolveAlias: type in: self parentType with: self factory aliasOccurrences) unpackAlias]
]

{ #category : #'as yet unclassified' }
SBTSCursor >> factory [

	^ factory
]

{ #category : #'as yet unclassified' }
SBTSCursor >> gotoFirstChild [

	| ret |
	ret := library cursorGotoFirstChild: cursor.
	(ret and: [self shouldSkipParsedNode: self node]) ifTrue: [^ self gotoNextSibling not].
	
	^ ret
		ifTrue: [
			atEnd := false.
			true]
		ifFalse: [false]
]

{ #category : #'as yet unclassified' }
SBTSCursor >> gotoNextSibling [

	| ret |
	ret := library cursorGotoNextSibling: cursor.
	[ret and: [self shouldSkipParsedNode: self node]] whileTrue: [ret := library cursorGotoNextSibling: cursor].
	^ atEnd := ret not
]

{ #category : #'as yet unclassified' }
SBTSCursor >> gotoParent [

	atEnd := false.
	^ library cursorGotoParent: cursor
]

{ #category : #'as yet unclassified' }
SBTSCursor >> initialize [

	super initialize.
	atEnd := false
]

{ #category : #'as yet unclassified' }
SBTSCursor >> isAlias [

	| type parentType |
	type := self type.
	parentType := self parentType.
	self factory
		bodyNodeForRule: type
		ifAbsent: [^ self factory aliasOccurrences anySatisfy: [:alias | alias name = type and: [alias parentType = parentType]]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSCursor >> isNamed [

	^ library nodeIsNamed: self node
]

{ #category : #'as yet unclassified' }
SBTSCursor >> library [

	^ library
]

{ #category : #'as yet unclassified' }
SBTSCursor >> library: aLibrary cursor: aCursor factory: aFactory [

	library := aLibrary.
	cursor := aCursor.
	factory := aFactory
]

{ #category : #'as yet unclassified' }
SBTSCursor >> node [

	^ library cursorCurrentNode: cursor
]

{ #category : #'as yet unclassified' }
SBTSCursor >> parentType [

	| parent |
	parent := library nodeParent: self node.
	^ parent tree isNull ifTrue: [nil] ifFalse: [library nodeType: parent]
]

{ #category : #'as yet unclassified' }
SBTSCursor >> position [

	^ self createRestorePoint
]

{ #category : #'as yet unclassified' }
SBTSCursor >> position: aPosition [

	self restoreTo: aPosition
]

{ #category : #'as yet unclassified' }
SBTSCursor >> resolveAlias: aString in: aParentString with: aCollection [

	| candidates indices symbolIndex |
	candidates := aCollection select: [:alias | alias name = aString and: [alias parentType = aParentString]].
	candidates size = 1 ifTrue: [^ candidates first object].
	
	self assert: cursor notNil.
	" treesitter has an internal table that maps aliases to indices. if the same alias is used
	twice in the same method, we cannot tell which use we are. We take the assumption
	that treesitter stores these symbols in order of apperance. With this assumption, we can
	now look up the index of our aliased node and look at what point in the symbol table it appears.
	For an example of this, see string_fragment in javascript, where double/single quotes take indices 100/101 "
	symbolIndex := self node context at: 4.
	symbolIndex = 0 ifTrue: [symbolIndex := self node id symbol].
	indices := library language symbolIndicesFor: aString.
	
	^ (candidates at: (indices indexOf: symbolIndex)) object
]

{ #category : #'as yet unclassified' }
SBTSCursor >> resolveCurrentAliasIfString: aBlock ifBlock: anotherBlock ifSymbol: aThirdBlock [

	| symbolIndex rule parentType |
	parentType := library nodeType: (library nodeParent: self node).
	symbolIndex := self node context at: 4.
	symbolIndex = 0 ifTrue: [symbolIndex := self node id symbol].
	
	rule := library language
		resolveAlias: self type
		symbolIndex: symbolIndex
		factory: factory
		parentType: parentType.
	
	rule value type = 'STRING' ifTrue: [^ aBlock value: rule value value].
	rule value type = 'SYMBOL' ifTrue: [^ aThirdBlock value: rule value name].
	
	^ SBToggledCode comment: '' active: 1 do: {
		[
			anotherBlock
				value: rule key
				value: ((self factory buildBlocksFor: rule value) alias: rule key)].
		[anotherBlock value: ((self factory buildBlocksFor: rule value) alias: rule key)]}
]

{ #category : #'as yet unclassified' }
SBTSCursor >> restoreTo: aCursor [

	cursor := aCursor
]

{ #category : #'as yet unclassified' }
SBTSCursor >> shouldSkipParsedNode: aNode [

	| parentType type |
	parentType := library nodeType: (library nodeParent: aNode).
	type := library nodeType: aNode.
	
	^ (factory delimitedRules
		at: parentType
		ifPresent: [:delims | delims includes: self type]
		ifAbsent: [false]) or: [factory extras includes: type]
]

{ #category : #'as yet unclassified' }
SBTSCursor >> text [

	^ library textForNode: self node
]

{ #category : #'as yet unclassified' }
SBTSCursor >> textBetween: aNode and: anEndNode [

	^ library textBetween: aNode and: anEndNode
]

{ #category : #'as yet unclassified' }
SBTSCursor >> type [

	^ library nodeType: self node
]

{ #category : #'as yet unclassified' }
SBTSCursor >> visitTextSlot: aSlot morph: aMorph [

	aMorph textFieldPattern: aSlot regex.
	aMorph contents: self text.
	true
]
