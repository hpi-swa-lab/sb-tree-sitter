"
A SBReComment is an inline comment in a regex.

It enables users to add inline explanations of the intent of a pattern.

You can use the Ctrl+M shortcut to wrap the currently selected block with an evaluator.
"
Class {
	#name : #SBReComment,
	#superclass : #SBReEncodedReplacement,
	#instVars : [
		'comment'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReComment >> build [

	self
		addMorphBack: (self createBindingBlock: 'pattern');
		addMorphBack: (SBColumn new
			addMorphBack: (comment := self
				createBindingFor: 'annotation'
				build: [:annotation |
					SBTextBubble multiLine
						placeholderText: 'comment';
						contents: annotation]
				update: [:c :m | m contents]);
			addMorphBack: (SBButton new
				balloonText: 'collapse';
				icon: SBIcon iconMinus shortcut: nil do: [self collapseBlock]))
]

{ #category : #accessing }
SBReComment >> collapsedContent [

	^ comment contents
]
