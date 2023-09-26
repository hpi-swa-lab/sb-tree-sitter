Class {
	#name : #SBTSInputEdit,
	#superclass : #ExternalStructure,
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'field definition' }
SBTSInputEdit class >> fields [

	^ #(
		(startByte uint32_t)
		(oldEndByte uint32_t)
		(newEndByte uint32_t)
		(startPoint SBTSPoint)
		(oldEndPoint SBTSPoint)
		(newEndPoint SBTSPoint)
	)
]
