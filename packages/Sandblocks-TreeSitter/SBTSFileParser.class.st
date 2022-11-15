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
		'position'
	],
	#category : #'Sandblocks-TreeSitter-Parser'
}

{ #category : #blocks }
SBTSFileParser >> addBlock: aBlock [

	self assert: aBlock isTSMorph.
	blocks add: aBlock
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> addSlot: aNode [

	slots add: (SBTSSlot with: aNode)
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> ascend [

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

	cursor gotoFirstChild ifFalse: [pendingText := cursor text]
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> initialize [

	super initialize.
	
	slots := OrderedCollection new.
	blocks := OrderedCollection new.
	memoizations := Dictionary new.
	justEnteredAlias := false.
	position := 0
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> justEnteredAlias [

	^ justEnteredAlias
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> justEnteredAlias: aBoolean [

	justEnteredAlias := aBoolean
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
		results anyOne blocks anyOne]
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

	self peekUncapturedText ifNotEmpty: [^ false].
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

	self peekIsNamed ifFalse: [" for e.g. python f-strings, the type is aliased to just the quote, so if we find an unnamed we may be better served to always return the node's full content "
	^ cursor text].
	^ cursor type
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
		anElement buildEmpty first
			contents: pair first;
			range: pair second;
			yourself]
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
	blocks := blocks collect: [:block | block copyBlock].
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

	self position: position + pendingText size.
	^ pendingText
]

{ #category : #'as yet unclassified' }
SBTSFileParser >> uncapturedText [

	| text |
	text := self peekUncapturedText.
	self position: position + text size.
	^ text
]
