"
A SBReNamedCapturingGroup replaces a named capturing group.
"
Class {
	#name : #SBReNamedCapturingGroup,
	#superclass : #SBRePatternWrapper,
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

{ #category : #initialization }
SBReNamedCapturingGroup >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBStringMorph new
			contents: 'Capture ');
		addMorphBack: self pattern;
		addMorphBack: (SBStringMorph new
			contents: ' as ');
		addMorphBack: (SBInlineBlockText new
			regexString: '[A-Za-z0-9]+';
			hint: 'group name';
			factory: self factory)
]

{ #category : #accessing }
SBReNamedCapturingGroup >> name [

	^ (self submorphs at: 4) contents
]

{ #category : #accessing }
SBReNamedCapturingGroup >> name: aString [

	(self submorphs at: 4) contents: aString
]

{ #category : #printing }
SBReNamedCapturingGroup >> sourceString [

	^ '(?<{1}>{2})'
		format: {self name contents . self pattern sourceString}
]
