Class {
	#name : #SBReComment,
	#superclass : #SBReAnnotation,
	#instVars : [
		'comment'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReComment >> annotation [

	^ comment contents
]

{ #category : #'as yet unclassified' }
SBReComment >> annotation: aString [

	comment contents: aString
]

{ #category : #'as yet unclassified' }
SBReComment >> collapsedContent [

	^ self annotation
]

{ #category : #'as yet unclassified' }
SBReComment >> color [

	^ Color lightGray
]

{ #category : #'as yet unclassified' }
SBReComment >> initialize [

	super initialize.
	
	self
		addMorphBack: self pattern;
		addMorphBack: (comment := SBTextBubble multiLine
			placeholderText: 'comment')
]
