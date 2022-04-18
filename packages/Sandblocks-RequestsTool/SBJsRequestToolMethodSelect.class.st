Class {
	#name : #SBJsRequestToolMethodSelect,
	#superclass : #SBComboBox,
	#category : #'Sandblocks-RequestsTool'
}

{ #category : #'as yet unclassified' }
SBJsRequestToolMethodSelect >> display: anObject [

	^ anObject asString asUppercase
]

{ #category : #'as yet unclassified' }
SBJsRequestToolMethodSelect >> initialize [

	super initialize.
	
	self layoutInset: (SBEdgeInsets left: 2 right: 2 top: 1 bottom: 2)
]

{ #category : #'as yet unclassified' }
SBJsRequestToolMethodSelect >> promptChangeValue [

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

{ #category : #'as yet unclassified' }
SBJsRequestToolMethodSelect >> values [

	^ #(#get #put #post #delete #patch #head #options #trace #connect)
]
