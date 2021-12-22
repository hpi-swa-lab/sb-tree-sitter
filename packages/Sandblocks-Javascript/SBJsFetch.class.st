Class {
	#name : #SBJsFetch,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Javascript'
}

{ #category : #'as yet unclassified' }
SBJsFetch class >> matchJs: aDictionary do: aBlock [
	<lang: #javascript match: '(call_expression
	(member_expression
    	(identifier) @window
        (property_identifier) @fetch)
    (arguments
    	(string) @url
        (object) @params)
) @call'>

	(aDictionary at: 'fetch') contents = 'fetch' ifFalse: [^ nil].
	(aDictionary at: 'window') contents = 'window' ifFalse: [^ nil].
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new url: (aDictionary at: 'url') childSandblocks first contents params: (aDictionary at: 'params'))
]

{ #category : #'initialize-release' }
SBJsFetch >> url: aString params: aSBInlineBlockSymbol [

	self
		listDirection: #topToBottom;
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'URL: ');
			addMorphBack: (SBTextBubble new contents: aString));
		addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'Params: ');
			addMorphBack: aSBInlineBlockSymbol buildCopy)
]

{ #category : #'as yet unclassified' }
SBJsFetch >> writeSourceOn: aStream [

	aStream nextPutAll: 'window.fetch("'.
	aStream nextPutAll: self firstSubmorph submorphs second contents.
	aStream nextPutAll: '", '.
	self submorphs second submorphs second writeSourceOn: aStream.
	aStream nextPutAll: ')'
]
