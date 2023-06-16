Class {
	#name : #SBWingParameterEditable,
	#superclass : #SBWingParameter,
	#instVars : [
		'initial'
	],
	#category : #'Sandblocks-Wing'
}

{ #category : #'as yet unclassified' }
SBWingParameterEditable >> from: aCost [

	| valueBlock params |
	params := aCost bindings at: 'parameters'.
	valueBlock := params childSandblocks
		detect: [:member | member childSandblocks first contents = self name]
		ifFound: [:member | member childSandblocks second]
		ifNone: [ | param |
			param := (SBWing parseExpression: ('\{{1}: {2}}' format: {self name. self initial asString})) childSandblocks first.
			params lastInsertPosition command
				morphs: {param};
				do.
			param childSandblocks second].
	
	aCost createBinding: [:c | self] update: [:c :m | valueBlock contents: m value asString]
]

{ #category : #'as yet unclassified' }
SBWingParameterEditable >> initial [

	^ initial
]

{ #category : #'as yet unclassified' }
SBWingParameterEditable >> initial: aNumber [

	initial := aNumber
]

{ #category : #'as yet unclassified' }
SBWingParameterEditable >> value [

	^ self subclassResponsibility
]
