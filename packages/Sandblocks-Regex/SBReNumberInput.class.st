Class {
	#name : #SBReNumberInput,
	#superclass : #SBStNumber,
	#instVars : [
		'minimum',
		'maximum',
		'onChange'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReNumberInput >> canDrag [

	^ false
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> contentsChanged [

	"super contentsChanged."
	self onChange ifNotNil: [:c | c value: self value]
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> hint [

	^ self currentTextMorph placeholderText
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> hint: aString [

	self currentTextMorph placeholderText: aString
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> isSmalltalk [

	^ false
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> language [

	^ #regex
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> maximum [

	^ maximum
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> maximum: aNumber [

	maximum := aNumber
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> minimum [

	^ minimum
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> minimum: aNumber [

	minimum := aNumber
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> onChange [

	^ onChange
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> onChange: aBlock [

	onChange := aBlock
]

{ #category : #'as yet unclassified' }
SBReNumberInput >> valid [

	^ super valid
		and: [self value isInteger]
		and: [self minimum ifNil: [true] ifNotNil: [:minimum | minimum <= self value]]
		and: [self maximum ifNil: [true] ifNotNil: [:maximum | self value <= maximum]]
]
