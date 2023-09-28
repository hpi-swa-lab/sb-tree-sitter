Class {
	#name : #SBTSFFIRange,
	#superclass : #ExternalStructure,
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'field definition' }
SBTSFFIRange class >> fields [

	^ #(#(#startPoint #SBTSPoint) #(#endPoint #SBTSPoint) #(#startByte #'uint32_t') #(#endByte #'uint32_t'))
]

{ #category : #converting }
SBTSFFIRange >> asRange [

	^ SBTSRange
		start: (SBTSPosition line: self startPoint row character: self startPoint column index: self startByte)
		end: (SBTSPosition line: self endPoint row character: self endPoint column index: self endByte)
]
