Class {
	#name : #BencodeDecoder,
	#superclass : #Object,
	#category : #'Sandblocks-Clojure'
}

{ #category : #'as yet unclassified' }
BencodeDecoder class >> on: aStream [

	| ret |
	^ aStream peek
		caseOf: {
			[$l] -> [
				aStream next.
				ret := Array streamContents: [:stream | [aStream peek ~= $e] whileTrue: [stream nextPut: (self on: aStream)]].
				aStream next.
				ret].
			[$i] -> [
				aStream next.
				ret := (aStream upTo: $e) asInteger.
				aStream next.
				ret].
			[$d] -> [ | flattened |
				aStream next.
				flattened := Array streamContents: [:stream | [aStream peek ~= $e] whileTrue: [stream nextPut: (self on: aStream)]].
				aStream next.
				ret := Dictionary new.
				flattened pairsDo: [:key :value | ret at: key put: value].
				ret]}
		otherwise: [
			self assert: aStream peek isDigit.
			aStream next: (aStream upTo: $:) asInteger]
]
