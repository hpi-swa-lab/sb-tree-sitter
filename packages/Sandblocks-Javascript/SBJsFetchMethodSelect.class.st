Class {
	#name : #SBJsFetchMethodSelect,
	#superclass : #SBMethodSelect,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetchMethodSelect >> initialize [
	super initialize
]

{ #category : #'as yet unclassified' }
SBJsFetchMethodSelect >> promptChangeValue [

	| index |
	index := UIManager default chooseFrom: self values.
	index > 0 ifTrue: [
		self sandblockEditor do: (SBMutatePropertyCommand new
			target: self;
			selector: #object;
			value: (self values at: index)).
		self owner owner method: (self values at: index).
		self owner owner recreateFromMorphs]
]
