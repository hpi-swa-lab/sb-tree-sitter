Class {
	#name : #SBReVerboseBackreference,
	#superclass : #SBReVerboseBlock,
	#instVars : [
		'group'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBReVerboseBackreference class >> matchRegex: aDictionary do: aBlock [
	<lang: #regex match:
'(backreference_escape
	(group_name) @group
) @backreference'>

	^ aBlock
		value: (aDictionary at: 'backreference')
		value: (self new group: (aDictionary at: 'group') submorphs first contents)
]

{ #category : #'as yet unclassified' }
SBReVerboseBackreference >> group [

	^ group contents
]

{ #category : #'as yet unclassified' }
SBReVerboseBackreference >> group: aString [

	group contents: aString
]

{ #category : #'as yet unclassified' }
SBReVerboseBackreference >> initialize [

	super initialize.
	
	self
		addMorphBack: (SBInlineBlockLabel new label: 'Contents of group: '; factory: self factory);
		addMorphBack: (group := SBRegex build: 'group_name')
]

{ #category : #'as yet unclassified' }
SBReVerboseBackreference >> sourceString [

	^ '\k',
		self group
]

{ #category : #'as yet unclassified' }
SBReVerboseBackreference >> type [

	^ 'backreference_escape'
]
