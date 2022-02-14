Class {
	#name : #SBReVerboseQuantifier,
	#superclass : #SBReVerboseBlock,
	#instVars : [
		'lazy'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> buildConcrete [
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> buildConcreteOn: aSBRow [

	self buildOn: aSBRow.
	^ aSBRow
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> buildLazyToggleOn: aSBRow [

	^ aSBRow
		addMorphBack: (lazy := SBCheckbox new
			value: false;
			canDrag: false);
		addMorphBack: (SBInlineBlockLabel new
			label: 'lazy';
			factory: self factory);
		yourself
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> buildOn: aSBRow [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> initialize [

	super initialize.

	self
		addMorphBack: (self buildConcreteOn: SBRow new);
		addMorphBack: (self buildLazyToggleOn: SBRow new);
		changeTableLayout;
		listDirection: #topToBottom
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> lazy [

	^ lazy value
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> lazy: aBoolean [

	lazy changeValue: aBoolean
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> lazySourceString [

	^ self lazy
		ifTrue: ['?']
		ifFalse: ['']
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> quantifierString [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBReVerboseQuantifier >> sourceString [

	^ self quantifierString , self lazySourceString
]
