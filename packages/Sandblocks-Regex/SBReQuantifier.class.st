"
A SBReQuantifier replaces quantifier (*,+,?,{n,m}). Quantifer specify the number of times a preceding element may repeat.

For each quantifier, there is also a lazy variation (achieved by appending a ? to the original quantifier) that causes the quantifier to be lazy instead of greedy. A greedy quantifier consumes as much of the preceding element as possible, while the lazy variant matches as few as possible. The lazy option can be enabled using a checkbox.
"
Class {
	#name : #SBReQuantifier,
	#superclass : #SBReBlock,
	#instVars : [
		'lazy'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #initialization }
SBReQuantifier >> buildConcreteOn: aMorph [

	self buildOn: aMorph.
	^ aMorph
]

{ #category : #initialization }
SBReQuantifier >> buildLazyToggleOn: aMorph [

	^ aMorph
		addMorphBack: (lazy := SBCheckbox new
			value: false;
			canDrag: false);
		addMorphBack: (SBStringMorph new
			contents: 'lazy');
		yourself
]

{ #category : #initialization }
SBReQuantifier >> buildOn: aMorph [

	^ self subclassResponsibility
]

{ #category : #initialization }
SBReQuantifier >> initialize [

	super initialize.

	self
		addMorphBack: (self buildConcreteOn: SBRow new);
		addMorphBack: (self buildLazyToggleOn: SBRow new);
		changeTableLayout;
		listDirection: #topToBottom
]

{ #category : #accessing }
SBReQuantifier >> lazy [

	^ lazy value
]

{ #category : #accessing }
SBReQuantifier >> lazy: aBoolean [

	lazy changeValue: aBoolean
]

{ #category : #printing }
SBReQuantifier >> lazySourceString [

	^ self lazy
		ifTrue: ['?']
		ifFalse: ['']
]

{ #category : #printing }
SBReQuantifier >> quantifierString [

	^ self subclassResponsibility
]

{ #category : #printing }
SBReQuantifier >> sourceString [

	^ self quantifierString , self lazySourceString
]
