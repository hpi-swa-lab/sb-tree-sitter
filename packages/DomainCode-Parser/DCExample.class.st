Class {
	#name : #DCExample,
	#superclass : #DCReplacement,
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCExample >> drawnColor [

	^ Color veryDarkGray
]

{ #category : #'as yet unclassified' }
DCExample >> initialize [

	super initialize.
	self changeTableLayout.
	self layoutInset: 4
]

{ #category : #'as yet unclassified' }
DCExample >> run [

	| receiver args |
	receiver := (Compiler evaluate: self source childNodes third sourceString) value.
	args := (Compiler evaluate: self source childNodes fifth sourceString) value.
	receiver perform: self containingArtefact selector withArguments: args
]

{ #category : #'as yet unclassified' }
DCExample >> runWithTimeout: aNumber [

	[self run] valueWithin: aNumber onTimeout: [TimedOut signal]
]
