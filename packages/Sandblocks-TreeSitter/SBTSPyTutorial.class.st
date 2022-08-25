Class {
	#name : #SBTSPyTutorial,
	#superclass : #Object,
	#category : #'Sandblocks-TreeSitter-Tutorial'
}

{ #category : #helper }
SBTSPyTutorial class >> open [

	SBExecutionEnvironment value sandblockEditor
		ifNotNil: [:editor | self openIn: editor]
		ifNil: [self error: 'No editor found in execution context']
]

{ #category : #helper }
SBTSPyTutorial class >> openIn: anEditor [

	self perform: self steps first with: anEditor
]

{ #category : #steps }
SBTSPyTutorial class >> stepExtending: anEditor [

	SBTutorialStep new
		toplevelSteps: self steps in: self;
		title: 'Extending Expressions';
		addIntroText: 'Just now, we have typed an expression from scratch. Next, we will extend existing expressions.';
		setup: anEditor do: [:step | | program |
			program := step createStep: (SBPython parseToplevel: '23*42
''array member?''
''a'' + ''b''
3+0.14').
			step
				addStep: 'To extend an expression place your cursor at the end of the `42` in the first row and type `+1` .'
				checkCondition: [:editor | program sourceString includesSubstring: '23*42+1'].
			step
				addStep: 'To wrap the string in the second row in an array move the cursor just before the first quotation mark, type `[`, then <#confirm>.'
				checkCondition: [:editor | program sourceString includesSubstring: '[''array member?'']'].
			step
				addStep: 'To wrap the entire third row in an array, we first have to select it via <#moveCursorLarger>. Then, press `[` and <#confirm>.'
				checkCondition: [:editor | program sourceString includesSubstring: '[''a''+''b'']'].
			step
				addStep: 'So far, we only added a single character in front of an expression. To add larger constructs, select the addition in the last row using <#moveCursorLarger>, press <Shift+Space> to open the "awaiting input"-popup, type `pi=`, then <#confirm>.'
				checkCondition: [:editor | program sourceString includesSubstring: 'pi=3+0.14'].
			program firstDeepChild startInputAtStart]
]

{ #category : #steps }
SBTSPyTutorial class >> stepInsert: anEditor [

	SBTutorialStep new
		toplevelSteps: self steps in: self;
		title: 'Inserting Elements';
		setup: anEditor do: [:step | | program |
			program := step createStep: (SBPython parseToplevel: '
def myFunc():
	await asyncio.sleep(1)

"str"').
			step addExplanationStep: 'Sandblocks will display a hint when your cursor is at positions where an element can be inserted.'.
			step
				addStep: 'To add an "async" in front of the `def` keep pressing <#moveCursorRight> or <#moveCursorLeft> until the popup indicates "async" and press the first letter of the input, in this case `a`, to confirm.'
				checkCondition: [:editor | program sourceString includesSubstring: 'async def'].
			step
				addStep: 'Next, add an argument called `arg` to the function by again moving into the right spot and typing `arg`.'
				checkCondition: [:editor | program sourceString includesSubstring: 'def myFunc(arg)'].
			step addExplanationStep: 'You can create a new statement by pressing <#insertStatementBelow> or <#insertStatementAbove> *anywhere*, the editor will always find the next closest position for a statement.'.
			step
				addStep: 'Press <#insertStatementBelow> to add a new empty statement inside the function.'
				checkCondition: [:editor | (program queryNode: '(block)') childSandblocks size = 2].
			program firstDeepChild startInputAtStart]
]

{ #category : #steps }
SBTSPyTutorial class >> stepNavigation: anEditor [

	SBTutorialStep new
		toplevelSteps: self steps in: self;
		title: 'Navigation';
		addIntroText: 'Navigation in Sandblocks is designed to be the same as in a text editor. Use the arrow keys to move character-wise, and control+arrow keys to move word-wise.

You can also use the Home/Pos1 and End keys to jump to the start or end of a statement.

Finally, using tab and shift+tab, you can jump between places that are in some way "empty".

Click anywhere in the code below to place the cursor, then try all three means of navigating the code below, then click the arrow on the right to go to the next step.';
		setup: anEditor do: [:step | | program |
			program := step createStep: (SBPython parseToplevel: 'import math

class A:
	def __init__(self):
		self.numbers = [3, 67, 1, 4, 8]
		for num in self.numbers:
			print(num)
	def b(self):
		pass

a = A()
d = {"key": "value", "weather": "good"}
emptyList = []').
			program firstDeepChild startInputAtStart]
]

{ #category : #steps }
SBTSPyTutorial class >> stepShortcuts: anEditor [

	SBTutorialStep new
		toplevelSteps: self steps in: self;
		title: 'Useful Shortcuts';
		setup: anEditor do: [:step | | program |
			program := step createStep: (SBPython parseToplevel: 'goodNum = nameIdentifier
[37]
justNumber=[2.123123]').
			step
				addStep: 'To quickly clear the contents of just the selected text field move your cursor into the identifier `nameIdentifier`, press <#moveCursorLarger> to select the block you want to change and start typing a `42`.'
				checkCondition: [:editor | program childSandblocks first sourceString = 'goodNum=42'].
			step
				addStep: 'Copy and paste works as you would expect it to: duplicate the `37` by moving the cursor into the number `37`, pressing <#copyToBuffer>, then moving the cursor right until it becomes a dashed line inside the array and press <#pasteReplace>.'
				checkCondition: [:editor | program sourceString includesSubstring: '[37,37]'].
			step
				addStep: 'Similarly, cutting works via <#deleteBlockWithCopy>. It is also a quick way to delete a block. Try emptying the array again by pressing <#deleteBlockWithCopy> on each `37`.'
				checkCondition: [:editor | program sourceString includesSubstring: '[]'].
			step addExplanationStep: 'When you want to unwrap a block, the easiest way is to copy it, then select its parent and paste over it.'.
			step
				addStep: 'Delete the array but keep the number in the last row by copying the number, selecting the array via <#moveCursorLarger>, then pasting.'
				checkCondition: [:editor | program childSandblocks last sourceString = 'justNumber=2.123123'].
			program firstDeepChild startInputAtStart]
]

{ #category : #steps }
SBTSPyTutorial class >> stepTryItYourself: anEditor [

	SBTutorialStep new
		toplevelSteps: self steps in: self;
		title: 'Try It Yourself';
		addIntroText: 'Finally, feel free to take some moments to explore the input system by following the prompts in the code comments below.

Tipp: you can always press <#undo> to undo a change.

Shortcuts you learned:
<#moveCursorLarger>: enlarge your selection
<Shift+Space>: insert something before your current selection
<#inputNextUnknown>: jump to next (or previous via Shift) position that takes input';
		setup: anEditor do: [:step | | program |
			program := step createStep: (SBPython parseToplevel: 'class Nums:
	def __init__(self):
		# TODO assign the below array to self.numbers
		[3, 67, 1, 4, 8]
		# HINT: use shift+up to select the array, press shift+space, then type `self.numbers=`

# TODO add another entry in the below dictionary, "rain": "none"
d = {"key": "value", "weather": "good"}
# HINT: move the cursor in the dictionary until it becomes a dashed line, then just type the key and value

headers = {"Content-Type": "application/json", "Authorization": "Bearer a239a2def"}
# TODO use shift-up to select the dictionary below, then just type the variable `headers` to replace your selection
request("https://google.com", {"todo-header": "todo"})

n = Nums()
# TODO try not to use the popup but just simply keep typing as you would in a text editor: replace the call below and create a for-loop that iterates over n.numbers and prints each number
replaceMe()


# TODO create a list comprehension by typing [i ** 2 for i in n.numbers]

# TODO then select the entire list and assign it to the variable `squared`
# HINT: again, you can simply the expression, then use shift+up to select it and hit shift+space to wrap it in the assignment
').
			program firstDeepChild startInputAtStart]
]

{ #category : #steps }
SBTSPyTutorial class >> stepTyping: anEditor [

	SBTutorialStep new
		toplevelSteps: self steps in: self;
		title: 'Typing';
		addIntroText: 'Similarly, typing and deleting code works the same as in a text editor.';
		setup: anEditor do: [:step | | program firstDone |
			program := step createStep: (SBPython parseToplevel: '').
			firstDone := false.
			step
				addStep: 'Try simply typing in the input at the bottom `print("Hello world")` while ignoring all popups. Sandblocks will automatically dismiss popups as you give it more input.'
				checkCondition: [:editor |
					(program sourceString asLowercase includesSubstring: 'print("hello world")')
						ifTrue: [
							firstDone := true.
							true]
						ifFalse: [false]].
			step
				addStep: 'Next, try backspacing until you have an empty program again and note how Sandblocks removes blocks for you as their content is emptied.'
				checkCondition: [:editor | firstDone and: [program childSandblocks isEmpty]].
			step
				addStep: 'Type just an `f` and observe what options Sandblocks offers for autocompletion. Select the `for` loop at the bottom, use <Tab> to jump to the next input field, type `num`, use <Tab> again and type `numbers`, and finally use <Tab> and type `print(num)`.'
				checkCondition: [:editor | firstDone and: [program sourceString = 'for num in numbers:
	print(num)']].
			step
				addStep: 'Note that you also can continue typing instead of using the popup. Try pressing <#insertStatementBelow> to create a new line, type `if `, and notice that as soon as you press space, the popup disappears as your input is now clearly the `if` keyword.'
				checkCondition: [:editor | program sourceString includesSubstring: 'if'].
			program startInsertAtEnd]
]

{ #category : #steps }
SBTSPyTutorial class >> steps [

	^ {#stepNavigation:. #stepTyping:. #stepExtending:. #stepInsert:. #stepShortcuts:. #stepTryItYourself:}
]
