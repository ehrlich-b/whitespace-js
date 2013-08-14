stringifySymbol = (symbol) ->
	if (symbol == TAB)
		return "TAB"
	if (symbol == SPACE)
		return "SPACE"
	if (symbol == LF)
		return "LF"

toWSNumber = (number) ->
	num = ""
	bin = []
	if (number == 0)
		return SPACE + SPACE + LF

	if (number >= 0)
		num += SPACE
	else
		num += TAB
		number = -number
	while (number > 0)
		if (number % 2 == 0)
			bin.push(SPACE)
		else
			bin.push(TAB)
		number = parseInt(number / 2)
	cur = null
	while (cur = bin.pop())
		num += cur
	num += LF
	return num

fromWSNumber = (symbols) ->
	if (symbols.length < 2)
		throw "Error: invalid number"
	numToReturn = 0
	i = symbols.length - 1
	mult = 0
	while (i > 0)
		sym = symbols.charAt(i)
		if (sym == TAB)
			numToReturn += Math.pow(2, mult)
		i--
		mult++

	if (symbols.charAt(0) == TAB)
		numToReturn *= -1
	return numToReturn