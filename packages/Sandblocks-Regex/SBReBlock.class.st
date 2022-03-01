"
SBReBlock is the superclass for all custom replacements for regular expressions in Sandblocks.

It just contains some utility for the subclasses.

The most important subclasses are SBRePatternWrapper for all replacements that contain another regex, SBReQuantifier for all quantifiers and SBReSimpleReplacement for blocks that substitute a simple syntax element for a verbose text. The class-hierarchy loosely follows the structure of the Treesitter-Regex grammar. Each class corresponds to one element of the grammar.

The goal of these replacements is to make it more easy to read, write and understand regular expressions.

Reading: Regex syntax is very concise and dense, whitespace cannot easily be entered without changing the meaning of expressions. Therefore, verbose representations of syntax elements are used to help with reading the expressions. These verbose explanations are displayed inline, which helps keep the context in the expression. Additionally, the structure of expressions is emphasized using differently colored blocks for different types of syntax elements. This coloring is defined in the SBRegex>>highlightFor: method.

Writing: Because the regex syntax can be obscure (especially for people unfamiliar with it), the verbose replacements abstract away the need to memorize this syntax. The replacements are listed in the palette so one can simply choose the written out version without needing to know the exact syntax. This could be even more useful if different regex dialects were supported.

Understanding: Because of the concise and obscure syntax and the lack of comments, regular expressions can be difficult to understand. This does not only apply to the syntax but arguably even more to the intent behind a regex. What the author wants to achieve is often not apparent from the actual expression but only from comments surrounding and names surrounding it. Regex could be called a ""write-only"" language because regex are written with the hope to never need to modify them again. To solve this problem, a SBReComment makes it possible to add inline comments to a regular expression in Sandblocks and persist them in saved source code to be able to import them again. This way, sub-expressions can be commented on. Another feature to simplify understanding and working with a regex is the SBReEvaluator, which allowes testing sub-expressions individually inside the Sandblocks editor. This saves the user from copying the regex to other tools (like regex101.com) and back after each modification.

TODO:
Currently, these replacements are not applied automatically. It would be nice if the source code a user types in got converted to the appropriate replacements immediately.
"
Class {
	#name : #SBReBlock,
	#superclass : #SBInlineBlockReplace,
	#category : #'Sandblocks-Regex'
}

{ #category : #accessing }
SBReBlock class >> factory [

	^ SBRegex
]

{ #category : #initialization }
SBReBlock >> initialize [

	super initialize.
	
	self
		factory: self class factory instance;
		vResizing: #shrinkWrap;
		hResizing: #shrinkWrap
]

{ #category : #printing }
SBReBlock >> sourceString [

	self subclassResponsibility
]

{ #category : #printing }
SBReBlock >> writeSourceOn: aStream [

	aStream nextPutAll: self sourceString
]
