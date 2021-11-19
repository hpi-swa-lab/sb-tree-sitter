Class {
	#name : #SBTSLanguageQueryTests,
	#superclass : #SBTest,
	#category : #'Sandblocks-TreeSitter-Tests'
}

{ #category : #'as yet unclassified' }
SBTSLanguageQueryTests >> testJsClass [

	| block |
	block := SBJavascript parseElement: 'class A {
example
}'.
	self assert: (block matchesQuery: '(class_declaration (class_body
	member: (field_definition
		property: (property_identifier))))').
	
	block := SBJavascript parseElement: 'class A {
example = {}
render() {}
}'.
	self assert: (block matchesQuery: '(class_declaration
name: (identifier)
(class_body
	member: (field_definition
		property: (property_identifier)
		value: (object))
	member: (method_definition
		name: (property_identifier)))))')
]
