Class {
	#name : #SBJsRequestToolParamTextBubble,
	#superclass : #SBJsRequestToolTextBubble,
	#category : #'Sandblocks-RequestsTool'
}

{ #category : #'as yet unclassified' }
SBJsRequestToolParamTextBubble >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
SBJsRequestToolParamTextBubble >> promptChangeValue [

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
SBJsRequestToolParamTextBubble >> values [

	^ #('Remove param')
]
