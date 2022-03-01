"
SBReNumberInput modifies the SBStNumber and adds minimum and maximum and on change callback functionality.
"
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

{ #category : #'event handling' }
SBReNumberInput >> acceptInputEvent: anEvent [

	anEvent keyCharacter isDigit
		ifTrue: [super acceptInputEvent: anEvent]
]

{ #category : #accessing }
SBReNumberInput >> canDrag [

	^ false
]

{ #category : #accessing }
SBReNumberInput >> contents: aString [

	aString asNumber negative
		ifTrue: [self contents: 0 asString]
		ifFalse: [super contents: aString asInteger asString]
]

{ #category : #updating }
SBReNumberInput >> contentsChanged [

	"super contentsChanged."
	self onChange ifNotNil: [:c | c value: self value]
]

{ #category : #accessing }
SBReNumberInput >> hint [

	^ self currentTextMorph placeholderText
]

{ #category : #accessing }
SBReNumberInput >> hint: aString [

	self currentTextMorph placeholderText: aString
]

{ #category : #testing }
SBReNumberInput >> isSmalltalk [

	^ false
]

{ #category : #accessing }
SBReNumberInput >> language [

	^ #regex
]

{ #category : #accessing }
SBReNumberInput >> maximum [

	^ maximum
]

{ #category : #accessing }
SBReNumberInput >> maximum: aNumber [

	maximum := aNumber
]

{ #category : #accessing }
SBReNumberInput >> minimum [

	^ minimum
]

{ #category : #accessing }
SBReNumberInput >> minimum: aNumber [

	minimum := aNumber
]

{ #category : #accessing }
SBReNumberInput >> onChange [

	^ onChange
]

{ #category : #accessing }
SBReNumberInput >> onChange: aBlock [

	onChange := aBlock
]

{ #category : #testing }
SBReNumberInput >> valid [

	^ super valid
		and: [self value isInteger]
		and: [self minimum ifNil: [true] ifNotNil: [:minimum | minimum <= self value]]
		and: [self maximum ifNil: [true] ifNotNil: [:maximum | self value <= maximum]]
]
