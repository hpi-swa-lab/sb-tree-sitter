"
A SBReNamedCapturingGroup replaces a named capturing group.
"
Class {
	#name : #SBReNamedCapturingGroup,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Regex'
}

{ #category : #matchers }
SBReNamedCapturingGroup class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(named_capturing_group
	(group_name) @name
	(pattern) @pattern
) @group'>

	^ aBlock
		value: (aDictionary at: 'group')
		value: (self new pattern: (aDictionary at: 'pattern');
						name: ((aDictionary at: 'name') submorphs first contents))
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
