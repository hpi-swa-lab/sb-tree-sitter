Class {
	#name : #SBTSGrammarHandler,
	#superclass : #SBGrammarHandler,
	#category : #'Sandblocks-TreeSitter-Nodes'
}

{ #category : #'as yet unclassified' }
SBTSGrammarHandler >> characterCanStartInput: aCharacter [

	^ true
]

{ #category : #'as yet unclassified' }
SBTSGrammarHandler >> startOverrideInput: anEvent in: anEditor [

	(anEditor selection language validPrefixInputs includes: anEvent keyCharacter) ifTrue: [
		^ SBTSInputReconcile new
			for: anEditor selection
			input: anEvent keyCharacter asString
			before: true].
	
	(anEditor selection language validSuffixIputs includes: anEvent keyCharacter) ifTrue: [
		^ SBTSInputReconcile new
			for: anEditor selection
			input: anEvent keyCharacter asString
			before: false].
	
	^ super startOverrideInput: anEvent in: anEditor
]
