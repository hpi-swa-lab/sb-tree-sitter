Class {
	#name : #SBTSRange,
	#superclass : #Object,
	#instVars : [
		'start',
		'end'
	],
	#category : #'Sandblocks-TreeSitter-Utils'
}

{ #category : #'instance creation' }
SBTSRange class >> fromLSP: aJsonObject [

	^ self
		start: (SBTSPosition fromLSP: (aJsonObject at: 'start'))
		end: ((SBTSPosition fromLSP: (aJsonObject at: 'end')))
]

{ #category : #'instance creation' }
SBTSRange class >> fromLSPWithRange: aJsonObject [

	^ self fromLSP: (aJsonObject at: 'range')
]

{ #category : #'instance creation' }
SBTSRange class >> merging: aCollection [

	| min max |
	min := (aCollection detectMin: [:range | range start index]) start index.
	max := (aCollection detectMax: [:range | range end index]) end index.
	^ SBTSRange start: min size: max - min
]

{ #category : #'instance creation' }
SBTSRange class >> null [

	^ SBTSRange start: SBTSPosition null end: SBTSPosition null
]

{ #category : #'instance creation' }
SBTSRange class >> point: aPoint [

	^ self start: aPoint end: aPoint
]

{ #category : #'instance creation' }
SBTSRange class >> start: aTSPosition end: anotherTSPosition [

	^ self new
		start: aTSPosition;
		end: anotherTSPosition
]

{ #category : #'instance creation' }
SBTSRange class >> start: aNumber size: anotherNumber [

	^ self new
		start: (SBTSPosition line: nil character: nil index: aNumber);
		end: (SBTSPosition line: nil character: nil index: aNumber + anotherNumber)
]

{ #category : #converting }
SBTSRange >> + aDelta [

	^ self class start: self start + aDelta end: self end + aDelta
]

{ #category : #comparing }
SBTSRange >> = anObject [

	self species == anObject species ifFalse: [^ false].
	^ self start = anObject start and: [self end = anObject end]
]

{ #category : #testing }
SBTSRange >> contains: aTSPosition [

	^ self start <= aTSPosition and: [self end >= aTSPosition]
]

{ #category : #'as yet unclassified' }
SBTSRange >> distance: aRange [

	^ (self start distance: aRange start) + (self end distance: aRange end)
]

{ #category : #testing }
SBTSRange >> encompasses: aTSRange [

	^ self start <= aTSRange start and: [self end >= aTSRange end]
]

{ #category : #accessing }
SBTSRange >> end [

	^ end
]

{ #category : #accessing }
SBTSRange >> end: aTSPosition [

	end := aTSPosition
]

{ #category : #converting }
SBTSRange >> forLSP [

	^ Dictionary newFrom: {'start' -> self start forLSP. 'end' -> self end forLSP}
]

{ #category : #comparing }
SBTSRange >> hash [

	^ self start hash bitXor: self end hash
]

{ #category : #testing }
SBTSRange >> isEmpty [

	^ self start = self end
]

{ #category : #'as yet unclassified' }
SBTSRange >> isNull [

	^ self start index = 0 and: [self end index = 0]
]

{ #category : #testing }
SBTSRange >> isSingleLine [

	^ start line = end line
]

{ #category : #converting }
SBTSRange >> map: aBlock [

	^ self class start: (aBlock value: self start) end: (aBlock value: self end)
]

{ #category : #copying }
SBTSRange >> postCopy [

	super postCopy.
	self
		start: self start copy;
		end: self end copy
]

{ #category : #printing }
SBTSRange >> printOn: aStream [

	aStream
		print: self start;
		nextPutAll: '->';
		print: self end
]

{ #category : #accessing }
SBTSRange >> size [

	^ self end index - self start index
]

{ #category : #accessing }
SBTSRange >> start [

	^ start
]

{ #category : #accessing }
SBTSRange >> start: aTSPosition [

	start := aTSPosition
]

{ #category : #'as yet unclassified' }
SBTSRange >> withSize: aNumber [

	^ self copy end: self start + aNumber
]
