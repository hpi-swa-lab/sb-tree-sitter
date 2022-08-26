Class {
	#name : #SBTSInputReconcile,
	#superclass : #SBPopup,
	#instVars : [
		'target',
		'currentChoices',
		'findOptionsBlock',
		'insertIndex',
		'explicitAppend'
	],
	#classVars : [
		'PreferNoPopup'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSInputReconcile class >> endIndex [

	^ 900000000
]

{ #category : #'as yet unclassified' }
SBTSInputReconcile class >> preferNoPopup [

	^ PreferNoPopup ifNil: [false]
]

{ #category : #'as yet unclassified' }
SBTSInputReconcile class >> preferNoPopup: aBoolean [

	PreferNoPopup := aBoolean
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
SBTSInputReconcile >> explicitAppend: aBoolean [

	explicitAppend := aBoolean
]

{ #category : #accessing }
SBTSInputReconcile >> findOptionsBlock [

	^ findOptionsBlock ifNil: [
		[
			self
				tryReconcileFor: target
				input: self contents
				in: target containingSandblock
				at: insertIndex
				explicitAppend: (explicitAppend ifNil: [false])]]
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
		ifFalse: [
			"if we are in a finished label, just return our index so that the next position will be taken. otherwise, we will likely want to continue typing here, so pretend that we were one index further out"
			(aCollectionOfMorphs indexOf: aCursor morph) + ((SBToggledCode comment: '' active: 1 do: {[false]. [aCursor morph slot firstNode isTSLabel]})
				ifTrue: [-1]
				ifFalse: [1])]
]

{ #category : #'initialize-release' }
SBTSInputReconcile >> initialize [

	super initialize.
	self addMorphBack: (SBOwnTextMorph new
		when: #contentsChanged send: #contentsChanged to: self;
		placeholderText: 'Add characters ...')
]

{ #category : #'as yet unclassified' }
SBTSInputReconcile >> objectInterface [

	^ SBInterfaces never
]

{ #category : #'reconciliation helper' }
SBTSInputReconcile >> optionsForInsert: aPosition given: aString [

	| next boundaryChar |
	next := aPosition adjacentPosition: 1 in: aPosition block sandblockEditor.
	boundaryChar := next isText ifTrue: [next morph contents ifNotEmpty: #first].
	^ (SBTSInputParser new
		validCondition: [:p | p atEnd or: [p stream next = boundaryChar and: [p stream atEnd]]];
		optionsForTemplate: aPosition command element given: aString) collect: [:blocks | aPosition command copy morphs: blocks]
]

{ #category : #'reconciliation helper' }
SBTSInputReconcile >> positionCursorIn: aCollection [

	| all stopIndex |
	insertIndex = 1 ifTrue: [ | block |
		block := aCollection detect: #isSandblock ifNone: [aCollection first containingSandblock].
		^ aCollection first containingSandblock sandblockEditor
			startInput: block
			at: 900000000
			replacingContents: false
			in: block textMorphs first].
	true ifTrue: [ | last |
		last := nil.
		aCollection reverseDo: [:morph | morph allMorphsDo: [:m | (m valueOfProperty: #lastConstructed ifAbsent: [false]) ifTrue: [last := m]]].
		aCollection do: [:m | m allMorphsDo: [:i | i removeProperty: #lastConstructed]].
		last
			ifNil: [
				aCollection last lastCursorPosition ifNotNil: [:position |
					^ aCollection last sandblockEditor cursor
						cursorPosition: (position placeAtEnd: true)
						explicitMove: false
						axis: #none].
				aCollection last isTextMorph ifTrue: [
					^ aCollection last containingSandblock sandblockEditor
						startInput: aCollection last containingSandblock
						at: 900000000
						replacingContents: false
						in: aCollection last]]
			ifNotNil: [
				last containingSandblock cursorPositionsDo: [:pos |
					(pos isText and: [pos textMorph = last]) ifTrue: [
						pos block sandblockEditor cursorPosition: (pos placeAtEnd: true).
						"if we are in a construct that is complete, meaning it's either a label or we typed a delimiter afterwards, we want to move to the best spot to facilitate continuing to type"
						((last slot firstNode isTSLabel and: [last isComplete]) or: [self contents notEmpty and: [(last contents includes: self contents last) not]]) ifTrue: [ | next |
							next := pos block sandblockEditor cursor
								getMoveHorizontal: 1
								wordWise: false.
							"will we stay inside our current expansion? if so, move ahead!"
							(aCollection anySatisfy: [:morph | next block = morph or: [next block hasOwner: morph]]) ifTrue: [
								pos block sandblockEditor cursorPosition: next.
								"if we already expanded something because the slot was required, try and move inside it"
								(next isInsert and: [next command element parent required]) ifTrue: [pos block sandblockEditor performForSelection: #moveCursorRight]]]]]].
		^ self].
	
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
					(SBToggledCode comment: '' active: 1 do: {
						[self contents notEmpty and: [cursor isText and: [(cursor textMorph contents includes: self contents last) not]]].
						[
							block sandblockEditor mode ~= #insert and: [
								self contents notEmpty and: [
									self contents last = $  and: [ | boundary |
										boundary := (all at: stopIndex) containingSandblock.
										boundary = boundary lastDeepChild containingSandblock and: [boundary slot firstNode isTSLabel]]]]]}) ifTrue: [block sandblockEditor performForSelection: #moveCursorRight].
					^ self]]]].
	aCollection last lastCursorPosition ifNotNil: [:position |
		^ aCollection last sandblockEditor cursor
			cursorPosition: (position placeAtEnd: true)
			explicitMove: false
			axis: #none].
	aCollection last isTextMorph ifTrue: [
		^ aCollection last containingSandblock sandblockEditor
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
		(position isText and: [position textMorph contentsForEdit isEmpty]) ifTrue: ["TODO: do we want the full reconciliation logic or just reinterpret?"
		^ self tryReinterpretFrom: position textMorph in: position block given: aString at: self class endIndex].
		position isInsert ifTrue: [(self optionsForInsert: position given: aString) ifNotEmpty: [:res | ^ res]]].
	^ {}
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryReconcileFor: aMorph input: aString in: aBlock at: aNumber explicitAppend: aBoolean [

	aMorph isUnknown ifTrue: [ | validCondition boundary |
		boundary := aMorph submorphAfter.
		validCondition := (boundary ifNotNil: #isTextMorph ifNil: [false])
			ifTrue: [[:p | p atEnd or: [p stream next = boundary contents first and: [p stream atEnd]]]]
			ifFalse: [nil].
		((SBTSInputParser new
			validCondition: validCondition;
			optionsForTemplate: aMorph slot firstNode given: aString) collect: [:blocks | | jumpAfterBoundary |
			jumpAfterBoundary := blocks noneSatisfy: [:b | b lastConstructedChild notNil].
			SBCombinedCommand newWith: {
				SBReplaceMultipleCommand new
					target: aMorph replacers: blocks;
					shouldMergeWithNext: true}, (jumpAfterBoundary
				ifTrue: [{SBTSBoundarySelectCommand new boundary: boundary}]
				ifFalse: [{}])]) ifNotEmpty: [:res | ^ res]].
	
	"recursive stop condition: either our owner is no longer a ts-block or we have already gone two steps. two steps were enough for all valid scenarios we have encountered thus far."
	aBlock isTSBlock ifFalse: [^ {}].
	(aMorph ownerChain indexOf: aBlock) > 5 ifTrue: [^ {}].
	
	^ aNumber = 1
		ifTrue: [
			(self tryWrapOrReinterpret: aBlock from: aMorph given: aString at: aNumber explicitAppend: aBoolean) ifEmpty: [
				aBoolean
					ifTrue: [{}]
					ifFalse: [(self trySkipLabel: aString in: aBlock from: aMorph at: aNumber) ifEmpty: [self trySkipLabel: aString in: aBlock owner from: aMorph at: aNumber]]]]
		ifFalse: [
			(self
				trySeparator: aString
				in: aBlock
				atEnd: aNumber > (aMorph contentsForEdit ifNotNil: [:m | m size] ifNil: [0])) ifEmpty: [(self tryWrapOrReinterpret: aBlock from: aMorph given: aString at: aNumber explicitAppend: aBoolean) ifEmpty: [(self tryAdjacentTo: aBlock given: aString) ifEmpty: [(self trySkipLabel: aString in: aBlock from: aMorph at: aNumber) ifEmpty: [self tryReconcileFor: aMorph input: aString in: aBlock owner at: aNumber explicitAppend: aBoolean]]]]]
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryReinterpretFrom: aMorph in: aBlock given: aString at: aNumber [

	^ self tryReinterpretFrom: aMorph in: aBlock given: aString at: aNumber fullToken: false
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryReinterpretFrom: aMorph in: aBlock given: aString at: aNumber fullToken: aBoolean [

	| pivot string boundary validCondition cursorAtEnd |
	aMorph contents ifNil: [^ {}].
	pivot := (aMorph orOwnerSuchThat: [:m | m owner = aBlock]) ifNil: [^ {}].
	
	"we may only consider owners if they do not introduce additional tokens"
	aMorph contents = pivot sourceString ifFalse: [^ {}].
	
	string := aNumber = self class endIndex
		ifTrue: [pivot contentsForEdit, aString]
		ifFalse: [(pivot contentsForEdit first: aNumber - 1), aString, (pivot contentsForEdit allButFirst: aNumber - 1)].
	
	boundary := pivot owner submorphAfter.
	validCondition := (boundary ifNotNil: #isTextMorph ifNil: [false])
		ifTrue: [[:p | p atEnd or: [p stream next = boundary contents first and: [p stream atEnd]]]]
		ifFalse: [nil].
	
	cursorAtEnd := aNumber >= aMorph contents size.
	^ (SBTSInputParser new
		matchFullToken: aBoolean;
		validCondition: validCondition;
		optionsFor: pivot owner
			given: string
			before: ((aBlock submorphs first: pivot submorphIndex - 1) select: #keepDuringTransform)
			after: ((aBlock submorphs allButFirst: pivot submorphIndex) select: #keepDuringTransform)
			allowMultiple: cursorAtEnd not) collect: [:blocks | | jumpAfterBoundary |
		jumpAfterBoundary := boundary notNil and: [blocks noneSatisfy: [:b | b isTSBlock and: [b lastConstructedChild notNil]]].
		SBCombinedCommand newWith: {
			SBReplaceMultipleCommand new
				target: pivot owner replacers: blocks;
				shouldMergeWithNext: true}, (jumpAfterBoundary
			ifTrue: [{SBTSBoundarySelectCommand new boundary: boundary}]
			ifFalse: [{}])]
]

{ #category : #reconciliation }
SBTSInputReconcile >> trySeparator: aString in: aBlock atEnd: aBoolean [

	aBoolean ifFalse: [^ {}].
	aBlock owner isTSBlock ifFalse: [^ {}].
	
	(aBlock owner slot delimiterBetween: aBlock and: aBlock) ifNotEmpty: [:delimiter | delimiter = aString ifTrue: [^ {(aBlock sandblockEditor cursor positionAfter: aBlock) command}]].
	
	aString = aBlock language statementTerminator ifTrue: [
		aBlock slot allParentsDo: [:node |
			(node isTSSeq and: [node hasStatementTerminator]) ifTrue: [
				^ {
					(aBlock cursorPositionAfterThat: [:pos | (pos isInsert and: [(pos command element hasParent: node) not]) or: [pos isText]]) command}]]].
	
	SBToggledCode comment: '' active: 0 do: {
		[
			aString = aBlock language statementTerminator ifTrue: ["FIXME: might catch too many cases, check for proximity to stmt end morph?"
			^ {SBDoItCommand new}]]}.
	
	^ {}
]

{ #category : #reconciliation }
SBTSInputReconcile >> trySkipLabel: aString in: aBlock from: aMorph at: aNumber [

	(aMorph isTextMorph and: [aMorph contents = aString and: [aNumber < (aMorph contents size + 1)]]) ifTrue: [^ {SBTSBoundarySelectCommand new boundary: aMorph}].
	
	self positionsAfter: aBlock from: aMorph do: [:position |
		(position isText and: [position textMorph contents = aString and: [position textMorph ~= aMorph]]) ifTrue: [ | currentContent currentFixed |
			currentContent := position textMorph contentsForEdit.
			currentFixed := aMorph fixedText.
			^ {
				SBDoItCommand new
					do: [
						position textMorph confirmFixedText.
						position textMorph];
					undo: [
						position textMorph
							contents: currentContent;
							fixedText: currentFixed]}]].
	
	^ {}
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryWrap: aBlock given: aString before: aBoolean [

	| get |
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
	^ Array streamContents: [:stream | | current |
		stream nextPutAll: (get value: aBlock).
		current := aBlock.
		SBToggledCode comment: '' active: 1 do: {
			[
				aBlock allOwnersDo: [:owner | | considerOwner |
					considerOwner := owner isTSBlock and: [
						current slot firstNode
							parentPrecedence: current slot nodes
							do: [:node :isLeftMost :isRightMost | node isLeftAssociative and: [isLeftMost not]]
							ifNone: [false]].
					considerOwner ifTrue: [ | results |
						results := get value: owner.
						stream nextPutAll: (results select: [:res | "TODO we want to only add these results if they actually were involved in a precedence conflict; a simple but insufficient approximation is that they changed at all"
						res morphs size > 1 or: [res morphs first sourceStringForCompare ~= owner sourceStringForCompare]])].
					owner isTSBlock ifTrue: [current := owner]]]}]
]

{ #category : #reconciliation }
SBTSInputReconcile >> tryWrapOrReinterpret: aBlock from: aMorph given: aString at: aNumber explicitAppend: aBoolean [

	| atBorder reinterpret wrap involvedInExplicitTransition extendsToken |
	"consider 2+3 and the input '+' on the 3.
Here, if we do reinterpret first, the 3 will be stringified. Instead, we want to keep the three by trying wrap first, if the input happened at the very border of the source block."
	wrap := [self tryWrap: aBlock given: aString before: aNumber = 1].
	reinterpret := [self tryReinterpretFrom: aMorph in: aBlock given: aString at: aNumber].
	
	aBoolean ifTrue: [^ wrap value].
	
	atBorder := (aMorph contents isNil or: [aMorph contents isEmpty]) not and: [aNumber = 1 or: [aNumber > aMorph contents size]].
	involvedInExplicitTransition := aBlock language transitionPairs anySatisfy: [:pair | pair key = aBlock type].
	extendsToken := aString first isLetter and: [
		(aMorph contents notNil and: [aMorph contents notEmpty])
			ifTrue: [aMorph contents first isLetter]
			ifFalse: [false]].
	
	(atBorder and: [involvedInExplicitTransition not and: [aString first isLetter not and: [extendsToken not]]]) ifTrue: [wrap value ifNotEmpty: [:res | ^ res]].
	^ reinterpret value
]

{ #category : #callbacks }
SBTSInputReconcile >> updateChoices [

	self contents ifEmpty: [
		currentChoices := {}.
		^ self].
	
	SBTSReconstructExperiment reportTime: [currentChoices := self findOptionsBlock cull: self cull: self contents] durationToRun.
	
	SBToggledCode comment: '' active: 1 do: {
		[((currentChoices size = 1 and: [(insertIndex > 1 or: [currentChoices first isKindOf: SBDoItCommand]) or: [target contentsForEdit isNil or: [target contentsForEdit isEmpty]]]) or: [self class preferNoPopup and: [currentChoices notEmpty]]) ifTrue: [self applyCommand: currentChoices first]]}
]
