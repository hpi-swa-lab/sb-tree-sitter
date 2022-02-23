Class {
	#name : #SBRePatternWrapper,
	#superclass : #SBReBlock,
	#instVars : [
		'pattern'
	],
	#category : #'Sandblocks-Regex'
}

{ #category : #'as yet unclassified' }
SBRePatternWrapper >> initialize [
	
	super initialize.

	self pattern: (SBTSUnknown new
		factory: self factory;
		template: (self factory getTemplate: 'pattern'))
]

{ #category : #'as yet unclassified' }
SBRePatternWrapper >> pattern [

	^ pattern
]

{ #category : #'as yet unclassified' }
SBRePatternWrapper >> pattern: aBlock [

	pattern := self pattern
		ifNil: [self wrapInSymbol: aBlock]
		ifNotNil: [self pattern replaceBy: (self wrapInSymbol: aBlock)]
]

{ #category : #'as yet unclassified' }
SBRePatternWrapper >> replaceWithWrapped [
	<action>

	self sandblockEditor do: (SBReplaceCommand new
		target: self
		replacer: self pattern buildCopy)
]

{ #category : #'as yet unclassified' }
SBRePatternWrapper >> sourceString [

	^ '(?:{1})' format: {self pattern sourceString}
]

{ #category : #'as yet unclassified' }
SBRePatternWrapper >> type [

	^ 'non_capturing_group'
]

{ #category : #'as yet unclassified' }
SBRePatternWrapper >> wrapInSymbol: aBlock [

	^ SBInlineBlockSymbol new
		type: 'pattern'
		factory: self factory
		block: aBlock
]
