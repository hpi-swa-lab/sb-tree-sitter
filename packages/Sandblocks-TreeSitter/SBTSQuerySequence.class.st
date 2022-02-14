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
	localCaptures := Dictionary new.
	
	[exprs atEnd] whileFalse: [ | expr nextBlocks |
		expr := exprs next.
		" no support for anchor . yet "
		self flag: #todo.
		((expr isKindOf: SBTSQueryElement) and: [expr contents = '.']) ifFalse: [
			nextBlocks := expr requiresField
				ifNotNil: [:field | | b |
					b := blocks detect: [:child | child field = field] ifNone: [^ nil].
					{b}]
				ifNil: [blocks].
			((nextBlocks notEmpty and: [
				nextBlocks anySatisfy: [:nextBlock | | captures |
					captures := Dictionary new.
					(expr evaluateAgainst: nextBlock captures: captures)
						ifNotNil: [
							localCaptures addAll: captures associations.
							blocks remove: nextBlock.
							true]
						ifNil: [false]]]) not and: [expr isOptional not]) ifTrue: [^ nil]]].
	
	exprs atEnd ifFalse: [^ nil].
	aDictionary addAll: localCaptures associations.
	
	^ aBlock childrenForQuery ifNotEmpty: [:l | l first] ifEmpty: [nil]
]

{ #category : #'as yet unclassified' }
SBTSQuerySequence >> predicatesOn: stream [

	self elements do: [:el | el predicatesOn: stream]
]
