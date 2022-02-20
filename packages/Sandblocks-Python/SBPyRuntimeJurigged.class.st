Class {
	#name : #SBPyRuntimeJurigged,
	#superclass : #SBPyRuntimeOSProcess,
	#category : #'Sandblocks-Python'
}

{ #category : #'as yet unclassified' }
SBPyRuntimeJurigged >> interpreter [

	^ self which: 'jurigged'
]
