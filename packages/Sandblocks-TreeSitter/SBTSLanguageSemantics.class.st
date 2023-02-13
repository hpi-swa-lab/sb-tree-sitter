Class {
	#name : #SBTSLanguageSemantics,
	#superclass : #Object,
	#category : #'Sandblocks-TreeSitter-LanguageClient'
}

{ #category : #notifications }
SBTSLanguageSemantics >> didChange: aTSFile [

	
]

{ #category : #notifications }
SBTSLanguageSemantics >> didClose: aTSFile [

	
]

{ #category : #notifications }
SBTSLanguageSemantics >> didOpen: aTSFile [

	
]

{ #category : #'as yet unclassified' }
SBTSLanguageSemantics >> hoverFor: aBlock do: aClosure blocking: aBoolean [

	
]

{ #category : #'initialize-release' }
SBTSLanguageSemantics >> on: aDirectory [

	
]

{ #category : #'initialize-release' }
SBTSLanguageSemantics >> shutdown [

	
]

{ #category : #'as yet unclassified' }
SBTSLanguageSemantics >> suggestionsFor: aBlock [

	^ #()
]

{ #category : #requests }
SBTSLanguageSemantics >> usagesOf: aBlock do: aClosure [

	^ aBlock language usagesOf: aBlock do: aClosure
]
