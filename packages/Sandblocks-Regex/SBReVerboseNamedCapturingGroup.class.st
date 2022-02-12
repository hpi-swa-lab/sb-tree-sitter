Class {
	#name : #SBReVerboseNamedCapturingGroup,
	#superclass : #SBReVerboseBlock,
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup class >> matchRegex: aDictionary do: aBlock [
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
SBReVerboseNamedCapturingGroup class >> newFor: aBlock as: aString [

	^ self new
		name: aString;
		pattern: aBlock
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBInlineBlockLabel new label: 'Capture '; factory: self factory);
		addMorphBack: (SBTSUnknown new factory: self factory; template: (self factory getTemplate: 'pattern'));
		addMorphBack: (SBInlineBlockLabel new label: ' as '; factory: self factory);
		addMorphBack: (SBRegex build: 'group_name')
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup >> name [

	^ (self submorphs at: 4) contents
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup >> name: aString [

	(self submorphs at: 4) contents: aString
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup >> pattern [

	^ self submorphs at: 2
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup >> pattern: aBlock [

	(self submorphs at: 2) replaceBy: aBlock
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup >> sourceString [

	^ '(?<',
		self name contents,
		'>',
		self pattern sourceString,
		')'
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup >> type [

	^ 'named_capturing_group'
]
