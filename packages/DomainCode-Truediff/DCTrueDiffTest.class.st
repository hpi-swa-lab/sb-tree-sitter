Class {
	#name : #DCTrueDiffTest,
	#superclass : #SBTest,
	#category : #'DomainCode-Truediff'
}

{ #category : #'as yet unclassified' }
DCTrueDiffTest >> testAddStatement [

	| a b new program first last |
	a := DCBlock parse: '1;2' language: SBJavascript.
	program := a.
	first := a children first.
	last := a children last.
	b := DCBlock parse: '1;a;2' language: SBJavascript.
	
	new := DCTrueDiff new compare: a to: b.
	
	self assert: program identical: new.
	self assert: first identical: new children first.
	self assert: last identical: new children last
]

{ #category : #'as yet unclassified' }
DCTrueDiffTest >> testKeepIdentityLeafAdd [

	| a b new program array one |
	a := DCBlock parse: '[1,]' language: SBJavascript.
	program := a.
	array := program children first children first.
	one := array children second.
	b := DCBlock parse: '[1,2]' language: SBJavascript.
	
	new := DCTrueDiff new compare: a to: b.
	
	self assert: program identical: new.
	self assert: one identical: new children first children first children second.
	self assert: array identical: new children first children first
]

{ #category : #'as yet unclassified' }
DCTrueDiffTest >> testKeepIdentityLeafRemove [

	| a b new program array one |
	a := DCBlock parse: '[1,2]' language: SBJavascript.
	program := a.
	array := program children first children first.
	one := array children second.
	b := DCBlock parse: '[1,]' language: SBJavascript.
	
	new := DCTrueDiff new compare: a to: b.
	
	self assert: program identical: new.
	self assert: one identical: new children first children first children second
]

{ #category : #'as yet unclassified' }
DCTrueDiffTest >> testKeepIdentityLeafUpdate [

	| a b new program add |
	a := DCBlock parse: '2+3' language: SBJavascript.
	program := a.
	add := program children first children first.
	b := DCBlock parse: '2+4' language: SBJavascript.
	
	new := DCTrueDiff new compare: a to: b.
	
	self assert: program identical: new.
	self assert: add identical: new children first children first.
	self assert: program lastDeepChild contents equals: '4'
]

{ #category : #'as yet unclassified' }
DCTrueDiffTest >> testKeepIdentityMove [

	| a b new program add |
	a := DCBlock parse: '2+2' language: SBJavascript.
	program := a.
	add := program children first children first.
	b := DCBlock parse: '(2+2)' language: SBJavascript.
	
	new := DCTrueDiff new compare: a to: b.
	
	self assert: program identical: new.
	self assert: add identical: new children first children first children second
]

{ #category : #'as yet unclassified' }
DCTrueDiffTest >> testUpdateBoolean [

	| a b new program id stmt |
	a := DCBlock parse: 'a' language: SBJavascript.
	program := a.
	stmt := a children first.
	id := a children first children first.
	b := DCBlock parse: 'a;' language: SBJavascript.
	
	new := DCTrueDiff new compare: a to: b.
	
	self assert: program identical: new.
	self assert: id identical: new children first children first
]
