
Commands = [
	{"Command":"PUSH", "Param": true, "Symbols": [SPACE, SPACE]}, #Push a number onto the stack
	{"Command":"COPY", "Param": false, "Symbols": [SPACE, LF, SPACE]}, #Duplicate the top item on the stack
	{"Command":"COPY_N", "Param": true, "Symbols": [SPACE, TAB, SPACE]}, #Copy the nth item on the stack (given by the agument) onto the top of the stack
	{"Command":"SWAP", "Param": false, "Symbols": [SPACE, LF, TAB]}, #Swap the top two items on the stack
	{"Command":"POP", "Param": false, "Symbols": [SPACE, LF, LF]}, #Discard the top item on the stack
	{"Command":"SLIDE", "Param": true, "Symbols": [SPACE, TAB, LF]}, #Slide n items off the stack, keeping the top item
	{"Command":"ADD", "Param": false, "Symbols": [TAB, SPACE, SPACE, SPACE]}, #Add the top two items on the stack and replace them with the result
	{"Command":"SUB", "Param": false, "Symbols": [TAB, SPACE, SPACE, TAB]}, #Subtract the top two items on the stack and replace them with the result
	{"Command":"MULT", "Param": false, "Symbols": [TAB, SPACE, SPACE, LF]}, #Multiply the top two items on the stack and replace them with the result
	{"Command":"DIV", "Param": false, "Symbols": [TAB, SPACE, TAB, SPACE]}, #Divide (integer division) the top two items on the stack and replace them with the result
	{"Command":"MOD", "Param": false, "Symbols": [TAB, SPACE, TAB, TAB]}, #Mod the top two items on the stack and replace them with the result
	{"Command":"STORE", "Param": false, "Symbols": [TAB, TAB, SPACE]}, #Pop value, then pop address, store the value at the address in the heap
	{"Command":"LOAD", "Param": false, "Symbols": [TAB, TAB, TAB]}, #Pop address, then put the value at the top of the stack
	{"Command":"LABEL", "Param": true, "Symbols": [LF, SPACE, SPACE]}, #Mark a location in the program
	{"Command":"CALL", "Param": true, "Symbols": [LF, SPACE, TAB]}, #Call a subroutine
	{"Command":"JMP", "Param": true, "Symbols": [LF, SPACE, LF]}, #Jump unconditionally to a label
	{"Command":"JEQ", "Param": true, "Symbols": [LF, TAB, SPACE]}, #Jump to a label if the top of the stack is zero -- pops the stack
	{"Command":"JLT", "Param": true, "Symbols": [LF, TAB, TAB]}, #Jump to a label if the top of the stack is negative -- pops the stack
	{"Command":"END_SUB", "Param": false, "Symbols": [LF, TAB, LF]}, #End a subroutine, transfer control back to caller
	{"Command":"END", "Param": false, "Symbols": [LF, LF, LF]}, #End a program
	{"Command":"OUT", "Param": false, "Symbols": [TAB, LF, SPACE, SPACE]}, #Output the character at the top of the stack
	{"Command":"OUT_N", "Param": false, "Symbols": [TAB, LF, SPACE, TAB]}, #Output the number at the top of the stack
	{"Command":"IN", "Param": false, "Symbols": [TAB, LF, TAB, SPACE]}, #Read a character and place it in the location given by the top of the stack
	{"Command":"IN_N", "Param": false, "Symbols": [TAB, LF, TAB, TAB]} #Read a number and place it in the location given by the top of the stack
]

TRIE_OBJ = '{"SPACE": null, "TAB": null, "LF": null, "Command": null}'

CommandsTrie = JSON.parse(TRIE_OBJ)

CommandsHash = {}

for command in Commands
	current = CommandsTrie
	for symbol in command.Symbols
		stringSymbol = stringifySymbol(symbol)
		if (!current[stringSymbol]?)
			current[stringSymbol] = JSON.parse(TRIE_OBJ)
		current = current[stringSymbol]
	current.Command = command

for command in Commands
	CommandsHash[command.Command] = command