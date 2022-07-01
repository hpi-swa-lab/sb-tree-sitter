Class {
	#name : #SBTSInputReconcile,
	#superclass : #SBPopup,
	#instVars : [
		'target',
		'before',
		'currentChoices',
		'findOptionsBlock'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'reconciliation helper' }
SBTSInputReconcile >> applyCommand: aCommand [

	target sandblockEditor do: aCommand.
	self positionCursorIn: aCommand morphs
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

	^ findOptionsBlock ifNil: [[self tryReconcileFor: target input: self contents in: target containingSandblock before: before]]
]

{ #category : #accessing }
SBTSInputReconcile >> findOptionsBlock: aBlock [

	findOptionsBlock := aBlock
]

{ #category : #'initialize-release' }
SBTSInputReconcile >> for: aTextMorph input: aString before: aBoolean [

	target := aTextMorph.
	before := aBoolean.
	
	self
		contents: aString;
		showBelow: aTextMorph closeOnDeselect: true;
		moveCursorToEnd;
		queueUpdateSuggestionsFocused: true.
	
	self updateChoices
]

{ #category : #'initialize-release' }
SBTSInputReconcile >> initialize [

	super initialize.
	self addMorphBack: (SBOwnTextMorph new when: #contentsChanged send: #contentsChanged to: self)
]

{ #category : #'reconciliation helper' }
SBTSInputReconcile >> optionsForInsert: aPosition given: aString [

	^ (SBTSInputParser new optionsForTemplate: aPosition command element given: aString) collect: [:blocks | aPosition command copy morphs: blocks]
]

{ #category : #'reconciliation helper' }
SBTSInputReconcile >> positionCursorIn: aCollection [

	| all positionInAll stopIndex |
	(before ifNil: [false]) ifTrue: [^ aCollection first startInputAtStart].
	all := Array streamContents: [:s | aCollection do: [:block | block allMorphsPreorderDo: [:m | s nextPut: m]]].
	stopIndex := all findLast: [:m | m valueOfProperty: #lastConstructed ifAbsent: [false]].
	stopIndex > 0 ifTrue: [
		aCollection do: [:m | m allMorphsDo: [:i | i removeProperty: #lastConstructed]].
		(all at: stopIndex) containingSandblock valid ifFalse: [^ (all at: stopIndex) containingSandblock startInputAtEnd].
		positionInAll := [:cursor |
			cursor isInsert
				ifTrue: [ | childIndex |
					childIndex := all findFirst: [:m | m = cursor container or: [m owner = cursor container]].
					childIndex + (((cursor container submorphs copyFrom: 1 to: cursor command insertIndex - 1) collect: #recursiveSubmorphCount)
						inject: 0
						into: [:s :c | s + c]) + 1]
				ifFalse: [
					"if we are in a finished label, just return our index so that the next position will be taken.
					otherwise, we will likely want to continue typing here, so pretend that we were one index further out"
					(all indexOf: cursor block currentTextMorph) + (cursor block currentTextMorph slot firstNode isTSLabel
						ifTrue: [0]
						ifFalse: [1])]].
		aCollection do: [:block |
			block cursorPositionsDo: [:cursor |
				(((cursor isInsert and: [(cursor command element hasParentThat: [:p | p isTSRepeat and: [p required or: [p multiple not]]]) not]) or: [cursor isText]) and: [(positionInAll value: cursor) > stopIndex]) ifTrue: [
					block sandblockEditor cursor
						cursorPosition: (cursor placeAtEnd: true)
						explicitMove: false
						axis: #none.
					"if we completed a keyword and the input finished at the very boundary of the block, move one to the right to facilitate continuing to type (may be replaced with a post-do action, mostly need in tryFill with separators)"
					(self contents notEmpty and: [self contents last = $  and: [block = block lastDeepChild containingSandblock]]) ifTrue: [block sandblockEditor performForSelection: #moveCursorRight].
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
SBTSInputReconcile >> positionsAfter: aBlock do: aClosure [

	| foundSelf foundContainer |
	foundSelf := false.
	foundContainer := false.
	aBlock owner isTSBlock ifFalse: [^ self].
	aBlock owner cursorPositionsDo: [:position |
		(foundSelf and: [position isInsert or: [position isText and: [position block wantsInput]]]) ifTrue: [aClosure value: position].
		position block = aBlock containingSandblock ifTrue: [foundContainer := true].
		(position isText and: [position block = aBlock containingSandblock]) ifTrue: [foundSelf := true]]
]

{ #category : #accessing }
SBTSInputReconcile >> suggestAlways [

	^ true
]

{ #category : #suggestions }
SBTSInputReconcile >> suggestions [

	^ (currentChoices ifNil: [{}]) collect: [:command | SBTSBlockSuggestion new blocks: command in: self sandblockEditor popup: self]
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryAdjacentTo: aBlock given: aString [

	self positionsAfter: aBlock do: [:position |
		(position isText and: [position block wantsInput]) ifTrue: ["TODO: do we want the full reconciliation logic or just reinterpret?"
		^ self tryReinterpretFrom: position textMorph in: position block given: aString before: false].
		position isInsert ifTrue: [(self optionsForInsert: position given: aString) ifNotEmpty: [:res | ^ res]]].
	^ {}
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryReconcileFor: aMorph input: aString in: aBlock before: aBoolean [
	"recursive stop condition: either our owner is no longer a ts-block or we have already gone two steps. two steps were enough for all valid scenarios we have encountered thus far."

	aBlock isTSBlock ifFalse: [^ {}].
	(aMorph ownerChain indexOf: aBlock) > 3 ifTrue: [^ {}].
	
	^ aBoolean
		ifTrue: [(self tryReinterpretFrom: aMorph in: aBlock given: aString before: true) ifEmpty: [self tryWrap: aBlock given: aString before: true]]
		ifFalse: [(self trySeparator: aString in: aBlock) ifEmpty: [(self tryReinterpretFrom: aMorph in: aBlock given: aString before: false) ifEmpty: [(self tryWrap: aBlock given: aString before: false) ifEmpty: [(self tryAdjacentTo: aBlock given: aString) ifEmpty: [self tryReconcileFor: aMorph input: aString in: aBlock owner before: false]]]]]
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryReinterpretFrom: aMorph in: aBlock given: aString before: aBoolean [

	| pivot |
	aMorph contents ifNil: [^ {}].
	pivot := (aMorph orOwnerSuchThat: [:m | m owner = aBlock]) ifNil: [^ {}].
	
	"we may only consider owners if they do not introduce additional tokens"
	aMorph contents = pivot sourceString ifFalse: [^ {}].
	
	^ (SBTSInputParser new
		optionsFor: pivot owner
		given: (aBoolean ifTrue: [aString, aMorph contents] ifFalse: [aMorph contents, aString])
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
SBTSInputReconcile >> tryWrap: aBlock given: aString before: aBoolean [

	^ (SBTSInputParser new
		optionsFor: aBlock
		given: aString
		before: (aBoolean ifTrue: [{}] ifFalse: [{aBlock}])
		after: (aBoolean ifTrue: [{aBlock}] ifFalse: [{}])) collect: [:blocks |
		SBReplaceMultipleCommand new
			target: aBlock replacers: blocks;
			shouldMergeWithNext: true]
]

{ #category : #callbacks }
SBTSInputReconcile >> updateChoices [

	self contents ifEmpty: [
		currentChoices := {}.
		^ self].
	
	currentChoices := self findOptionsBlock cull: self cull: self contents.
	
	(currentChoices size = 1 and: [before not]) ifTrue: [self applyCommand: currentChoices anyOne]
]
