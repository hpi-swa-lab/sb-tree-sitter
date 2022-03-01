"
SBRePatternWrapper is the superclass for all regex replacements that contain another pattern.

Because the subclasses are designed for containing valid regular expressions, the enclosed expressions must be patterns. This is because a pattern is the root rule for the regex grammar and it is the only element that can contain a disjunction. Therefore, a SBRePatternWrapper defaults to a non-capturing group as its type. A non-capturing group can contain a pattern and does not produce a group in the result of the regex execution. Because this can only contain a pattern, some limitations apply. For example, only valid regexes can be wrapped; a single quantifier can not.
"
Class {
	#name : #SBRePatternWrapper,
	#superclass : #SBReBlock,
	#instVars : [
		'pattern'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #initialization }
SBRePatternWrapper >> initialize [
	
	super initialize.

	self pattern: (SBTSUnknown new
		factory: self factory;
		template: (self factory getTemplate: 'pattern'))
]

{ #category : #accessing }
SBRePatternWrapper >> pattern [

	^ pattern
]

{ #category : #accessing }
SBRePatternWrapper >> pattern: aBlock [

	pattern := self pattern
		ifNil: [self wrapInSymbol: aBlock]
		ifNotNil: [self pattern replaceBy: (self wrapInSymbol: aBlock)]
]

{ #category : #actions }
SBRePatternWrapper >> replaceWithWrapped [
	<action>

	self sandblockEditor do: (SBReplaceCommand new
		target: self
		replacer: self pattern buildCopy)
]

{ #category : #printing }
SBRePatternWrapper >> sourceString [

	^ '(?:{1})' format: {self pattern sourceString}
]

{ #category : #accessing }
SBRePatternWrapper >> type [

	^ 'non_capturing_group'
]

{ #category : #helpers }
SBRePatternWrapper >> wrapInSymbol: aBlock [

	^ aBlock isTSSymbol
		ifFalse: [SBInlineBlockSymbol new
			type: 'pattern'
			factory: self factory
			block: aBlock buildCopy]
		ifTrue: [aBlock]
]
