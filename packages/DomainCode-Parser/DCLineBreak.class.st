Class {
	#name : #DCLineBreak,
	#superclass : #DCText,
	#category : #'DomainCode-Parser'
}

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
