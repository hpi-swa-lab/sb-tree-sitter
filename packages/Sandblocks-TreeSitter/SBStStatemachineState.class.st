Class {
	#name : #SBStStatemachineState,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBStStatemachineState >> build [
	<lang: #smalltalk match: '(keyword_message (unary_message (identifier) ="SBState") (keyword) ="name:" (string) @name)' sample: 'a

	SBState new name: ''asd'''>

	self addMorphBack: (self createBinding: [SBTextBubble new] contents: 'name')
]
