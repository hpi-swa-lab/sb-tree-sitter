"
Acts as a reference to another node -- effectively allowing a subtree to have two parents. Consequently, the marker is treated as a normal node and moved around in place of the subtree it is representing. The marker exists only in the AST world (and allows its reference to exist in the UI world).

The marker is updated/uninstalled by subsequent queries on the replacement.
"
Class {
	#name : #DCEmbedMarker,
	#superclass : #DCBlock,
	#instVars : [
		'source'
	],
	#category : #'DomainCode-Parser'
}

{ #category : #'as yet unclassified' }
DCEmbedMarker >> contents [

	^ ''
]

{ #category : #'as yet unclassified' }
DCEmbedMarker >> isReplacement [

	^ true
]

{ #category : #'as yet unclassified' }
DCEmbedMarker >> parent [

	^ self owner
]

{ #category : #'as yet unclassified' }
DCEmbedMarker >> printOn: aStream [

	aStream nextPutAll: 'EmbedMarker('.
	aStream print: self source.
	aStream nextPut: $)
]

{ #category : #'as yet unclassified' }
DCEmbedMarker >> siblingIndex [

	^ self submorphIndex
]

{ #category : #'as yet unclassified' }
DCEmbedMarker >> source [

	^ source
]

{ #category : #'as yet unclassified' }
DCEmbedMarker >> source: aBlock [

	source := aBlock.
	aBlock replacedParent: self
]

{ #category : #'as yet unclassified' }
DCEmbedMarker >> treeLabel [

	^ ''
]

{ #category : #'as yet unclassified' }
DCEmbedMarker >> type [

	^ ''
]

{ #category : #'as yet unclassified' }
DCEmbedMarker >> uninstall [

	self replaceNodeBy: source.
	source replacedParent: nil
]
