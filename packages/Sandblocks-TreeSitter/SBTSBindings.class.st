Class {
	#name : #SBTSBindings,
	#superclass : #Object,
	#instVars : [
		'root',
		'bindings'
	],
	#classInstVars : [
		'root'
	],
	#category : #'Sandblocks-TreeSitter-Replacements'
}

{ #category : #'as yet unclassified' }
SBTSBindings class >> match: aBlock against: aTSQuery bind: aDictionary for: aBlockClass [

	aTSQuery executeAgainst: aBlock capturesDo: [:captures :success |
		success ifTrue: [
			root := captures at: 'root' ifAbsent: [aBlock].
			^ SBReplaceCommand new target: root root replacer: aBlockClass new build]].
	^ nil
]

{ #category : #'as yet unclassified' }
SBTSBindings >> at: aString [

	^ (bindings at: aString) to
]

{ #category : #'as yet unclassified' }
SBTSBindings >> createBinding: aString block: aBlock do: aDictionary captures: captures [

	^ aDictionary at: aString ifPresent: [:mapping | | binding |
		binding := mapping cull: aBlock cull: captures.
		bindings at: aString put: (SBTSBinding new from: aBlock to: binding)]
]

{ #category : #'as yet unclassified' }
SBTSBindings >> initialize [

	super initialize.
	
	bindings := Dictionary new
]

{ #category : #'as yet unclassified' }
SBTSBindings >> root [

	^ root
]

{ #category : #'as yet unclassified' }
SBTSBindings >> root: aBlock [

	root := aBlock
]

{ #category : #'as yet unclassified' }
SBTSBindings >> writeSourceOn: aStream indent: aNumber forCompare: aBoolean [

	bindings do: [:binding | binding update].
	root writeSourceOn: aStream
]
