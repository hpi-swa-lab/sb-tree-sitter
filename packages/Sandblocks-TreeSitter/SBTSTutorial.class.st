Class {
	#name : #SBTSTutorial,
	#superclass : #Object,
	#category : #'Sandblocks-TreeSitter-Tutorial'
}

{ #category : #helper }
SBTSTutorial class >> open [

	SBExecutionEnvironment value sandblockEditor
		ifNotNil: [:editor | self openIn: editor]
		ifNil: [self error: 'No editor found in execution context']
]

{ #category : #helper }
SBTSTutorial class >> openIn: anEditor [

	self stepIntro: anEditor
]

{ #category : #steps }
SBTSTutorial class >> stepInsert: anEditor [

	SBTutorialStep new
		toplevelSteps: self steps in: self;
		title: 'Inserting Elements';
		setup: anEditor do: [:step | | program |
			program := step createStep: (SBJavascript parseToplevel: '
function() {await Promise.resolve(arg)}
"line1line2"').
			step
				addStep: 'Sandblocks will display a hint when your cursor is at a position where an element can be inserted. Keep pressing <#moveCursorRight> or <#moveCursorLeft> until it offers you to add an "async" in front of the function. Press the first letter of the input, in this case `a` to confirm.'
				checkCondition: [:editor | program sourceString includesSubstring: 'async function'].
			step
				addStep: 'Next, add an argument called `arg` to the function by again moving into the right stop and typing `arg`.'
				checkCondition: [:editor | program sourceString includesSubstring: 'async function(arg)'].
			step
				addStep: 'You can create a new statement by pressing <#insertStatementBelow> or <#insertStatementAbove> *anywhere*. Try moving into the function and pressing <#insertStatementBelow>.'
				checkCondition: [:editor | (program queryNode: '(statement_block)') childSandblocks size = 2].
			step
				addStep: 'Now, create a new statement underneath, outside the function. To do so, you have to move the cursor out of the current statement block via <#moveCursorLarger> and only then press <#insertStatementBelow>.'
				checkCondition: [:editor | program sourceString includesSubstring: 'async function(arg)
{

}
'].
			step
				addStep: 'If you want to create a multiline string, you have to press <#typeNewLine>, as otherwise the <#insertStatementBelow> input would be used to create a new line. Try splitting the lines of the below string.'
				checkCondition: [:editor | program sourceString includesSubstring: '"line1
line2"']]
]

{ #category : #steps }
SBTSTutorial class >> stepIntro: anEditor [

	SBTutorialStep new
		toplevelSteps: self steps in: self;
		title: 'Welcome to Sandblocks!';
		addIntroText: 'This brief tutorial will guide you through the essential things to know for editing code in Sandblocks. We will JavaScript as our example language.';
		setup: anEditor do: [:step | | program firstDone |
			program := step createStep: (SBJavascript parseToplevel: '').
			firstDone := false.
			step
				addStep: 'Try simply typing in the input at the bottom `console.log("Hello world")` while ignoring all popups. Sandblocks will automatically dismiss popups as you give it more input.'
				checkCondition: [:editor |
					(program sourceString includesSubstring: 'console.log("Hello world")')
						ifTrue: [
							firstDone := true.
							true]
						ifFalse: [false]].
			step
				addStep: 'Next, try backspacing until you have an empty program again and note how Sandblocks removes blocks for you as their content is emptied.'
				checkCondition: [:editor | firstDone and: [program childSandblocks isEmpty]].
			program startInsertAtEnd]
]

{ #category : #steps }
SBTSTutorial class >> stepShortcuts: anEditor [

	SBTutorialStep new
		toplevelSteps: self steps in: self;
		title: 'Useful Shortcuts';
		setup: anEditor do: [:step | | program |
			program := step createStep: (SBJavascript parseToplevel: 'const goodNum = nameIdentifier;
[37];
const justNumber=[2.123123];').
			step
				addStep: 'Select identifier `nameIdentifier` and press <#clearInput> to quickly clear the contents of just the selected block and change it to a `42`.'
				checkCondition: [:editor | program childSandblocks first sourceString = 'const goodNum=42;'].
			step
				addStep: 'Copy and paste works as you would expect it to: select the number `37`, press <#copyToBuffer>, then move the cursor right until it becomes a dashed line and press <#pasteReplace>.'
				checkCondition: [:editor | program childSandblocks second sourceString = '[37,37];'].
			step
				addStep: 'Similarly, cutting works via <#deleteBlockWithCopy>. It is also a quick way to delete a block (otherwise, you should select the whole block via <#moveCursorLarger>, then press <#deleteBlock>). Try emptying the array again by pressing <#deleteBlockWithCopy> on both `37`s.'
				checkCondition: [:editor | program childSandblocks second sourceString = '[];'].
			step
				addStep: 'When you want to unwrap a block, the easiest way is to copy it, then select its parent and paste over it. For example, delete the array but keep the number in the last row by copying the number, selecting the array via <#moveCursorLarger>, then pasting.'
				checkCondition: [:editor | program childSandblocks third sourceString = 'const justNumber=2.123123;']]
]

{ #category : #steps }
SBTSTutorial class >> stepTryItYourself: anEditor [

	SBTutorialStep new
		toplevelSteps: self steps in: self;
		title: 'Try It Yourself';
		addIntroText: 'Finally, feel free to take some moments to explore the input system by yourself by modifying, deleting or extending the below JavaScript code as you wish.

For example, try creating a new class named Dog and add an appropriate method with a console.log. Or try adding a loop that iterates over the number list.

Note that adding comments is currently not supported in Sandblocks.';
		setup: anEditor
			do: [:step | step createStep: (SBJavascript parseToplevel: 'class A {
	numbers = [3, 67, 1, 4, 8]

	constructor() {
		super(32);
	}
}

{key: "value", weather: "good"}')]
]

{ #category : #steps }
SBTSTutorial class >> stepWrapping: anEditor [

	SBTutorialStep new
		toplevelSteps: self steps in: self;
		title: 'Wrapping Expressions';
		addIntroText: 'Just now, we have typed an expression from scratch. Next, we will extend existing expressions.';
		setup: anEditor do: [:step | | program |
			program := step createStep: (SBJavascript parseToplevel: '23*42
12+43
''array member?''
3+0.14').
			step
				addStep: 'First, navigate to the `42` in the first row and type `+1` to extend the expression.'
				checkCondition: [:editor | program childSandblocks first sourceString = '23*(42+1);'].
			step
				addStep: 'In the second row, we want to multiply the result of the addition by 5. To do so, move your cursor to the `43` and use <#moveCursorLarger> to select the addition `12+43`. Then press space and type `*5`.'
				checkCondition: [:editor | program childSandblocks second sourceString = '(12+43)*5;'].
			step
				addStep: 'Space wrapped and added new constructs *after* our selection. Using Shift+Space, you can add constructs before the selection. Select the string in the thid row, press <#moveCursorLarger> *twice* to select the whole string and type `[`, then <#confirm>, to wrap the string in an array.'
				checkCondition: [:editor | program childSandblocks third sourceString = '[''array member?''];'].
			step
				addStep: 'Finally, you can also insert larger constructs. Select the addition in the last row using <#moveCursorLarger>, press Shift+Space and type `const pi=`, then <#confirm>.'
				checkCondition: [:editor | program childSandblocks fourth sourceString = 'const pi=3+0.14;']]
]

{ #category : #steps }
SBTSTutorial class >> steps [

	^ {#stepIntro:. #stepWrapping:. #stepInsert:. #stepShortcuts:. #stepTryItYourself:}
]
