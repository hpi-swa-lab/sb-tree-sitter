Class {
	#name : #SBTSFileParser,
	#superclass : #Object,
	#instVars : [
		'stream',
		'slots',
		'blocks',
		'cursor',
		'memoizations',
		'pendingText',
		'justEnteredAlias',
		'position',
		'level'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #blocks }
SBTSFileParser >> addBlock: aBlock [

	self assert: (aBlock isKindOf: SBTSParseNode).
	blocks add: aBlock
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> addSlot: aNode [

	slots add: (SBTSSlot with: aNode)
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> ascend [

	level := level - 1.
	
	" parsed a leaf "
	(blocks size = 1 and: [blocks first kind = #text]) ifTrue: [^ true].
	
	^ pendingText
		ifNotNil: [
			pendingText := nil.
			true]
		ifNil: [ | success |
			success := cursor atEnd.
			cursor gotoParent.
			success]
]

{ #category : #stream }
SBTSFileParser >> atEnd [

	^ cursor atEnd
]

{ #category : #blocks }
SBTSFileParser >> blocks [

	^ blocks
]

{ #category : #blocks }
SBTSFileParser >> blocks: aCollection [

	blocks := aCollection
]

{ #category : #stream }
SBTSFileParser >> contentsSize [

	^ stream originalContents size
]

{ #category : #testing }
SBTSFileParser >> copyEmbeds [

	^ false
]

{ #category : #accessing }
SBTSFileParser >> currentRange [

	^ cursor range
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> currentSlot [

	^ slots last
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> cursor [

	^ cursor
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> descend [

	cursor gotoFirstChild ifFalse: [pendingText := cursor text].
	level := level + 1
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> initialize [

	super initialize.
	
	slots := OrderedCollection new.
	blocks := OrderedCollection new.
	memoizations := Dictionary new.
	justEnteredAlias := false.
	position := 0.
	level := 0
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> justEnteredAlias [

	^ justEnteredAlias
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> justEnteredAlias: aBoolean [

	justEnteredAlias := aBoolean
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> level [

	^ level
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> level: aNumber [

	level := aNumber
]

{ #category : #memo }
SBTSFileParser >> memoizedAt: aNumber for: aSymbol ifNone: aBlock [

	SBToggledCode comment: '' active: 0 do: {[true ifTrue: [^ aBlock value]]}.
	^ (memoizations at: aNumber ifAbsentPut: [Dictionary new])
		at: aSymbol type
		ifPresent: [:parsers |
			parsers do: [:p | self assert: p blocks last slot lastNode type = aSymbol type].
			parsers collect: [:p | | parser |
				parser := p copy.
				"adapt to exact expected instances of that symbol"
				parser blocks do: [:block | block slot lastNode type = aSymbol type ifTrue: [block slot: (block slot replaceLast: aSymbol)]].
				parser]]
		ifAbsent: [ | orig |
			orig := aBlock value.
			orig ifNotEmpty: [(memoizations at: aNumber) at: aSymbol type put: (orig collect: [:p | p copy])].
			orig]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> nextSibling [

	| newPosition t |
	t := cursor type.
	newPosition := cursor endByteIndex: cursor node.
	pendingText := nil.
	cursor gotoNextSibling ifFalse: [self position: newPosition]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> numberOfNewLinesToNext [

	| current previous text |
	cursor atEnd
		ifTrue: [
			current := nil.
			previous := cursor node]
		ifFalse: [
			current := cursor node.
			previous := cursor previousNode: current.
			previous ifNil: [^ 0]].
	
	position > (cursor endByteIndex: previous) ifTrue: [^ 0].
	text := cursor textBetween: previous and: current.
	^ text occurrencesOf: Character lf
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> parse: aString language: aLanguage [

	| api language |
	api := SBTreeSitter new.
	language := aLanguage isBehavior ifTrue: [aLanguage instance] ifFalse: [aLanguage].
	^ api parseAsCursor: aString language: language class language do: [:cursorObj | | results |
		cursor := SBTSCursor new library: api cursor: cursorObj factory: language grammar.
		results := (SBTSNodeSymbol new
			type: language class rootRuleName
			factory: language grammar) resultsForBlocks: self.
		self assert: results size = 1.
		self assert: results anyOne blocks size = 1.
		results anyOne blocks anyOne buildWith: self]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> parseTopLevel: aString language: aFactory [

	| toplevel |
	toplevel := self parse: aString language: aFactory.
	toplevel
		hResizing: #rigid;
		layoutInset: 12;
		attachDecorator: SBResizableDecorator new;
		attachDecorator: SBForceMoveDecorator newConfigured.
	^ toplevel
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> peekForLabel: aString [

	self peekUncapturedText ifNotEmpty: [^ false].
	^ self peekIsNamed not and: [self peekType = aString]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> peekForType: aString [

	self peekUncapturedText isEmpty ifFalse: [^ false].
	^ self peekIsNamed and: [self peekType = aString]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> peekHasText [

	^ pendingText notNil
]

{ #category : #stream }
SBTSFileParser >> peekIsNamed [

	^ cursor isNamed
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> peekText [

	^ pendingText
]

{ #category : #stream }
SBTSFileParser >> peekType [

	| t |
	t := cursor type.
	" FIXME the below breaks for just whitespaces, as in for example the C preproc_include "
	(t allSatisfy: #isSeparator) ifTrue: [^ t].
	
	" for e.g. python f-strings, the type is aliased to just the quote, so if we find an unnamed we may be better served to always return the node's full content "
	self peekIsNamed ifFalse: [^ cursor text].
	
	^ t
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> peekUncapturedText [

	| current previous text |
	cursor atEnd
		ifTrue: [
			current := nil.
			previous := cursor node]
		ifFalse: [
			current := cursor node.
			previous := cursor previousNode: current.
			previous ifNil: [
				position >= ((cursor startByteIndex: current) - 1) ifTrue: [^ ''].
				^ cursor factory trimExtra: (cursor textBetween: nil and: current)]].
	
	position > (cursor endByteIndex: previous) ifTrue: [^ ''].
	text := cursor textBetween: previous and: current.
	text := cursor factory trimExtra: text.
	^ text
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> popPendingCommentsFor: anElement [

	^ cursor popComments collect: [:pair |
		(SBTSFileParseNode kind: #block slot: (SBTSSlot with: anElement) contents: {
			SBTSFileParseNode
				kind: #text
				slot: (SBTSSlot with: anElement bodyTemplate)
				contents: pair first}) range: pair second]
]

{ #category : #stream }
SBTSFileParser >> position [

	^ position
]

{ #category : #stream }
SBTSFileParser >> position: aNumber [

	position := aNumber
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> postCopy [

	super postCopy.
	blocks := blocks collect: [:block | block copy].
	cursor := cursor copy
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> printTree [

	^ String streamContents: [:s | self cursor library printTreeFrom: self cursor depth: 0 on: s]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> replaceCurrentSlot: aSlot [

	slots removeLast.
	slots add: aSlot
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> skipDelimiters: aString [

	(self peekForLabel: aString) ifTrue: [self nextSibling]
]

{ #category : #accessing }
SBTSFileParser >> slots [

	^ slots
]

{ #category : #accessing }
SBTSFileParser >> stream [

	^ stream
]

{ #category : #accessing }
SBTSFileParser >> stream: aStream [

	stream := aStream
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> text [

	| ret |
	self position: position + pendingText size.
	ret := pendingText.
	pendingText := nil.
	^ ret
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> uncapturedText [

	| text |
	text := self peekUncapturedText.
	self position: position + text size.
	^ text
]
