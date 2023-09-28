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

{ #category : #'as yet unclassified' }
SBTSInputEdit >> bytesToPointsIn: aString new: anotherString [

	| line startByte oldEndByte newEndByte char done |
	line := 0.
	char := 0.
	
	startByte := self startByte.
	oldEndByte := self oldEndByte.
	newEndByte := self newEndByte.
	done := 0.
	
	0 to: (oldEndByte max: startByte) do: [:offset |
		startByte = offset ifTrue: [
			self startPoint: (SBTSPoint new
				row: line;
				column: char)].
		oldEndByte = offset ifTrue: [
			self oldEndPoint: (SBTSPoint new
				row: line;
				column: char)].
		(aString at: offset + 1 ifAbsent: [nil]) = Character cr
			ifTrue: [
				line := line + 1.
				char := 0]
			ifFalse: [char := char + 1]].
	
	line := 0.
	char := 0.
	0 to: newEndByte do: [:offset |
		newEndByte = offset ifTrue: [
			self newEndPoint: (SBTSPoint new
				row: line;
				column: char).
			done := done + 1].
		(anotherString at: offset + 1 ifAbsent: [nil]) = Character cr
			ifTrue: [
				line := line + 1.
				char := 0]
			ifFalse: [char := char + 1]]
]
