Class {
	#name : #SBTSInputReconcile,
	#superclass : #SBPopup,
	#instVars : [
		'target',
		'currentChoices',
		'findOptionsBlock',
		'insertIndex'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSInputReconcile class >> endIndex [

	^ 900000000
]

{ #category : #'reconciliation helper' }
SBTSInputReconcile >> applyCommand: aCommand [

	| anyConstructed |
	target sandblockEditor do: aCommand.
	
	anyConstructed := false.
	aCommand morphs do: [:p | p allMorphsDo: [:m | (m valueOfProperty: #lastConstructed ifAbsent: [false]) ifTrue: [anyConstructed := true]]].
	anyConstructed ifTrue: [self positionCursorIn: aCommand morphs]
]

{ #category : #callbacks }
SBTSInputReconcile >> contentsChanged [

	currentChoices ifNil: [^ self].
	self contents ifEmpty: [^ self dismiss].
	
	self updateChoices
]

{ #category : #accessing }
SBTSInputReconcile >> currentTextMorph [

	^ self firstSubmorph
]

{ #category : #actions }
SBTSInputReconcile >> dismiss [
	<action>

	self delete.
	target containingSandblock
		select;
		moveCursorToEnd
]

{ #category : #accessing }
SBTSInputReconcile >> findOptionsBlock [

	^ findOptionsBlock ifNil: [[self tryReconcileFor: target input: self contents in: target containingSandblock at: insertIndex]]
]

{ #category : #accessing }
SBTSInputReconcile >> findOptionsBlock: aBlock [

	findOptionsBlock := aBlock
]

{ #category : #'initialize-release' }
SBTSInputReconcile >> for: aTextMorph input: aString at: aNumber [

	target := aTextMorph.
	insertIndex := aNumber.
	
	self currentTextMorph placeholderText: ('Add characters {1}...' format: {aNumber = 1 ifTrue: ['before'] ifFalse: ['after']}).
	
	self
		contents: aString;
		showBelow: aTextMorph closeOnDeselect: true;
		moveCursorToEnd;
		queueUpdateSuggestionsFocused: true.
	
	aNumber = 1 ifTrue: [self topRight: aTextMorph position] ifFalse: [
		aTextMorph sourceString
			ifEmpty: [self topLeft: aTextMorph topLeft]
			ifNotEmpty: [self topLeft: aTextMorph topRight]].
	
	self updateChoices
]

{ #category : #'reconciliation helper' }
SBTSInputReconcile >> indexOf: aCursor in: aCollectionOfMorphs [

	^ aCursor isInsert
		ifTrue: [ | childIndex |
			childIndex := aCollectionOfMorphs findFirst: [:m | m = aCursor container or: [m owner = aCursor container]].
			childIndex + (((aCursor container submorphs copyFrom: 1 to: aCursor command insertIndex - 1) collect: #recursiveSubmorphCount)
				inject: 0
				into: [:s :c | s + c]) + 1]
		ifFalse: ["if we are in a finished label, just return our index so that the next position will be taken. otherwise, we will likely want to continue typing here, so pretend that we were one index further out"
		(aCollectionOfMorphs indexOf: aCursor morph) + (aCursor morph slot firstNode isTSLabel ifTrue: [-1] ifFalse: [1])]
]

{ #category : #'initialize-release' }
SBTSInputReconcile >> initialize [

	super initialize.
	self addMorphBack: (SBOwnTextMorph new
		when: #contentsChanged send: #contentsChanged to: self;
		placeholderText: 'Add characters ...')
]

{ #category : #'reconciliation helper' }
SBTSInputReconcile >> optionsForInsert: aPosition given: aString [

	^ (SBTSInputParser new optionsForTemplate: aPosition command element given: aString) collect: [:blocks | aPosition command copy morphs: blocks]
]

{ #category : #'reconciliation helper' }
SBTSInputReconcile >> positionCursorIn: aCollection [

	| all stopIndex |
	insertIndex = 1 ifTrue: [^ aCollection first startInputAtStart].
	
	all := Array streamContents: [:s | aCollection do: [:block | block allMorphsPreorderDo: [:m | s nextPut: m]]].
	stopIndex := all findLast: [:m | m valueOfProperty: #lastConstructed ifAbsent: [false]].
	
	stopIndex > 0 ifTrue: [
		aCollection do: [:m | m allMorphsDo: [:i | i removeProperty: #lastConstructed]].
		(all at: stopIndex) containingSandblock valid ifFalse: [^ (all at: stopIndex) containingSandblock startInputAtEnd].
		
		aCollection do: [:block |
			block cursorPositionsDo: [:cursor |
				(((cursor isInsert and: [(cursor command element hasParentThat: [:p | p isTSRepeat and: [p required]]) not and: [cursor command element isTSLabel not]]) or: [cursor isText]) and: [(self indexOf: cursor in: all) > stopIndex]) ifTrue: [
					block sandblockEditor cursor
						cursorPosition: (cursor placeAtEnd: true)
						explicitMove: false
						axis: #none.
					"if we completed a keyword and the input finished at the very boundary of the block, move one to the right to facilitate continuing to type (may be replaced with a post-do action, mostly need in tryFill with separators)"
					(block sandblockEditor mode ~= #insert and: [
						self contents notEmpty and: [
							self contents last = $  and: [ | boundary |
								boundary := (all at: stopIndex) containingSandblock.
								boundary = boundary lastDeepChild containingSandblock and: [boundary slot firstNode isTSLabel]]]]) ifTrue: [block sandblockEditor performForSelection: #moveCursorRight].
					^ self]]]].
	aCollection last isSandblock ifTrue: [aCollection last lastDeepChild startInputAtEnd].
	aCollection last isTextMorph ifTrue: [
		aCollection last containingSandblock sandblockEditor
			startInput: aCollection last containingSandblock
			at: 900000000
			replacingContents: false
			in: aCollection last]
]

{ #category : #'reconciliation helper' }
SBTSInputReconcile >> positionsAfter: aBlock from: aSourceBlock do: aClosure [

	| foundSelf |
	foundSelf := false.
	aBlock owner isTSBlock ifFalse: [^ self].
	aBlock owner cursorPositionsDo: [:position |
		(foundSelf and: [position isInsert or: [position isText]]) ifTrue: [aClosure value: position].
		(position isText and: [
			aSourceBlock isTextMorph
				ifTrue: [position textMorph = aSourceBlock]
				ifFalse: [position block = aSourceBlock containingSandblock]]) ifTrue: [foundSelf := true]]
]

{ #category : #accessing }
SBTSInputReconcile >> suggestAlways [

	^ true
]

{ #category : #suggestions }
SBTSInputReconcile >> suggestions [

	^ ((currentChoices ifNil: [{}]) collect: [:command | SBTSBlockSuggestion new command: command in: self sandblockEditor popup: self]) ifEmpty: [
		{
			SBSuggestionItemNonSelectable
				selector: ('input `{3}` not valid in {1} {2}' format: {
					target containingSandblock printString first isVowel
						ifTrue: ['an']
						ifFalse: ['a'].
					target containingSandblock printString.
					self contents})
				label: ''}]
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryAdjacentTo: aBlock given: aString [

	self positionsAfter: aBlock from: target do: [:position |
		(position isText and: [position block wantsInput]) ifTrue: ["TODO: do we want the full reconciliation logic or just reinterpret?"
		^ self tryReinterpretFrom: position textMorph in: position block given: aString at: self class endIndex].
		position isInsert ifTrue: [(self optionsForInsert: position given: aString) ifNotEmpty: [:res | ^ res]]].
	^ {}
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryReconcileFor: aMorph input: aString in: aBlock at: aNumber [

	aMorph isUnknown ifTrue: [
		((SBTSInputParser new optionsForTemplate: aMorph slot firstNode given: aString) collect: [:blocks |
			SBReplaceMultipleCommand new
				target: aMorph replacers: blocks;
				shouldMergeWithNext: true]) ifNotEmpty: [:res | ^ res]].
	
	"recursive stop condition: either our owner is no longer a ts-block or we have already gone two steps. two steps were enough for all valid scenarios we have encountered thus far."
	aBlock isTSBlock ifFalse: [^ {}].
	(aMorph ownerChain indexOf: aBlock) > 3 ifTrue: [^ {}].
	
	^ aNumber = 1
		ifTrue: [(self tryWrapOrReinterpret: aBlock from: aMorph given: aString at: aNumber) ifEmpty: [(self trySkipLabel: aString in: aBlock from: aMorph at: aNumber) ifEmpty: [self trySkipLabel: aString in: aBlock owner from: aMorph at: aNumber]]]
		ifFalse: [(self trySeparator: aString in: aBlock) ifEmpty: [(self tryWrapOrReinterpret: aBlock from: aMorph given: aString at: aNumber) ifEmpty: [(self tryAdjacentTo: aBlock given: aString) ifEmpty: [(self trySkipLabel: aString in: aBlock from: aMorph at: aNumber) ifEmpty: [self tryReconcileFor: aMorph input: aString in: aBlock owner at: aNumber]]]]]
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryReinterpretFrom: aMorph in: aBlock given: aString at: aNumber [

	^ self tryReinterpretFrom: aMorph in: aBlock given: aString at: aNumber fullToken: false
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryReinterpretFrom: aMorph in: aBlock given: aString at: aNumber fullToken: aBoolean [

	| pivot string |
	aMorph contents ifNil: [^ {}].
	pivot := (aMorph orOwnerSuchThat: [:m | m owner = aBlock]) ifNil: [^ {}].
	
	"we may only consider owners if they do not introduce additional tokens"
	aMorph contents = pivot sourceString ifFalse: [^ {}].
	
	string := aNumber = self class endIndex
		ifTrue: [pivot contents, aString]
		ifFalse: [(pivot contents first: aNumber - 1), aString, (pivot contents allButFirst: aNumber - 1)].
	
	^ (SBTSInputParser new
		matchFullToken: aBoolean;
		optionsFor: pivot owner
			given: string
			before: ((aBlock submorphs first: pivot submorphIndex - 1) select: #keepDuringTransform)
			after: ((aBlock submorphs allButFirst: pivot submorphIndex) select: #keepDuringTransform)) collect: [:blocks |
		SBReplaceMultipleCommand new
			target: pivot owner replacers: blocks;
			shouldMergeWithNext: true]
]

{ #category : #reconciliation }
SBTSInputReconcile >> trySeparator: aString in: aBlock [

	aBlock owner isTSBlock ifFalse: [^ {}].
	
	(aBlock owner slot delimiterBetween: aBlock and: aBlock) ifNotEmpty: [:delimiter | delimiter = aString ifTrue: [^ {(aBlock sandblockEditor cursor positionAfter: aBlock) command}]].
	^ {}
]

{ #category : #reconciliation }
SBTSInputReconcile >> trySkipLabel: aString in: aBlock from: aMorph at: aNumber [

	(aMorph isTextMorph and: [aMorph contents = aString and: [aNumber < (aMorph contents size + 1)]]) ifTrue: [^ {SBDoItCommand new do: [aMorph]}].
	
	self
		positionsAfter: aBlock
		from: aMorph
		do: [:position | (position isText and: [position textMorph contents = aString and: [position textMorph ~= aMorph]]) ifTrue: [^ {SBDoItCommand new do: [position textMorph]}]].
	
	^ {}
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryWrap: aBlock given: aString before: aBoolean [

	| get considerOwner |
	get := [:root |
		(SBTSInputParser new
			optionsFor: root
			given: aString
			before: (aBoolean ifTrue: [{}] ifFalse: [{root}])
			after: (aBoolean ifTrue: [{root}] ifFalse: [{}])) collect: [:blocks |
			SBReplaceMultipleCommand new
				target: root replacers: blocks;
				shouldMergeWithNext: true]].
	
	"if we have a left associative parent, we should always also check the owner for options, otherwise we risk committing too early to a local solution. For example, consider _+_ and _++ in e.g. C"
	considerOwner := aBlock slot firstNode
		parentPrecedence: aBlock slot nodes
		do: [:node :isLeftMost | isLeftMost not]
		ifNone: [false].
	
	^ (get value: aBlock), (considerOwner ifTrue: [get value: aBlock owner] ifFalse: [{}])
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryWrapOrReinterpret: aBlock from: aMorph given: aString at: aNumber [

	| atBorder reinterpret wrap |
	"consider 2+3 and the input '+' on the 3.
Here, if we do reinterpret first, the 3 will be stringified. Instead, we want to keep the three by trying wrap first, if the input happened at the very border of the source block."
	wrap := [self tryWrap: aBlock given: aString before: aNumber = 1].
	reinterpret := [self tryReinterpretFrom: aMorph in: aBlock given: aString at: aNumber].
	
	atBorder := (aMorph contents isNil or: [aMorph contents isEmpty]) not and: [aNumber = 1 or: [aNumber > aMorph contents size]].
	
	^ (atBorder and: [aBlock language transitionPairs noneSatisfy: [:pair | pair key = aBlock type]])
		ifTrue: [wrap value ifEmpty: reinterpret]
		ifFalse: [reinterpret value ifEmpty: wrap]
]

{ #category : #callbacks }
SBTSInputReconcile >> updateChoices [

	self contents ifEmpty: [
		currentChoices := {}.
		^ self].
	
	currentChoices := self findOptionsBlock cull: self cull: self contents.
	
	SBToggledCode comment: '' active: 1 do: {
		[(currentChoices size = 1 and: [insertIndex > 1 or: [currentChoices first isKindOf: SBDoItCommand]]) ifTrue: [self applyCommand: currentChoices anyOne]]}
]
