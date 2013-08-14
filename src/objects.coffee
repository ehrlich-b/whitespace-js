
class _AstNode
	constructor: (@command, @param) ->
		if (@command.toUpperCase() == "IN" || @command.toUpperCase() == "IN_N")
			@async = true
		else
			@async = false

	execute: (inStream, outStream, symbolTable, callback) ->
		switch @command.toUpperCase()
			when "PUSH"
				toPush = 0
				if (toPush = parseInt(@param))
					Stack.push(toPush)
				else
					if (toPush == 0)
						Stack.push(toPush)
					else
						throw "Error: parameter to a PUSH command must be a number"
			when "ADD"
				if (Stack.length < 2)
					throw "Error: popping empty stack"
				a = Stack.pop()
				b = Stack.pop()
				Stack.push(a + b)
			when "SUB"
				if (Stack.length < 2)
					throw "Error: popping empty stack"
				a = Stack.pop()
				b = Stack.pop()
				Stack.push(b - a)
			when "MULT"
				if (Stack.length < 2)
					throw "Error: popping empty stack"
				a = Stack.pop()
				b = Stack.pop()
				Stack.push(b * a)
			when "DIV"
				if (Stack.length < 2)
					throw "Error: popping empty stack"
				a = Stack.pop()
				b = Stack.pop()
				Stack.push(parseInt(b / a))
			when "MOD"
				if (Stack.length < 2)
					throw "Error: popping empty stack"
				a = Stack.pop()
				b = Stack.pop()
				Stack.push(b % a)
			when "OUT"
				if (Stack.length == 0)
					throw "Error: empty stack on OUT"
				else 
					outStream.put(String.fromCharCode(Stack.pop()))
			when "OUT_N"
				if (Stack.length == 0)
					throw "Error: empty stack on OUT_N"
				else 
					outStream.put(Stack.pop().toString())
			when "COPY"
				if (Stack.length == 0)
					throw "Error: empty stack on COPY"
				else 
					Stack.push(Stack[Stack.length - 1])
			when "COPY_N"
				stackLoc = parseInt(@param)
				if (!stackLoc && stackLoc != 0)
					throw "Error: stack location must be a number"
				if (stackLoc > Stack.length - 1)
					throw "Error: tried to copy non-existant stack item"
				Stack.push(Stack[Stack.length - stackLoc - 1])
			when "SLIDE"
				slideNum = parseInt(@param)
				if (!slideNum && slideNum != 0)
					throw "Error: parameter to slide must be a number"
				if (slideNum > Stack.length - 1)
					throw "Error: attempt to slide too many off the stack"
				Stack.splice(Stack.length - slideNum - 1, slideNum)
			when "JMP"
				if (symbolTable[@param]?)
					PC = symbolTable[@param]
				else
					throw "Error: label could not be resolved on JMP"
			when "JEQ"
				if (Stack.length == 0)
					throw "Error: empty stack on JEQ"
				else 
					control = Stack.pop()
					if (control == 0)
						if (symbolTable[@param]?)
							PC = symbolTable[@param]
						else
							throw "Error: label could not be resolved on JEQ"
			when "JLT"
				if (Stack.length == 0)
					throw "Error: empty stack on JLT"
				else 
					control = Stack.pop()
					if (control < 0)
						if (symbolTable[@param]?)
							PC = symbolTable[@param]
						else
							throw "Error: label could not be resolved on JEQ"
			when "CALL"
				if (symbolTable[@param]?)
					ExecutionStack.push(PC)
					PC = symbolTable[@param]
				else
					throw "Error: label could not be resolved on CALL"
			when "END_SUB"
				if (ExecutionStack.length == 0)
					throw "Error: END_SUB without matching CALL"
				else
					PC = ExecutionStack.pop()
			when "POP"
				if (Stack.length == 0)
					throw "Error: popping empty stack"
				else
					Stack.pop()
			when "SWAP"
				if (Stack.length < 2)
					throw "Error: Cannot swap when stack does not have two items"
				a = Stack.pop()
				b = Stack.pop()
				Stack.push(a)
				Stack.push(b)
			when "STORE"
				if (Stack.length < 2)
					throw "Error: there must be a value and an address on the stack on STORE"
				val = Stack.pop()
				addr = Stack.pop()
				if (addr < 0)
					throw "Error: cannot access negative address"
				Heap[addr] = val
			when "LOAD"
				if (Stack.length == 0)
					throw "Error: there must be an address on the stack on LOAD"
				addr = Stack.pop()
				if (addr < 0)
					throw "Error: cannot access negative address"
				if (!Heap[addr]?)
					throw "Error: address is not defined"
				Stack.push(Heap[addr])
			when "IN_N"
				if (Stack.length == 0)
					throw "Error: there must be an address on the stack"
				addr = Stack.pop()
				if (addr < 0)
					throw "Error: cannot access negative address"
				inStream.get_n((number) ->
					Heap[addr] = number
					callback()
				)
			when "IN"
				if (Stack.length == 0)
					throw "Error: there must be an address on the stack"
				addr = Stack.pop()
				if (addr < 0)
					throw "Error: cannot access negative address"
				inStream.get((c) ->
					Heap[addr] = c.charCodeAt(0)
					callback()
				)

class Stream
	constructor: ->
		@buffer = ""
		
	put: (char) ->
		@buffer += char
		
	get: () ->
		toReturn = @buffer[0]
		@buffer = @buffer.substring(1)
		return toReturn

class Program
	constructor: (@program, @inStream, @outStream, @black) ->
		@ast = []
		@astBuilt = undefined
		@_program = @program
		@symbolTable = {}
		if (!inStream?)
			inStream = ->
		if (!outStream?)
			outStream = ->

	#Run the program
	run: (complete) ->
		ast = @_buildAst()
		@_execute(ast, complete)
		return undefined

	#Print the whitespace code
	print: (blackspace) ->
		ast = @_buildAst()
		toReturn = ""
		
		for command in ast
			commandActual = CommandsHash[command.command]
			if (!blackspace)
				for sym in commandActual.Symbols
					toReturn += sym
			else 
				toReturn += command.command + " "
			if (command.param)
				toOutput = parseInt(command.param)
				if (command.command == "LABEL" || command.command == "CALL" || command.command == "JMP" || command.command == "JEQ" || command.command == "JLT")
					toOutput = @symbolTable[command.param]
				if (!toOutput && toOutput != 0)
					throw "Error: expected number param or label not found"
				if (!blackspace)
					toReturn += toWSNumber(toOutput)
				else 
					toReturn += toOutput
			if (blackspace) then toReturn += "\n"
		return toReturn

	printBs: () ->
		ast = @_buildAst()
		toReturn = ""
		for command in ast
			commandActual = CommandsHash[command.command]
			toReturn += command.command + " "
			if (command.param)
				toOutput = parseInt(command.param)
				if (command.command == "LABEL" || command.command == "CALL" || command.command == "JMP" || command.command == "JEQ" || command.command == "JLT")
					toOutput = @symbolTable[command.param]
				if (!toOutput && toOutput != 0)
					throw "Error: expected number param or label not found"
				toReturn += toOutput
			toReturn += "\n"
		return toReturn
		
	_execute: (ast, complete) ->
		#Reset globals
		PC = 0
		Heap = []
		Stack = []
		ExecutionStack = []
		@_doLoop(ast, complete)

	_continue: (ast, complete) ->
		PC++
		@_doLoop(ast, complete)
	
	_doLoop: (ast, complete) ->
		while (true)
			node = ast[PC]
			if (!node?) #If node at the program counter does not exist
				throw "Advanced beyond the end of the program, programs must end with LFLFLF" 
			if (node.command == "END") #If the command is to end the program, return
				complete?()
				return 
			if (!node.async)
				node.execute(@inStream, @outStream, @symbolTable)
			else 
				node.execute(@inStream, @outStream, @symbolTable, () => 
					@_continue(ast, complete)
				)
				break;
			PC++ 

	_buildAst: () ->
		if (@astBuilt? && (@program == @_program))
			return astBuilt
			
		@_program = @program

		if (!@program? || @program == "")
			return []

		if (@black == null || @black == true)
			return @astBuilt = @_blackspaceAst()
		else
			return @astBuilt = @_whitespaceAst()

	_whitespaceAst: () ->
		_ast = []
		i = 0
		param = false
		current = null
		currentTrie = null
		accum = ""
		while i < @program.length
			sym = @program.charAt(i)
			if (sym != TAB and sym != SPACE and sym != LF)
				i++
				continue
			if (param)
				if (sym != LF)
					accum += sym
				else
					if (current.command == "LABEL" || current.command == "CALL" || current.command == "JMP" || current.command == "JEQ" || current.command == "JLT")
						if (current.command == "LABEL")
							if (@symbolTable[accum]?)
								throw "Error: Duplicate symbol"
							@symbolTable[accum] = _ast.length
						current.param = accum
					else
						num = fromWSNumber(accum)
						current.param = num.toString()
					_ast.push(current)
					accum = ""
					param = false
			else
				if (!currentTrie?)
					currentTrie = CommandsTrie[stringifySymbol(sym)]
				else 
					if (!currentTrie[stringifySymbol(sym)]?)
						throw "Error: unrecongnized command"
					currentTrie = currentTrie[stringifySymbol(sym)]
					if (currentTrie.Command?)
						current = new _AstNode(currentTrie.Command.Command)
						if (!(param = currentTrie.Command.Param))
							_ast.push(current)
						currentTrie = null
			i++
		if (param)
			throw "Error: missing parameter"
		return _ast

	# "Blackspace" is a helper language to make whitespace easier to write, it is translated 1 to 1 to whitespace
	_blackspaceAst: () ->
		_ast = []
		lineSplit = []
		lineNum = 1
		rawSplit = []
		param = false
		current = null
		#Tokenizer
		lineSplit = @program.split("\n")
		for line in lineSplit
			if (line.indexOf("#") != -1)
				line = line.substring(0, line.indexOf("#"))
			rawSplit = line.split(" ")

			for s in rawSplit
				sOrig = s.trim()
				s = s.trim().toUpperCase()
				if (s != "")
					if (param)
						if (current.command == "LABEL")
							if (@symbolTable[s]?)
								throw "Error: Duplicate label"
							@symbolTable[s] = _ast.length
						if (current.command == "PUSH")
							if (s != "0" and !parseInt(s))
								if (s == "'\''")
									s = "39"
								else if (s == "'\\S'")
									s = "32"
								else if (s.length == 3 && s.charCodeAt(0) == 39 && s.charCodeAt(2) == 39)
									s = sOrig.charCodeAt(1).toString()
								else
									throw "Error: Must push a number or a character"
						current.param = s
						_ast.push(current)
						param = false
					else 
						if (CommandsHash[s]?)
							current = new _AstNode(s)
							if (!(param = CommandsHash[s].Param))
								_ast.push(current)
						else
							throw "Error: Unexpected token " + s + " on line " + lineNum

			lineNum++
		if (param)
			throw "Error: missing parameter on line " + lineNum
		return _ast