Class {
	#name : #SBTSCursorRaw,
	#superclass : #Object,
	#instVars : [
		'library',
		'cursor',
		'atEnd',
		'factory',
		'previousSiblings',
		'comments',
		'position'
	],
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> advance: aNumber [

	self position: position + aNumber
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> atEnd [

	^ atEnd
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> createRestorePoint [

	^ SBToggledCode comment: '' active: 1 do: {[cursor copy]. [library cursorCopy: cursor]}
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> currentDo: aBlock [

	| type template isAlias |
	type := self unaliasedType.
	isAlias := type ~= self type.
	
	SBToggledCode comment: '' active: 2 do: {
		[
			template := isAlias
				ifTrue: [
					SBTSNodeAlias new
						factory: self factory;
						alias: type;
						element: (self factory bodyNodeForRule: type ifAbsent: [
							isAlias := true.
							(self resolveAlias: self type in: self parentType with: self factory aliasOccurrences) unpackAlias])]
				ifFalse: [SBTSNodeSymbol new type: type factory: self factory]].
		[
			template := self factory bodyNodeForRule: type ifAbsent: [
				isAlias := true.
				(self resolveAlias: self type in: self parentType with: self factory aliasOccurrences) unpackAlias]]}.
	^ aBlock value: type value: template value: isAlias
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> currentFieldName [

	^ cursor fieldName
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> currentIndex [

	^ library nodeStartByte: self node
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> endByteIndex: aNode [

	^ library nodeEndByte: aNode
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> factory [

	^ factory
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> fieldName [

	^ self currentFieldName
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> gotoFirstChild [

	| ret |
	ret := cursor gotoFirstChild.
	ret ifTrue: [previousSiblings add: nil].
	
	^ ret
		ifTrue: [
			atEnd := false.
			true]
		ifFalse: [false]
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> gotoNextSibling [

	| ret |
	previousSiblings atLast: 1 put: self node.
	self position: (self endByteIndex: self node).
	ret := cursor gotoNextSibling.
	^ atEnd := ret not
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> gotoParent [

	| ret |
	atEnd := false.
	ret := SBToggledCode
		comment: ''
		active: 1
		do: {[cursor gotoParent]. [library cursorGotoParent: cursor]}.
	ret ifTrue: [previousSiblings removeLast].
	
	^ ret
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> initialize [

	super initialize.
	atEnd := false.
	previousSiblings := OrderedCollection with: nil.
	comments := OrderedCollection new.
	position := 0
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> isAlias [

	| type parentType |
	type := self type.
	parentType := self parentType.
	self factory
		bodyNodeForRule: type
		ifAbsent: [^ self factory aliasOccurrences anySatisfy: [:alias | alias name = type and: [alias parentType = parentType]]].
	^ false
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> isMissing [

	^ library nodeIsMissing: self node
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> isNamed [

	^ library nodeIsNamed: self node
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> library [

	^ library
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> library: aLibrary cursor: aCursor factory: aFactory [

	library := aLibrary.
	cursor := aCursor.
	factory := aFactory
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> node [

	^ SBToggledCode
		comment: ''
		active: 1
		do: {[cursor currentNode]. [library cursorCurrentNode: cursor]}
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> numberOfNewLinesToNext [

	| current previous text |
	self atEnd
		ifTrue: [
			current := nil.
			previous := self node]
		ifFalse: [
			current := self node.
			previous := self previousNode: current.
			previous ifNil: [^ 0]].
	self position > (self endByteIndex: previous) ifTrue: [^ 0].
	text := self textBetween: previous and: current.
	^ text occurrencesOf: Character lf
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> parent [

	^ library nodeParent: self node
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> parentType [

	| parent |
	parent := library nodeParent: self node.
	^ parent tree isNull ifTrue: [nil] ifFalse: [library nodeType: parent]
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> popComments [

	| c |
	c := comments.
	comments := OrderedCollection new.
	^ c
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> position [
	"0-based byte index"

	^ position
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> position: aNumber [

	position := aNumber
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> postCopy [

	super postCopy.
	cursor := self createRestorePoint.
	previousSiblings := previousSiblings copy.
	comments := comments copy
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> previousNode: aNode [

	SBToggledCode comment: '' active: 2 do: {
		[ | prev |
			prev := library nodePrevSibling: aNode.
			^ prev id isNull ifFalse: [prev] ifTrue: [nil]].
		["our custom data structure saves about 30% of time"
		^ previousSiblings size > 0 ifTrue: [previousSiblings last] ifFalse: [nil]]}
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> range [

	| start end node |
	node := self node.
	start := library nodeStartPoint: node.
	end := library nodeEndPoint: node.
	"FIXME: utf8?"
	^ SBTSRange
		start: (SBTSPosition line: start row character: start column index: (library nodeStartByte: node))
		end: (SBTSPosition line: end row character: end column index: (library nodeEndByte: node))
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> resolveAlias: aString in: aParentString with: aCollection [

	| candidates indices symbolIndex |
	candidates := aCollection select: [:alias | alias name = aString and: [alias parentType = aParentString]].
	candidates size = 1 ifTrue: [^ candidates first object].
	
	"if we have not found any candidates, it may be because we are actually an alias inside a supertype such as primary_expression. check for this with this heuristic (that may be a bit wonky due to the inclusion check in the parent-type that does not consider exact position)"
	candidates ifEmpty: [ | parent |
		parent := factory bodyNodeForRule: aParentString ifAbsent: [self assert: false].
		candidates := aCollection select: [:alias | alias name = aString and: [(factory isSuperType: alias parentType) and: [parent includesChild: [:c | c type = alias parentType]]]]].
	
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
SBTSCursorRaw >> resolveCurrentAliasIfString: aBlock ifBlock: anotherBlock ifSymbol: aThirdBlock [

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
SBTSCursorRaw >> shouldSkipParsedNode: aNode [

	| type |
	type := library nodeType: aNode.
	(type includesSubstring: #comment) ifTrue: [
		comments add: {(library textForNode: aNode) withoutTrailingBlanks. self range}.
		^ true].
	^ factory language shouldSkipParsing: type cursor: self
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> startByteIndex: aNode [

	^ library nodeStartByte: aNode
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> text [

	^ library textForNode: self node
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> textBetween: aNode and: anEndNode [

	^ library textBetween: aNode and: anEndNode
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> textBetweenIndex: aNumber and: anotherNumber [

	^ library textBetweenIndex: aNumber and: anotherNumber
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> textBetweenIndex: aNumber andNode: anEndNode [

	^ library textBetweenIndex: aNumber and: (library nodeStartByte: anEndNode)
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> textToNext [

	| current previous |
	self atEnd
		ifTrue: [
			current := nil.
			previous := self node]
		ifFalse: [
			current := self node.
			previous := self previousNode: current].
	(previous notNil and: [self position > (self endByteIndex: previous)]) ifTrue: [^ ''].
	^ self textBetween: previous and: current
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> type [

	^ library nodeType: self node
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> unaliasedType [

	| index n type |
	n := self node.
	" here things get real tricky: tree-sitter subtrees (id) can have a compact representation that is directly in the struct or point to a larger structure.	
	 below are the excerpts from the structs that are relevant. let's hope they never change -.-

	typedef struct {
	  uint32_t bytes;
	  TSPoint extent;
	} Length; 12

	typedef struct {
	  uint32_t row;
	  uint32_t column;
	} TSPoint; 8

	typedef struct {
	  volatile uint32_t ref_count; 	4   4
	  Length padding;               	12  16
	  Length size;                  		12  28
	  uint32_t lookahead_bytes;     	4   32
	  uint32_t error_cost;          		4   36
	  uint32_t child_count;         	4   40
	  TSSymbol symbol;              	2
	"
	index := (n id ignore bitAt: 1) ~= 0 ifTrue: [n id symbol] ifFalse: [(n id getHandle pointerAt: 1) getHandle uint16At: 41].
	type := index = 0
		ifTrue: [library nodeType: n]
		ifFalse: [library language symbolNames at: index + 1].
	
	" does the entry actually exist? apparently aliases can be reused as proper symbol names as part of the symbolNames table. (_import_export_specifier in JS) "
	"factory bodyNodeForRule: type ifAbsent: [^ library nodeType: n]."
	^ type
]

{ #category : #'as yet unclassified' }
SBTSCursorRaw >> uncapturedText [

	^ self textBetweenIndex: self position + 1 and: (self atEnd
		ifTrue: [self endByteIndex: self parent]
		ifFalse: [self endByteIndex: self node])
]
