
-- Applies a text color escape to a translated string such that it won't cause any errors to
--> spam the chat or log.
function Etc.colorizeTranslated (color, text)
	return core.colorize(color, text: gsub('\n', '\\n')): gsub('\\n', '\n'): sub(1, -1)
end

-- Used by Etc.wrapText as indicators of where and how to break a line.
--> on: breaking character will be REMOVED and replaced with newline.
--> after: character will REMAIN, and a newline will be inserted after; subsequent spaces will be removed.
--> before: character will REMAIN and the newline will be inserted before, replacing any preceding spaces.
Etc.breakingCharacters = {
 [' '] = 'on',
 ['-'] = 'after',
 ['.'] = 'after',
 ['!'] = 'after',
 ['?'] = 'after',
 [','] = 'after',
 ['('] = 'before',
 ['['] = 'before'
}

-- Inserts newlines into text to control how far it can extend past <limit> characters per line.
-- If <hard> is true, it will break words, otherwise it will only break after it reaches a character
--> in Etc.breakingCharacters; in this case it will follow the rule specified therein.
-- Trailing spaces and tabs will also be removed always.
-- You can safely add newlines anywhere in the text and wrapping will still behave correctly.
function Etc.wrapText (text, limit, hard)
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
					if Etc.breakingCharacters[char] == 'on' then
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
					if Etc.breakingCharacters[char] == 'on' then
						newtext = newtext .. '\n'
						passed = 0
					elseif Etc.breakingCharacters[char] == 'before' then
						newtext = newtext .. '\n' .. char
						passed = 0
					elseif Etc.breakingCharacters[char] == 'after' then
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
				if Etc.breakingCharacters[char] == 'after' then
					state = 'just_after'
				else
					state = ''
				end
				
				newtext = newtext .. char
			end
		end
		
		return (newtext: gsub('%s+$', ''))
	end
end
