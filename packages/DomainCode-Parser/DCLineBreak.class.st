Class {
	#name : #DCLineBreak,
	#superclass : #DCText,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCLineBreak >> getIndentString [

	| s current |
	s := ''.
	current := self submorphAfter.
	[current notNil and: [current isExtra]] whileTrue: [
		s := s, current contents.
		current := current submorphAfter].
	^ s
]

{ #category : #nil }
DCLineBreak >> isLineBreak [

	^ true
]

{ #category : #'as yet unclassified' }
DCLineBreak >> keyStroke: anEvent [

	self halt
]

{ #category : #'as yet unclassified' }
DCLineBreak >> printOn: aStream [

	aStream nextPutAll: '<linebreak>'
]

{ #category : #'as yet unclassified' }
DCLineBreak >> treeLabel [

	^ String lf
]

{ #category : #'as yet unclassified' }
DCLineBreak >> type [

	^ ''
]
