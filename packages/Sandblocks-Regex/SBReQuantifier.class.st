Class {
	#name : #SBReQuantifier,
	#superclass : #SBReBlock,
	#instVars : [
		'lazy'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReQuantifier >> buildConcrete [
]

{ #category : #'as yet unclassified' }
SBReQuantifier >> buildConcreteOn: aSBRow [

	self buildOn: aSBRow.
	^ aSBRow
]

{ #category : #'as yet unclassified' }
SBReQuantifier >> buildLazyToggleOn: aSBRow [

	^ aSBRow
		addMorphBack: (lazy := SBCheckbox new
			value: false;
			canDrag: false);
		addMorphBack: (SBInlineBlockLabel new
			label: 'lazy';
			factory: self factory;
			canDrag: false);
		yourself
]

{ #category : #'as yet unclassified' }
SBReQuantifier >> buildOn: aSBRow [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBReQuantifier >> initialize [

	super initialize.

	self
		addMorphBack: (self buildConcreteOn: SBRow new);
		addMorphBack: (self buildLazyToggleOn: SBRow new);
		changeTableLayout;
		listDirection: #topToBottom
]

{ #category : #'as yet unclassified' }
SBReQuantifier >> lazy [

	^ lazy value
]

{ #category : #'as yet unclassified' }
SBReQuantifier >> lazy: aBoolean [

	lazy changeValue: aBoolean
]

{ #category : #'as yet unclassified' }
SBReQuantifier >> lazySourceString [

	^ self lazy
		ifTrue: ['?']
		ifFalse: ['']
]

{ #category : #'as yet unclassified' }
SBReQuantifier >> quantifierString [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBReQuantifier >> sourceString [

	^ self quantifierString , self lazySourceString
]
