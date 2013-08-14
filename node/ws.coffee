fs = require("fs")
ws = require("./whitespace.js")

endsWith = (str, suffix) ->
	str.indexOf(suffix, str.length - suffix.length) != -1

getCharFromQueue = (queue) ->
	while (true) 
		if (queue.length == 0)
			return null
		current = queue[0]
		if (current.length == 0) 
			queue.splice(0, 1)
			continue
		toReturn = current.substr(0, 1)
		queue[0] = current.substr(1, current.length - 1)
		return toReturn

args = process.argv
if (args.length < 3 || args.length == 4 || args.length > 5)
	console.log("Usage: ws {file to run or convert} [-c {converted program name}]")
	return
if (!(endsWith(args[2], ".ws") || endsWith(args[2], ".bs")))
	console.log("Program must have either a ws or a bs extension")
	return
if (args.length == 3)
	fs.readFile(args[2], { encoding: "ascii" }, (err,data) ->
		callbackQueue = []
		inputQueue = []
		if err then return console.log(err)
		readline = require("readline")
		rl = readline.createInterface(process.stdin, process.stdout)
		rl.setPrompt("")
		rl.on("line", (line) ->
			inputQueue.push(line.trim() + "\x0A")
			if (callbackQueue.length != 0)
				if (callbackQueue[0].type == "num")
					if (!parseInt(line) && parseInt(line) != 0)
						throw "Error: expected integer, got " + line
					cb = callbackQueue[0]
					callbackQueue.splice(0, 1)
					setTimeout(cb.callback, 0, parseInt(line))
				else
					c = getCharFromQueue(inputQueue)
					if (c != null)
						cb = callbackQueue[0]
						callbackQueue.splice(0, 1)
						setTimeout(cb.callback, 0, c)
			rl.prompt()
		)
		out_s = {
			put: (str) ->
				process.stdout.write(str)
		}
		in_s = {
			get: (callback) ->
				c = getCharFromQueue(inputQueue)
				if (inputQueue.length == 0 && c == null)
					callbackQueue.push({ callback: callback, type: "char" })
					return
				setTimeout(callback, 0, c)
			get_n: (callback) ->
				if (inputQueue.length == 0)
					callbackQueue.push({ callback: callback, type: "num" })
					return
				line = inputQueue[0]
				inputQueue.splice(0, 1)
				if (!parseInt(line) && parseInt(line) != 0)
					throw "Error: expected integer, got " + line
				setTimeout(cb.callback, 0, parseInt(line))
		}
		program = data
		wsp = new ws.WhitespaceProgram(program, in_s, out_s, endsWith(args[2], ".bs"))
		wsp.run(() -> 
			rl.close()
		)
	)

if (args.length == 5)
	fs.readFile(args[2], { encoding: "ascii" }, (err,data) ->
		if (err) then throw err
		targetExtension = if endsWith(args[2], ".ws") then ".bs" else ".ws"
		wsp = new ws.WhitespaceProgram(data, null, null, endsWith(args[2], ".bs"))
		fs.writeFile(args[4] + targetExtension, wsp.print(endsWith(args[2], ".ws")), (err) ->
			if (err) then throw err;
		)
	)

