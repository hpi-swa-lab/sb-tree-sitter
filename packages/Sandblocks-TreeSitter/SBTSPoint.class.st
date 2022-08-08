Class {
	#name : #SBTSPoint,
	#superclass : #ExternalStructure,
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'as yet unclassified' }
SBTSPoint class >> fields [

	^ #(#(#row #'uint32_t') #(#column #'uint32_t'))
]
