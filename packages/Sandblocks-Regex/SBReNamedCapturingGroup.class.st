"
A SBReNamedCapturingGroup replaces a named capturing group.
"
Class {
	#name : #SBReNamedCapturingGroup,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Regex'
}

{ #category : #build }
SBReNamedCapturingGroup class >> newEmpty [

	^ (SBRegex unknownFor: 'named_capturing_group') applyReplacement
]

{ #category : #printing }
SBReNamedCapturingGroup >> build [
	<lang: #regex match: '(named_capturing_group
	(group_name) @name
	(pattern) @pattern
)' sample: '(?<test>123)'>

	self addMorphBack: (SBStringMorph new contents: 'Capture').
	self addMorphBack: (self createBindingBlock: 'pattern').
	self addMorphBack: (SBStringMorph new contents: ' as ').
	self addMorphBack: (self createBinding: [SBTextBubble new] contents: 'name')
]
