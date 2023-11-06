Class {
	#name : #DCTrueDiff,
	#superclass : #Object,
	#category : #'DomainCode-Truediff'
}

{ #category : #'as yet unclassified' }
DCTrueDiff >> assignSharesFrom: this to: that subtreeReg: aRegistry [

	| thisShare thatShare |
	thisShare := aRegistry assignShare: this.
	thatShare := aRegistry assignShare: that.
	(thisShare = thatShare and: [this isLiterallyEqual: that])
		ifTrue: [self assignTreeFrom: this to: that literalMatch: true]
		ifFalse: [self assignSharesRecurseFrom: this to: that subtreeReg: aRegistry]
]

{ #category : #'as yet unclassified' }
DCTrueDiff >> assignSharesRecurseFrom: this to: that subtreeReg: aRegistry [

	(this type = that type and: [this children size = that children size])
		ifTrue: [
			this share registerAvailableTree: this.
			this children
				with: that children
				do: [:l :r | self assignSharesFrom: l to: r subtreeReg: aRegistry]]
		ifFalse: [
			this allChildrenDo: [:c | aRegistry assignShareAndRegisterTree: c].
			that onlyChildrenDo: [:c | aRegistry assignShare: c]]
]

{ #category : #'as yet unclassified' }
DCTrueDiff >> assignSubtreesFrom: this to: that subtreeReg: aRegistry [

	| queue |
	queue := SortedCollection sortBlock: [:a :b | a treeHeight > b treeHeight].
	queue add: that.
	[queue isEmpty] whileFalse: [ | level nextNodes remainingMatchedNodes unassignedNodes |
		level := queue first treeHeight.
		nextNodes := OrderedCollection new.
		[queue notEmpty and: [queue first treeHeight = level]] whileTrue: [ | next |
			next := queue removeFirst.
			next assigned ifNil: [nextNodes add: next]].
		remainingMatchedNodes := self
			selectAvailableTreeFrom: nextNodes
			literalMatch: true
			subtreeReg: aRegistry.
		unassignedNodes := self
			selectAvailableTreeFrom: remainingMatchedNodes
			literalMatch: false
			subtreeReg: aRegistry.
		unassignedNodes do: [:node | queue addAll: node children]]
]

{ #category : #'as yet unclassified' }
DCTrueDiff >> assignTreeFrom: this to: that literalMatch: aBoolean [

	this share: nil.
	this literalMatch: aBoolean.
	aBoolean
		ifTrue: [
			this assigned: that.
			that assigned: this]
		ifFalse: [self assignTreeRecFrom: this to: that]
]

{ #category : #'as yet unclassified' }
DCTrueDiff >> assignTreeRecFrom: this to: that [

	this assigned: that.
	that assigned: this.
	this children with: that children do: [:l :r | self assignTreeRecFrom: l to: r]
]

{ #category : #'as yet unclassified' }
DCTrueDiff >> compare: this to: that [

	| subtreeReg buffer root |
	subtreeReg := DCSubtreeRegistry new.
	self assignSharesFrom: this to: that subtreeReg: subtreeReg.
	self assignSubtreesFrom: this to: that subtreeReg: subtreeReg.
	buffer := DCEditBuffer new.
	root := self computeEditScriptFrom: this to: that parent: nil parentType: #dcRootType link: 1 edits: buffer.
	buffer apply.
	^ root
]

{ #category : #'as yet unclassified' }
DCTrueDiff >> computeEditScriptFrom: this to: that parent: anotherNode parentType: aSymbol link: aLink edits: anEditBuffer [

	| newTree |
	(this assigned notNil and: [this assigned uri = that uri]) ifTrue: [
		newTree := this literalMatch
			ifTrue: [this]
			ifFalse: [self updateLiteralsFrom: this to: that in: anEditBuffer].
		this assigned: nil.
		^ newTree].
	(this assigned isNil and: [that assigned isNil]) ifTrue: [
		(self
			computeEditScriptRecurseFrom: this
			to: that
			parent: anotherNode
			parentType: aSymbol
			link: aLink
			in: anEditBuffer) ifNotNil: [:new | ^ new]].
	
	anEditBuffer detach: this.
	self unloadUnassigned: this in: anEditBuffer.
	newTree := self loadUnassigned: that in: anEditBuffer.
	anEditBuffer attach: newTree to: anotherNode at: aLink.
	^ newTree
]

{ #category : #'as yet unclassified' }
DCTrueDiff >> computeEditScriptRecurseFrom: this to: that parent: aNode parentType: aSymbol link: aLink in: anEditBuffer [

	^ (this type = that type and: [this children size = that children size])
		ifTrue: [
			this range: that range.
			this children with: that children do: [:thisNode :thatNode | | newNode |
				newNode := self
					computeEditScriptFrom: thisNode
					to: thatNode
					parent: this
					parentType: this type
					link: thisNode siblingIndex
					edits: anEditBuffer
				"thisNode = newNode ifFalse: [thisNode replaceBy: newNode]"].
			this]
		ifFalse: [nil]
]

{ #category : #'as yet unclassified' }
DCTrueDiff >> loadUnassigned: aNode in: anEditBuffer [

	^ aNode assigned
		ifNotNil: [self updateLiteralsFrom: aNode assigned to: aNode in: anEditBuffer]
		ifNil: [ | parent |
			parent := aNode shallowCopyBlock.
			aNode children withIndexDo: [:c :index | anEditBuffer attach: (self loadUnassigned: c in: anEditBuffer) to: parent at: index].
			parent]
]

{ #category : #'as yet unclassified' }
DCTrueDiff >> selectAvailableTreeFrom: aCollection literalMatch: aBoolean subtreeReg: aRegistry [

	^ aCollection select: [:node |
		node assigned ifNotNil: [false] ifNil: [
			(node share takeAvailableTree: node preferred: aBoolean subtreeReg: aRegistry)
				ifNotNil: [:availableTree |
					self assignTreeFrom: availableTree to: node literalMatch: aBoolean.
					false]
				ifNil: [true]]]
]

{ #category : #'as yet unclassified' }
DCTrueDiff >> unloadUnassigned: aNode in: anEditBuffer [

	aNode assigned ifNotNil: [aNode assigned: nil] ifNil: [
		anEditBuffer remove: aNode.
		aNode children do: [:c | self unloadUnassigned: c in: anEditBuffer]]
]

{ #category : #'as yet unclassified' }
DCTrueDiff >> updateLiteralsFrom: this to: that in: anEditBuffer [

	this range: that range.
	this treeLabel = that treeLabel ifFalse: [anEditBuffer update: this to: that contents].
	this children
		with: that children
		do: [:l :r | self updateLiteralsFrom: l to: r in: anEditBuffer].
	^ this
]
