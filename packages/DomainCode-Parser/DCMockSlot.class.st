Class {
	#name : #DCMockSlot,
	#superclass : #Object,
	#instVars : [
		'morph'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCMockSlot >> addNode: a [

	
]

{ #category : #'as yet unclassified' }
DCMockSlot >> canExpandInStack: aCollection [

	^ true
]

{ #category : #'as yet unclassified' }
DCMockSlot >> firstNode [

	
]

{ #category : #'as yet unclassified' }
DCMockSlot >> for: aMorph [

	morph := aMorph
]

{ #category : #'as yet unclassified' }
DCMockSlot >> indent: aNumber on: aStream [

	aNumber timesRepeat: [
		morph language tabsToSpaces
			ifTrue: [aStream nextPutAll: '    ']
			ifFalse: [aStream tab]]
]

{ #category : #'as yet unclassified' }
DCMockSlot >> isStatementIn: aBlock [

	^ false
]

{ #category : #'as yet unclassified' }
DCMockSlot >> isTSLabel [

	^ morph isTextMorph
]

{ #category : #'as yet unclassified' }
DCMockSlot >> label [

	^ self isTSLabel ifTrue: [morph contents] ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
DCMockSlot >> lastNode [

	^ self
]

{ #category : #'as yet unclassified' }
DCMockSlot >> needsParenthesis: aBlock [

	^ false
]

{ #category : #'as yet unclassified' }
DCMockSlot >> parentThat: aBlock [

	
]

{ #category : #'as yet unclassified' }
DCMockSlot >> preferredColorIn: aColorPolicy for: aHighlightString [
	" specific "

	aHighlightString
		caseOf: {
			['variable.part'] -> [^ aColorPolicy default].
			['variable.builtin'] -> [^ aColorPolicy identifier]}
		otherwise: [].
	
	" general "
	^ (aHighlightString copyUpTo: $.)
		caseOf: {
			['keyword'] -> [aColorPolicy keyword].
			['function'] -> [aColorPolicy identifier].
			['comment'] -> [aColorPolicy defaultLight].
			['punctuation'] -> [aColorPolicy defaultLight].
			['variable'] -> [aColorPolicy identifier].
			['type'] -> [aColorPolicy keyword].
			['number'] -> [aColorPolicy literal].
			['string'] -> [aColorPolicy literal].
			['escape'] -> [aColorPolicy literal].
			['punctuation.bracket'] -> [aColorPolicy builtIn].
			['constant.builtin'] -> [aColorPolicy builtIn].
			['annotation'] -> [aColorPolicy builtIn].
			['operator'] -> [aColorPolicy identifier].
			['property'] -> [aColorPolicy important].
			['major_declaration'] -> [aColorPolicy default].
			['important'] -> [aColorPolicy important]}
		otherwise: [aColorPolicy default]
]

{ #category : #'as yet unclassified' }
DCMockSlot >> repeater [

	^ nil
]

{ #category : #'as yet unclassified' }
DCMockSlot >> replaceLast: aNode [

	
]

{ #category : #'as yet unclassified' }
DCMockSlot >> separatorBetween: aBlock and: anotherBlock indent: aNumber lastCharacterOfFirst: aCharacter [

	SBToggledCode
		comment: ''
		active: 0
		do: {[(self delimiterBetween: aBlock and: anotherBlock) ifNotEmpty: [:delimiter | ^ delimiter]]}.
	(morph language hardLineBreakBetween: aBlock and: anotherBlock) ifTrue: [
		^ String streamContents: [:s |
			s cr.
			self indent: aNumber on: s]].
	(morph language
		spaceBetween: aBlock
		and: anotherBlock
		lastCharacterOfFirst: aCharacter) ifTrue: [^ String space].
	^ ''
]

{ #category : #'as yet unclassified' }
DCMockSlot >> trimNodesToTypeOf: a [

	
]

{ #category : #'as yet unclassified' }
DCMockSlot >> type [

	^ morph type
]

{ #category : #'as yet unclassified' }
DCMockSlot >> updateAllHighlightsFor: aBlock [

	morph language instance grammar hasHighlight ifFalse: [^ #'_sb_none'].
	aBlock allMorphsDo: [:m | m isTSMorph ifTrue: [m highlight: #'_sb_none']].
	aBlock allMorphsBreadthFirstDo: [:m | m isTSMorph ifTrue: [m slot updateHighlightFor: m]].
	^ aBlock highlight
]

{ #category : #'as yet unclassified' }
DCMockSlot >> updateHighlightFor: aBlock [

	morph language instance grammar highlightQuery ifNotNil: [:query | (query executeCaptureAgainst: aBlock) do: [:pair | (pair value highlight isNil or: [pair value highlight = #'_sb_none' or: [(pair value highlight occurrencesOf: '.') < (pair key highlight occurrencesOf: '.')]]) ifTrue: [pair value highlight: pair key]]]
]
