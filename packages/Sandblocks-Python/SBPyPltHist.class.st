"
I am the class representing the matplotlib hist function without any optional parameters set.
"
Class {
	#name : #SBPyPltHist,
	#superclass : #SBPyPltPlots,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltHist class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(call
        	function: (attribute
            	object: (identifier) @ax
                (#eq @ax "ax")
                attribute: (identifier) ="hist" @plot
            )
        	arguments: (argument_list
			(identifier) @paramX
		)
        ) @call' sample: 'ax.plot(Y)'>
	
	^ aBlock
		value: (aDictionary at: 'call')
		value: (self new factory: (aDictionary at: 'call') factory;
			createReplacementWithX: (aDictionary at: 'paramX') contents)
			
		
]

{ #category : #'initialize-release' }
SBPyPltHist >> createReplacementWithX: aString [

	self addMorphBack: (SBRow new
			addMorphBack: (SBStringMorph new contents: 'histogram: (');
			addMorphBack: (SBTextBubble new contents: aString);
			addMorphBack: (SBStringMorph new contents: ')');
			addMorphBack: (SBPyPltImage histogram);
			cellGap: 4
		).
]

{ #category : #'initialize-release' }
SBPyPltHist >> isAxes [
	"indicates whether this replacement is to be shown in the Axes Palette"

	^ true
]

{ #category : #'as yet unclassified' }
SBPyPltHist >> writeSourceOn: aStream [
"called when blocks are copied. It transforms the block back to source code"

	| xArg |
	xArg := self submorphs first submorphs second contents.
	
	aStream nextPutAll: 'ax.hist('.
	aStream nextPutAll: xArg.
	aStream nextPutAll: ')'.
]
