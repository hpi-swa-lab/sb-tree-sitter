Class {
	#name : #SBPyFilePath,
	#superclass : #SBTSReplacementBlock,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyFilePath >> build [
	<lang: #python match: '(call
	(identifier) ="open"
    (argument_list
    	(string) @path @root))' sample: 'open(''Hello'')'>

	self addMorphBack: (SBIcon iconFile on: #click send: #choose to: self).
	
	self addMorphBack: (self
		createBinding: [:c | SBStringMorph new contents: (c at: 'path') contents]
		update: [:c :m | (c at: 'path') contents: m contents])
]

{ #category : #'as yet unclassified' }
SBPyFilePath >> choose [
	<action>

	| path |
	path := UIManager default chooseFileMatching: '*'.
	path ifNil: [^ self].
	self submorphs second contents: path
]
