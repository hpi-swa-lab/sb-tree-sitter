Class {
	#name : #SBTSNodeBase,
	#superclass : #Object,
	#instVars : [
		'field',
		'factory',
		'parent'
	],
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #blocks }
SBTSNodeBase >> allChildrenDo: aBlock [

	self subclassResponsibility
]

{ #category : #hierarchy }
SBTSNodeBase >> allSuperTypesDo: aBlock [

	self parent ifNotNil: [:o | o allSuperTypesDo: aBlock]
]

{ #category : #hierarchy }
SBTSNodeBase >> andParentsDo: aBlock [

	| current |
	current := self.
	[aBlock value: current] doWhileTrue: [(current := current parent) notNil]
]

{ #category : #accessing }
SBTSNodeBase >> bodyTemplate [

	^ self
]

{ #category : #blocks }
SBTSNodeBase >> buildEmpty [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSNodeBase >> buildMorphWith: aBlock slot: aSlot [

	(self factory promotedInlineSymbols includes: self type) ifTrue: [
		self assert: aBlock isString.
		^ SBTSTextMorph new contents: aBlock].
	
	(self factory isBlockInlined: aBlock type) ifTrue: [
		aBlock submorphs do: [:m | aSlot nodes do: [:n | m slot addNode: n]].
		^ aBlock submorphs].
	
	^ aBlock slot: aSlot
]

{ #category : #testing }
SBTSNodeBase >> compatibleWithType: aSymbol [

	^ factory type: self type compatibleWith: aSymbol
]

{ #category : #blocks }
SBTSNodeBase >> cursorPositionsDo: aClosure shallow: aBoolean blocks: aStream parent: aBlock [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSNodeBase >> factory [

	^ factory
]

{ #category : #accessing }
SBTSNodeBase >> factory: aFactory [

	factory := aFactory
]

{ #category : #accessing }
SBTSNodeBase >> field [

	^ field
]

{ #category : #accessing }
SBTSNodeBase >> field: aString [

	field := aString
]

{ #category : #hierarchy }
SBTSNodeBase >> hasParent: aNode [

	self andParentsDo: [:p | p = aNode ifTrue: [^ true]].
	^ false
]

{ #category : #hierarchy }
SBTSNodeBase >> hasParentThat: aBlock [

	self andParentsDo: [:p | (aBlock value: p) ifTrue: [^ true]].
	^ false
]

{ #category : #testing }
SBTSNodeBase >> isBlockInlined [

	^ factory isBlockInlined: self type
]

{ #category : #testing }
SBTSNodeBase >> isInlined [

	^ self isSuperType or: [self isBlockInlined]
]

{ #category : #testing }
SBTSNodeBase >> isSuperType [

	^ factory isSuperType: self type
]

{ #category : #testing }
SBTSNodeBase >> isTSAlias [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSChoice [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSLabel [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSNode [

	^ true
]

{ #category : #testing }
SBTSNodeBase >> isTSOptional [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSRepeat [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSSeq [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSSymbol [

	^ false
]

{ #category : #testing }
SBTSNodeBase >> isTSText [

	^ false
]

{ #category : #accessing }
SBTSNodeBase >> language [

	^ self factory name
]

{ #category : #accessing }
SBTSNodeBase >> parent [

	^ parent
]

{ #category : #accessing }
SBTSNodeBase >> parent: aNode [

	parent := aNode
]

{ #category : #hierarchy }
SBTSNodeBase >> parentThat: aBlock [

	self andParentsDo: [:p | (aBlock value: p) ifTrue: [^ p]].
	^ nil
]

{ #category : #parsing }
SBTSNodeBase >> resultsFor: aParser [

	^ self subclassResponsibility
]

{ #category : #hierarchy }
SBTSNodeBase >> root [

	^ self parent ifNil: [self] ifNotNil: [:p | p root]
]

{ #category : #parsing }
SBTSNodeBase >> takeNodesFrom: aParser [

	^ self subclassResponsibility
]

{ #category : #hierarchy }
SBTSNodeBase >> transitionRoot [

	| current |
	current := self.
	[current parent notNil and: [current parent isTSChoice]] whileTrue: [current := current parent].
	^ current
]

{ #category : #hierarchy }
SBTSNodeBase >> traverseBlocks: aStream do: aBlock [

	^ self subclassResponsibility
]

{ #category : #accessing }
SBTSNodeBase >> type [

	^ nil
]
