"
Base class of all keyword argument replacements that use a SBPyPltComboBox replacement. 
"
Class {
	#name : #SBPyPltParamCBReplace,
	#superclass : #SBInlineBlockReplace,
	#instVars : [
		'prefix'
	],
	#category : #'Sandblocks-Python'
}

{ #category : #'initialize-release' }
SBPyPltParamCBReplace >> createReplacementWithSelectedLabel: aString [

	| itemsMorphs selectedItem |
	
	itemsMorphs := self items collect: [:pair |
				SBRow new
					cellGap: 8;
					addMorphBack: (SBStringMorph new contents: pair first);
					addMorphBack: pair second
				].
	
	selectedItem := (itemsMorphs select: [:i | i submorphs first contents = aString]) ifEmpty: [aString] ifNotEmpty: [:aCollection | aCollection first].

	self
		addMorphBack:  (SBPyPltComboBox new 
				values: itemsMorphs; prefix: self prefix; object: selectedItem; tooltips: self tooltips)
]

{ #category : #'initialize-release' }
SBPyPltParamCBReplace >> items [
"set the choices the user can choose of. A collection of {'argument'. imageForm} pairs"
	^ self subclassResponsibility.
]

{ #category : #'initialize-release' }
SBPyPltParamCBReplace >> palettes [
"arguments don't have their own palette because they might be shown in different arguments.

For example, marker= is used in ax.plot and ax.scatter"
	^ {}
]

{ #category : #'initialize-release' }
SBPyPltParamCBReplace >> prefix [
"the keyword argument name in python, e.g. 'marker='"
	^ prefix
]

{ #category : #'initialize-release' }
SBPyPltParamCBReplace >> prefix: aString [
	prefix := aString
]

{ #category : #'initialize-release' }
SBPyPltParamCBReplace >> tooltips [
"messages that appear once hovering over individual items"
	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBPyPltParamCBReplace >> type [
	^ 'keyword_argument'
]

{ #category : #'as yet unclassified' }
SBPyPltParamCBReplace >> writeSourceOn: aStream [

	aStream nextPutAll: (self prefix, '"', self firstSubmorph contents, '"')
]
