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

	| itemMorphs selectedItem tooltips |
	
	itemMorphs := SBPyPltComboBox itemDefinitionsToMorphs: self itemDefinitions.
	selectedItem := SBPyPltComboBox find: aString inItemDefinitions: itemMorphs fallback: #first.
	tooltips := self itemDefinitions collect: #third. 

	self
		addMorphBack:  (SBPyPltComboBox new 
				values: itemMorphs; prefix: self prefix; object: selectedItem; tooltips: tooltips)
]

{ #category : #'initialize-release' }
SBPyPltParamCBReplace >> itemDefinitions [
"set the choices the user can choose of. A collection of {'argument'. imageForm. tooltip} triplets"
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

{ #category : #classification }
SBPyPltParamCBReplace >> type [
	^ 'keyword_argument'
]

{ #category : #copying }
SBPyPltParamCBReplace >> writeSourceOn: aStream [

	aStream nextPutAll: (self prefix, '"', self firstSubmorph contents, '"')
]
