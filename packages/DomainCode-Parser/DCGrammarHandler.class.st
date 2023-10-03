Class {
	#name : #DCGrammarHandler,
	#superclass : #SBGrammarHandler,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCGrammarHandler >> characterCanStartInput: aCharacter [

	^ aCharacter isPrintable
]

{ #category : #'as yet unclassified' }
DCGrammarHandler >> startOverrideInput: anEvent in: anEditor [

	anEditor selection replaceWith: anEvent keyCharacter asString
]
