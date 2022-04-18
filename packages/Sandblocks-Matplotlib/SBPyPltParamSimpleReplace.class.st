"
Replacements for simple parameters that only have a single input block. The prefix of the input block passed to createReplacementOfInputBlock: is assumed the be param name.
"
Class {
	#name : #SBPyPltParamSimpleReplace,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Matplotlib'
}

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace class >> matchAlpha: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="alpha"
      value: (float) @value
) @argument' sample: 'ax.plot(alpha=0.5)'>

	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementOfInputBlock: (SBPyNumberWithPrefix new 
			prefix: 'alpha='; rangeFrom: 0.0 to: 1.0; floatSteps; 
			contents: (aDictionary at: 'value') contents))
]

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace class >> matchColor: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="color"
    value: (string) @value
) @argument' sample: 'ax.plot(color="r")'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementOfInputBlock: (SBTextBubble new prefix: 'color='; contents: (aDictionary at: 'value') contents)
			)
]

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace class >> matchGid: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="gid"
    value: (string) @value
) @argument' sample: 'ax.plot(gid="unique-graph-id")'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementOfInputBlock: (SBTextBubble new prefix: 'gid='; contents: (aDictionary at: 'value') contents))
]

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace class >> matchLabel: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="label"
    value: (string) @value
) @argument' sample: 'ax.plot(label="fancy line plot")'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementOfInputBlock: (SBTextBubble new prefix: 'label='; contents: (aDictionary at: 'value') contents))
]

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace class >> matchLinewidth: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="linewidth"
      value: (float) @value
) @argument' sample: 'ax.plot(linewidth=0.5)'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementOfInputBlock: (SBPyNumberWithPrefix new prefix: 'linewidth='; contents: (aDictionary at: 'value') contents
			))
]

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace class >> matchLw: aDictionary do: aBlock [
"Same as matchLinewidth:do: but matches linewidth's shortform lw"
	<lang: #python match: '(keyword_argument
	name: (identifier) ="lw"
      value: (float) @value
) @argument' sample: 'ax.plot(lw=0.5)'>
	
	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementOfInputBlock: (SBPyNumberWithPrefix new prefix: 'linewidth='; contents: (aDictionary at: 'value') contents
			))
]

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace class >> matchYmax: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="ymax"
      value: [(float) (integer)] @value
) @argument' sample: 'ax.axvline(ymax=0.5)'>

	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementOfInputBlock: ((SBPyNumberWithPrefix new prefix: 'ymax='; rangeFrom: 0.0 to: 1.0; floatSteps; contents: (aDictionary at: 'value') contents)))
]

{ #category : #'as yet unclassified' }
SBPyPltParamSimpleReplace class >> matchYmin: aDictionary do: aBlock [
	<lang: #python match: '(keyword_argument
	name: (identifier) ="ymin"
      value: [(float) (integer)] @value
) @argument' sample: 'ax.axvline(ymin=0.5)'>

	^ aBlock
		value: (aDictionary at: 'argument')
		value: (self new factory: (aDictionary at: 'argument') factory;
			createReplacementOfInputBlock: (SBPyNumberWithPrefix new prefix: 'ymin='; rangeFrom: 0.0 to: 1.0; floatSteps; contents: (aDictionary at: 'value') contents))
]

{ #category : #'initialize-release' }
SBPyPltParamSimpleReplace >> createReplacementOfInputBlock: anInputBlock [
"anInputBlock is any single input block that has a prefix, e.g. SBPyNumberWithPrefix, SBTextBubble"
	self addMorphBack: anInputBlock.
]

{ #category : #classification }
SBPyPltParamSimpleReplace >> palettes [
"keyword args have no palettes because they can be shown in different contexts."
	^ {}
]

{ #category : #classification }
SBPyPltParamSimpleReplace >> type [
	^ 'keyword_argument'
]

{ #category : #copying }
SBPyPltParamSimpleReplace >> writeSourceOn: aStream [

	| isAllDigits |
	isAllDigits := [self firstSubmorph contents asNumber isNumber] on: NumberParserError do: [false].
	
	isAllDigits 
		ifTrue: [aStream nextPutAll: (self firstSubmorph prefix, self firstSubmorph contents)] 
		ifFalse: [aStream nextPutAll: (self firstSubmorph prefix, '"', self firstSubmorph contents, '"')].
]
