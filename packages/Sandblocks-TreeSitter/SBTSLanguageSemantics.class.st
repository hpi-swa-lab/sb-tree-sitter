Class {
	#name : #SBTSLanguageSemantics,
	#superclass : #Object,
	#category : #'Sandblocks-TreeSitter-Project'
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

{ #category : #'initialize-release' }
SBTSLanguageSemantics >> on: aDirectory [

	
]

{ #category : #'initialize-release' }
SBTSLanguageSemantics >> shutdown [

	
]

{ #category : #requests }
SBTSLanguageSemantics >> usagesOf: aBlock do: aClosure [

	^ aBlock language usagesOf: aBlock do: aClosure
]
