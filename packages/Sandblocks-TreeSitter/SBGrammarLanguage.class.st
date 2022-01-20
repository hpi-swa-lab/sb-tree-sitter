Class {
	#name : #SBGrammarLanguage,
	#superclass : #SBMetaBlockFactory,
	#classInstVars : [
		'instance'
	],
	#category : #'Sandblocks-TreeSitter'
}

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> allRuntimes [

	^ Array streamContents: [:stream | SBTSLanguageRuntime allSubclassesDo: [:cl | cl language = self ifTrue: [stream nextPut: cl]]]
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> build: aRuleName [

	^ self instance instantiateTemplate: aRuleName
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> defaultRuntimeClass [

	^ nil
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> file: aFilenameString [

	^ SBTSFile new filepath: aFilenameString language: self
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> fileSuffix [

	^ nil
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
SBGrammarLanguage class >> icon [

	^ nil
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage class >> iconMorph [

	^ self icon ifNotNil: #asMorph ifNil: [SBIcon iconFile]
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
		ifTrue: [
			self
				assert: program childSandblocks size = 1
				description: 'More than one child was returned from the parsed expression. Consider using parse: instead.'.
			program childSandblocks first]
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

	^ #()
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
	self prepareBlocks.
	self findBlockInlineCandidates.
	self postConfigure
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> postConfigure [

	
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> prepareBlocks [

	grammar rules keysAndValuesDo: [:name :r | self getTemplate: name]
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> preprocessGrammar [
	" entrypoint to clean the grammar before the automated steps happen, e.g. replacing or removing external rules "

	
]

{ #category : #'as yet unclassified' }
SBGrammarLanguage >> runtime [

	SBTSActiveRuntime value ifNotNil: [:runtime | runtime class language = self class ifTrue: [^ runtime]].
	
	^ self class defaultRuntimeClass ifNotNil: [:cl | cl new factory: self]
]
