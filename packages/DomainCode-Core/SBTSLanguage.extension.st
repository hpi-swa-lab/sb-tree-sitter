Extension { #name : #SBTSLanguage }

{ #category : #'*DomainCode-Core' }
SBTSLanguage class >> grammarRule: aSymbol [

	^ self rawGrammar rules at: aSymbol
]

{ #category : #'*DomainCode-Core' }
SBTSLanguage class >> rawGrammar [

	^ RawGrammar ifNil: [RawGrammar := Json readFrom: self grammarJson readStream]
]

{ #category : #'*DomainCode-Core' }
SBTSLanguage class >> ruleIsInlined: aSymbol [

	^ ((self rawGrammar at: #inline) includes: aSymbol) or: [aSymbol first = $_]
]

{ #category : #'*DomainCode-Core' }
SBTSLanguage class >> supertype: aSymbol includes: anotherSymbol [

	^ ((self rawGrammar supertypes includes: aSymbol) or: [self ruleIsInlined: aSymbol])
		ifTrue: [ | nestedRule |
			nestedRule := self grammarRule: aSymbol.
			nestedRule type = 'CHOICE' ifFalse: [nestedRule := nestedRule content].
			nestedRule members anySatisfy: [:rule | self supertype: (rule name ifNil: [rule content name]) includes: anotherSymbol]]
		ifFalse: [aSymbol = anotherSymbol]
]
