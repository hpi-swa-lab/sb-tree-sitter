Class {
	#name : #SBTSLanguageStruct,
	#superclass : #ExternalStructure,
	#instVars : [
		'symbolNames'
	],
	#category : #'Sandblocks-TreeSitter-FFI'
}

{ #category : #'as yet unclassified' }
SBTSLanguageStruct class >> fields [

	^ #(#(#version 'uint32_t') #(#'symbol_count' 'uint32_t') #(#'alias_count' 'uint32_t') #(#'token_count' 'uint32_t') #(#'external_token_count' 'uint32_t') #(#'state_count' 'uint32_t') #(#'large_state_count' 'uint32_t') #(#'production_id_count' 'uint32_t') #(#'field_count' 'uint32_t') #(#'max_alias_sequence_length' 'uint16_t') #(#'parse_table' 'uint16_t*') #(#'small_parse_table' 'uint16_t*') #(#'small_parse_table_map' 'uint32_t*') #(#'parse_actions' 'void*') #(#'symbol_names' 'uintptr_t*') #(#'field_names' 'uintptr_t*'))
]

{ #category : #helper }
SBTSLanguageStruct >> resolveAlias: aString symbolIndex: aNumber factory: aFactory parentType: aTypeString [

	| indices index |
	indices := self symbolIndicesFor: aString.
	index := indices indexOf: aNumber.
	self assert: index > 0.
	
	^ (aFactory aliases select: [:alias | alias name = aString]) at: index
]

{ #category : #helper }
SBTSLanguageStruct >> symbolIndicesFor: aString [

	^ Array streamContents: [:stream |
		1 to: self symbol_count + self alias_count do: [:index | | name |
			name := self symbolNames at: index.
			name = aString ifTrue: [stream nextPut: index - 1]]]
]

{ #category : #helper }
SBTSLanguageStruct >> symbolNameAt: aNumber [

	self assert: (aNumber >= 1 and: [aNumber <= (self symbol_count + self alias_count)]).
	^ (ExternalData fromHandle: (ExternalAddress fromInteger: (self symbol_names at: aNumber)) type: ExternalType string) fromCString
]

{ #category : #helper }
SBTSLanguageStruct >> symbolNames [

	^ symbolNames ifNil: [symbolNames := (1 to: self symbol_count + self alias_count) collect: [:index | self symbolNameAt: index]]
]
