
etc.textcolors = {
	description = '#7f819a',
	statblock   = '#f4315b'
}

ETC_DESC_WRAP_LIMIT = 40

etc.breaking_characters = {
 [' '] = 'on',
 ['-'] = 'after',
 ['.'] = 'after',
 ['!'] = 'after',
 ['?'] = 'after',
 [','] = 'after',
 ['('] = 'before'
}

-- Inserts newlines into a text to control how far it can extend past <limit> characters per line.
-- If <hard> is true, it will break words, otherwise it will only break after it reaches a character
-- in etc.breaking_characters; in this case it will follow the rule specified therein.
-- Trailing spaces and tabs will also be removed always.
-- You can safely add newlines anywhere in the text and wrapping will still behave correctly.
function etc.wrap_text (text, limit, hard)
	if hard then
		local passed = 0
		local newtext = ''
		
		for i = 1, #text do
			if text: sub(i, i) == '\n' then
				passed = 0
			end
			
			if passed == limit then
				newtext = newtext .. '\n'
				passed = 0
			else
				newtext = newtext .. text: sub(i, i)
				passed = passed + 1
			end
			
			return newtext: gsub('%s+$', '')
		end
	else
		local passed, total = 0, 0
		local state = ''
		local newtext = ''
		
		while state ~= 'finished' do
			if total > #text then
				state = 'finished'
				break
			end
			
			passed = passed + 1
			total = total + 1
			
			local char = text: sub(total, total)
			
			if passed >= limit then
				if state == 'just_after' then
					if etc.breaking_characters[char] == 'on' then
						newtext = newtext .. '\n'
					else
						if char == '\n' then
							if total > 0 and text: sub(total-1, total-1) ~= char then
								newtext = newtext .. char
							end
							
							passed = 0
						else
							newtext = newtext .. '\n' .. char
						end
					end
					passed = 0
				else
					if etc.breaking_characters[char] == 'on' then
						newtext = newtext .. '\n'
						passed = 0
					elseif etc.breaking_characters[char] == 'before' then
						newtext = newtext .. '\n' .. char
						passed = 0
					elseif etc.breaking_characters[char] == 'after' then
						state = 'just_after'
						newtext = newtext .. char
					else
						if char == '\n' then
							if total > 0 and text: sub(total-1, total-1) ~= char then
								newtext = newtext .. char
							end
							
							passed = 0
						else
							newtext = newtext .. char
						end
					end
				end
			else
				if etc.breaking_characters[char] == 'after' then
					state = 'just_after'
				else
					state = ''
				end
				
				newtext = newtext .. char
			end
		end
		
		return newtext: gsub('%s+$', '')
	end
end

local not_caps = {
	a = true,
	an = true,
	['and'] = true,
	as = true,
	at = true,
	but = true,
	by = true,
	['for'] = true,
	from = true,
	['if'] = true,
	['in'] = true,
	nor = true,
	of = true,
	on = true,
	['or'] = true,
	the = true,
	up = true
}

-- Formats a string of plain text as if it were a title (first letter of each word is capitalized)
-- Optionally ignores the convention to leave some short words lowercase (see not_caps above)
-- The very first letter will always be capitalized
function etc.format_as_title (text, all)
	local new_text = ''
	local just_space = true
	
	for i = 1, #text do
		local char = text: sub(i, i)
		local lookahead = text: sub(i, i+4)
		
		if char: match '[a-zA-Z]' and just_space then
			just_space = false
			
			if all then
				new_text = new_text .. char: upper()
			else
				local nocap_match = false
				
				for nocap, _ in pairs(not_caps) do
					if lookahead: sub(1, #nocap) == nocap and lookahead: sub(1, #nocap+1) : match '[%s_.-)]' then
						nocap_match = true
						break
					end
				end
				
				if nocap_match and i ~= 1 then
					new_text = new_text .. char: lower()
				else
					new_text = new_text .. char: upper()
				end
			end
		elseif char: match '[%s_.-)]' then
			just_space = true
			new_text = new_text .. char
		else
			just_space = false
			new_text = new_text .. char: lower()
		end
	end
	
	return new_text
end
