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

	| index key jsfetch |
	index := UIManager default chooseFrom: self values.
	index > 0 ifTrue: [
		key := self values at: index.
		jsfetch := self owner owner owner.
		key = 'Remove param' ifTrue: [
			jsfetch headers removeKey: (self owner submorphs first contents) ifAbsent: [].
			self owner delete].
		jsfetch recreate: (jsfetch method)].
]

{ #category : #'as yet unclassified' }
SBJsFetchParamTextBubble >> values [

	^ #('Remove param')
]
