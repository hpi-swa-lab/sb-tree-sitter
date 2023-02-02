Class {
	#name : #SBTSQuerySequence,
	#superclass : #SBTSQueryNode,
	#instVars : [
		'type',
		'elements'
	],
	#category : #'Sandblocks-TreeSitter-Query'
}

{ #category : #'as yet unclassified' }
SBTSQuerySequence >> elements [

	^ elements
]

{ #category : #'as yet unclassified' }
SBTSQuerySequence >> elements: aCollection [

	elements := aCollection
]

{ #category : #'as yet unclassified' }
SBTSQuerySequence >> evaluateAgainst: aBlock captures: aDictionary [

	| exprs blocks localCaptures |
	exprs := self elements readStream.
	blocks := OrderedCollection withAll: (aBlock childrenForQuery select: [:c | c language = aBlock language]).
	localCaptures := OrderedCollection new.
	
	[exprs atEnd] whileFalse: [ | expr nextBlocks |
		expr := exprs next.
		" no support for anchor . yet "
		self flag: #todo.
		((expr isKindOf: SBTSQueryElement) and: [expr contents = '.']) ifFalse: [ | anyMatch |
			nextBlocks := expr requiresField
				ifNotNil: [:field | blocks select: [:child | child field = field]]
				ifNil: [blocks copy].
			
			anyMatch := false.
			nextBlocks do: [:nextBlock | | captures |
				captures := OrderedCollection new.
				(expr evaluateAgainst: nextBlock captures: captures) ifNotNil: [
					localCaptures addAll: captures.
					SBToggledCode comment: '' active: 0 do: {[blocks remove: nextBlock]}.
					anyMatch := true]].
			(anyMatch not and: [expr isOptional not]) ifTrue: [^ nil]]].
	
	exprs atEnd ifFalse: [^ nil].
	aDictionary addAll: localCaptures.
	
	^ aBlock childrenForQuery ifNotEmpty: [:l | l first] ifEmpty: [nil]
]

{ #category : #'as yet unclassified' }
SBTSQuerySequence >> predicatesOn: stream [

	self elements do: [:el | el predicatesOn: stream]
]
