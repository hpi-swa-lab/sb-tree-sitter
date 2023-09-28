Class {
	#name : #SBTSPoint,
	#superclass : #ExternalStructure,
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'as yet unclassified' }
SBTSPoint class >> fields [

	^ #(#(#row #'uint32_t') #(#column #'uint32_t'))
]

{ #category : #'as yet unclassified' }
SBTSPoint class >> row: aNumber column: anotherNumber [

	^ self new row: aNumber column: anotherNumber
]

{ #category : #'as yet unclassified' }
SBTSPoint >> = anotherPoint [

	^ self row = anotherPoint row and: [self column = anotherPoint column]
]

{ #category : #'as yet unclassified' }
SBTSPoint >> hash [

	^ self row hash bitXor: self column hash
]

{ #category : #'as yet unclassified' }
SBTSPoint >> printOn: stream [

	stream nextPutAll: 'SBTSPoint[row='.
	stream print: self row.
	stream nextPutAll: ',col='.
	stream print: self column.
	stream nextPut: $]
]

{ #category : #'as yet unclassified' }
SBTSPoint >> row: aNumber column: anotherNumber [

	self row: aNumber.
	self column: anotherNumber
]
