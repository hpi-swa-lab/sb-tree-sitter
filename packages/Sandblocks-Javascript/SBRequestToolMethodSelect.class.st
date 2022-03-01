"
Subclass of Combobox which is used to switch between HTTP methods.
"
Class {
	#name : #SBRequestToolMethodSelect,
	#superclass : #SBComboBox,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'initialize-release' }
SBRequestToolMethodSelect >> display: anObject [

	^ anObject asString asUppercase
]

{ #category : #'initialize-release' }
SBRequestToolMethodSelect >> initialize [

	super initialize.
	
	self layoutInset: (SBEdgeInsets left: 2 right: 2 top: 1 bottom: 2)
]

{ #category : #'initialize-release' }
SBRequestToolMethodSelect >> promptChangeValue [

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

{ #category : #accessing }
SBRequestToolMethodSelect >> values [

	^ #(#get #put #post #delete #patch #head #options #trace #connect)
]
