"
A SBReQuantifier replaces quantifier (*,+,?,{n,m}). Quantifer specify the number of times a preceding element may repeat.

For each quantifier, there is also a lazy variation (achieved by appending a ? to the original quantifier) that causes the quantifier to be lazy instead of greedy. A greedy quantifier consumes as much of the preceding element as possible, while the lazy variant matches as few as possible. The lazy option can be enabled using a checkbox.
"
Class {
	#name : #SBReQuantifier,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Regex'
}

{ #category : #initialization }
SBReQuantifier >> buildLazyToggle [

	self addMorphBack: (SBRow new
		addMorphBack: (self createBinding: [SBCheckbox new] optional: 'lazy' insert: [:c | (c at: 'root') lastInsertPosition]);
		addMorphBack: (SBStringMorph new contents: 'lazy'))
]

{ #category : #initialization }
SBReQuantifier >> initialize [

	super initialize.
	
	self
		changeTableLayout;
		listDirection: #topToBottom
]
