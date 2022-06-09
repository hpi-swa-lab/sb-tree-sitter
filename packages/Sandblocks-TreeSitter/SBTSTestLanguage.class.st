Class {
	#name : #SBTSTestLanguage,
	#superclass : #SBTSGrammar,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSTestLanguage >> add: aString rule: aBlock [

	rules at: aString put: aBlock
]

{ #category : #'as yet unclassified' }
SBTSTestLanguage >> initialize [

	super initialize.
	
	supertypes := {}.
	inlinedRules := {}.
	rules := Dictionary new
]

{ #category : #'as yet unclassified' }
SBTSTestLanguage >> language [

	^ SBTSLanguage
]

{ #category : #'as yet unclassified' }
SBTSTestLanguage >> rulesWithStatementTerminator [

	^ {}
]

{ #category : #'as yet unclassified' }
SBTSTestLanguage >> supertypes: aCollection [

	supertypes := aCollection
]
