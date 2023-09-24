Class {
	#name : #DCParseTest,
	#superclass : #SBTest,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCParseTest >> testKeepEmptyLine [

	| program editor |
	program := DCBlock parse: 'a;

b;' language: SBJavascript.
	editor := self editorAndWorldFor: program.
	program lastDeepChild startInputAtEnd.
	self type: 'b' in: editor.
	self assert: 3 equals: editor childSandblocks first childSandblocks size
]
