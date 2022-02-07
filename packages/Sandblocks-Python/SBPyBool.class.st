"
Replaces all python booleans with checkboxes.
"
Class {
	#name : #SBPyBool,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyBool class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '[(true) (false)] @bool' sample: 'True'>

	(aDictionary at: 'bool') type = 'true'
		ifTrue: [^ aBlock value: (aDictionary at: 'bool') value: (self new factory: (aDictionary at: 'bool') factory; replaceWithChecked: true)]
		ifFalse: [^ aBlock value: (aDictionary at: 'bool') value: (self new factory: (aDictionary at: 'bool') factory; replaceWithChecked: false)].
]

{ #category : #'initialize-release' }
SBPyBool >> replaceWithChecked: aBoolean [ 
	self addMorphBack: (SBCheckbox new value: aBoolean)
]

{ #category : #'initialize-release' }
SBPyBool >> writeSourceOn: aStream [
	self firstSubmorph value ifTrue: [aStream nextPutAll: 'True'] ifFalse: [aStream nextPutAll: 'False'].
]
