Class {
	#name : #SBPyPltSubplots,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyPltSubplots class >> matchPython: aDictionary do: aBlock [
	<lang: #python match: '(module
  (expression_statement
  (assignment
    left:
      (pattern_list
        (identifier) ="ax"
        (identifier) ="fig"
      )
    right:
      (call
        function:
          (attribute
            object: (identifier) ="plt"
            attribute: (identifier) ="subplots"
          )
      )
  )
) @initMatplotlib
)' sample: 'ax, fig = plt.subplots()'>
"TODO: replace arg of createFigureButtonFrom to enclosing node in aDictionary as soon as supported"
	
	^ aBlock
		value: (aDictionary at: 'initMatplotlib')
		value: (self new factory: (aDictionary at: 'initMatplotlib') factory; createFigureButtonFrom: (self newNullBlock: 'Axes type'))
]

{ #category : #'initialize-release' }
SBPyPltSubplots >> createFigureButtonFrom: aBlock [ 
	
	self submorphCount > 1 ifTrue: [self firstSubmorph delete].
	aBlock ifNotNil: [self 
			addMorph: (SBColumn new
				addMorphBack: (SBStringMorph new contents: 'Create Figure'; bold);
				addMorphBack: aBlock)]
]
