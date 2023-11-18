Class {
	#name : #DCLayout,
	#superclass : #LayoutPolicy,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCLayout >> layout: aMorph in: newBounds [
]

{ #category : #'as yet unclassified' }
DCLayout >> minExtentOf: aMorph in: newBounds [

	^ (DCLayoutInfo new measureRoot: aMorph at: newBounds topLeft) extent
]
