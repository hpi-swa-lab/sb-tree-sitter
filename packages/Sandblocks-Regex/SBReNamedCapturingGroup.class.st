Class {
	#name : #SBReNamedCapturingGroup,
	#superclass : #SBRePatternWrapper,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
SBReNamedCapturingGroup >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBInlineBlockLabel new
			label: 'Capture ';
			factory: self factory);
		addMorphBack: self pattern;
		addMorphBack: (SBInlineBlockLabel new
			label: ' as ';
			factory: self factory);
		addMorphBack: (SBInlineBlockText new
			regexString: '[A-Za-z0-9]+';
			hint: 'group name';
			factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReNamedCapturingGroup >> name [

	^ (self submorphs at: 4) contents
]

{ #category : #'as yet unclassified' }
SBReNamedCapturingGroup >> name: aString [

	(self submorphs at: 4) contents: aString
]

{ #category : #'as yet unclassified' }
SBReNamedCapturingGroup >> sourceString [

	^ '(?<{1}>{2})'
		format: {self name contents . self pattern sourceString}
]
