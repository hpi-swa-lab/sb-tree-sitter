"
A SBReComment is an inline comment in a regex.
"
Class {
	#name : #SBReComment,
	#superclass : #SBReAnnotation,
	#instVars : [
		'comment'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #accessing }
SBReComment >> annotation [

	^ comment contents
]

{ #category : #accessing }
SBReComment >> annotation: aString [

	comment contents: aString
]

{ #category : #accessing }
SBReComment >> collapsedContent [

	^ self annotation
]

{ #category : #accessing }
SBReComment >> color [

	^ Color lightGray
]

{ #category : #initialization }
SBReComment >> initialize [

	super initialize.
	
	self
		addMorphBack: self pattern;
		addMorphBack: (SBColumn new
			addMorphBack: (comment := SBTextBubble multiLine
				placeholderText: 'comment');
			addMorphBack: (SBButton new
				balloonText: 'collapse';
				icon: SBIcon iconMinus
				shortcut: nil
				do: [self collapseBlock]))
]
