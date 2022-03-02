"
SBRePatternWrapper is the superclass for all regex replacements that contain another pattern.

Because the subclasses are designed for containing valid regular expressions, the enclosed expressions must be patterns. This is because a pattern is the root rule for the regex grammar and it is the only element that can contain a disjunction. Therefore, a SBRePatternWrapper defaults to a non-capturing group as its type. A non-capturing group can contain a pattern and does not produce a group in the result of the regex execution. Because this can only contain a pattern, some limitations apply. For example, only valid regexes can be wrapped; a single quantifier can not.

TODO:
Wrapping and un-wrapping a pattern is not trivial, because insertion can break when wrapping a block (using the Ctrl+M and Ctrl+N shortcuts) and because unwrapping the pattern can lead to a situation where the pattern cannot be inserted into the parent block according to the grammar. See the todos in pattern: and replaceWithWrappedPattern.
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

	self flag: #todo. "Using this setter can break the inserting and suggestions of the block, since the inline blocks are missing."

	pattern := self pattern
		ifNil: [self wrapInSymbol: aBlock]
		ifNotNil: [self pattern replaceBy: (self wrapInSymbol: aBlock)]
]

{ #category : #actions }
SBRePatternWrapper >> replaceWithWrappedPattern [
	<action>

	self flag: #todo. "Since the pattern includes the outer pattern and term, this leads to ugly (and grammatically incorrect) additional blocks with the naive implementation below. If the pattern contains an alternative, it is not even allowed to insert it."

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
