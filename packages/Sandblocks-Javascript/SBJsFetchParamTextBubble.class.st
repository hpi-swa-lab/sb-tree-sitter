Class {
	#name : #SBJsFetchParamTextBubble,
	#superclass : #SBJsFetchTextBubble,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetchParamTextBubble >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
SBJsFetchParamTextBubble >> promptChangeValue [

	| index key fetch paramsCopy |
	index := UIManager default chooseFrom: self values.
	index > 0 ifTrue: [
		key := self values at: index.
		fetch := self owner owner owner.
		key = 'Remove param' ifTrue: [ 
			paramsCopy := fetch params deepCopy.
			paramsCopy removeKey: ((self owner submorphs first contents) asString, (self owner submorphs second contents) asString) ifAbsent: [].
			fetch params: paramsCopy.
			self owner delete.
			fetch recreateFromMorphs]].
]

{ #category : #'as yet unclassified' }
SBJsFetchParamTextBubble >> values [

	^ #('Remove param')
]
