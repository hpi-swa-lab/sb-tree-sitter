Class {
	#name : #SBGrammarLanguage,
	#superclass : #SBMetaBlockFactory,
	#classInstVars : [
		'instance'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> build: aRuleName [

	^ self instance instantiateTemplate: aRuleName
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> grammarJson [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> highlightQuery [

	^ nil
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> initialize [

	self allSubclassesDo: #invalidate
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> instance [

	^ instance ifNil: [instance := self new]
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> invalidate [

	instance := nil
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> language [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> parse: aString [

	^ self instance parse: aString
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> parseAndReplace: aString [

	^ (self instance parse: aString) applyReplacements
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> parseElement: aString [

	| program |
	program := self instance parse: aString.
	^ self instance rootRuleName = program type
		ifTrue: [program childSandblocks first]
		ifFalse: [program]
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> rebuild [

	self invalidate.
	^ self instance
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> rootRuleName [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> statementContainerTypes [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> toplevel [

	^ self instance toplevel
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> configure [
	" entry point for calling configuration methods on the processed grammar, e.g. blockInline:, or delimitedRules: "

	
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> initialize [

	super initialize.
	
	grammar := Json readFrom: self class grammarJson readStream.
	supertypes := grammar supertypes.
	name := self class language.
	highlightQuery := self class highlightQuery ifNotNil: [:query | SBTSQuery new prepare: query].
	extras := grammar extras
		select: [:rule | rule type = 'SYMBOL']
		thenCollect: [:rule | rule name].
	
	self wordRule: grammar word.
	self rootRuleName: self class rootRuleName.
	self statementContainerTypes: self class statementContainerTypes.
	
	self preprocessGrammar.
	self cleanGrammar.
	self configure.
	
	" make sure all rules are in the cache "
	grammar rules keysAndValuesDo: [:name :r | self getTemplate: name]
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> preprocessGrammar [
	" entrypoint to clean the grammar before the automated steps happen, e.g. replacing or removing external rules "

	
]
