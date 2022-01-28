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
						name: ((aDictionary at: 'name') submorphs first))
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup class >> newFor: aBlock as: aTextBlock [

	^ self new
		name: aTextBlock;
		pattern: aBlock
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBInlineBlockLabel new label: 'Capture '; factory: self factory);
		addMorphBack: (SBTSUnknown new factory: self factory; template: (self factory getTemplate: 'pattern'));
		addMorphBack: (SBInlineBlockLabel new label: ' as '; factory: self factory);
		addMorphBack: (SBInlineBlockText new factory: self factory)
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup >> name [

	^ self submorphs at: 4
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup >> name: aTextBlock [

	(self submorphs at: 4) replaceBy: aTextBlock
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
SBReVerboseNamedCapturingGroup >> type [

	^ 'named_capturing_group'
]

{ #category : #'as yet unclassified' }
SBReVerboseNamedCapturingGroup >> writeSourceOn: aStream [

	aStream
		nextPutAll: '(?<';
		nextPutAll: self name contents;
		nextPutAll: '>';
		nextPutAll: self pattern sourceString;
		nextPutAll: ')'
]
