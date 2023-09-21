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
		layoutPolicy: SBAlgebraLayout new;
		addMorphBack: (comment := self
			createBindingFor: 'annotation'
			build: [:annotation |
				SBTextBubble multiLine
					italic;
					placeholderText: 'comment';
					contents: annotation]
			update: [:c :m | m contents]);
		addMorphBack: (SBButton new
			makeSmall;
			balloonText: 'collapse';
			icon: SBIcon iconMinus shortcut: nil do: [self collapseBlock]);
		addMorphBack: (self createBindingBlock: 'pattern')
]

{ #category : #accessing }
SBReComment >> collapsedContent [

	^ comment contents
]

{ #category : #'as yet unclassified' }
SBReComment >> layoutCommands [

	^ SBAlgebraCommand container
		data: {
			self submorphs first layoutCommands.
			self submorphs second layoutCommands.
			SBAlgebraCommand hardLine.
			self submorphs third layoutCommands};
		morph: self
]
