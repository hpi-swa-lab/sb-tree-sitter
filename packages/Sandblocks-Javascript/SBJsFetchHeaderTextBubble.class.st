Class {
	#name : #SBJsFetchHeaderTextBubble,
	#superclass : #SBJsFetchTextBubble,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetchHeaderTextBubble >> drawnColor [
	^Color red.
]

{ #category : #'as yet unclassified' }
SBJsFetchHeaderTextBubble >> foregroundColor [

	^ Color green.
]

{ #category : #'as yet unclassified' }
SBJsFetchHeaderTextBubble >> initialize [
	super initialize.
	self colored: true.
	self color: Color green.
]

{ #category : #'as yet unclassified' }
SBJsFetchHeaderTextBubble >> promptChangeValue [

	| index key jsfetch |
	index := UIManager default chooseFrom: self values.
	
	index > 0 ifTrue: [
		key := self values at: index.
		jsfetch := self owner owner owner.
		key ~= 'Remove header' ifTrue: [self contents: key].
		key = 'Remove header' ifTrue: [
			jsfetch headers removeKey: (self owner submorphs first contents) ifAbsent: [].
			self owner delete].
		jsfetch recreate: (jsfetch method).]
]

{ #category : #'as yet unclassified' }
SBJsFetchHeaderTextBubble >> values [

	^ #('Content-Type' 'Authorization' 'Cache-Control' 'Origin' 'Content-Length' 'Remove header')
]
